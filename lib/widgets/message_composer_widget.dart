import 'dart:io';

import 'package:fiora_app_flutter/providers/auth.dart';
import 'package:fiora_app_flutter/utils/custom_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import 'expressions_widget.dart';

class MessageComposerWidget extends StatefulWidget {
  final String id;

  MessageComposerWidget(this.id);
  // 表情扩展栏开关
  @override
  _MessageComposerWidgetState createState() => _MessageComposerWidgetState();
}

class _MessageComposerWidgetState extends State<MessageComposerWidget> {
  bool isToggleExp = false;
  final _messageController = TextEditingController();
  final _messageFocusNode = FocusNode();

  setToggleExp(bool value) {
    FocusScope.of(context).unfocus();
    setState(() {
      isToggleExp = value;
    });
  }

  @override
  dispose() {
    _messageController.dispose();
    _messageFocusNode.dispose();
    super.dispose();
  }

  // 发送消息
  Future<void> _sendMessage({
    String to,
    String type,
    String content,
  }) async {
    await Provider.of<Auth>(context, listen: false)
        .sendMessage(to: to, type: type, content: content);
  }

  @override
  Widget build(BuildContext context) {
    print("重新渲染");
    return Container(
      // decoration: BoxDecoration(
      //   borderRadius: BorderRadius.only(
      //     topLeft: Radius.circular(18.0),
      //     topRight: Radius.circular(18.0),
      //   ),
      //   color: Color.fromRGBO(251, 250, 252, 1),
      // ),
      padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(80.0)),
      // 220
      height: ScreenUtil()
          .setHeight(isToggleExp ? 620 + (Platform.isIOS ? 40 : 0) : 220),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Color.fromRGBO(251, 246, 255, 1),
              borderRadius: BorderRadius.all(Radius.circular(38.0)),
            ),
            child: Row(
              children: <Widget>[
                IconButton(
                  icon: Icon(CustomIcon.emoticon_happy),
                  iconSize: ScreenUtil().setWidth(90.0),
                  color: Color.fromRGBO(220, 219, 224, 1),
                  onPressed: () {
                    // 打开表情栏
                    setToggleExp(!isToggleExp);
                  },
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: ScreenUtil().setWidth(50.0),
                    ),
                    child: TextField(
                      controller: _messageController,
                      textCapitalization: TextCapitalization.sentences,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) {
                        if (_messageController.text.isEmpty) return;
                        _sendMessage(
                          to: widget.id,
                          type: 'text',
                          content: _messageController.text,
                        );
                        _messageController.text = '';
                      },
                      focusNode: _messageFocusNode,
                      // collapsed 去除input 下面的线
                      decoration: InputDecoration.collapsed(
                        hintText: '代码写完了吗?',
                      ),
                    ),
                  ),
                ),
                IconButton(
                    // attach_file
                    icon: Icon(
                      CustomIcon.send,
                      // color: Colors.white,
                    ),
                    iconSize: ScreenUtil().setWidth(90.0),
                    color: Color.fromRGBO(220, 219, 224, 1),
                    onPressed: () {
                      if (_messageController.text.isEmpty) return;
                      _sendMessage(
                        to: widget.id,
                        type: 'text',
                        content: _messageController.text,
                      );
                      _messageController.text = '';
                    }),
              ],
            ),
          ),
          isToggleExp
              ? Container(
                  child: ExpressionsWidget(),
                )
              : Container(),
        ],
      ),
    );
  }
}
