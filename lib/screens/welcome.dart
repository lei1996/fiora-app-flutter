import 'package:fiora_app_flutter/widgets/buttons/block_level_button.dart';
import 'package:fiora_app_flutter/widgets/login.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_player/video_player.dart';

class Welcome extends StatelessWidget {
  static const String routeName = '/welcome';
  @override
  Widget build(BuildContext context) {
    ScreenUtil.instance = ScreenUtil(
      width: 1125,
      height: 2436,
      allowFontScaling: true,
    )..init(context);
    final NavigatorState route = Navigator.of(context);
    return Scaffold(
      body: Center(
        child: Stack(
          children: <Widget>[
            VideoBackground(),
            Positioned(
              bottom: 50.0,
              left: 25.0,
              right: 25.0,
              height: 60.0,
              child: BlockLevelButton(
                text: '登录',
                radius: BorderRadius.circular(8.0),
                handleTap: () {
                  route.pushReplacementNamed(LoginPage.routeName);
                },
                gradient: null,
                textStyle: TextStyle(
                  color: Colors.white,
                  fontSize: 18.0,
                  fontFamily: "SF-UI-Display-Regular",
                ),
                borderColors: Colors.white,
              ),
            ),
            Positioned(
              bottom: 130.0,
              left: 25.0,
              right: 25.0,
              height: 60.0,
              child: BlockLevelButton(
                text: '注册',
                radius: BorderRadius.circular(8.0),
                handleTap: () {
                  route.pushReplacementNamed(LoginPage.routeName);
                },
                gradient: LinearGradient(colors: <Color>[
                  Color.fromRGBO(28, 224, 218, 1),
                  Color.fromRGBO(71, 157, 228, 1)
                ]),
                textStyle: TextStyle(
                  color: Colors.white,
                  fontSize: 18.0,
                  fontFamily: "SF-UI-Display-Regular",
                ),
                borderColors: Colors.transparent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class VideoBackground extends StatefulWidget {
  @override
  _VideoBackground createState() => _VideoBackground();
}

class _VideoBackground extends State<VideoBackground> {
  VideoPlayerController _controller;
  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset("assets/video/splash.mp4");
    // 在初始化完成后必须更新界面
    _controller
      ..initialize().then((_) {
        // 视频为播放状态
        _controller.play();
        // 循环播放
        _controller.setLooping(true);
        setState(() {});
      });
  }

  @override
  dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: _controller.value.initialized
          ? VideoPlayer(_controller)
          : Image.asset(
              "assets/images/splash.png",
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            ),
    );
  }
}
