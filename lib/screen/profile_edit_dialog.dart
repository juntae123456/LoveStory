import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void showProfileEditDialog(BuildContext context, String userId) async {
  final TextEditingController userIdController = TextEditingController();
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController partnerIdController = TextEditingController();

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
              Navigator.of(context).pop();
            },
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
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
              Navigator.of(context).pop();
            },
            child: const Text('저장'),
          ),
        ],
      );
    },
  );
}
