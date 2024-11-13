import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';

Future<void> _pickAndUploadImage(BuildContext context, String type,
    String userId, Function(String, String) callback) async {
  final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
  if (pickedFile != null) {
    File imageFile = File(pickedFile.path);
    try {
      final storageRef = FirebaseStorage.instance.ref().child(
          '$userId/$type/${DateTime.now().millisecondsSinceEpoch}_${pickedFile.name}');
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
  }
}

void showImageUploadDialog(
    BuildContext context, String userId, Function(String, String) callback) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('이미지 업로드'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () async {
                await _pickAndUploadImage(context, 'main', userId, callback);
                Navigator.of(context).pop();
              },
              child: Text('메인 이미지 업로드'),
            ),
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
