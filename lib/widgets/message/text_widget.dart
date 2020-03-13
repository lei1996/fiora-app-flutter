import 'dart:math';

import 'package:fiora_app_flutter/utils/util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

class TextWidget extends StatelessWidget {
  final String text;
  final RegExp linkPattern = new RegExp(
      r'https?:\/\/(www\.)?[-a-zA-Z0-9@:%._+~#=]{2,256}\.[a-z]{2,6}\b([-a-zA-Z0-9@:%_+.~#?&//=]*)');
  final RegExp expressionPattern = new RegExp(r'#\(([\u4e00-\u9fa5a-z]+)\)');

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
    String textStack = text;
    int linkIndex;
    int expressionIndex;
    int minIndex;

    // for (var i = 0; i < 5; i++) {
    while (textStack != '') {
      linkIndex = textStack.indexOf(linkPattern);
      expressionIndex = textStack.indexOf(expressionPattern);
      List<int> indexAry = [linkIndex, expressionIndex];
      // 获取数组里面大于0 的最小值，但是还是会有为 -1 的情况.
      minIndex = indexAry.reduce((curr, next) =>
          min(curr, next) < 0 ? max(curr, next) : min(curr, next));

      var result;

      if (minIndex > 0) {
        inlineList.add(
          TextSpan(
            text: textStack.substring(0, minIndex),
            style: TextStyle(
                fontSize: 17.0, color: Color.fromRGBO(163, 163, 173, 1)),
          ),
        );
        textStack = textStack.substring(minIndex, textStack.length);
        continue;
      }
      if (minIndex == 0) {
        if (expressionIndex == 0) {
          result = _expressionWidget(textStack);
          inlineList.add(result[1]);
          textStack = textStack.substring(result[0], textStack.length);
          continue;
        }
        if (linkIndex == 0) {
          result = _linkWidget(textStack);
          inlineList.add(result[1]);
          textStack = textStack.substring(result[0], textStack.length);
          continue;
        }
      }

      inlineList.add(
        TextSpan(
          text: textStack,
          style: TextStyle(
              fontSize: 17.0, color: Color.fromRGBO(163, 163, 173, 1)),
        ),
      );
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
