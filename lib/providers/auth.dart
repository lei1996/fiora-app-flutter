import 'dart:convert';
import 'dart:async';

import 'package:fiora_app_flutter/models/groups.dart';
import 'package:fiora_app_flutter/models/friends.dart';
import 'package:fiora_app_flutter/models/linkman.dart';
import 'package:fiora_app_flutter/models/message.dart';
import 'package:fiora_app_flutter/utils/util.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/fetch.dart' as Fetch;
import '../models/socket_exception.dart';

import 'package:socket_io_client/socket_io_client.dart' as IO;

final url = ['http://127.0.0.1:9200', 'https://fiora.suisuijiang.com'];

IO.Socket socket = IO.io(url[1], <String, dynamic>{
  'transports': ['websocket'],
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

  Map<String, List<Message>> _message = {};

  List<LinkmanItem> _linkmans = [];

  final List<FriendItem> _friends = [];
  final List<GroupItem> _groups = [];

  bool get isAuth {
    return token != null;
  }

  int get messageCount => _message.length;

  dynamic get avatar => _avatar;

  List<LinkmanItem> get linkmans => [..._linkmans];

  String get token {
    if (_expiryDate != null &&
        _expiryDate.isAfter(DateTime.now()) &&
        _token != null) {
      return _token;
    }
    return null;
  }

  String get userId {
    return _userId;
  }

  Future<void> _authenticate(
    String urlSegment,
    String userName,
    String password,
  ) async {
    try {
      final res = await Fetch.fetch(
        urlSegment,
        {'username': userName, 'password': password},
      );
      // print(res);
      if (res[0] != null) {
        throw SocketException(res[0]);
      }
      final resData = res[1];
      setValue(
        token: resData['token'],
        userId: resData['_id'],
        isAdmin: resData['isAdmin'],
        tag: resData['tag'],
        username: resData['username'],
        avatar: resData['avatar'],
        expiryDate: DateTime.now().add(Duration(
          days: 7,
        )),
      );
      _autoLogout();
      final linkmanIds = [
        ...(resData['groups'] as List<dynamic>).map((group) => group['_id']),
        ...(resData['friends'] as List<dynamic>).map(
            (friend) => Util.getFriendId(friend['from'], friend['to']['_id'])),
      ];
      await getLinkmansLastMessages(linkmanIds);
      notifyListeners();
      final perfs = await SharedPreferences.getInstance();
      final userData = json.encode({
        'token': _token,
        'userId': _userId,
        'isAdmin': _isAdmin,
        'tag': _tag,
        'username': _username,
        'avatar': "https:" + _avatar,
        'expiryDate': _expiryDate.toIso8601String(),
      });
      perfs.setString('userData', userData);
      setFriends(resData);
      setGroups(resData);
      _linkmansSort();
    } catch (e) {
      throw e;
    }
  }

  // String getFriendId(String userId1, String userId2) {
  //   if (userId1.compareTo(userId2) == -1) {
  //     return userId1 + userId2;
  //   }
  //   return userId2 + userId1;
  // }

  // 注册
  Future<void> signup(String userName, String password) async {
    return _authenticate('register', userName, password);
  }

  // 登录
  Future<void> login(String userName, String password) async {
    return _authenticate('login', userName, password);
  }

  // 自动登录
  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) {
      return false;
    }
    final extractedUserData =
        json.decode(prefs.getString('userData')) as Map<String, Object>;
    final expiryDate = DateTime.parse(extractedUserData['expiryDate']);

    if (expiryDate.isBefore(DateTime.now())) {
      return false;
    }
    // 自动登录 - 保留
    final res = await Fetch.fetch(
      'loginByToken',
      {'token': extractedUserData['token'], 'os': '宇宙最强ios版本'},
    );
    if (res[0] != null) {
      throw SocketException(res[0]);
    }
    _listenMessage();
    final resData = res[1];
    final linkmanIds = [
      ...(resData['groups'] as List<dynamic>).map((group) => group['_id']),
      ...(resData['friends'] as List<dynamic>).map(
          (friend) => Util.getFriendId(friend['from'], friend['to']['_id'])),
    ];
    await getLinkmansLastMessages(linkmanIds);
    setFriends(resData);
    setGroups(resData);
    _linkmansSort();
    setValue(
      token: extractedUserData['token'],
      userId: extractedUserData['userId'],
      isAdmin: extractedUserData['isAdmin'],
      tag: extractedUserData['tag'],
      username: extractedUserData['username'],
      avatar: extractedUserData['avatar'],
      expiryDate: expiryDate,
    );
    notifyListeners();
    _autoLogout();
    return true;
  }

  Future<void> _listenMessage() async {
    socket.on('message', (dynamic message) {
      print(message);
      var isMe = message['from']['_id'] == _userId;
      if (isMe && message['from']['tag'] != _tag) {
        _tag = message['from']['tag'];
        notifyListeners();
      }
      var index = _linkmans
          .indexWhere((linkman) => linkman.sId.startsWith(message['to']));
      if (index >= 0) {
        // 这里查找Map 里面有没有具体的key
        String sId;
        if (_message.containsKey(message['to'])) {
          sId = message['to'];
          _message.update(
              sId,
              (messages) => [
                    ...messages,
                    Message(
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
                    ),
                  ]);
        } else {
          sId = Util.getFriendId(_userId, message['from']['_id']);
          _message.update(
              sId,
              (messages) => [
                    ...messages,
                    Message(
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
                    ),
                  ]);
        }
        Message lastMessage = _message[sId][_message[sId].length - 1];
        // print(lastMessage);
        _linkmans[index] = LinkmanItem(
          sId: _linkmans[index].sId,
          type: _linkmans[index].type,
          unread: 0,
          name: _linkmans[index].name,
          avatar: _linkmans[index].avatar,
          creator: _linkmans[index].creator,
          createTime: DateTime.parse(lastMessage.createTime),
          message: lastMessage,
        );
        _linkmansSort();
      }
      notifyListeners();
    });
  }

  Future<void> _disconnect() async {
    socket.on('_disconnect', (_) => print("_disconnect"));
  }

  // 获取联系人最后消息
  Future<void> getLinkmansLastMessages(List<dynamic> linkmanIds) async {
    // print(linkmanIds);
    try {
      final res = await Fetch.fetch(
        'getLinkmansLastMessages',
        {
          'linkmans': linkmanIds,
        },
      );
      // print(res);
      if (res[0] != null) {
        throw SocketException(res[0]);
      }
      final resData = res[1];
      // print(resData);
      // 消息 要使用Map<String, List<Message>> 的数据结构
      (resData as Map<String, dynamic>).forEach((linkmanId, massageData) {
        List<Message> messageItem = [];
        _message.putIfAbsent(linkmanId, () {
          (massageData as List<dynamic>).forEach((message) {
            messageItem.add(
              Message(
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
              ),
            );
          });
          return messageItem;
        });
      });
      // print(_message);
    } catch (e) {
      throw e;
    }
  }

  // 获取联系人历史消息
  Future<void> getLinkmanHistoryMessages(
      {String linkmanId, int existCount}) async {
    // print(linkmanIds);
    try {
      final res = await Fetch.fetch(
        'getLinkmanHistoryMessages',
        {
          'linkmanId': linkmanId,
          'existCount': existCount,
        },
      );
      // print(res);
      if (res[0] != null) {
        throw SocketException(res[0]);
      }
      final resData = res[1];
      // print(resData);
      // 消息 要使用Map<String, List<Message>> 的数据结构
      List<Message> messageItem = [];
      (resData as List<dynamic>).forEach((message) {
        messageItem.add(
          Message(
            type: message['type'],
            content: message['content'],
            sId: message['sId'],
            from: FromUser(
              tag: message['from']['tag'],
              sId: message['from']['_id'],
              username: message['from']['username'],
              avatar: message['from']['avatar'],
            ),
            createTime: message['createTime'],
          ),
        );
      });
      _message.update(linkmanId, (messages) {
        return [...messageItem, ...messages];
      });
      notifyListeners();
      // print(_message);
    } catch (e) {
      throw e;
    }
  }

  // 发送消息
  Future<void> sendMessage({
    String to,
    String type,
    String content,
  }) async {
    try {
      final res = await Fetch.fetch(
        'sendMessage',
        {
          'to': to,
          'type': type,
          'content': content,
        },
      );
      if (res[0] != null) {
        throw SocketException(res[0]);
      }
      final resData = res[1];
      if (_message.containsKey(to)) {
        final message = Message(
          type: resData['type'],
          content: resData['content'],
          sId: resData['sId'],
          from: FromUser(
            tag: resData['from']['tag'],
            sId: resData['from']['_id'],
            username: resData['from']['username'],
            avatar: resData['from']['avatar'],
          ),
          createTime: resData['createTime'],
        );
        _message.update(to, (messages) {
          return [...messages, message];
        });
        print(_message[to].length);
      }
      notifyListeners();
      // print(_message);
    } catch (e) {
      throw e;
    }
  }

  List<Message> getMessageItem(String sId) =>
      _message.containsKey(sId) ? _message[sId] : [];

  void setValue({
    token,
    userId,
    isAdmin,
    tag,
    username,
    avatar,
    expiryDate,
  }) {
    _token = token;
    _userId = userId;
    _isAdmin = isAdmin;
    _tag = tag;
    _username = username;
    _avatar = avatar;
    _expiryDate = expiryDate;
  }

  // 组装好友
  Future<void> setFriends(resData) async {
    (resData['friends'] as List<dynamic>).forEach((friend) {
      String usId = Util.getFriendId(friend['from'], friend['to']['_id']);
      Message lastMessage = _message[usId][_message[usId].length - 1];
      _linkmans.add(
        LinkmanItem(
          sId: usId,
          type: '',
          unread: 0,
          name: friend['to']['username'],
          avatar: friend['to']['avatar'],
          creator: '',
          createTime: DateTime.parse(friend['createTime']),
          message: lastMessage,
        ),
      );
    });
  }

  // 组装群组
  Future<void> setGroups(resData) async {
    (resData['groups'] as List<dynamic>).forEach((group) {
      String usId = group['_id'];
      Message lastMessage = _message[usId][_message[usId].length - 1];
      _linkmans.add(
        LinkmanItem(
          sId: usId,
          type: '',
          unread: 0,
          name: group['name'],
          avatar: group['avatar'],
          creator: group['creator'],
          createTime: DateTime.parse(lastMessage.createTime),
          message: lastMessage,
        ),
      );
    });
  }

  Future<void> _linkmansSort() async {
    _linkmans.sort(
        (LinkmanItem a, LinkmanItem b) => b.createTime.compareTo(a.createTime));
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

  // 自动登出
  void _autoLogout() {
    if (_authTimer != null) {
      _authTimer.cancel();
    }
    final timeToExpiry = _expiryDate.difference(DateTime.now()).inSeconds;
    // print(timeToExpiry);
    _authTimer = Timer(Duration(seconds: timeToExpiry), logout);
  }
}
