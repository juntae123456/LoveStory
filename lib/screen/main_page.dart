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

  const MainPage({
    super.key,
    required this.userId,
    required this.backgroundImageUrl,
    required this.userName,
    required this.firstImageUrl,
    required this.partnerName,
    required this.secondImageUrl,
  });

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  String dDay = '';
  final DateTime startDate = DateTime(2024, 4, 2);
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    calculateDDay(startDate, (difference) {
      setState(() {
        dDay = '$difference일';
      });
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
      // 현재 페이지가 메인 페이지이므로 아무 작업도 하지 않음
    } else if (index == 1) {
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => CalendarPage(
              userId: widget.userId,
              userName: widget.userName,
              backgroundImageUrl: widget.backgroundImageUrl,
              firstImageUrl: widget.firstImageUrl,
              secondImageUrl: widget.secondImageUrl),
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
              backgroundImageUrl: widget.backgroundImageUrl),
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
              backgroundImageUrl: widget.backgroundImageUrl),
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
              backgroundImageUrl: widget.backgroundImageUrl,
              firstImageUrl: widget.firstImageUrl,
              secondImageUrl: widget.secondImageUrl // 추가
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
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              widget.backgroundImageUrl.isNotEmpty
                  ? widget.backgroundImageUrl
                  : 'assets/home_image.png', // 기본 배경 이미지
              fit: BoxFit.cover,
            ),
          ),
          Column(
            children: [
              SizedBox(height: 70),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      'love',
                      style: TextStyle(
                        fontFamily: 'ImperialScript-Regular',
                        fontSize: 70,
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
                    SizedBox(width: 20),
                    Text(
                      'story',
                      style: TextStyle(
                        fontFamily: 'ImperialScript-Regular',
                        fontSize: 70,
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
              SizedBox(height: 200),
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 30.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dDay,
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
                      Text(
                        '${startDate.year}.${startDate.month}.${startDate.day}',
                        style: TextStyle(
                          fontFamily: 'GowunDodum-Regular',
                          fontSize: 20,
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
              SizedBox(height: 40),
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
                          radius: 50,
                          backgroundImage:
                              _getImageProvider(widget.firstImageUrl),
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        widget.userName,
                        style: TextStyle(
                          fontFamily: 'GowunDodum-Regular',
                          fontSize: 25,
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
                  SizedBox(width: 20),
                  Lottie.asset(
                    'assets/love.json',
                    width: 100,
                    height: 100,
                  ),
                  SizedBox(width: 20),
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
                          radius: 50,
                          backgroundImage:
                              _getImageProvider(widget.secondImageUrl),
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        widget.partnerName,
                        style: TextStyle(
                          fontFamily: 'GowunDodum-Regular',
                          fontSize: 25,
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
            bottom: 20,
            right: 20,
            child: GestureDetector(
              onTap: () {
                showMailDialog(context, widget.userId, widget.userName);
              },
              child: Lottie.asset(
                'assets/mail.json',
                width: 60,
                height: 60,
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            left: 20,
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
                            secondImageUrl: widget.secondImageUrl),
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
                width: 70,
                height: 70,
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
