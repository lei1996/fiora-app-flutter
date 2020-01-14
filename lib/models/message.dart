import 'package:flutter/foundation.dart';

class Message {
  String type;
  String content;
  String sId;
  FromUser from;
  String createTime;

  Message({
    @required this.type,
    @required this.content,
    @required this.sId,
    @required this.from,
    @required this.createTime,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      sId: json['_id'] as String,
      type: json['type'] as String,
      content: json['content'] as String,
      from: FromUser.fromJson(json['from'] as Map<String, dynamic>),
      createTime: json['createTime'] as String,
    );
  }

  static List<Message> parseMessage(responseBody) {
    return responseBody.map<Message>((json) => Message.fromJson(json)).toList();
  }

  // {
  //   type: text, 
  //   content: 本来新号说话还是萌新限制#(阴险)变成了小黑屋了, 
  //   _id: 5e19d8c1a0ba560766fcab4c, 
  //   from: {
  //     tag: 小天使, 
  //     _id: 5b4ee8321b53ec11c8505de5, 
  //     username: zhcxk1998, 
  //     avatar: //cdn.suisuijiang.com/Avatar/5b4ee8321b53ec11c8505de5_1578399067962
  //   }, 
  //   createTime: 2020-01-11T14:16:33.672Z
  // }
}

class FromUser {
  String tag;
  String sId;
  String username;
  String avatar;

  FromUser({
    @required this.tag,
    @required this.sId,
    @required this.username,
    @required this.avatar,
  });

  factory FromUser.fromJson(Map<String, dynamic> json) {
    return FromUser(
      sId: json['_id'] as String,
      tag: json['tag'] as String,
      username: json['username'] as String,
      avatar: json['avatar'] as String,
    );
  }
}
