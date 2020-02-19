import 'package:fiora_app_flutter/providers/auth.dart';
import 'package:fiora_app_flutter/widgets/message/image_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import './avatar.dart';
import '../utils/time.dart';
import 'gallery_photo_viewWrapper.dart';
import 'message/text_widget.dart';

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

  Widget _buildMessage(BuildContext context) {
    final bloc = Provider.of<Auth>(context, listen: false);
    switch (type) {
      case 'text':
        return Container(
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
            color: Color.fromRGBO(80, 85, 90, 1),
          ),
          child: 
          // Column(
          //   children: <Widget>[
          //     Text(
          //       content,
          //       style: TextStyle(
          //         color: Colors.white,
          //       ),
          //     ),
              TextWidget(text: content,),
          //   ],
          // ),
        );
        break;
      case 'image':
        return ImageWidget(
            id: id,
            url: "https:" + content,
            handleTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GalleryPhotoViewWrapper(
                    galleryItems: bloc.getGalleryItem(),
                    backgroundDecoration: const BoxDecoration(
                      color: Colors.black,
                    ),
                    initialIndex: bloc.getGalleryItemIndex(id),
                    scrollDirection:
                        Axis.horizontal,
                  ),
                ),
              );
            });
        break;
      default:
        return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    // print(type);
    return creator == prevCreator
        ? Padding(
            padding: EdgeInsets.only(
              left: ScreenUtil().setWidth(154),
              top: ScreenUtil().setHeight(5),
              bottom: ScreenUtil().setHeight(5),
            ),
            child: Row(
              children: <Widget>[
                _buildMessage(context),
              ],
            ),
          )
        : Padding(
            padding: EdgeInsets.only(
              top: ScreenUtil().setHeight(22),
              bottom: ScreenUtil().setHeight(5),
              left: ScreenUtil().setWidth(22),
              right: ScreenUtil().setWidth(22),
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
                      _buildMessage(context),
                    ],
                  ),
                )
              ],
            ),
          );
  }
}