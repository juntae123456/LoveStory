import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';

Future<void> _pickAndUploadImage(
    BuildContext context,
    String type,
    String userId,
    String userName,
    String partnerName,
    Function(String, String) callback) async {
  final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
  if (pickedFile != null) {
    File imageFile = File(pickedFile.path);
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      Map<String, dynamic>? userData = userDoc.data() as Map<String, dynamic>?;

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

      final storageRef = FirebaseStorage.instance.ref().child(
          '$userName/$partnerName/$type/${DateTime.now().millisecondsSinceEpoch}_${pickedFile.name}');
      await storageRef.putFile(imageFile);
      final imageUrl = await storageRef.getDownloadURL();

      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        type == 'main' ? 'mainImageUrl' : 'profileUrl': imageUrl,
      });

      callback(type, imageUrl);
    } catch (e) {
      print('Error uploading image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('이미지 업로드에 실패했습니다.')),
      );
    }
  } else {
    print('No image selected.');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('이미지가 선택되지 않았습니다.')),
    );
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
                await _pickAndUploadImage(context, 'profile', userId, userName,
                    partnerName, callback);
                Navigator.of(context).pop();
              },
              child: Text('$userName 프로필 이미지 업로드'),
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
                Navigator.of(context).pop();
              },
              child: const Text('배경 이미지 업로드'),
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
        ],
      );
    },
  );
}
