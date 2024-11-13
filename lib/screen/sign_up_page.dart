import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_page.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _userIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();

  Future<void> _signUp() async {
    String userId = _userIdController.text.trim();
    String password = _passwordController.text.trim();
    String firstName = _firstNameController.text.trim();
    String lastName = _lastNameController.text.trim();

    if (userId.isEmpty ||
        password.isEmpty ||
        firstName.isEmpty ||
        lastName.isEmpty) {
      _showErrorDialog('모든 필드를 입력해주세요.');
      return;
    }

    await FirebaseFirestore.instance.collection('users').doc(userId).set({
      'userId': userId,
      'password': password,
      'firstName': firstName,
      'lastName': lastName,
    });

    if (!mounted) return; // BuildContext 사용 전 mounted 체크
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => LoginPage(
          onLogin: (userId) {
            // 로그인 시 수행할 작업
            print('User logged in: $userId');
          },
        ),
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, // 앱바 뒤로 배경이 연장되도록 설정
      appBar: AppBar(
        title: const Text('회원가입'),
        backgroundColor: Colors.transparent, // 앱바 배경을 투명하게 설정
        elevation: 0, // 앱바 그림자 제거
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/home_image.png', // 로컬 이미지 경로
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0), // 배경 흐리게 설정
              child: Container(
                color: Colors.black.withOpacity(0), // 투명한 컨테이너
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _userIdController,
                    decoration: const InputDecoration(
                      labelText: '아이디',
                      labelStyle: TextStyle(
                        fontFamily: 'CuteFont',
                        fontSize: 20,
                      ), // 귀여운 폰트 스타일
                      border: OutlineInputBorder(), // 테두리 추가
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: '비밀번호',
                      labelStyle: TextStyle(
                          fontFamily: 'CuteFont', fontSize: 20), // 귀여운 폰트 스타일
                      border: OutlineInputBorder(), // 테두리 추가
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _firstNameController,
                    decoration: const InputDecoration(
                      labelText: '성',
                      labelStyle: TextStyle(
                          fontFamily: 'CuteFont', fontSize: 20), // 귀여운 폰트 스타일
                      border: OutlineInputBorder(), // 테두리 추가
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _lastNameController,
                    decoration: const InputDecoration(
                      labelText: '이름',
                      labelStyle: TextStyle(
                          fontFamily: 'CuteFont', fontSize: 20), // 귀여운 폰트 스타일
                      border: OutlineInputBorder(), // 테두리 추가
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _signUp,
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
                              fontSize: 20,
                              fontFamily: 'CuteFont'), // 귀여운 폰트 스타일
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
