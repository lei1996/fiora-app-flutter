import 'package:flutter/material.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'dart:ui';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
            child: Container(
              width: 150.0,
              height: 150.0,
              color: Colors.white12,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: <Widget>[
                  FlareActor(
                    "assets/flare/loading.flr", // flr文件
                    animation: "Untitled", // 动画名称
                    fit: BoxFit.contain,
                    color: Color.fromRGBO(24, 29, 40, 1),
                    shouldClip: false,
                  ),
                  Positioned(
                    bottom: 15.0,
                    child: Text("加载中..."),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
      // backgroundColor: Colors.transparent,
    );
  }
}
