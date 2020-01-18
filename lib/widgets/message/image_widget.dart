import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ImageWidget extends StatelessWidget {
  final String id;
  final String url;
  final Function handleTap;
  double width = 200.0;
  double height = 200.0;
  String scaleImgUrl;

  ImageWidget({
    @required this.id,
    @required this.url,
    @required this.handleTap,
  });

  setWidget() {
    const maxWidth = 200;
    const maxHeight = 200;

    var regex = new RegExp(r"width=([0-9]+)&height=([0-9]+)");
    for (var match in regex.allMatches(url)) {
      // group(0) width=1242&height=2688
      var natureWidth = int.parse(match.group(1));
      var naturehHeight = int.parse(match.group(2));
      double scale = 1.0;
      if (natureWidth * scale > maxWidth) {
        scale = maxWidth / natureWidth;
      }
      if ((naturehHeight * scale) > maxHeight) {
        scale = maxHeight / naturehHeight;
      }
      width = natureWidth * scale;
      height = naturehHeight * scale;
      scaleImgUrl =
          "${url}&imageView2/3/w/${(width * 1.2).round()}/h/${(height * 1.2).round()}";
    }
  }

  @override
  Widget build(BuildContext context) {
    // print(url);
    setWidget();
    return GestureDetector(
      onTap: handleTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: ScreenUtil().setHeight(8),
          horizontal: ScreenUtil().setWidth(8),
        ),
        child: Hero(
          tag: id,
          child: CachedNetworkImage(
            imageUrl: scaleImgUrl,
            imageBuilder: (context, imageProvider) => Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: imageProvider,
                  fit: BoxFit.cover,
                  colorFilter: null,
                ),
              ),
              width: width * 1.2,
              height: height * 1.2,
            ),
            placeholder: (context, url) => Container(
              width: width * 1.2,
              height: height * 1.2,
              decoration: BoxDecoration(
                color: Colors.grey,
              ),
            ),
            errorWidget: (context, url, error) => Container(),
          ),
        ),
      ),
    );
  }
}
