import 'dart:convert';
import 'dart:async';

import 'package:fiora_app_flutter/models/groups.dart';
import 'package:fiora_app_flutter/models/friends.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/fetch.dart' as Fetch;
import '../models/socket_exception.dart';

class Auth with ChangeNotifier {
  String _userId; // 用户ID
  DateTime _expiryDate; // 过期时间
  Timer _authTimer; // 定时器
  String _token; // token
  String _avatar; // 头像
  String _username; // 用户名
  String _tag; // 标签
  bool _isAdmin; // 判断是否为管理员

  final List<FriendItem> _friends = [];
  final List<GroupItem> _groups = [];

  bool get isAuth {
    return token != null;
  }

  dynamic get avatar {
    return _avatar;
  }

  dynamic get friends {
    return [..._friends];
  }

  dynamic get groups {
    return [..._groups];
  }

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
      print((resData['friends'] as List<dynamic>).map((friend) => friend['to']['_id']).toList());
      getLinkmansLastMessages(resData['_id']);
      setFriends(resData);
      setGroups(resData);
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
    } catch (e) {
      throw e;
    }
  }

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
      {'token': extractedUserData['token']},
    );
    if (res[0] != null) {
      throw SocketException(res[0]);
    }
    final resData = res[1];
    setValue(
      token: extractedUserData['token'],
      userId: extractedUserData['userId'],
      isAdmin: extractedUserData['isAdmin'],
      tag: extractedUserData['tag'],
      username: extractedUserData['username'],
      avatar: extractedUserData['avatar'],
      expiryDate: expiryDate,
    );
    getLinkmansLastMessages([resData['_id']]);
    setFriends(resData);
    setGroups(resData);
    notifyListeners();
    _autoLogout();
    return true;
  }

  // 获取联系人最后消息
  Future<void> getLinkmansLastMessages(List<String> linkmanIds) async {
    try {
      // print(linkmans);
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
    } catch (e) {
      throw e;
    }
  }

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
      _friends.add(
        FriendItem(
          sId: friend['_id'],
          from: friend['from'],
          to: To(
            sId: friend['to']['_id'],
            username: friend['to']['username'],
            avatar: friend['to']['avatar'],
          ),
        ),
      );
    });
    print(resData['friends']);
  }

  // 组装群组
  Future<void> setGroups(resData) async {
    (resData['groups'] as List<dynamic>).forEach((group) {
      _groups.add(
        GroupItem(
          sId: group['_id'],
          name: group['name'],
          avatar: group['avatar'],
          creator: group['creator'],
        ),
      );
    });
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