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
                  fontSize: 17.0,
                  decoration: TextDecoration.underline,
                  color: Color.fromRGBO(163, 163, 173, 1))),
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
        WidgetSpan(child: Util.exressionModel(index)),
      ];
    }
    return [
      cont.length,
      TextSpan(
          text: cont,
          style: TextStyle(
              fontSize: 17.0, color: Color.fromRGBO(163, 163, 173, 1)))
    ];
  }

  _renderWidget() {
    final List<InlineSpan> inlineList = [];
    String textStack;
    int linkIndex;
    int expressionIndex;
    int maxIndex;
    int minIndex;

    textStack = text;

    // for (var i = 0; i < 5; i++) {
    while (textStack != '') {
      linkIndex = textStack.indexOf(linkPattern);
      expressionIndex = textStack.indexOf(expressionPattern);
      maxIndex = [linkIndex, expressionIndex].reduce(max);
      minIndex = [linkIndex, expressionIndex].reduce(min);

      var result;

      // 这里设计有缺陷，应该求 数组中 “大于0的最小值” 。
      if (minIndex > 0 ||
          (expressionIndex > 0 && minIndex == -1) ||
          (linkIndex > 0 && minIndex == -1)) {
        if (minIndex != -1) {
          inlineList.add(TextSpan(text: textStack.substring(0, minIndex)));
          textStack = textStack.substring(minIndex, textStack.length);
          continue;
        } else {
          inlineList.add(TextSpan(text: textStack.substring(0, maxIndex)));
          textStack = textStack.substring(maxIndex, textStack.length);
          continue;
        }
      }

      if (expressionIndex == 0 || (expressionIndex > 0 && minIndex == -1)) {
        result = _expressionWidget(textStack);
        inlineList.add(result[1]);
        textStack = textStack.substring(result[0], textStack.length);
        continue;
      }
      if (linkIndex == 0 || (linkIndex > 0 && minIndex == -1)) {
        result = _linkWidget(textStack);
        inlineList.add(result[1]);
        textStack = textStack.substring(result[0], textStack.length);
        continue;
      }

      inlineList.add(TextSpan(
          text: textStack,
          style: TextStyle(
              fontSize: 17.0, color: Color.fromRGBO(163, 163, 173, 1))));
      textStack = '';
      continue;
    }

    return inlineList;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: RichText(
        // textAlign: TextAlign.left,
        text: TextSpan(
          style: TextStyle(
            color: Color.fromRGBO(163, 163, 173, 1),
            fontSize: ScreenUtil().setSp(40),
          ),
          children: _renderWidget(),
        ),
      ),
    );
  }
}
