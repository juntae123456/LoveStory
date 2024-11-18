import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_page.dart';

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
  }
}

Future<void> logout(BuildContext context) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage(onLogin: _login)),
    );
  } catch (e) {
    print('Error logging out: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('로그아웃에 실패했습니다.')),
    );
  }
}
