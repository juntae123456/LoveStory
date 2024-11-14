import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:ui'; // ImageFilter를 사용하기 위해 추가
import 'calender_add_page.dart';

class EventDetailPage extends StatelessWidget {
  final String userId;
  final String userName;
  final String title;
  final String text;
  final String location;
  final List<String> imageUrls; // 여러 장의 이미지 URL을 저장하는 리스트
  final DateTime date;
  final String backgroundImageUrl; // backgroundImageUrl 매개변수 추가
  final String firstImageUrl;
  final String secondImageUrl;
  final String eventId; // eventId 매개변수 추가
  final String partnerName;
  final String partnerId;

  const EventDetailPage({
    super.key,
    required this.userId,
    required this.userName,
    required this.title,
    required this.text,
    required this.location,
    required this.imageUrls, // 여러 장의 이미지 URL을 저장하는 리스트
    required this.date,
    required this.backgroundImageUrl, // backgroundImageUrl 매개변수 추가
    required this.firstImageUrl,
    required this.secondImageUrl,
    required this.eventId, // eventId 매개변수 추가
    required this.partnerName,
    required this.partnerId,
  });

  Future<String> _getUserProfileImageUrl(String userId) async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      return userDoc['profileUrl'] as String;
    } catch (e) {
      print('Error fetching user profile image URL: $e');
      return '';
    }
  }

  Future<void> _deleteEvent(BuildContext context) async {
    try {
      await FirebaseFirestore.instance
          .collection('events')
          .doc(eventId)
          .delete();
      Navigator.of(context).pop(true); // 삭제 후 이전 화면으로 돌아가기
    } catch (e) {
      print('Error deleting event: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('삭제 중 오류가 발생했습니다.')),
      );
    }
  }

  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('삭제 확인'),
          content: Text('이 일정을 삭제하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 팝업 닫기
              },
              child: Text('아니오'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 팝업 닫기
                _deleteEvent(context); // 이벤트 삭제
              },
              child: Text('예'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('일정 상세보기'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CalenderAddPage(
                    userId: userId,
                    userName: userName,
                    startDate: date,
                    endDate: date,
                    isEditMode: true,
                    eventId: eventId,
                    partnerId: partnerId,
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              _showDeleteConfirmationDialog(context);
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          if (backgroundImageUrl.isNotEmpty)
            Positioned.fill(
              child: backgroundImageUrl.startsWith('http')
                  ? Image.network(
                      backgroundImageUrl,
                      fit: BoxFit.cover,
                    )
                  : Image.asset(
                      backgroundImageUrl,
                      fit: BoxFit.cover,
                    ),
            ),
          if (backgroundImageUrl.isNotEmpty)
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0), // 흐림 효과 적용
                child: Container(
                  color: Colors.black.withOpacity(0), // 투명한 컨테이너
                ),
              ),
            ),
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(
                  top: 80.0, left: 20.0, right: 20.0), // 상단에 100 패딩 추가
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FutureBuilder<String>(
                    future: _getUserProfileImageUrl(userId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      } else if (snapshot.hasError ||
                          !snapshot.hasData ||
                          snapshot.data!.isEmpty) {
                        return Row(
                          children: [
                            CircleAvatar(
                              backgroundImage: AssetImage(
                                  'assets/default_profile.png'), // 기본 프로필 이미지
                              radius: 20,
                            ),
                            SizedBox(width: 10),
                            Text(
                              '올린 사람: $userName',
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'GowunDodum-Regular',
                                fontSize: 17, // 글자 크기 증가
                              ),
                            ),
                          ],
                        );
                      } else {
                        return Row(
                          children: [
                            CircleAvatar(
                              backgroundImage: NetworkImage(snapshot.data!),
                              radius: 20,
                            ),
                            SizedBox(width: 10),
                            Text(
                              userName,
                              style: TextStyle(
                                fontSize: 22, // 글자 크기 증가
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontFamily: 'GowunDodum-Regular',
                              ),
                            ),
                          ],
                        );
                      }
                    },
                  ),
                  SizedBox(height: 10),
                  Text(
                    '제목: $title',
                    style: TextStyle(
                      fontSize: 24, // 글자 크기 증가
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'GowunDodum-Regular',
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    '날짜: ${DateFormat('yyyy-MM-dd').format(date)}',
                    style: TextStyle(
                      fontSize: 17, // 글자 크기 증가
                      color: Colors.white,
                      fontFamily: 'GowunDodum-Regular',
                    ),
                  ),
                  SizedBox(height: 10),
                  if (imageUrls.isNotEmpty)
                    Container(
                      height: 500,
                      child: PageView.builder(
                        itemCount: imageUrls.length,
                        itemBuilder: (context, index) {
                          return Hero(
                            tag: imageUrls[index],
                            child: Image.network(
                              imageUrls[index],
                              fit: BoxFit.cover,
                            ),
                          );
                        },
                      ),
                    ),
                  if (imageUrls.isNotEmpty) SizedBox(height: 10),
                  if (imageUrls.isEmpty)
                    Container(
                      height: 500,
                      child: Center(
                        child: Text(
                          '이미지가 없습니다.',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                            fontFamily: 'GowunDodum-Regular',
                          ),
                        ),
                      ),
                    ),
                  Text(
                    '내용: $text',
                    style: TextStyle(
                      fontSize: 20, // 글자 크기 증가
                      color: Colors.white,
                      fontFamily: 'GowunDodum-Regular',
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    '장소: $location',
                    style: TextStyle(
                      fontSize: 20, // 글자 크기 증가
                      color: Colors.white,
                      fontFamily: 'GowunDodum-Regular',
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
