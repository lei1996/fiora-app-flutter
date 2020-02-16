import 'dart:ui';

import 'package:flutter/material.dart';

class BlockLevelButton extends StatelessWidget {
  ///  文本内容
  final String text;

  /// 按钮半径
  final BorderRadius radius;

  /// 按钮触发函数
  final Function handleTap;

  /// 渐变色
  final LinearGradient gradient;

  /// 样式
  final TextStyle textStyle;

  /// 边框色
  final Color borderColors;

  final double width;

  final double height;

  BlockLevelButton({
    this.text,
    this.radius,
    this.handleTap,
    this.gradient,
    this.textStyle,
    this.borderColors,
    this.width,
    this.height,
  });

  Widget gradientBtn() {
    return RaisedButton(
      onPressed: handleTap,
      shape: RoundedRectangleBorder(borderRadius: radius),
      padding: const EdgeInsets.all(0.0),
      child: Ink(
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: radius,
          border: Border.all(
            color: borderColors,
          ),
        ),
        child: commonBtn(),
      ),
    );
  }

  Widget transparentBtn() {
    return FlatButton(
      onPressed: handleTap,
      shape: RoundedRectangleBorder(borderRadius: radius),
      padding: const EdgeInsets.all(0.0),
      child: commonBtn(),
    );
  }

  Widget commonBtn() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        border: Border.all(
          color: borderColors,
        ),
        borderRadius: radius,
      ),
      constraints: const BoxConstraints(
        minWidth: 88.0,
        minHeight: 36.0,
      ), // min sizes for Material buttons
      child: Center(
        child: Text(
          text,
          style: textStyle,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return gradient != null ? gradientBtn() : transparentBtn();
  }
}
