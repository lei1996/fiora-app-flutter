import 'package:fiora_app_flutter/screens/welcome.dart';
import 'package:fiora_app_flutter/widgets/login.dart';
import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';

import 'package:provider/provider.dart';

import './providers/auth.dart';
import './screens/home.dart';
import './screens/chat.dart';
import './screens/splash_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => Auth()),
      ],
      child: Consumer<Auth>(
        builder: (ctx, auth, _) => OKToast(
          child: MaterialApp(
            title: 'Flutter Fiora',
            theme: ThemeData(
              primarySwatch: Colors.blueGrey,
              scaffoldBackgroundColor: Colors.white,
              accentColor: Colors.grey,
              platform: TargetPlatform.iOS,
              pageTransitionsTheme: PageTransitionsTheme(
                builders: {
                  TargetPlatform.android: CupertinoPageTransitionsBuilder(),
                  TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
                },
              ),
            ),
            home: auth.isAuth
                ? HomePage()
                : FutureBuilder(
                    future: auth.tryAutoLogin(),
                    builder: (ctx, authResultSnapshot) =>
                        authResultSnapshot.connectionState ==
                                ConnectionState.waiting
                            ? SplashScreen()
                            : Welcome(),
                  ),
            // initialRoute: '/',
            routes: {
              HomePage.routeName: (ctx) => HomePage(),
              ChatPage.routeName: (ctx) => ChatPage(),
              Welcome.routeName: (ctx) => Welcome(),
              LoginPage.routeName: (ctx) => LoginPage(),
            },
          ),
        ),
      ),
    );
  }
}
