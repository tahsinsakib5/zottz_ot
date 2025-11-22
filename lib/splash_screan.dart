// screens/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:zottz_ot/signin.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _playWelcomeSound();
    _navigateToSignIn();
  }

  Future<void> _playWelcomeSound() async {
    try {
      await _audioPlayer.setAsset('assets/audio/welcome.mp3');
      await _audioPlayer.play();
    } catch (e) {
      print("Error playing sound: $e");
    }
  }

  void _navigateToSignIn() {
    Future.delayed(Duration(seconds: 3), () {
      // Navigator.pushReplacementNamed(context, '/signin');
      Navigator.push(context,MaterialPageRoute(builder: (context) => SignInScreen(),));
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FlutterLogo(size: 100),
            SizedBox(height: 20),
            Text(
              'ZOTTZ OT',
              style: TextStyle(
                fontSize: 32,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}