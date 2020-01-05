import 'package:fiora_app_flutter/models/socket_exception.dart';
import 'package:flutter/foundation.dart';

import '../utils/fetch.dart' as Fetch;
import '../models/friends.dart';

class Service {
  static Future<dynamic> authenticate(
    String urlSegment,
    String userName,
    String password,
  ) async {
      final res = await Fetch.fetch(
        urlSegment,
        {'username': userName, 'password': password},
      );
      if (res[0] != null) {
        throw SocketException(res[0]);
      }
      return res[1];
  }


  Future<List<FriendItem>> setFriends(resData) async {
    return compute(parseFriends, resData['friends']);
  }

  List<FriendItem> parseFriends(dynamic responseBody) =>
    responseBody.map<FriendItem>((json) => FriendItem.fromJson(json)).toList();
}
