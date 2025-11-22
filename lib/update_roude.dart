// Update main.dart routes
import 'package:flutter/material.dart';
import 'package:zottz_ot/device_scan.dart';
import 'package:zottz_ot/led_sound.dart';
import 'package:zottz_ot/main_activity.dart';
import 'package:zottz_ot/manual_screan.dart';
import 'package:zottz_ot/signin.dart';
import 'package:zottz_ot/signup.dart';
import 'package:zottz_ot/splash_screan.dart';
import 'package:zottz_ot/statistic_screan.dart';

class ZottzApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ZOTTZ OT',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(),
        '/signin': (context) => SignInScreen(),
        '/signup': (context) => SignUpScreen(),
        '/device_scan': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as String;
          return DeviceScanScreen(userName: args);
        },
        '/led_sound': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return LedSoundScreen(
            userName: args['userName'],
            device: args['device'],
          );
        },
        '/ot_control': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return OTControlScreen(settings: args);
        },
        '/statistics': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as String;
          return StatisticsScreen(userName: args);
        },
        '/manual': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as String;
          return ManualScreen(userName: args);
        },
      },
    );
  }
}