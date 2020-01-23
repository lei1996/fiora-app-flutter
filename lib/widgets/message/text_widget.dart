import 'dart:math';

import 'package:fiora_app_flutter/utils/util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

class TextWidget extends StatelessWidget {
  final String text;
  RegExp linkPattern = new RegExp(
      r'https?:\/\/(www\.)?[-a-zA-Z0-9@:%._+~#=]{2,256}\.[a-z]{2,6}\b([-a-zA-Z0-9@:%_+.~#?&//=]*)');
  RegExp expressionPattern = new RegExp(r'#\(([\u4e00-\u9fa5a-z]+)\)');
  String renderText;
  List<dynamic> renderWidgets = [];

  TextWidget({this.text});

  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  _linkWidget(String stext) {
    final linkMatch = linkPattern.firstMatch(stext);
    final url = linkMatch.group(0);
    return [
      url.length,
      WidgetSpan(
        child: GestureDetector(
          child: Text(url,
              style: TextStyle(
                  decoration: TextDecoration.underline, color: Colors.blue)),
          onTap: () => _launchURL(url),
        ),
      ),
    ];
  }

  _expressionWidget(String stext) {
    final expressionMatch = expressionPattern.firstMatch(stext);
    final cont = expressionMatch.group(0);
    final index = Util.expression.indexOf(expressionMatch.group(1));
    if (index != -1) {
      return [
        cont.length,
        WidgetSpan(
          child: Image.asset(
            'assets/images/baidu.png',
            width: 30,
            height: 30,
            fit: BoxFit.cover,
            // 正确的值  index 为15的时候 思路：计算图标大小 和 偏移量
            // alignment: Alignment(0, -0.3885), (-0.38850999999999997动态计算的值，虽然有一点点的误差，但是问题不大)
            alignment: Alignment(0, -(1 - 0.042666 * index) - (0.0019 * index)),
            matchTextDirection: true,
          ),
        ),
      ];
    }
    return [cont.length, TextSpan(text: cont)];
  }

  _renderWidget() {
    final List<InlineSpan> inlineList = [];
    String textStack;
    int linkIndex;
    int expressionIndex;
    int minIndex;

    textStack = text;

    while (textStack != '') {
      linkIndex = textStack.indexOf(linkPattern);
      expressionIndex = textStack.indexOf(expressionPattern);
      minIndex = [linkIndex, expressionIndex].reduce(min);

      if (expressionIndex > 0 && linkIndex > 0) {
        inlineList.add(TextSpan(text: textStack.substring(0, minIndex)));
        textStack = textStack.substring(minIndex, textStack.length);
        linkIndex = textStack.indexOf(linkPattern);
        expressionIndex = textStack.indexOf(expressionPattern);
      }
      if (expressionIndex > linkIndex) {
        var result;
        if (linkIndex != -1) {
          result = _linkWidget(textStack);
          inlineList.add(result[1]);
        } else {
          result = _expressionWidget(textStack);
          inlineList.add(result[1]);
        }
        textStack = textStack.substring(result[0], textStack.length);
      } else if (linkIndex > expressionIndex) {
        var result;
        if (expressionIndex != -1) {
          result = _expressionWidget(textStack);
          inlineList.add(result[1]);
        } else {
          result = _linkWidget(textStack);
          inlineList.add(result[1]);
        }
        textStack = textStack.substring(result[0], textStack.length);
      } else {
        inlineList.add(TextSpan(text: textStack));
        textStack = '';
      }
    }

    return inlineList;
  }

  @override
  Widget build(BuildContext context) {
    // _renderWidget();
    return Container(
      child: RichText(
        text: TextSpan(
          style: TextStyle(
            color: Colors.white,
            fontSize: ScreenUtil().setSp(40),
          ),
          children: _renderWidget(),
        ),
      ),
    );
  }
}
