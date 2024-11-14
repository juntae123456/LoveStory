import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart'; // SharedPreferences 임포트
import 'main_page.dart';
import 'calender_page.dart';
import 'map_page.dart';
import 'list_page.dart';
import 'login_page.dart'; // 로그인 페이지 임포트
import 'dart:io';

class SettingsPage extends StatefulWidget {
  final String userId;
  final String userName;
  final String backgroundImageUrl;
  final String firstImageUrl;
  final String secondImageUrl;
  final String partnerName;
  final String partnerId;

  const SettingsPage({
    super.key,
    required this.userId,
    required this.userName,
    required this.backgroundImageUrl,
    required this.firstImageUrl,
    required this.secondImageUrl,
    required this.partnerName,
    required this.partnerId,
  });

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late String backgroundImageUrl;
  late String firstImageUrl;
  late String secondImageUrl;
  bool isLoading = false; // 로딩 상태 변수 추가

  @override
  void initState() {
    super.initState();
    backgroundImageUrl = widget.backgroundImageUrl;
    firstImageUrl = widget.firstImageUrl;
    secondImageUrl = widget.secondImageUrl;
  }

  void _onItemTapped(BuildContext context, int index) {
    String backgroundImageUrl = this.backgroundImageUrl.isNotEmpty
        ? this.backgroundImageUrl
        : 'assets/home_image.png';

    if (index == 0) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => MainPage(
            userId: widget.userId,
            userName: widget.userName,
            partnerName: widget.partnerName,
            backgroundImageUrl: backgroundImageUrl,
            firstImageUrl: firstImageUrl,
            secondImageUrl: secondImageUrl,
            partnerId: widget.partnerId,
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
            userId: widget.userId,
            userName: widget.userName,
            backgroundImageUrl: backgroundImageUrl,
            firstImageUrl: firstImageUrl,
            secondImageUrl: secondImageUrl,
            partnerName: widget.partnerName,
            partnerId: widget.partnerId,
          ),
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
          pageBuilder: (context, animation, secondaryAnimation) => MapPage(
            userId: widget.userId,
            backgroundImageUrl: backgroundImageUrl,
            firstImageUrl: firstImageUrl,
            secondImageUrl: secondImageUrl,
            userName: widget.userName,
            partnerName: widget.partnerName,
            partnerId: widget.partnerId,
          ),
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
          pageBuilder: (context, animation, secondaryAnimation) => ListPage(
            userId: widget.userId,
            backgroundImageUrl: backgroundImageUrl,
            firstImageUrl: firstImageUrl,
            secondImageUrl: secondImageUrl,
            userName: widget.userName,
            partnerName: widget.partnerName,
            partnerId: widget.partnerId,
          ),
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

  Future<void> _pickAndUploadImage(
      BuildContext context,
      String type,
      String userId,
      String userName,
      String partnerName,
      Function(String, String) callback) async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      setState(() {
        isLoading = true; // 업로드 시작 시 로딩 상태를 true로 설정
      });
      try {
        // 기존 이미지 URL 가져오기
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();
        Map<String, dynamic>? userData =
            userDoc.data() as Map<String, dynamic>?;

        String? existingImageUrl;
        if (userData != null) {
          if (type == 'main') {
            existingImageUrl = userData['mainImageUrl'];
          } else if (type == 'profile') {
            existingImageUrl = userData['profileUrl'];
          }
        }
        if (existingImageUrl != null && existingImageUrl.isNotEmpty) {
          await FirebaseStorage.instance.refFromURL(existingImageUrl).delete();
        }

        // 새로운 이미지 업로드
        final storageRef = FirebaseStorage.instance.ref().child(
            '$userName/$partnerName/$type/${DateTime.now().millisecondsSinceEpoch}_${pickedFile.name}');
        await storageRef.putFile(imageFile);
        final imageUrl = await storageRef.getDownloadURL();

        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .update({
          type == 'main' ? 'mainImageUrl' : 'profileUrl': imageUrl,
        });

        callback(type, imageUrl);

        // 이미지 URL 업데이트
        if (mounted) {
          setState(() {
            if (type == 'main') {
              backgroundImageUrl = imageUrl;
            } else if (type == 'profile') {
              firstImageUrl = imageUrl;
            }
            isLoading = false; // 업로드 완료 시 로딩 상태를 false로 설정
          });
        }
      } catch (e) {
        print('Error uploading image: $e');
        if (mounted) {
          setState(() {
            isLoading = false; // 업로드 실패 시 로딩 상태를 false로 설정
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('이미지 업로드에 실패했습니다.')),
          );
        }
      }
    } else {
      print('No image selected.');
      if (mounted) {
        setState(() {
          isLoading = false; // 이미지 선택 취소 시 로딩 상태를 false로 설정
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('이미지가 선택되지 않았습니다.')),
        );
      }
    }
  }

  void showProfileImageUploadDialog(BuildContext context, String userId,
      String userName, String partnerName, Function(String, String) callback) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('프로필 이미지 업로드'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () async {
                  await _pickAndUploadImage(context, 'profile', userId,
                      userName, partnerName, callback);
                  if (mounted) {
                    Navigator.of(context).pop();
                  }
                },
                child: Text('$userName 프로필 이미지 업로드'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (mounted) {
                  Navigator.of(context).pop();
                }
              },
              child: const Text('취소'),
            ),
          ],
        );
      },
    );
  }

  void showBackgroundImageUploadDialog(BuildContext context, String userId,
      String userName, String partnerName, Function(String, String) callback) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('배경 이미지 업로드'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () async {
                  await _pickAndUploadImage(
                      context, 'main', userId, userName, partnerName, callback);
                  if (mounted) {
                    Navigator.of(context).pop();
                  }
                },
                child: const Text('배경 이미지 업로드'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (mounted) {
                  Navigator.of(context).pop();
                }
              },
              child: const Text('취소'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _login(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', userId);
    _fetchUserData(userId);
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
          secondImageUrl = partnerData?['profileImageUrl'] ??
              'assets/woman_profile_image.png';
        }
      }

      if (mounted) {
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
      }
    }
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
      userIdController.text = userDoc['userId'];
      userNameController.text = userDoc['lastName'];
      partnerIdController.text = userDoc['partnerId'];
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('프로필 수정'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: userIdController,
                decoration: const InputDecoration(labelText: '아이디'),
                readOnly: true,
              ),
              TextField(
                controller: userNameController,
                decoration: const InputDecoration(labelText: '이름'),
              ),
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(labelText: '비밀번호 변경'),
                obscureText: true,
              ),
              TextField(
                controller: partnerIdController,
                decoration: const InputDecoration(labelText: '상대방 아이디'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (mounted) {
                  Navigator.of(context).pop();
                }
              },
              child: const Text('취소'),
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
                }).then((_) {
                  print('Profile updated successfully.');
                }).catchError((error) {
                  print('Failed to update profile: $error');
                });
                if (mounted) {
                  Navigator.of(context).pop();
                }
              },
              child: const Text('저장'),
            ),
          ],
        );
      },
    );
  }

  void showDateChangeDialog(BuildContext context) async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (selectedDate != null) {
      // Firestore에 날짜 업데이트 로직 추가
      FirebaseFirestore.instance.collection('users').doc(widget.userId).update({
        'startDate': selectedDate,
      }).then((_) {
        print('Date updated successfully.');
      }).catchError((error) {
        print('Failed to update date: $error');
      });

      // 상대방의 시작 날짜도 업데이트
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .get();
      if (userDoc.exists) {
        String partnerId = userDoc['partnerId'];
        FirebaseFirestore.instance.collection('users').doc(partnerId).update({
          'startDate': selectedDate,
        }).then((_) {
          print('Partner date updated successfully.');
        }).catchError((error) {
          print('Failed to update partner date: $error');
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('날짜가 변경되었습니다: ${selectedDate.toLocal()}')),
        );
      }
    } else {
      print('No date selected.');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('날짜가 선택되지 않았습니다.')),
        );
      }
    }
  }

  Future<void> _logout(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('userId'); // 사용자 세션 정보 삭제
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage(onLogin: _login)),
        );
      }
    } catch (e) {
      print('Error logging out: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('로그아웃에 실패했습니다.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('설정'),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                height: 100, // 광고 배너를 위한 공간
                color: Colors.grey[300],
                child: const Center(child: Text('광고 배너')),
              ),
              Expanded(
                child: ListView(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.edit),
                      title: const Text('프로필 수정'),
                      onTap: () {
                        showProfileEditDialog(context, widget.userId);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.photo_camera),
                      title: const Text('프로필 사진 변경'),
                      onTap: () {
                        showProfileImageUploadDialog(context, widget.userId,
                            widget.userName, widget.partnerName, (type, url) {
                          // 프로필 사진 변경 로직 추가
                        });
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.image),
                      title: const Text('배경 사진 변경'),
                      onTap: () {
                        showBackgroundImageUploadDialog(context, widget.userId,
                            widget.userName, widget.partnerName, (type, url) {
                          // 배경 사진 변경 로직 추가
                        });
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.date_range),
                      title: const Text('날짜 변경'),
                      onTap: () {
                        showDateChangeDialog(context);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.logout),
                      title: const Text('로그아웃'),
                      onTap: () => _logout(context),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (isLoading)
            const Center(
              child: CircularProgressIndicator(),
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
