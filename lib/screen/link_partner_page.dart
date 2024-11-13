import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'main_page.dart';
import 'dart:ui';

class LinkPartnerPage extends StatefulWidget {
  final String userId;

  const LinkPartnerPage({super.key, required this.userId});

  @override
  State<LinkPartnerPage> createState() => _LinkPartnerPageState();
}

class _LinkPartnerPageState extends State<LinkPartnerPage> {
  final TextEditingController _partnerIdController = TextEditingController();

  Future<void> _linkPartner() async {
    String partnerId = _partnerIdController.text.trim();

    if (partnerId.isEmpty) {
      _showErrorDialog('상대방의 아이디를 입력해주세요.');
      return;
    }

    DocumentSnapshot partnerDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(partnerId)
        .get();

    if (partnerDoc.exists) {
      var userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .get();

      var userData = userDoc.data() as Map<String, dynamic>?;

      if (userData != null &&
          userData.containsKey('partnerId') &&
          userData['partnerId'] == partnerId) {
        _fetchUserData(widget.userId);
      } else {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.userId)
            .update({
          'partnerId': partnerId,
        });
        _showInfoDialog('상대방의 아이디를 연결하고 있습니다.');
      }
    } else {
      _showErrorDialog('상대방의 아이디가 존재하지 않습니다.');
    }
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

  void _showInfoDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Info'),
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
        title: const Text('Link Partner'),
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
                    controller: _partnerIdController,
                    decoration: const InputDecoration(
                      labelText: 'Partner ID',
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
                        onPressed: _linkPartner,
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
                        icon: const Icon(Icons.link, size: 24), // 아이콘 추가
                        label: const Text(
                          'Link Partner',
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
