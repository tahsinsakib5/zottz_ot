// main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:zottz_ot/device_scan.dart';
import 'package:zottz_ot/firebase_options.dart';
import 'package:zottz_ot/signin.dart';
import 'package:zottz_ot/signup.dart';
import 'package:zottz_ot/splash_screan.dart';
import 'package:zottz_ot/statistic_screan.dart';

// import 'screens/splash_screen.dart';
// import 'screens/signin_screen.dart';
// import 'screens/signup_screen.dart';
// import 'screens/device_scan_screen.dart';
// import 'screens/statistics_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
   options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(ZottzApp());
}

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
        '/device_scan': (context) => DeviceScanScreen(userName: 'dskib',),
        '/statistics': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as String;
          return StatisticsScreen(userName: args);
        },
      },
      // home: SplashScreen(),
    );
  }
}