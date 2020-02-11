import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:provider/provider.dart';

import '../widgets/avatar_widget.dart';
import '../widgets/linkman.dart';
import '../providers/auth.dart';
import '../utils/animations/fade_in.dart';

class HomePage extends StatelessWidget {
  static const routeName = '/home';

  final num customTop = 90;

  @override
  Widget build(BuildContext context) {
    ScreenUtil.instance = ScreenUtil(
      width: 1125,
      height: 2436,
      allowFontScaling: true,
    )..init(context);
    final bloc = Provider.of<Auth>(context, listen: false);
    return Scaffold(
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
                    onPressed: () => bloc.logout(),
                  ),
                  AvatarWidget(),
                ],
              ),
            ),
            SizedBox(
              height: ScreenUtil().setHeight(1950),
              child: Consumer<Auth>(
                builder: (ctx, authData, child) => ListView.builder(
                  itemCount: authData.linkmans.length,
                  // 需要根据消息时间 sort， 需要将
                  itemBuilder: (ctx, i) => FadeIn(
                    i / 4,
                    Linkman(
                      id: authData.linkmans[i].sId,
                      avatar: authData.linkmans[i].avatar,
                      name: authData.linkmans[i].name,
                      message: authData.linkmans[i].message.content,
                      lastName: authData.linkmans[i].message.from.username,
                      time: DateTime.parse(
                          authData.linkmans[i].message.createTime),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
