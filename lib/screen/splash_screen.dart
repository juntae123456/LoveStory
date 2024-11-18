import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lovestory/screen/home_page.dart';
import 'main_page.dart';

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
    _checkLoggedInUser();
  }

  Future<void> _checkLoggedInUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    if (userId != null) {
      _fetchUserData(userId);
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const MyHomePage(
            title: 'Home Page',
          ),
        ),
      );
    }
  }

  Future<void> _fetchUserData(String userId) async {
    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();

    if (userDoc.exists) {
      var userData = userDoc.data() as Map<String, dynamic>?;
      String backgroundImageUrl = userData?['mainImageUrl'] ?? '';
      String userName = userData?['lastName'] ?? 'Unknown';
      String firstImageUrl =
          userData?['profileUrl'] ?? 'assets/man_profile_image.png';

      String partnerName = 'Unknown';
      String secondImageUrl = 'assets/woman_profile_image.png';
      String partnerId = userData?['partnerId'] ?? 'Unknown';

      if (userData != null && userData.containsKey('partnerId')) {
        String partnerId = userData['partnerId'];
        DocumentSnapshot partnerDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(partnerId)
            .get();

        if (partnerDoc.exists) {
          var partnerData = partnerDoc.data() as Map<String, dynamic>?;
          partnerName = partnerData?['lastName'] ?? 'Unknown';
          secondImageUrl =
              partnerData?['profileUrl'] ?? 'assets/woman_profile_image.png';
        }
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MainPage(
            userId: userId,
            backgroundImageUrl: backgroundImageUrl.isNotEmpty
                ? backgroundImageUrl
                : 'assets/home_image.png', // 기본 배경 이미지
            userName: userName,
            firstImageUrl: firstImageUrl,
            partnerName: partnerName,
            secondImageUrl: secondImageUrl,
            partnerId: partnerId,
          ),
        ),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const MyHomePage(
            title: 'Home Page',
          ),
        ),
      );
    }
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
