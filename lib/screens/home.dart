import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:provider/provider.dart';

import '../models/linkman.dart';
import './welcome.dart';
import '../widgets/avatar_widget.dart';
import '../widgets/linkman.dart';
import '../providers/auth.dart';
import '../utils/toast_utils.dart';
import '../utils/animations/fade_in.dart';

class HomePage extends StatelessWidget {
  static const routeName = '/home';

  final num customTop = 90;

  int lastBack = 0;
  Future<bool> doubleBackExit() {
    int now = DateTime.now().millisecondsSinceEpoch;
    if (now - lastBack > 800) {
      showToast('再按一次退出应用');
      lastBack = DateTime.now().millisecondsSinceEpoch;
    } else {
      SystemNavigator.pop();
    }
    return Future.value(false);
  }

  large(List<LinkmanItem> linkmans) => ListView.builder(
        itemCount: linkmans.length,
        // 需要根据消息时间 sort， 需要将
        itemBuilder: (ctx, i) => FadeIn(
          i / 4,
          Linkman(
            id: linkmans[i].sId,
            avatar: linkmans[i].avatar,
            name: linkmans[i].name,
            message: linkmans[i].message.content,
            lastName: linkmans[i].message.from.username,
            time: DateTime.parse(linkmans[i].message.createTime),
          ),
        ),
      );

  small(List<LinkmanItem> linkmans) => ListView(
        // 需要根据消息时间 sort， 需要将
        children: linkmans
            .map(
              (linkman) => Linkman(
                id: linkman.sId,
                avatar: linkman.avatar,
                name: linkman.name,
                message: linkman.message.content,
                lastName: linkman.message.from.username,
                time: DateTime.parse(linkman.message.createTime),
              ),
            )
            .toList(),
      );

  @override
  Widget build(BuildContext context) {
    ScreenUtil.instance = ScreenUtil(
      width: 1125,
      height: 2436,
      allowFontScaling: true,
    )..init(context);
    final bloc = Provider.of<Auth>(context, listen: false);
    return WillPopScope(
      onWillPop: doubleBackExit,
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(
                  top: ScreenUtil().setHeight(customTop),
                  left: ScreenUtil().setWidth(40),
                  right: ScreenUtil().setWidth(40),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    IconButton(
                      icon: Icon(Icons.menu),
                      onPressed: () {
                        Navigator.of(context)
                            .pushReplacementNamed(Welcome.routeName);
                        bloc.logout();
                      },
                    ),
                    AvatarWidget(),
                  ],
                ),
              ),
              SizedBox(
                height: ScreenUtil().setHeight(1950),
                child: Consumer<Auth>(
                    builder: (ctx, authData, child) =>
                        authData.linkmans.length >= 80
                            ? large(authData.linkmans)
                            : small(authData.linkmans)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
