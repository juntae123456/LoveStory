import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geocoding/geocoding.dart'; // geocoding 패키지 추가
import 'main_page.dart'; // main_page.dart 임포트
import 'calender_page.dart'; // calender_page.dart 임포트
import 'list_page.dart'; // list_page.dart 임포트
import 'settings_page.dart'; // settings_page.dart 임포트
import 'package:intl/intl.dart';
import 'dart:ui' as ui;
import 'package:flutter/services.dart' show rootBundle;
import 'dart:typed_data';

class MapPage extends StatefulWidget {
  final String userId;
  final String backgroundImageUrl;
  final String userName;
  final String firstImageUrl;
  final String partnerName;
  final String secondImageUrl;
  final String partnerId;

  const MapPage({
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
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late GoogleMapController mapController;
  final LatLng _center = const LatLng(35.333985, 129.006277);
  int _selectedIndex = 2; // 지도 아이콘이 기본 선택되도록 설정
  Set<Marker> _markers = {};
  BitmapDescriptor? customIcon;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCustomMarker();
  }

  Future<void> _loadCustomMarker() async {
    final Uint8List markerIcon =
        await _getBytesFromAsset('assets/heart_map_icon.png', 100);
    customIcon = BitmapDescriptor.fromBytes(markerIcon);
    setState(() {});
  }

  Future<Uint8List> _getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(
      data.buffer.asUint8List(),
      targetWidth: width,
    );
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    _getCurrentLocation();
    _loadMarkersFromCalendar();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // 위치 서비스 활성화 확인
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return Future.error('Location services are disabled.');
    }

    // 위치 권한 확인
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // 현재 위치 가져오기
    Position position = await Geolocator.getCurrentPosition();
    mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(position.latitude, position.longitude),
          zoom: 15.0,
        ),
      ),
    );
  }

  Future<void> _loadMarkersFromCalendar() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('events').get();

    Set<Marker> markers = querySnapshot.docs
        .map((doc) {
          String locationString = doc['location'];
          List<String> latLng = locationString.split(', ');
          double? latitude;
          double? longitude;

          try {
            latitude = double.parse(latLng[0]);
            longitude = double.parse(latLng[1]);
          } catch (e) {
            print('Error parsing location: $e');
            return null;
          }

          // userId와 partnerId가 있는지 확인
          if (doc['userId'] == widget.userId ||
              doc['userId'] == widget.partnerId ||
              doc['partnerId'] == widget.userId ||
              doc['partnerId'] == widget.partnerId) {
            if (latitude != null && longitude != null) {
              LatLng position = LatLng(latitude, longitude);
              print('Marker added at position: $position'); // 마커 위치 로그 출력
              return Marker(
                markerId: MarkerId(doc.id),
                position: position,
                icon: customIcon ?? BitmapDescriptor.defaultMarker,
                infoWindow: InfoWindow(
                  title: doc['title'],
                  snippet: doc['text'],
                  onTap: () {
                    _showEventDetailDialog(doc);
                  },
                ),
              );
            } else {
              return null;
            }
          } else {
            return null;
          }
        })
        .where((marker) => marker != null)
        .cast<Marker>()
        .toSet();

    setState(() {
      _markers = markers;
    });
  }

  Future<void> _searchLocation() async {
    try {
      List<Location> locations =
          await locationFromAddress(_searchController.text);
      if (locations.isNotEmpty) {
        Location location = locations.first;
        LatLng newPosition = LatLng(location.latitude, location.longitude);
        mapController.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(
            target: newPosition,
            zoom: 17.0, // 줌 레벨 설정
          ),
        ));
        setState(() {
          _searchController.clear(); // 검색 성공 시 검색창 비우기
        });
      } else {
        // 검색 결과가 없을 경우 사용자에게 알림 표시
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('검색 결과가 없습니다.')),
        );
      }
    } catch (e) {
      print('Error occurred while searching location: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('위치 검색 중 오류가 발생했습니다.')),
      );
    }
  }

  void _showEventDetailDialog(QueryDocumentSnapshot doc) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(doc['title']),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('내용: ${doc['text']}'),
              Text(
                  '날짜: ${DateFormat('yyyy-MM-dd').format((doc['date'] as Timestamp).toDate())}'),
              Text('장소: ${doc['location']}'),
            ],
          ),
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
              partnerName: widget.partnerName,
              backgroundImageUrl: backgroundImageUrl,
              firstImageUrl: widget.firstImageUrl,
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
      // 현재 페이지가 지도 페이지이므로 아무 작업도 하지 않음
    } else if (index == 3) {
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => ListPage(
              userId: widget.userId,
              backgroundImageUrl: backgroundImageUrl,
              userName: widget.userName,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '지도',
          style: TextStyle(fontSize: 27, fontFamily: 'GowunDodum-Regular'),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: '위치 검색',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (value) {
                      _searchLocation();
                    },
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.search),
                  onPressed: _searchLocation,
                ),
              ],
            ),
          ),
          Expanded(
            child: GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: _center,
                zoom: 11.0,
              ),
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              markers: _markers,
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
        unselectedItemColor: Colors.grey, // 선택되지 않은 항목의 색상을 밝은 회색으로 설정
        onTap: _onItemTapped,
      ),
    );
  }
}
