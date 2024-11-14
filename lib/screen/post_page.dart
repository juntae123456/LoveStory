import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:ui'; // ImageFilter를 사용하기 위해 추가
import 'package:intl/intl.dart'; // 날짜 형식을 위해 추가
import 'main_page.dart'; // main_page.dart 임포트
import 'calender_page.dart'; // calender_page.dart 임포트

class PostPage extends StatefulWidget {
  final String userId;
  final String userName;
  final String backgroundImageUrl;
  final String firstImageUrl;
  final String secondImageUrl;
  final String partnerName;
  final String partnerId;

  const PostPage(
      {super.key,
      required this.userId,
      required this.userName,
      required this.backgroundImageUrl,
      required this.firstImageUrl,
      required this.secondImageUrl,
      required this.partnerName,
      required this.partnerId});

  @override
  _PostPageState createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  bool showSentMessages = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          if (widget.backgroundImageUrl.isNotEmpty)
            Positioned.fill(
              child: Image.network(
                widget.backgroundImageUrl.isNotEmpty
                    ? widget.backgroundImageUrl
                    : 'assets/home_image.png',
                fit: BoxFit.cover,
              ),
            ),
          if (widget.backgroundImageUrl.isNotEmpty)
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0), // 흐림 효과 적용
                child: Container(
                  color: Colors.black.withOpacity(0), // 투명한 컨테이너
                ),
              ),
            ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 50),
              Padding(
                padding: const EdgeInsets.only(left: 20.0),
                child: Row(
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    MainPage(
                              userId: widget.userId,
                              userName: widget.userName,
                              backgroundImageUrl: widget.backgroundImageUrl,
                              firstImageUrl: widget.firstImageUrl,
                              secondImageUrl: widget.secondImageUrl,
                              partnerName: widget.partnerName,
                              partnerId: widget
                                  .partnerId, // Replace with actual partner name
                            ),
                            transitionsBuilder: (context, animation,
                                secondaryAnimation, child) {
                              return FadeTransition(
                                opacity: animation,
                                child: child,
                              );
                            },
                          ),
                        );
                      },
                      child: Text(
                        'love',
                        style: TextStyle(
                          fontFamily: 'ImperialScript-Regular',
                          fontSize: 50,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              offset: Offset(2.0, 2.0),
                              blurRadius: 3.0,
                              color: Color.fromARGB(255, 0, 0, 0),
                            ),
                          ],
                        ),
                      ),
                      style: TextButton.styleFrom(
                        splashFactory: NoSplash.splashFactory,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    CalendarPage(
                              userId: widget.userId,
                              userName: widget.userName,
                              backgroundImageUrl: widget.backgroundImageUrl,
                              firstImageUrl: widget.firstImageUrl,
                              secondImageUrl: widget.secondImageUrl,
                              partnerName: widget.partnerName,
                              partnerId: widget.partnerId,
                            ),
                            transitionsBuilder: (context, animation,
                                secondaryAnimation, child) {
                              return FadeTransition(
                                opacity: animation,
                                child: child,
                              );
                            },
                          ),
                        );
                      },
                      child: Text(
                        'story',
                        style: TextStyle(
                          fontFamily: 'ImperialScript-Regular',
                          fontSize: 50,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              offset: Offset(2.0, 2.0),
                              blurRadius: 3.0,
                              color: Color.fromARGB(255, 0, 0, 0),
                            ),
                          ],
                        ),
                      ),
                      style: TextButton.styleFrom(
                        splashFactory: NoSplash.splashFactory,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 30.0),
                child: Text(
                  '편지함',
                  style: TextStyle(
                    fontFamily: 'GowunDodum-Regular',
                    fontSize: 60,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        offset: Offset(1.0, 1.0),
                        blurRadius: 3.0,
                        color: Color.fromARGB(255, 0, 0, 0),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        showSentMessages = false;
                      });
                    },
                    child: Text(
                      '받은편지함',
                      style: TextStyle(
                        fontFamily: 'GowunDodum-Regular',
                        fontSize: 25,
                        color: showSentMessages
                            ? Colors.white.withOpacity(0.6)
                            : Colors.black,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      splashFactory: NoSplash.splashFactory,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        showSentMessages = true;
                      });
                    },
                    child: Text(
                      '보낸편지함',
                      style: TextStyle(
                        fontFamily: 'GowunDodum-Regular',
                        fontSize: 25,
                        color: showSentMessages
                            ? Colors.black
                            : Colors.white.withOpacity(0.6),
                      ),
                    ),
                    style: TextButton.styleFrom(
                      splashFactory: NoSplash.splashFactory,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: showSentMessages
                      ? FirebaseFirestore.instance
                          .collection('message')
                          .where('userId', isEqualTo: widget.userId)
                          .orderBy('timestamp', descending: true)
                          .snapshots()
                      : FirebaseFirestore.instance
                          .collection('message')
                          .where('userId', isNotEqualTo: widget.userId)
                          .where(
                            'timestamp',
                            isLessThan: Timestamp.fromDate(
                              DateTime(DateTime.now().year,
                                  DateTime.now().month, DateTime.now().day),
                            ),
                          )
                          .orderBy('timestamp', descending: true)
                          .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Center(child: CircularProgressIndicator());
                    }
                    final messages = snapshot.data!.docs;
                    final groupedMessages = _groupMessagesByDate(messages);
                    return ListView.builder(
                      itemCount: groupedMessages.length,
                      itemBuilder: (context, index) {
                        final date = groupedMessages.keys.elementAt(index);
                        final messagesForDate = groupedMessages[date]!;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                DateFormat('yyyy.MM.dd').format(date),
                                style: TextStyle(
                                  fontFamily: 'GowunDodum-Regular',
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            ...messagesForDate.map((message) {
                              final data =
                                  message.data() as Map<String, dynamic>;
                              final content = data['content'] as String;
                              final truncatedContent = content.length > 10
                                  ? content.substring(0, 10) + '...'
                                  : content;
                              return ListTile(
                                title: Text(truncatedContent),
                                subtitle: Text(data['timestamp'] != null
                                    ? (data['timestamp'] as Timestamp)
                                        .toDate()
                                        .toString()
                                    : 'Loading...'),
                                onTap: () {
                                  _showMessageDialog(context, content);
                                },
                              );
                            }).toList(),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showMessageDialog(BuildContext context, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            '어제 온 편지',
            style: TextStyle(fontFamily: 'GowunDodum-Regular', fontSize: 30),
          ),
          content: Text(content,
              style: TextStyle(fontFamily: 'PretendardThin', fontSize: 17)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('닫기'),
            ),
          ],
        );
      },
    );
  }

  Map<DateTime, List<QueryDocumentSnapshot>> _groupMessagesByDate(
      List<QueryDocumentSnapshot> messages) {
    final Map<DateTime, List<QueryDocumentSnapshot>> groupedMessages = {};
    for (var message in messages) {
      final timestamp = (message['timestamp'] as Timestamp).toDate();
      final date = DateTime(timestamp.year, timestamp.month, timestamp.day);
      if (!groupedMessages.containsKey(date)) {
        groupedMessages[date] = [];
      }
      groupedMessages[date]!.add(message);
    }
    return groupedMessages;
  }
}
