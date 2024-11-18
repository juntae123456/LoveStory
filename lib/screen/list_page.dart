import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'main_page.dart'; // main_page.dart 임포트
import 'calender_page.dart'; // calender_page.dart 임포트
import 'map_page.dart'; // map_page.dart 임포트
import 'note_page.dart'; // note_page.dart 임포트
import 'settings_page.dart'; // settings_page.dart 임포트
import 'dart:ui'; // ImageFilter를 사용하기 위해 추가

class ListPage extends StatefulWidget {
  final String userId;
  final String backgroundImageUrl;
  final String userName;
  final String firstImageUrl;
  final String partnerName;
  final String secondImageUrl;
  final String partnerId;

  const ListPage({
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
  _ListPageState createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  int _selectedIndex = 3; // 리스트 아이콘이 기본 선택되도록 설정
  final TextEditingController _titleController = TextEditingController();

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    String backgroundImageUrl = widget.backgroundImageUrl.isNotEmpty
        ? widget.backgroundImageUrl
        : 'assets/home_image.png';

    if (index == 0) {
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => MainPage(
              userId: widget.userId,
              userName: widget.userName,
              backgroundImageUrl: backgroundImageUrl,
              firstImageUrl: widget.firstImageUrl,
              partnerName: widget.partnerName,
              secondImageUrl: widget.secondImageUrl,
              partnerId: widget.partnerId),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
        ),
      );
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
      // 현재 페이지가 리스트 페이지이므로 아무 작업도 하지 않음
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

  Future<void> _addListItem() async {
    if (_titleController.text.isEmpty) return;

    await FirebaseFirestore.instance.collection('lists').add({
      'title': _titleController.text,
      'userId': widget.userId,
      'partnerId': widget.partnerId,
    });

    _titleController.clear();
    Navigator.of(context).pop(); // 다이얼로그 닫기
  }

  void _showAddListItemDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('리스트 제목 입력'),
          content: TextField(
            controller: _titleController,
            decoration: const InputDecoration(hintText: '리스트 제목 입력'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 다이얼로그 닫기
              },
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: _addListItem,
              child: const Text('추가'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(String listId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('삭제 확인'),
          content: const Text('이 리스트를 삭제하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 다이얼로그 닫기
              },
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection('lists')
                    .doc(listId)
                    .delete();
                Navigator.of(context).pop(); // 다이얼로그 닫기
              },
              child: const Text('삭제'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          if (widget.backgroundImageUrl.isNotEmpty)
            Positioned.fill(
              child: widget.backgroundImageUrl.startsWith('http')
                  ? Image.network(
                      widget.backgroundImageUrl,
                      fit: BoxFit.cover,
                    )
                  : Image.asset(
                      widget.backgroundImageUrl,
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
            children: [
              AppBar(
                title: const Text('Wish List',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 27,
                        fontFamily: 'GowunDodum-Regular')),
                backgroundColor: Colors.transparent,
                elevation: 0,
              ),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('lists').where(
                      'userId',
                      whereIn: [widget.userId, widget.partnerId]).snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final lists = snapshot.data!.docs;
                    return ListView.builder(
                      itemCount: lists.length,
                      itemBuilder: (context, index) {
                        final list = lists[index];
                        return Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ListTile(
                            leading:
                                const Icon(Icons.event, color: Colors.black),
                            title: Text(list['title'],
                                style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 20,
                                    fontFamily: 'GowunDodum-Regular')),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => NotePage(
                                    title: list['title'],
                                    listId: list.id,
                                  ),
                                ),
                              );
                            },
                            onLongPress: () {
                              _showDeleteConfirmationDialog(list.id);
                            },
                          ),
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
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddListItemDialog,
        child: const Icon(Icons.add),
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
        unselectedItemColor: Colors.grey, // 선택되지 않은 항목의 색상을 밝은 회색으로 설정
        onTap: _onItemTapped,
      ),
    );
  }
}
