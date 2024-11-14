import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:ui'; // ImageFilter를 사용하기 위해 추가
import 'calender_add_page.dart';
import 'event_detail_page.dart';
import 'main_page.dart'; // main_page.dart 임포트
import 'map_page.dart'; // map_page.dart 임포트
import 'list_page.dart'; // list_page.dart 임포트
import 'settings_page.dart'; // settings_page.dart 임포트

class CalendarPage extends StatefulWidget {
  final String userId;
  final String userName;
  final String backgroundImageUrl;
  final String firstImageUrl;
  final String secondImageUrl;
  final String partnerName;
  final String partnerId;

  const CalendarPage({
    super.key,
    required this.userId,
    required this.userName,
    required this.backgroundImageUrl,
    required this.firstImageUrl,
    required this.secondImageUrl,
    required this.partnerName,
    required this.partnerId,
  });

  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;
  Map<DateTime, List<dynamic>> _events = {};
  int _selectedIndex = 1; // 캘린더 아이콘이 기본 선택되도록 설정

  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }

  Future<void> _fetchEvents() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('events')
        .where('userId', whereIn: [widget.userId, widget.partnerId]).get();
    final events = snapshot.docs.map((doc) => doc.data()).toList();

    if (!mounted) return; // 위젯이 여전히 활성 상태인지 확인

    setState(() {
      _events = {};
      for (var event in events) {
        final date = (event['date'] as Timestamp).toDate();
        final eventDate =
            DateTime.utc(date.year, date.month, date.day); // 날짜만 저장

        if (_events[eventDate] == null) {
          _events[eventDate] = [];
        }
        _events[eventDate]!.add(event);
      }
    });
  }

  List<dynamic> _getEventsForDay(DateTime day) {
    final eventDate = DateTime.utc(day.year, day.month, day.day);
    return _events[eventDate] ?? [];
  }

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
              firstImageUrl: widget.firstImageUrl,
              partnerName: widget.partnerName,
              secondImageUrl: widget.secondImageUrl,
              backgroundImageUrl: backgroundImageUrl,
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
      // 현재 페이지가 캘린더 페이지이므로 아무 작업도 하지 않음
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
              partnerId: widget.partnerId),
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

  Future<void> _navigateToEventDetail(
      String eventId,
      String userId,
      String userName,
      String title,
      String text,
      String location,
      List<String> imageUrls,
      DateTime date) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EventDetailPage(
          userId: userId,
          userName: userName,
          title: title,
          text: text,
          location: location,
          imageUrls: imageUrls,
          date: date,
          backgroundImageUrl: widget.backgroundImageUrl,
          firstImageUrl: widget.firstImageUrl,
          secondImageUrl: widget.secondImageUrl,
          eventId: eventId,
          partnerId: widget.partnerId,
          partnerName: widget.partnerName,
        ),
      ),
    );

    if (result == true) {
      _fetchEvents(); // 이벤트 데이터를 다시 로드하는 메서드 호출
    }
  }

  Future<void> _navigateToAddEvent() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CalenderAddPage(
          userId: widget.userId,
          userName: widget.userName,
          startDate: _rangeStart ?? _selectedDay!,
          endDate: _rangeEnd ?? _selectedDay!,
          partnerId: widget.partnerId,
        ),
      ),
    );

    if (result == true) {
      _fetchEvents(); // 이벤트 데이터를 다시 로드하는 메서드 호출
    }
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
                title: const Text('일정표',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 27,
                        fontFamily: 'GowunDodum-Regular')),
                backgroundColor: Colors.transparent,
                elevation: 0,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      if (_selectedDay != null ||
                          (_rangeStart != null && _rangeEnd != null)) {
                        _navigateToAddEvent();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('날짜를 먼저 선택하세요.')),
                        );
                      }
                    },
                  ),
                ],
              ),
              TableCalendar(
                locale: 'ko_KR',
                firstDay: DateTime.utc(2010, 10, 16),
                lastDay: DateTime.utc(2030, 3, 14),
                daysOfWeekHeight: 30,
                focusedDay: _focusedDay,
                calendarFormat: _calendarFormat,
                availableCalendarFormats: const {
                  CalendarFormat.month: 'Month',
                },
                rangeStartDay: _rangeStart,
                rangeEndDay: _rangeEnd,
                selectedDayPredicate: (day) {
                  return isSameDay(_selectedDay, day);
                },
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    if (_rangeStart != null &&
                        _rangeEnd == null &&
                        selectedDay.isAfter(_rangeStart!)) {
                      _rangeEnd = selectedDay;
                      _selectedDay = null;
                    } else {
                      _selectedDay = selectedDay;
                      _rangeStart = null;
                      _rangeEnd = null;
                    }
                    _focusedDay = focusedDay;
                  });
                },
                onDayLongPressed: (selectedDay, focusedDay) {
                  setState(() {
                    _rangeStart = selectedDay;
                    _rangeEnd = null;
                    _selectedDay = null; // 선택된 날짜 초기화
                    _focusedDay = focusedDay;
                  });
                },
                onFormatChanged: (format) {
                  if (_calendarFormat != format) {
                    setState(() {
                      _calendarFormat = format;
                    });
                  }
                },
                onPageChanged: (focusedDay) {
                  _focusedDay = focusedDay;
                },
                calendarStyle: const CalendarStyle(
                  // 오늘 날짜 스타일
                  todayDecoration: BoxDecoration(
                    color: Colors.blueAccent,
                    shape: BoxShape.circle,
                  ),
                  // 선택된 날짜 스타일
                  selectedDecoration: BoxDecoration(
                    color: Colors.deepOrangeAccent,
                    shape: BoxShape.circle,
                  ),
                  // 범위 시작 날짜 스타일
                  rangeStartDecoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  // 범위 끝 날짜 스타일
                  rangeEndDecoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  // 주말 날짜 스타일
                  weekendTextStyle: TextStyle(
                    color: Colors.red,
                  ),
                  // 기본 날짜 스타일
                  defaultTextStyle: TextStyle(
                    color: Colors.black,
                  ),
                  // 오늘 날짜 텍스트 스타일
                  todayTextStyle: TextStyle(
                    color: Colors.white,
                  ),
                  // 선택된 날짜 텍스트 스타일
                  selectedTextStyle: TextStyle(
                    color: Colors.white,
                  ),
                ),
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle: TextStyle(
                    fontSize: 20.0,
                    color: Colors.black,
                  ),
                  leftChevronIcon: Icon(
                    Icons.chevron_left,
                    color: Colors.black,
                  ),
                  rightChevronIcon: Icon(
                    Icons.chevron_right,
                    color: Colors.black,
                  ),
                ),
                daysOfWeekStyle: const DaysOfWeekStyle(
                  weekendStyle: TextStyle(
                    color: Colors.red,
                  ),
                ),
                calendarBuilders: CalendarBuilders(
                  markerBuilder: (context, date, events) {
                    if (events.isNotEmpty) {
                      return Positioned(
                        bottom: 1,
                        child: const Icon(
                          Icons.favorite,
                          color: Colors.red,
                          size: 16,
                        ),
                      );
                    }
                    return null;
                  },
                ),
                eventLoader: (day) {
                  return _getEventsForDay(day);
                },
              ),
              const SizedBox(height: 20), // 캘린더와 입력 필드 사이의 여백
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('events')
                      .where('userId', whereIn: [
                    widget.userId,
                    widget.partnerId
                  ]).snapshots(), // userId 필터 추가
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final events = snapshot.data!.docs;
                    final selectedEvents = events.where((event) {
                      final data = event.data() as Map<String, dynamic>;
                      final date = (data['date'] as Timestamp?)?.toDate();
                      return date != null && isSameDay(date, _selectedDay);
                    }).toList();

                    return ListView(
                      children: selectedEvents.map((event) {
                        final data = event.data() as Map<String, dynamic>;
                        final imageUrls = List<String>.from(data['imageUrls']);
                        final title = data['title'] as String?;
                        final text = data['text'] as String?;
                        final location = data['location'] as String?;
                        final date = (data['date'] as Timestamp?)?.toDate();
                        final userName = data['userName'] as String?;
                        final userId = data['userId'] as String?;

                        if (title == null ||
                            text == null ||
                            location == null ||
                            date == null ||
                            userName == null ||
                            userId == null) {
                          return const SizedBox
                              .shrink(); // 데이터가 null인 경우 빈 위젯 반환
                        }

                        return ListTile(
                          leading: imageUrls.isNotEmpty
                              ? Hero(
                                  tag: imageUrls[0],
                                  child: Image.network(imageUrls[0]),
                                )
                              : const Icon(Icons.event),
                          title: Text(
                            title,
                            style: const TextStyle(color: Colors.white),
                          ),
                          subtitle: Text(DateFormat('yyyy-MM-dd').format(date)),
                          onTap: () {
                            _navigateToEventDetail(
                              event.id,
                              userId,
                              userName,
                              title,
                              text,
                              location,
                              imageUrls,
                              date,
                            );
                          },
                        );
                      }).toList(),
                    );
                  },
                ),
              ),
            ],
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
        unselectedItemColor: Colors.grey, // 선택되지 않은 항목의 색상을 밝은 회색으로 설정
        onTap: _onItemTapped,
      ),
    );
  }
}
