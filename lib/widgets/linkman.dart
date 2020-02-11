import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../utils/time.dart';
import '../screens/chat.dart';
import 'avatar.dart';

class Linkman extends StatelessWidget {
  final String id;
  final String avatar;
  final String name;
  final String message;
  final String lastName;
  final DateTime time;

  Linkman({
    @required this.id,
    @required this.avatar,
    @required this.name,
    @required this.message,
    @required this.lastName,
    @required this.time,
  });

  @override
  Widget build(BuildContext context) {
    // print(id);
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed(
          ChatPage.routeName,
          arguments: {'id': id, 'name': name},
        );
      },
      child: Hero(
        tag: id,
        child: Card(
          margin: EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 4,
          ),
          child: Padding(
            padding: EdgeInsets.all(2),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.white,
                child: Avatar(
                  url: "https:" + avatar,
                  width: ScreenUtil().setWidth(110),
                  height: ScreenUtil().setHeight(110),
                ),
              ),
              title: Text(name),
              subtitle: Text(
                id.length < 35 ? '$lastName: $message' : message,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              trailing: Text(Time.formatTime(time)),
            ),
          ),
        ),
      ),
    );
  }
}
