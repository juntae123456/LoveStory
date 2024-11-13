import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> fetchUserName(String userId, Function(String) callback) async {
  try {
    DocumentSnapshot doc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    callback(doc['name']);
  } catch (e) {
    print('Error fetching user name: $e');
  }
}

Future<void> fetchImages(
    String userId, Function(String, Map<String, String>) callback) async {
  try {
    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    String mainImageUrl = userDoc['mainImageUrl'];

    DocumentSnapshot leeDoc =
        await FirebaseFirestore.instance.collection('users').doc('lee').get();
    String firstImageUrl = leeDoc['profileUrl'];

    DocumentSnapshot joDoc =
        await FirebaseFirestore.instance.collection('users').doc('jo').get();
    String secondImageUrl = joDoc['profileUrl'];

    callback(mainImageUrl, {'lee': firstImageUrl, 'jo': secondImageUrl});
  } catch (e) {
    print('Error fetching images: $e');
  }
}
