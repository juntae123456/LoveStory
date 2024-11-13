import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'dart:async';
import 'package:lovestory/screen/home_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    loadResources();
  }

  Future<void> loadResources() async {
    await Future.delayed(Duration(seconds: 4)); // 스플래쉬 화면을 4초 동안 표시

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const MyHomePage(
          title: 'Home Page',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // 배경색을 흰색으로 설정
      body: Stack(
        children: [
          Positioned(
            top: 80, // 원하는 만큼 위로 이동
            left: 0,
            right: 0,
            child: Image.asset(
              'assets/you.gif',
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            bottom: 20,
            right: 0,
            child: Lottie.asset(
              'assets/splash_animation.json',
              width: 300, // 크기를 더 크게 조정
              height: 300, // 크기를 더 크게 조정
            ),
          ),
        ],
      ),
    );
  }
}
