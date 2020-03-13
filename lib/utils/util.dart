import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Util {
  static String getFriendId(String userId1, String userId2) {
    if (userId1.compareTo(userId2) == -1) {
      return userId1 + userId2;
    }
    return userId2 + userId1;
  }

  static setPerfsData(Map<String, dynamic> data) async {
    final perfs = await SharedPreferences.getInstance();
    final userData = json.encode(data);
    perfs.setString('userData', userData);
  }

  static Image exressionModel(int index) => Image.asset(
        'assets/images/baidu.png',
        width: 30,
        height: 30,
        fit: BoxFit.cover,
        // 正确的值  index 为15的时候 思路：计算图标大小 和 偏移量
        // alignment: Alignment(0, -0.3885), (-0.38850999999999997动态计算的值，虽然有一点点的误差，但是问题不大)
        alignment: Alignment(0, -(1 - 0.042666 * index) - (0.0019 * index)),
        matchTextDirection: true,
      );

  static List<String> expression = [
    '呵呵',
    '哈哈',
    '吐舌',
    '啊',
    '酷',
    '怒',
    '开心',
    '汗',
    '泪',
    '黑线',
    '鄙视',
    '不高兴',
    '真棒',
    '钱',
    '疑问',
    '阴险',
    '吐',
    '咦',
    '委屈',
    '花心',
    '呼',
    '笑眼',
    '冷',
    '太开心',
    '滑稽',
    '勉强',
    '狂汗',
    '乖',
    '睡觉',
    '惊哭',
    '升起',
    '惊讶',
    '喷',
    '爱心',
    '心碎',
    '玫瑰',
    '礼物',
    '星星月亮',
    '太阳',
    '音乐',
    '灯泡',
    '蛋糕',
    '彩虹',
    '钱币',
    '咖啡',
    'haha',
    '胜利',
    '大拇指',
    '弱',
    'ok',
  ];
}
