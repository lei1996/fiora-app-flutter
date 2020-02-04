import 'package:fiora_app_flutter/utils/util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ExpressionsWidget extends StatelessWidget {
  //表情列表
  final List<Container> exps = [];

  expressions() {
    for (var i = 0; i < 50; i++) {
      exps.add(
        Container(
          margin: EdgeInsets.all(ScreenUtil().setWidth(5)),
          child: Util.exressionModel(i),
        ),
      );
    }
    print(exps.length);
  }

  @override
  Widget build(BuildContext context) {
    expressions();
    return Container(
      child: Wrap(
        children: exps,
      ),
    );
  }
}
