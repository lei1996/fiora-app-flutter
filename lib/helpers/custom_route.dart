import 'dart:math';
import 'package:flutter/material.dart';

// <T> 泛型
class CustomRoute<T> extends MaterialPageRoute<T> {
  CustomRoute({
    WidgetBuilder builder,
    RouteSettings settings,
  }) : super(
          builder: builder,
          settings: settings,
        );

  // 构建一个过渡方法
  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    // 如果是初始路劲,直接返回child
    if (settings.isInitialRoute) {
      return child;
    }
    return FadeTransition(
      opacity: animation,
      child: child,
    );
  }
}

class CustomPageTransitionBuilder extends PageTransitionsBuilder {
  // 构建一个过渡方法
  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    // 如果是初始路劲,直接返回child
    if (route.settings.isInitialRoute) {
      return child;
    }
    print("animation: $animation");
    print("child: $child");
    return FadeTransition(
      opacity: animation,
      child: child,
    );
  }
}

// 有bug ------------
class RouteConfig {
  Offset offset;
  double circleRadius;
  RouteConfig.fromContext(BuildContext context) {
    final RenderBox renderBox = context.findRenderObject();
    print(MediaQuery.of(context).size.height);
    offset = renderBox.localToGlobal(renderBox.size.center(Offset.zero));
    if (offset.dx > MediaQuery.of(context).size.width / 2) {
      if (offset.dy > MediaQuery.of(context).size.height / 2) {
        circleRadius = sqrt(pow(offset.dx, 2) + pow(offset.dy, 2)).toDouble();
      } else {
        circleRadius = sqrt(pow(offset.dx, 2) +
                pow(MediaQuery.of(context).size.height - offset.dy, 2))
            .toDouble();
      }
    }
    if (offset.dx <= MediaQuery.of(context).size.width / 2) {
      if (offset.dy > MediaQuery.of(context).size.height / 2) {
        circleRadius = sqrt(
                pow(MediaQuery.of(context).size.width - offset.dx, 2) +
                    pow(offset.dy, 2))
            .toDouble();
      } else {
        circleRadius = sqrt(
                pow(MediaQuery.of(context).size.width - offset.dx, 2) +
                    pow(MediaQuery.of(context).size.height - offset.dy, 2))
            .toDouble();
      }
    }
  }
}

// double circleRadius
class RippleRoute extends PageRouteBuilder {
  final Widget widget;
  final RouteConfig routeConfig;

  RippleRoute(this.widget, this.routeConfig)
      : super(
          // 设置过度时间
          transitionDuration: Duration(seconds: 1),
          // 构造器
          pageBuilder: (
            // 上下文和动画
            BuildContext context,
            Animation<double> animation,
            Animation<double> _,
          ) {
            return widget;
          },
          opaque: false,
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> _,
            Widget child,
          ) {
            return Stack(
              alignment: Alignment.center,
              children: <Widget>[
                Positioned(
                  top: routeConfig.offset.dy -
                      routeConfig.circleRadius * animation.value,
                  left: routeConfig.offset.dx -
                      routeConfig.circleRadius * animation.value,
                  child: SizedBox(
                    height: routeConfig.circleRadius * 2 * animation.value,
                    width: routeConfig.circleRadius * 2 * animation.value,
                    child: ClipOval(
                      child: Stack(
                        children: <Widget>[
                          Positioned(
                            top: routeConfig.circleRadius * animation.value -
                                routeConfig.offset.dy,
                            left: routeConfig.circleRadius * animation.value -
                                routeConfig.offset.dx,
                            child: Align(
                              alignment: Alignment.center,
                              child: Container(
                                width: MediaQuery.of(context).size.width,
                                height: MediaQuery.of(context).size.height,
                                child: child,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
}
