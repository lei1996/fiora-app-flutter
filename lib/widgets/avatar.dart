import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../utils/profileClipper.dart';

class Avatar extends StatelessWidget {
  final String url;
  final double width;
  final double height;
  final String defaultUrl = 'assets/images/headericon.jpg';

  Avatar({
    @required this.url,
    @required this.width,
    @required this.height,
  });

  Widget defaultImage() {
    return Image.asset(
      defaultUrl,
      width: width,
      height: height,
      fit: BoxFit.cover,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      clipper: ProfileClipper(),
      // 本地缓存图片 lib  占未启用
      child: CachedNetworkImage(
        imageUrl: url,
        imageBuilder: (context, imageProvider) => Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: imageProvider,
              fit: BoxFit.cover,
              colorFilter: null,
            ),
          ),
          width: width,
          height: height,
        ),
        placeholder: (context, url) => defaultImage(),
        errorWidget: (context, url, error) => defaultImage(),
      ),
    );
  }
}
