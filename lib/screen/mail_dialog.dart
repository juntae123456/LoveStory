import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lottie/lottie.dart';

void showMailDialog(
    BuildContext context, String userId, String userName, String partnerId) {
  final TextEditingController _mailController = TextEditingController();

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(
          '내일로 편지',
          style: TextStyle(
            fontFamily: 'prettendardBlack',
            shadows: [
              Shadow(
                offset: Offset(1.0, 1.0),
                blurRadius: 3.0,
                color: Color.fromARGB(255, 0, 0, 0),
              ),
            ],
          ),
        ),
        content: Container(
          width: double.maxFinite,
          child: TextField(
            controller: _mailController,
            maxLines: 20,
            decoration: InputDecoration(
              hintText: '내일 전할 편지를 작성해주세요.',
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('취소',
                style: TextStyle(
                  color: Colors.black,
                  fontFamily: 'PretendardThin',
                )),
          ),
          TextButton(
            onPressed: () async {
              if (_mailController.text.isNotEmpty) {
                await FirebaseFirestore.instance
                    .collection('messages')
                    .doc(userId)
                    .collection('userMessages')
                    .add({
                  'content': _mailController.text,
                  'timestamp': FieldValue.serverTimestamp(),
                  'userId': userId,
                  'userName': userName,
                  'partnerId': partnerId,
                });
                Navigator.of(context).pop();
                _showLottieAnimation(context);
              }
            },
            child: Text('보내기',
                style: TextStyle(
                  color: Colors.black,
                  fontFamily: 'PretendardThin',
                )),
          ),
        ],
      );
    },
  );
}

void _showLottieAnimation(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      Future.delayed(Duration(milliseconds: 2700), () {
        Navigator.of(context).pop();
      });
      return Center(
        child: Lottie.asset(
          'assets/push_mail.json',
          width: 200,
          height: 200,
        ),
      );
    },
  );
}
