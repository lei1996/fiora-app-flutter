import 'dart:async';

import 'package:fiora_app_flutter/widgets/message_composer_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../models/message.dart';
import '../providers/auth.dart';
import '../widgets/message_widget.dart';

class ChatPage extends StatefulWidget {
  static const routeName = '/chat';

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  ScrollController _scrollController;
  // @(?!@)(\S+)
  // double _prevOffset;

  @override
  void initState() {
    _scrollController = ScrollController();
    Future.delayed(Duration.zero).then((_) {
      _scrollController.jumpTo(
        _scrollController.position.maxScrollExtent,
      );
      // _prevOffset = _scrollController.position.maxScrollExtent;
    });
    super.initState();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the
    // widget tree.
    super.dispose();
  }

  // _scrollListener() {
  //   print(_scrollController.offset);
  //   if (_scrollController.offset >=
  //           _scrollController.position.maxScrollExtent &&
  //       !_scrollController.position.outOfRange) {
  //     setState(() {
  //       message = "reach the bottom";
  //     });
  //     // print(message);
  //     print(_scrollController.position.maxScrollExtent);
  //   }
  //   if (_scrollController.offset <=
  //           _scrollController.position.minScrollExtent &&
  //       !_scrollController.position.outOfRange) {
  //     setState(() {
  //       _prevOffset = _scrollController.position.maxScrollExtent;
  //     });
  //     // print(message);
  //     print(_scrollController.position.maxScrollExtent);
  //   }
  // }

  // 加载历史消息
  Future<void> _loadingMessages({
    BuildContext context,
    String id,
    int count,
  }) async {
    var bloc = Provider.of<Auth>(context, listen: false);
    await bloc.getLinkmanHistoryMessages(linkmanId: id, existCount: count);
    bloc.setGalleryItem(id);
    // 拉取历史数据之后 scroll 跳到上一次记录的位置
    // Timer(
    //     Duration(milliseconds: 1000),
    //     () => _scrollController
    //         .jumpTo(_scrollController.position.maxScrollExtent - _prevOffset));
    // print(_scrollController.position.maxScrollExtent - _prevOffset);
    // _prevOffset = _scrollController.position.maxScrollExtent;
  }

  @override
  Widget build(BuildContext context) {
    final params = ModalRoute.of(context).settings.arguments as dynamic;
    final bloc = Provider.of<Auth>(context, listen: false);
    final List<Message> messages = bloc.getMessageItem(params['id'] as String);
    bloc.setGalleryItem(params['id']);
    // 获取键盘高度
    final mediaQuery = MediaQuery.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(params['name']),
      ),
      body: GestureDetector(
        // 触碰body 收回输入法
        onTap: () => FocusScope.of(context).unfocus(),
        child: Container(
          // 动画时长
          // duration: Duration(milliseconds: 300),
          // curve: Curves.easeIn,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(35),
              topRight: Radius.circular(35),
            ),
            // color: Colors.grey,
          ),
          height: ScreenUtil().setHeight(2164) - mediaQuery.viewInsets.bottom,
          constraints: BoxConstraints(
            minHeight:
                ScreenUtil().setHeight(2164) - mediaQuery.viewInsets.bottom,
            maxHeight: ScreenUtil().setHeight(2164),
          ),
          child: Column(
            children: <Widget>[
              Expanded(
                child: Container(
                  height: ScreenUtil().setHeight(1944) -
                      mediaQuery.viewInsets.bottom,
                  child: RefreshIndicator(
                    onRefresh: () => _loadingMessages(
                      context: context,
                      id: params['id'],
                      count: messages.length,
                    ),
                    child: Consumer<Auth>(
                      builder: (ctx, authData, child) => ListView.builder(
                        controller: _scrollController,
                        cacheExtent: 40,
                        // 逐项滚动 聊天message 并不需要
                        // physics: PageScrollPhysics(),
                        itemCount: authData.getMessageItem(params['id']).length,
                        itemBuilder: (ctx, i) {
                          final Message message =
                              authData.getMessageItem(params['id'])[i];
                          return MessageWidget(
                            id: message.sId,
                            content: message.content,
                            type: message.type,
                            name: message.from.username,
                            avatar: message.from.avatar,
                            creator: message.from.sId,
                            prevCreator: i == 0
                                ? ''
                                : authData
                                    .getMessageItem(params['id'])[i - 1]
                                    .from
                                    .sId,
                            nextCreator: i ==
                                    authData
                                            .getMessageItem(params['id'])
                                            .length -
                                        1
                                ? ''
                                : authData
                                    .getMessageItem(params['id'])[i + 1]
                                    .from
                                    .sId,
                            createTime: DateTime.parse(message.createTime),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
              MessageComposerWidget(params['id']),
            ],
          ),
        ),
      ),
    );
  }
}
