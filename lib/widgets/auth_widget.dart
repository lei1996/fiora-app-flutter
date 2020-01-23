import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../providers/auth.dart';
import '../models/socket_exception.dart';

enum AuthMode { Signup, Login }

class AuthWidget extends StatefulWidget {
  @override
  _AuthAuthWidgetState createState() => _AuthAuthWidgetState();
}

class _AuthAuthWidgetState extends State<AuthWidget>
    with SingleTickerProviderStateMixin {
  // 登录 小部件

  final GlobalKey<FormState> _formKey = GlobalKey();
  AuthMode _authMode = AuthMode.Login;
  Map<String, String> _authData = {
    'username': '',
    'password': '',
  };
  var _isLoading = false;
  final _passwordController = TextEditingController();

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('出错了!'),
        content: Text(message),
        actions: <Widget>[
          FlatButton(
            child: Text('Okay'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          )
        ],
      ),
    );
  }

  // 表单提交 注册 or 登录
  Future<void> _submit() async {
    if (!_formKey.currentState.validate()) {
      // Invalid!
      return;
    }
    _formKey.currentState.save();
    setState(() {
      _isLoading = true;
    });
    try {
      await Provider.of<Auth>(context, listen: false)
          .login(_authData['username'], _authData['password']);
      Navigator.of(context).pop();
    } on SocketException catch (e) {
      Navigator.of(context).pop();
      _showErrorDialog(e.toString());
    } catch (e) {
      print(e);
      const errorMessage = '未知错误，请稍后再试.';
      _showErrorDialog(errorMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(
            left: ScreenUtil().setWidth(100),
            right: ScreenUtil().setWidth(100),
            top: ScreenUtil().setHeight(100),
            bottom: mediaQuery.viewInsets.bottom + ScreenUtil().setHeight(100),
          ),
          child: Column(
            children: <Widget>[
              TextFormField(
                decoration: InputDecoration(labelText: '用户名'),
                keyboardType: TextInputType.text,
                validator: (value) => value.isEmpty ? '无效的用户名!' : null,
                onSaved: (value) {
                  _authData['username'] = value;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: '密码'),
                obscureText: true,
                controller: _passwordController,
                validator: (value) => value.isEmpty ? '密码不能为空!' : null,
                onSaved: (value) {
                  _authData['password'] = value;
                },
              ),
              SizedBox(
                height: 20,
              ),
              _isLoading
                  ? CircularProgressIndicator()
                  // 后面替换成自定义按钮
                  // child: Container(
                  //   padding: EdgeInsets.all(12.0),
                  //   decoration: BoxDecoration(
                  //     color: Theme.of(context).buttonColor,
                  //     borderRadius: BorderRadius.circular(8.0),
                  //   ),
                  //   child: Text('My Button'),
                  // ),
                  : RaisedButton(
                      child: Text(_authMode == AuthMode.Login ? '登录' : '注册'),
                      onPressed: _submit,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding:
                          EdgeInsets.symmetric(horizontal: 30.0, vertical: 8.0),
                      color: Theme.of(context).primaryColor,
                      textColor:
                          Theme.of(context).primaryTextTheme.button.color,
                    ),
              // FlatButton(
              //   child: Text(
              //       '${_authMode == AuthMode.Login ? 'SIGNUP' : 'LOGIN'} INSTEAD'),
              //   // onPressed: _switchAuthMode,
              //   padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 4),
              //   materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              //   textColor: Theme.of(context).primaryColor,
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
