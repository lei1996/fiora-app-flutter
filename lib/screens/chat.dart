import 'dart:async';
import 'dart:math';

import 'package:fiora_app_flutter/utils/custom_icon.dart';
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
  final _messageController = TextEditingController();
  final _messageFocusNode = FocusNode();
  // double _prevOffset;

  @override
  void initState() {
    _scrollController = ScrollController();
    // _scrollController.addListener(_scrollListener);
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
    _messageController.dispose();
    _messageFocusNode.dispose();
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

  // 发送消息
  Future<void> _sendMessage({
    String to,
    String type,
    String content,
  }) async {
    await Provider.of<Auth>(context, listen: false)
        .sendMessage(to: to, type: type, content: content);
    Timer(
        Duration(milliseconds: 300),
        () => _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: Duration(milliseconds: 300),
              curve: Curves.easeIn,
            ));
  }

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

  Widget _buildMessageComposer(String id) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18.0),
        color: Colors.grey[300],
      ),
      padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(80.0)),
      height: ScreenUtil().setHeight(220),
      child: Row(
        children: <Widget>[
          IconButton(
            icon: Icon(CustomIcon.emoticon_happy),
            iconSize: ScreenUtil().setWidth(90.0),
            color: Theme.of(context).accentColor,
            onPressed: () {},
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
                    to: id,
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
              icon: Icon(CustomIcon.send),
              iconSize: ScreenUtil().setWidth(90.0),
              color: Theme.of(context).accentColor,
              onPressed: () {
                if (_messageController.text.isEmpty) return;
                _sendMessage(
                  to: id,
                  type: 'text',
                  content: _messageController.text,
                );
                _messageController.text = '';
              }),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final params = ModalRoute.of(context).settings.arguments as dynamic;
    final bloc = Provider.of<Auth>(context, listen: false);
    final List<Message> messages = bloc.getMessageItem(params['id'] as String);
    bloc.setGalleryItem(params['id']);
    return Scaffold(
      appBar: AppBar(
        title: Text(params['name']),
      ),
      body: GestureDetector(
        // 触碰body 收回输入法
        onTap: () => FocusScope.of(context).unfocus(),
        child: Column(
          children: <Widget>[
            Expanded(
              child: Container(
                child: RefreshIndicator(
                  onRefresh: () => _loadingMessages(
                    context: context,
                    id: params['id'],
                    count: messages.length,
                  ),
                  child: Consumer<Auth>(
                    builder: (ctx, authData, child) => ListView.builder(
                      controller: _scrollController,
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
                          createTime: DateTime.parse(message.createTime),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
            _buildMessageComposer(params['id']),
          ],
        ),
      ),
    );
  }
}
