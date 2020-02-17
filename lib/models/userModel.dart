import 'dart:async';

class UserModel {
  String userId; // 用户ID
  DateTime expiryDate; // 过期时间
  String token; // token
  String avatar; // 头像
  String username; // 用户名
  String tag; // 标签
  bool isAdmin; // 判断是否为管理员

  UserModel({
    this.userId,
    this.expiryDate,
    this.token,
    this.avatar,
    this.username,
    this.tag,
    this.isAdmin,
  });

  UserModel copyWith({
    String userId,
    DateTime expiryDate,
    String token,
    String avatar,
    String username,
    String tag,
    bool isAdmin,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      expiryDate: expiryDate ?? this.expiryDate,
      token: token ?? this.token,
      avatar: avatar ?? this.avatar,
      username: username ?? this.username,
      tag: tag ?? this.tag,
      isAdmin: isAdmin ?? this.isAdmin,
    );
  }
}
