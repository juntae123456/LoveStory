import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_page.dart';
import 'sign_up_page.dart';
import 'main_page.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  void _login(String userId) {
    _fetchUserData(userId);
  }

  @override
  void initState() {
    super.initState();
    // checkLoggedInUser(); // 로컬 저장 확인 부분 주석 처리
  }

  Future<void> _fetchUserData(String userId) async {
    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();

    if (userDoc.exists) {
      var userData = userDoc.data() as Map<String, dynamic>?;
      String backgroundImageUrl = userData?['backgroundImageUrl'] ?? '';
      String userName = userData?['lastName'] ?? 'Unknown';
      String firstImageUrl =
          userData?['profileImageUrl'] ?? 'assets/man_profile_image.png';

      String partnerName = 'Unknown';
      String secondImageUrl = 'assets/woman_profile_image.png';

      if (userData != null && userData.containsKey('partnerId')) {
        String partnerId = userData['partnerId'];
        DocumentSnapshot partnerDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(partnerId)
            .get();

        if (partnerDoc.exists) {
          var partnerData = partnerDoc.data() as Map<String, dynamic>?;
          partnerName = partnerData?['lastName'] ?? 'Unknown';
          secondImageUrl = partnerData?['profileImageUrl'] ??
              'assets/woman_profile_image.png';
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
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/home_image.png', // 로컬 이미지 경로
              fit: BoxFit.cover,
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    LoginPage(onLogin: _login),
                            transitionsBuilder: (context, animation,
                                secondaryAnimation, child) {
                              return FadeTransition(
                                opacity: animation,
                                child: child,
                              );
                            },
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.pinkAccent
                            .withOpacity(0.8), // 버튼 배경색에 투명도 적용
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15), // 둥근 모서리
                        ),
                        padding: const EdgeInsets.symmetric(
                            vertical: 15), // 버튼 높이 조정
                      ),
                      icon: const Icon(Icons.login, size: 24), // 아이콘 추가
                      label: const Text(
                        '로그인',
                        style: TextStyle(
                            fontSize: 20, fontFamily: 'CuteFont'), // 귀여운 폰트 스타일
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20), // 버튼 사이 간격
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    SignUpPage(),
                            transitionsBuilder: (context, animation,
                                secondaryAnimation, child) {
                              return FadeTransition(
                                opacity: animation,
                                child: child,
                              );
                            },
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.lightBlueAccent
                            .withOpacity(0.8), // 버튼 배경색에 투명도 적용
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15), // 둥근 모서리
                        ),
                        padding: const EdgeInsets.symmetric(
                            vertical: 15), // 버튼 높이 조정
                      ),
                      icon: const Icon(Icons.person_add, size: 24), // 아이콘 추가
                      label: const Text(
                        '회원가입',
                        style: TextStyle(
                            fontSize: 20, fontFamily: 'CuteFont'), // 귀여운 폰트 스타일
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 120), // 버튼과 화면 하단 사이의 간격
              ],
            ),
          ),
        ],
      ),
    );
  }
}
