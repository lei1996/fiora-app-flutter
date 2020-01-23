import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../providers/auth.dart';
import './user_widget.dart';
import './auth_widget.dart';
import './avatar.dart';

class AvatarWidget extends StatelessWidget {
  void _showModal(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      builder: (_) {
        return Container(
          // height: ScreenUtil().setHeight(760),
          child: Provider.of<Auth>(ctx, listen: false).isAuth
              ? UserWidget()
              : AuthWidget(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final avatar = Provider.of<Auth>(context, listen: false).avatar;
    return GestureDetector(
      onTap: () => _showModal(context),
      child: Avatar(
        url: avatar != null
            ? avatar
            : 'https://cdn.suisuijiang.com/GroupAvatar/5adad39555703565e7903f78_1546952226984?imageView2/3/w/96/h/96',
        width: ScreenUtil().setWidth(160),
        height: ScreenUtil().setHeight(160),
      ),
    );
  }
}
