import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'post_page.dart';
import 'calender_page.dart';
import 'map_page.dart';
import 'list_page.dart';
import 'settings_page.dart'; // 설정 페이지 임포트
import 'fetch_user_data.dart';
import 'dday_calculation.dart';
import 'mail_dialog.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class MainPage extends StatefulWidget {
  final String userId;
  final String backgroundImageUrl;
  final String userName;
  final String firstImageUrl;
  final String partnerName;
  final String secondImageUrl;
  final String partnerId;

  const MainPage({
    super.key,
    required this.userId,
    required this.backgroundImageUrl,
    required this.userName,
    required this.firstImageUrl,
    required this.partnerName,
    required this.secondImageUrl,
    required this.partnerId,
  });

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  String dDay = '';
  DateTime startDate = DateTime(2024, 4, 2); // 기본 날짜 설정
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchStartDate();
  }

  Future<void> _fetchStartDate() async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .get();

    Map<String, dynamic>? userData = userDoc.data() as Map<String, dynamic>?;

    if (userData != null) {
      setState(() {
        startDate =
            userData.containsKey('startDate') && userData['startDate'] != null
                ? (userData['startDate'] as Timestamp).toDate()
                : DateTime.now();
        calculateDDay(startDate, (difference) {
          setState(() {
            dDay = '$difference일';
          });
        });
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    String backgroundImageUrl = widget.backgroundImageUrl.isNotEmpty
        ? widget.backgroundImageUrl
        : 'assets/home_image.png';

    if (index == 0) {
      // 현재 페이지가 메인 페이지이므로 아무 작업도 하지 않음
    } else if (index == 1) {
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => CalendarPage(
            userId: widget.userId,
            userName: widget.userName,
            backgroundImageUrl: backgroundImageUrl,
            firstImageUrl: widget.firstImageUrl,
            secondImageUrl: widget.secondImageUrl,
            partnerName: widget.partnerName,
            partnerId: widget.partnerId,
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
        ),
      );
    } else if (index == 2) {
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => MapPage(
            userId: widget.userId,
            backgroundImageUrl: backgroundImageUrl,
            firstImageUrl: widget.firstImageUrl,
            secondImageUrl: widget.secondImageUrl,
            partnerName: widget.partnerName,
            userName: widget.userName,
            partnerId: widget.partnerId,
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
        ),
      );
    } else if (index == 3) {
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => ListPage(
            userId: widget.userId,
            backgroundImageUrl: backgroundImageUrl,
            firstImageUrl: widget.firstImageUrl,
            secondImageUrl: widget.secondImageUrl,
            userName: widget.userName,
            partnerName: widget.partnerName,
            partnerId: widget.partnerId,
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
        ),
      );
    } else if (index == 4) {
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => SettingsPage(
            userId: widget.userId,
            userName: widget.userName,
            backgroundImageUrl: backgroundImageUrl,
            firstImageUrl: widget.firstImageUrl,
            secondImageUrl: widget.secondImageUrl,
            partnerName: widget.partnerName,
            partnerId: widget.partnerId,
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image(
              image: _getImageProvider(widget.backgroundImageUrl),
              fit: BoxFit.cover,
            ),
          ),
          Column(
            children: [
              SizedBox(height: screenHeight * 0.1),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      'love',
                      style: TextStyle(
                        fontFamily: 'ImperialScript-Regular',
                        fontSize: screenWidth * 0.15,
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
                    SizedBox(width: screenWidth * 0.05),
                    Text(
                      'story',
                      style: TextStyle(
                        fontFamily: 'ImperialScript-Regular',
                        fontSize: screenWidth * 0.15,
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
                  ],
                ),
              ),
              SizedBox(height: screenHeight * 0.2),
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.only(left: screenWidth * 0.1),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dDay,
                        style: TextStyle(
                          fontFamily: 'GowunDodum-Regular',
                          fontSize: screenWidth * 0.15,
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
                      Text(
                        '${startDate.year}.${startDate.month}.${startDate.day}',
                        style: TextStyle(
                          fontFamily: 'GowunDodum-Regular',
                          fontSize: screenWidth * 0.05,
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
                    ],
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.03),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 2.0,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: screenWidth * 0.13,
                          backgroundImage:
                              _getImageProvider(widget.firstImageUrl),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      Text(
                        widget.userName,
                        style: TextStyle(
                          fontFamily: 'GowunDodum-Regular',
                          fontSize: screenWidth * 0.06,
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
                    ],
                  ),
                  SizedBox(width: screenWidth * 0.05),
                  Lottie.asset(
                    'assets/love.json',
                    width: screenWidth * 0.25,
                    height: screenHeight * 0.1,
                  ),
                  SizedBox(width: screenWidth * 0.03),
                  Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 2.0,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: screenWidth * 0.13,
                          backgroundImage:
                              _getImageProvider(widget.secondImageUrl),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      Text(
                        widget.partnerName,
                        style: TextStyle(
                          fontFamily: 'GowunDodum-Regular',
                          fontSize: screenWidth * 0.06,
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
                    ],
                  ),
                ],
              ),
            ],
          ),
          Positioned(
            bottom: screenHeight * 0.0,
            right: screenWidth * 0.0,
            child: GestureDetector(
              onTap: () {
                showMailDialog(
                    context, widget.userId, widget.userName, widget.partnerId);
              },
              child: Lottie.asset(
                'assets/mail.json',
                width: screenWidth * 0.15,
                height: screenHeight * 0.1,
              ),
            ),
          ),
          Positioned(
            bottom: screenHeight * 0.0,
            left: screenWidth * 0.0,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        PostPage(
                            userId: widget.userId,
                            userName: widget.userName,
                            backgroundImageUrl: widget.backgroundImageUrl,
                            firstImageUrl: widget.firstImageUrl,
                            secondImageUrl: widget.secondImageUrl,
                            partnerName: widget.partnerName,
                            partnerId: widget.partnerId),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                      return FadeTransition(
                        opacity: animation,
                        child: child,
                      );
                    },
                  ),
                );
              },
              child: Lottie.asset(
                'assets/send_mail.json',
                width: screenWidth * 0.18,
                height: screenHeight * 0.1,
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: '캘린더',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: '지도',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: '리스트',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: '설정',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }

  ImageProvider _getImageProvider(String imageUrl) {
    if (imageUrl.startsWith('http') || imageUrl.startsWith('https')) {
      return NetworkImage(imageUrl);
    } else {
      return AssetImage(imageUrl);
    }
  }
}
