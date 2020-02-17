import '../models/userModel.dart';

class User {
  Map<String, UserModel> _user = {};

  ///获得单个用户
  UserModel getUser(String id) => _user.containsKey('id') ? _user['id'] : {};

  /// 添加用户/更新用户token等信息
  addUser(dynamic data, DateTime expiryDate) {
    final String userId = data['_id'] ?? data['userId'];

    final UserModel user = UserModel(
      userId: userId,
      token: data['token'],
      isAdmin: data['isAdmin'],
      tag: data['tag'],
      username: data['username'],
      avatar: data['avatar'],
      expiryDate: expiryDate,
    );

    if (_user.containsKey(userId)) {
      _user.update(userId, (user) => user);
    } else {
      _user.putIfAbsent(userId, () => user);
    }
  }

  /// 移除某个用户
  Future<bool> removeUser(String userId) async {
    if (!_user.containsKey(userId)) return false;

    _user.remove(userId);
    return true;
  }

  // 清空所有用户信息
  void clear() {
    _user = {};
    // notifyListeners();
  }
}
