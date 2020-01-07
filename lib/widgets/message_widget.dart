import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import './avatar.dart';
import '../utils/time.dart';

class MessageWidget extends StatelessWidget {
  final String id;
  final String content;
  final String type;
  final String name;
  final String avatar;
  final String creator;
  final String prevCreator; // 上一条消息的 id
  final DateTime createTime;

  MessageWidget({
    @required this.id,
    @required this.content,
    @required this.type,
    @required this.name,
    @required this.avatar,
    @required this.creator,
    @required this.prevCreator,
    @required this.createTime,
  });

  @override
  Widget build(BuildContext context) {
    return creator == prevCreator
        ? Padding(
            padding: EdgeInsets.only(
              left: ScreenUtil().setWidth(154),
              top: ScreenUtil().setHeight(5),
              bottom: ScreenUtil().setHeight(5),
            ),
            child: Row(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.symmetric(
                    vertical: ScreenUtil().setHeight(20),
                    horizontal: ScreenUtil().setWidth(30),
                  ),
                  constraints: BoxConstraints(
                    minWidth: ScreenUtil().setWidth(20),
                    maxWidth: ScreenUtil().setWidth(780),
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    color: Color.fromRGBO(22, 44, 23, 0.6),
                  ),
                  child: Text(
                    content,
                  ),
                ),
              ],
            ),
          )
        : Padding(
            padding: EdgeInsets.symmetric(
              horizontal: ScreenUtil().setWidth(22),
              vertical: ScreenUtil().setHeight(22),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Avatar(
                  url: "https:" + avatar,
                  height: ScreenUtil().setHeight(110),
                  width: ScreenUtil().setWidth(110),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    left: ScreenUtil().setWidth(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('$name  ${Time.formatTime(createTime)}'),
                      Container(
                        padding: EdgeInsets.symmetric(
                          vertical: ScreenUtil().setHeight(20),
                          horizontal: ScreenUtil().setWidth(30),
                        ),
                        constraints: BoxConstraints(
                          minWidth: ScreenUtil().setWidth(20),
                          maxWidth: ScreenUtil().setWidth(780),
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          color: Color.fromRGBO(22, 44, 23, 0.6),
                        ),
                        child: Text(
                          content,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          );
  }
}
