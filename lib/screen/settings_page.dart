import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'main_page.dart';
import 'calender_page.dart';
import 'map_page.dart';
import 'list_page.dart';
import 'dart:io';

class SettingsPage extends StatelessWidget {
  final String userId;
  final String userName;
  final String backgroundImageUrl;
  final String firstImageUrl;
  final String secondImageUrl;

  const SettingsPage({
    super.key,
    required this.userId,
    required this.userName,
    required this.backgroundImageUrl,
    required this.firstImageUrl,
    required this.secondImageUrl,
  });

  void _onItemTapped(BuildContext context, int index) {
    if (index == 0) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => MainPage(
            userId: userId,
            userName: userName,
            partnerName: 'partnerName', // Add the required argument here
            backgroundImageUrl: backgroundImageUrl,
            firstImageUrl: firstImageUrl,
            secondImageUrl: secondImageUrl,
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
        ),
      );
    } else if (index == 1) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => CalendarPage(
              userId: userId,
              userName: userName,
              backgroundImageUrl: backgroundImageUrl,
              firstImageUrl: firstImageUrl,
              secondImageUrl: secondImageUrl),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
        ),
      );
    } else if (index == 2) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              MapPage(userId: userId, backgroundImageUrl: backgroundImageUrl),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
        ),
      );
    } else if (index == 3) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              ListPage(userId: userId, backgroundImageUrl: backgroundImageUrl),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
        ),
      );
    }
  }

  Future<void> _pickAndUploadImage(BuildContext context, String type,
      String userId, Function(String, String) callback) async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      try {
        final storageRef = FirebaseStorage.instance.ref().child(
            '$userId/$type/${DateTime.now().millisecondsSinceEpoch}_${pickedFile.name}');
        await storageRef.putFile(imageFile);
        final imageUrl = await storageRef.getDownloadURL();

        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .update({
          type == 'main' ? 'mainImageUrl' : 'profileUrl': imageUrl,
        });

        callback(type, imageUrl);
      } catch (e) {
        print('Error uploading image: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('이미지 업로드에 실패했습니다.')),
        );
      }
    }
  }

  void showProfileImageUploadDialog(
      BuildContext context, String userId, Function(String, String) callback) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('프로필 이미지 업로드'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () async {
                  await _pickAndUploadImage(context, 'face', 'lee', callback);
                  Navigator.of(context).pop();
                },
                child: Text('준태 프로필 이미지 업로드'),
              ),
              ElevatedButton(
                onPressed: () async {
                  await _pickAndUploadImage(context, 'face', 'jo', callback);
                  Navigator.of(context).pop();
                },
                child: Text('은혜 프로필 이미지 업로드'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('취소'),
            ),
          ],
        );
      },
    );
  }

  void showBackgroundImageUploadDialog(
      BuildContext context, String userId, Function(String, String) callback) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('배경 이미지 업로드'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () async {
                  await _pickAndUploadImage(context, 'main', userId, callback);
                  Navigator.of(context).pop();
                },
                child: Text('배경 이미지 업로드'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('취소'),
            ),
          ],
        );
      },
    );
  }

  void showProfileEditDialog(BuildContext context, String userId) async {
    final TextEditingController userIdController = TextEditingController();
    final TextEditingController userNameController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    final TextEditingController partnerIdController = TextEditingController();

    // Firestore에서 사용자 정보 가져오기
    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();

    if (userDoc.exists) {
      userIdController.text = userDoc['username'];
      userNameController.text = userDoc['lastName'];
      partnerIdController.text = userDoc['partnerId'];
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('프로필 수정'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: userIdController,
                decoration: InputDecoration(labelText: '아이디'),
                readOnly: true,
              ),
              TextField(
                controller: userNameController,
                decoration: InputDecoration(labelText: '이름'),
              ),
              TextField(
                controller: passwordController,
                decoration: InputDecoration(labelText: '비밀번호 변경'),
                obscureText: true,
              ),
              TextField(
                controller: partnerIdController,
                decoration: InputDecoration(labelText: '파트너 아이디'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('취소'),
            ),
            TextButton(
              onPressed: () {
                // 프로필 수정 로직 추가
                FirebaseFirestore.instance
                    .collection('users')
                    .doc(userId)
                    .update({
                  'lastName': userNameController.text,
                  'password': passwordController.text,
                  'partnerId': partnerIdController.text,
                });
                Navigator.of(context).pop();
              },
              child: Text('저장'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('설정'),
      ),
      body: Column(
        children: [
          Container(
            height: 100, // 광고 배너를 위한 공간
            color: Colors.grey[300],
            child: Center(child: Text('광고 배너')),
          ),
          Expanded(
            child: ListView(
              children: [
                ListTile(
                  leading: Icon(Icons.edit),
                  title: Text('프로필 수정'),
                  onTap: () {
                    showProfileEditDialog(context, userId);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.photo_camera),
                  title: Text('프로필 사진 변경'),
                  onTap: () {
                    showProfileImageUploadDialog(context, userId, (type, url) {
                      // 프로필 사진 변경 로직 추가
                    });
                  },
                ),
                ListTile(
                  leading: Icon(Icons.image),
                  title: Text('배경 사진 변경'),
                  onTap: () {
                    showBackgroundImageUploadDialog(context, userId,
                        (type, url) {
                      // 배경 사진 변경 로직 추가
                    });
                  },
                ),
                ListTile(
                  leading: Icon(Icons.date_range),
                  title: Text('날짜 변경'),
                  onTap: () {
                    // 날짜 변경 로직 추가
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: '캘린더',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: '지도',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: '리스트',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: '설정',
          ),
        ],
        currentIndex: 4, // 설정 페이지의 인덱스
        selectedItemColor: Colors.amber[800],
        unselectedItemColor: Colors.grey,
        onTap: (index) => _onItemTapped(context, index),
      ),
    );
  }
}
