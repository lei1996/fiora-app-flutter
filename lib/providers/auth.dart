import 'dart:convert';
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../utils/fetch.dart' as Fetch;
import '../models/socket_exception.dart';
import '../models/galleryItem.dart';
import '../models/linkman.dart';
import '../models/message.dart';
import '../utils/util.dart';

import 'linkmans.dart';
import 'messages.dart';

final url = ['http://127.0.0.1:9200', 'https://fiora.suisuijiang.com'];

IO.Socket socket = IO.io(url[1], <String, dynamic>{
  'transports': ['websocket'],
  // 'autoConnect': false,
});

class Auth with ChangeNotifier {
  String _userId; // 用户ID
  DateTime _expiryDate; // 过期时间
  Timer _authTimer; // 定时器
  String _token; // token
  String _avatar; // 头像
  String _username; // 用户名
  String _tag; // 标签
  bool _isAdmin; // 判断是否为管理员

  Messages _message = Messages();
  Linkmans _linkmans = Linkmans();

  Map<String, List<GalleryItem>> _galleryItems = {};
  String focusId;

  bool get isAuth => token != null;

  String get avatar => _avatar;

  List<LinkmanItem> get linkmans => _linkmans.linkmans;

  String get token {
    if (_expiryDate != null &&
        _expiryDate.isAfter(DateTime.now()) &&
        _token != null) {
      return _token;
    }
    return null;
  }

  // 公共 fetch
  Future<dynamic> fetchCommon(String urlSegment, dynamic data) async {
    try {
      final res = await Fetch.fetch(urlSegment, data);
      if (res[0] != null) {
        throw SocketException(res[0]);
      }
      return res[1];
    } catch (e) {
      throw e;
    }
  }

  // 公共
  Future<void> _authenticate(
    String urlSegment,
    String userName,
    String password,
  ) async {
    try {
      final resData = await fetchCommon(
          urlSegment, {'username': userName, 'password': password});

      setValue(
        resData: resData,
        expiryDate: DateTime.now().add(Duration(days: 7)),
      );

      _autoLogout();
      final linkmanIds = [
        ...(resData['groups'] as List<dynamic>).map((group) => group['_id']),
        ...(resData['friends'] as List<dynamic>).map(
            (friend) => Util.getFriendId(friend['from'], friend['to']['_id'])),
      ];
      await getLinkmansLastMessages(
          linkmanIds, resData['friends'], resData['groups']);
      notifyListeners();
      Util.setPerfsData({
        'token': _token,
        'userId': _userId,
        'isAdmin': _isAdmin,
        'tag': _tag,
        'username': _username,
        'avatar': "https:" + _avatar,
        'expiryDate': _expiryDate.toIso8601String(),
      });
    } catch (e) {
      throw e;
    }
  }

  // 自动登录
  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    // 如果本地持久化存储找不到 userData，则返回 false
    if (!prefs.containsKey('userData')) return false;

    final extractedUserData =
        json.decode(prefs.getString('userData')) as Map<String, Object>;
    final expiryDate = DateTime.parse(extractedUserData['expiryDate']);

    // 如果token过期时间戳超时, 则返回false
    if (expiryDate.isBefore(DateTime.now())) return false;

    // 自动登录
    final resData = await fetchCommon('loginByToken',
        {'token': extractedUserData['token'], 'os': '宇宙最强ios版本'});

