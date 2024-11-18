import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void showDateChangeDialog(BuildContext context, String userId) async {
  DateTime? selectedDate = await showDatePicker(
    context: context,
    initialDate: DateTime.now(),
    firstDate: DateTime(2000),
    lastDate: DateTime(2100),
  );

  if (selectedDate != null) {
    FirebaseFirestore.instance.collection('users').doc(userId).update({
      'startDate': selectedDate,
    }).then((_) {
      print('Date updated successfully.');
    }).catchError((error) {
      print('Failed to update date: $error');
    });

    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
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

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('날짜가 변경되었습니다: ${selectedDate.toLocal()}')),
    );
  } else {
    print('No date selected.');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('날짜가 선택되지 않았습니다.')),
    );
  }
}
