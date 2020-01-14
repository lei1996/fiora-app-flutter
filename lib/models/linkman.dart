import 'package:flutter/foundation.dart';

import 'message.dart';

class LinkmanItem {
  final String sId;
  final String type;
  final int unread;
  final String name;
  final String avatar;
  final String creator;
  final DateTime createTime;
  final Message message;

  LinkmanItem({
    @required this.sId,
    @required this.type,
    @required this.unread,
    @required this.name,
    @required this.avatar,
    @required this.creator,
    @required this.createTime,
    @required this.message,
  });

  factory LinkmanItem.fromJson(Map<String, dynamic> json) {
    return LinkmanItem(
      sId: json['_id'] as String,
      type: json['type'] as String,
      unread: 0,
      name: json['content'] as String,
      avatar: json['content'] as String,
      creator: json['content'] as String,
      createTime: DateTime.parse(['createTime'] as String),
      message: ,
    );
  }

  static List<LinkmanItem> parseLinkman(responseBody) {
    return responseBody.map<LinkmanItem>((json) => LinkmanItem.fromJson(json)).toList();
  }

}