    final linkmanIds = [
      ...(resData['groups'] as List<dynamic>).map((group) => group['_id']),
      ...(resData['friends'] as List<dynamic>).map(
          (friend) => Util.getFriendId(friend['from'], friend['to']['_id'])),
    ];
    await getLinkmansLastMessages(
        linkmanIds, resData['friends'], resData['groups']);
    print(resData);
    // print(extractedUserData);
    setValue(
      resData: extractedUserData,
      expiryDate: expiryDate,
    );
    notifyListeners();
    _autoLogout();
    return true;
  }

  // 注册
  Future<void> signup(String userName, String password) async {
    final resData = await fetchCommon(
        'register', {'username': userName, 'password': password});
  }

  // 登录
  Future<void> login(String userName, String password) async {
    return _authenticate('login', userName, password);
  }

  Future<void> _listenMessage() async {
    socket.on('message', (dynamic message) {
      var isMe = message['from']['_id'] == _userId;
      if (isMe && message['from']['tag'] != _tag) {
        _tag = message['from']['tag'];
        notifyListeners();
      }
      final index = _linkmans.findLinkmanIndex(message['to']);
      if (index >= 0) {
        // 这里查找Map 里面有没有具体的key
        String sId = _message.messages.containsKey(message['to'])
            ? message['to']
            : Util.getFriendId(_userId, message['from']['_id']);
        final Message unitMessage = Message(
          type: message['type'],
          content: message['content'],
          sId: message['_id'],
          from: FromUser(
            tag: message['from']['tag'],
            sId: message['from']['_id'],
            username: message['from']['username'],
            avatar: message['from']['avatar'],
          ),
          createTime: message['createTime'],
        );
        _message.updateItem(sId, unitMessage);
        _linkmans.addItem(
            _linkmans.linkmans[index], _message.getLastMessage(sId));
        _linkmans.linkmanSort();
        notifyListeners();
      }
    });
  }

  static parseLinkman(data) {
    var friend = data['friends'].firstWhere(
        (f) => Util.getFriendId(f['from'], f['to']['_id']) == data['linkmanId'],
        orElse: () => print('No matching element.'));

    var group = data['groups'].firstWhere((g) => g['_id'] == data['linkmanId'],
        orElse: () => print('No matching element.'));

    // 返回一个数组，用于判断是 friend 还是 group
    return friend != null ? [true, friend] : [false, group];
  }

  // 获取联系人最后消息
  Future<void> getLinkmansLastMessages(
    List<dynamic> linkmanIds,
    List<dynamic> friends,
    List<dynamic> groups,
  ) async {
    final resData =
        await fetchCommon('getLinkmansLastMessages', {'linkmans': linkmanIds});

    // 消息 要使用Map<String, List<Message>> 的数据结构
    resData.forEach((linkmanId, massageData) async {
      // 这里是切换了线程进行计算，所以当await之前，foreach 会跳入下一个循环
      List<Message> messages = Message.parseMessage(massageData);

      // 联系人
      var linkman = parseLinkman(
          {'linkmanId': linkmanId, 'friends': friends, 'groups': groups});

      final Message lastMessage = messages.last;
      final linkmanItem = LinkmanItem(
        sId: linkmanId,
        type: linkman[0] ? 'friend' : 'group',
        unread: 0,
        name: linkman[0] ? linkman[1]['to']['username'] : linkman[1]['name'],
        avatar: linkman[0] ? linkman[1]['to']['avatar'] : linkman[1]['avatar'],
        creator: linkman[0] ? '' : linkman[1]['creator'],
        createTime: DateTime.parse(lastMessage.createTime),
        message: lastMessage,
      );
      _linkmans.addItem(linkmanItem);
      _message.addItem(linkmanId, messages);
      _linkmans.linkmanSort();
      notifyListeners();
    });
    _listenMessage();
  }

  // 获取联系人历史消息
  Future<void> getLinkmanHistoryMessages(
      {String linkmanId, int existCount}) async {
    final resData = await fetchCommon('getLinkmanHistoryMessages', {
      'linkmanId': linkmanId,
      'existCount': existCount,
    });

    // 消息 要使用Map<String, List<Message>> 的数据结构
    List<Message> messageItem = await compute(Message.parseMessage, resData);
    _message.addItem(linkmanId, messageItem);
    notifyListeners();
  }

  // 发送消息
  Future<void> sendMessage({
    String to,
    String type,
    String content,
  }) async {
    final resData = await fetchCommon('sendMessage', {
      'to': to,
      'type': type,
      'content': content,
    });

    if (_message.messages.containsKey(to)) {
      final message = Message(
        type: resData['type'],
        content: resData['content'],
        sId: resData['_id'],
        from: FromUser(
          tag: resData['from']['tag'],
          sId: resData['from']['_id'],
          username: resData['from']['username'],
          avatar: resData['from']['avatar'],
        ),
        createTime: resData['createTime'],
      );
      _message.updateItem(to, message);
      final index = _linkmans.findLinkmanIndex(to);
      _linkmans.addItem(_linkmans.linkmans[index], _message.getLastMessage(to));
      _linkmans.linkmanSort();
      notifyListeners();
    }
  }

  List<GalleryItem> getGalleryItem() {
    return _galleryItems[focusId];
  }

  int getGalleryItemIndex(String id) {
    return getGalleryItem().indexWhere((gallery) => gallery.id == id);
  }

  // 获取某个会话消息的 image 数组
  Future<void> setGalleryItem(String id) async {
    // 这里将会话id 赋值.
    focusId = id;
    final List<Message> messages = getMessageItem(id);
    final List<GalleryItem> _galleryItemsTmp = [];
    messages.map((message) {
      if (message.type == 'image')
        _galleryItemsTmp.add(
            GalleryItem(id: message.sId, resource: "https:" + message.content));
    }).toList();
    _galleryItems.containsKey(id)
        ? _galleryItems.update(id, (_) => _galleryItemsTmp)
        : _galleryItems.putIfAbsent(id, () => _galleryItemsTmp);
  }

  List<Message> getMessageItem(id) => _message.getMessageItem(id);

  void setValue({
    dynamic resData,
    DateTime expiryDate,
  }) {
    _token = resData['token'];
    _userId = resData['_id'] ?? resData['userId'];
    _isAdmin = resData['isAdmin'];
    _tag = resData['tag'];
    _username = resData['username'];
    _avatar = resData['avatar'];
    _expiryDate = expiryDate;
  }

  // 登出
  Future<void> logout() async {
    _token = null;
    _userId = null;
    _isAdmin = null;
    _expiryDate = null;
    if (_authTimer != null) {
      _authTimer.cancel();
      _authTimer = null;
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('userData');
    _disconnect();
    // prefs.clear();
  }

  Future<void> _disconnect() async {
    socket.io..disconnect()..connect();
    _message.clear();
    _linkmans.clear();
    notifyListeners();
    socket.on('disconnect', (_) => print("_disconnect"));
  }

  // 自动登出
  void _autoLogout() {
    if (_authTimer != null) {
      _authTimer.cancel();
    }
    final timeToExpiry = _expiryDate.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: timeToExpiry), logout);
  }
}
