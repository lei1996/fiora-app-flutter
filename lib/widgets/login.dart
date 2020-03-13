import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';

import 'auth_widget.dart';

class LoginPage extends StatefulWidget {
  static const routeName = '/login';

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool onTap = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "LOGIN",
          style: TextStyle(
              fontSize: 20.0,
              fontFamily: "SF-UI-Display-Medium",
              color: Color.fromRGBO(24, 29, 40, 1)),
        ),
        centerTitle: true,
        elevation: 0.0,
        brightness: Brightness.light,
        backgroundColor: Colors.white,
        actionsIconTheme: IconThemeData(color: Color.fromRGBO(24, 29, 40, 1)),
        actions: <Widget>[
          Container(
            margin: EdgeInsets.only(right: 15.0),
            child: IconButton(
              onPressed: () {
                // Navigator.of(context).pushReplacement(
                //     // FadeRoute(Registration())
                // );
              },
              icon: Icon(Icons.bubble_chart),
            ),
          )
        ],
      ),
      backgroundColor: Colors.white,
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            GestureDetector(
              // 触摸收起键盘
              onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(30.0, 50.0, 30.0, 50.0),
                child: Form(
                  onChanged: () {
                    // if(!_autoForm){
                    //   setState(()=>_autoForm = true);
                    // }
                  },
                  // autovalidate: _autoForm,
                  child: Column(
                    children: <Widget>[
                      //账号
                      // LoginUserInput(
                      //   setCountry: setCountry,
                      //   setPhone: setPhone,
                      // ),
                      // // 历史账号
                      // HistoricalAccount(
                      //   setCountry: setCountry,
                      //   setPhone: setPhone,
                      //   setPassWord: setPassWord,
                      //   setRemember: setRemember,
                      //   doLogin: doLogin
                      // ),
                      // 密码
                      // PassWordInput(
                      //   setPassWord: setPassWord,
                      // ),
                      Container(
                          width: 200,
                          height: 100,
                          child: FlareActor("assets/flare/switch_daytime.flr",
                              animation: onTap ? "day_idle" : "night_idle",
                              shouldClip: false,
                              isPaused: false)),
                      AuthWidget(),
                      // 忘记密码
                      Container(
                        width: 325.0,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "忘记密码 ?",
                          style: TextStyle(
                            color: Color.fromRGBO(24, 29, 40, 0.64),
                            fontSize: 14.0,
                            fontFamily: "SF-UI-Display-Medium",
                          ),
                        ),
                      ),
                      // BlockLevelButton(
                      //   width: 325.0,
                      //   height: 60,
                      //   text: '登录',
                      //   radius: BorderRadius.circular(8.0),
                      //   handleTap: () {
                      //     // route.pushReplacementNamed(LoginPage.routeName);
                      //   },
                      //   gradient: LinearGradient(colors: <Color>[
                      //     Color.fromRGBO(28, 224, 218, 1),
                      //     Color.fromRGBO(71, 157, 228, 1)
                      //   ]),
                      //   textStyle: TextStyle(
                      //     color: Colors.white,
                      //     fontSize: 18.0,
                      //     fontFamily: "SF-UI-Display-Regular",
                      //   ),
                      //   borderColors: Colors.transparent,
                      // ),
                      // //登录
                      Container(
                        width: 325.0,
                        height: 60,
                        margin: EdgeInsets.only(top: 70.0),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.0),
                            gradient: LinearGradient(colors: <Color>[
                              Color.fromRGBO(28, 224, 218, 1),
                              Color.fromRGBO(71, 157, 228, 1)
                            ]),
                            boxShadow: <BoxShadow>[
                              BoxShadow(
                                  color: Color.fromRGBO(159, 210, 243, 0.35),
                                  blurRadius: 24.0,
                                  spreadRadius: 0.0,
                                  offset: Offset(0.0, 12.0))
                            ]),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {},
                            splashColor: Color.fromRGBO(28, 224, 218, 0.5),
                            borderRadius: BorderRadius.circular(8.0),
                            child: Container(
                              alignment: Alignment.center,
                              child: Text("登录",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18.0,
                                      fontFamily: "SF-UI-Display-Regular")),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
      resizeToAvoidBottomPadding: false, //输入框抵住键盘 内容不随键盘滚动
    );
  }
}
