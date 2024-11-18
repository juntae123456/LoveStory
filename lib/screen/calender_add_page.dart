import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart'; // geocoding 패키지 추가
import 'package:geolocator/geolocator.dart'; // geolocator 패키지 추가
import 'dart:io';
import 'package:intl/intl.dart';

class CalenderAddPage extends StatefulWidget {
  final String userId;
  final String userName;
  final DateTime startDate;
  final DateTime endDate;
  final bool isEditMode;
  final String? eventId;
  final String partnerId;

  const CalenderAddPage({
    super.key,
    required this.userId,
    required this.userName,
    required this.startDate,
    required this.endDate,
    this.isEditMode = false,
    this.eventId,
    required this.partnerId,
  });

  @override
  _CalenderAddPageState createState() => _CalenderAddPageState();
}

class _CalenderAddPageState extends State<CalenderAddPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _eventController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  List<File> _selectedImages = [];
  List<String> _existingImageUrls = [];
  late DateTime _startDate;
  late DateTime _endDate;
  LatLng? _selectedLocation;
  bool _isImagePickerActive = false;

  @override
  void initState() {
    super.initState();
    _startDate = widget.startDate;
    _endDate = widget.endDate;

    if (widget.isEditMode && widget.eventId != null) {
      _loadEventData(widget.eventId!);
    }
  }

  Future<void> _loadEventData(String eventId) async {
    final doc = await FirebaseFirestore.instance
        .collection('events')
        .doc(eventId)
        .get();
    final data = doc.data()!;
    setState(() {
      _titleController.text = data['title'];
      _eventController.text = data['text'];
      _locationController.text = data['location'];
      _existingImageUrls = List<String>.from(data['imageUrls']);
      _startDate = (data['date'] as Timestamp).toDate();
      _endDate = _startDate;
    });
  }

  Future<void> _pickImages() async {
    if (_isImagePickerActive) return; // 이미지 선택기가 이미 활성화된 경우 반환
    _isImagePickerActive = true;

    try {
      final pickedFiles = await ImagePicker().pickMultiImage();
      if (pickedFiles != null) {
        setState(() {
          _selectedImages =
              pickedFiles.map((pickedFile) => File(pickedFile.path)).toList();
        });
      }
    } catch (e) {
      print('Error picking images: $e');
    } finally {
      _isImagePickerActive = false;
    }
  }

  Future<void> _saveEvent() async {
    if (_titleController.text.isEmpty || _eventController.text.isEmpty) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    try {
      List<String> imageUrls = List.from(_existingImageUrls);
      for (File image in _selectedImages) {
        final storageRef = FirebaseStorage.instance.ref().child(
            'events/${DateTime.now().millisecondsSinceEpoch}_${image.path.split('/').last}');
        await storageRef.putFile(image);
        final imageUrl = await storageRef.getDownloadURL();
        imageUrls.add(imageUrl);
      }

      final event = {
        'title': _titleController.text,
        'text': _eventController.text,
        'location': _locationController.text,
        'imageUrls': imageUrls,
        'userId': widget.userId,
        'userName': widget.userName,
        'date': _startDate,
        'partnerId': widget.partnerId,
      };

      if (widget.isEditMode && widget.eventId != null) {
        await FirebaseFirestore.instance
            .collection('events')
            .doc(widget.eventId)
            .update(event);
      } else {
        DateTime currentDate = _startDate;
        while (currentDate.isBefore(_endDate.add(Duration(days: 1)))) {
          await FirebaseFirestore.instance.collection('events').add({
            'date': currentDate,
            'title': _titleController.text,
            'text': _eventController.text,
            'location': _locationController.text,
            'imageUrls': imageUrls,
            'userId': widget.userId,
            'userName': widget.userName, // userName 필드 추가
            'partnerId': widget.partnerId,
          });
          currentDate = currentDate.add(Duration(days: 1));
        }
      }

      _titleController.clear();
      _eventController.clear();
      _locationController.clear();
      _selectedImages = [];
      _existingImageUrls = [];

      Navigator.of(context).pop();
      Navigator.of(context).pop(true); // 캘린더 페이지로 돌아갈 때 true 값을 전달
    } catch (e) {
      Navigator.of(context).pop();
      print('Error saving event: $e'); // 로그 추가

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('오류'),
            content: Text('저장 중 오류가 발생했습니다: $e'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('확인'),
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> _selectDate(BuildContext context, DateTime initialDate,
      Function(DateTime) onDateSelected) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2010),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != initialDate) {
      onDateSelected(picked);
    }
  }

  Future<void> _selectLocation(BuildContext context) async {
    final LatLng? selectedLocation = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SelectLocationPage(),
      ),
    );
    if (selectedLocation != null) {
      setState(() {
        _selectedLocation = selectedLocation;
        _locationController.text =
            '${selectedLocation.latitude}, ${selectedLocation.longitude}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditMode ? '일정 수정' : '일정 추가',
            style: TextStyle(fontFamily: 'GowunDodum-Regular')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: '제목',
                  border: UnderlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                ),
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      _selectDate(context, _startDate, (pickedDate) {
                        setState(() {
                          _startDate = pickedDate;
                        });
                      });
                    },
                    child: Row(
                      children: [
                        Text(
                          '시작일: ${DateFormat('yyyy-MM-dd').format(_startDate)}',
                          style: TextStyle(
                              fontSize: 20, fontFamily: 'GowunDodum-Regular'),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      _selectDate(context, _endDate, (pickedDate) {
                        setState(() {
                          _endDate = pickedDate;
                        });
                      });
                    },
                    child: Row(
                      children: [
                        Text(
                          '종료일: ${DateFormat('yyyy-MM-dd').format(_endDate)}',
                          style: TextStyle(
                              fontSize: 20, fontFamily: 'GowunDodum-Regular'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              GestureDetector(
                onTap: _pickImages,
                child: Container(
                  width: double.infinity,
                  height: 300,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                  ),
                  child: _selectedImages.isNotEmpty ||
                          _existingImageUrls.isNotEmpty
                      ? PageView.builder(
                          itemCount: _selectedImages.length +
                              _existingImageUrls.length,
                          itemBuilder: (context, index) {
                            if (index < _existingImageUrls.length) {
                              return Stack(
                                children: [
                                  Image.network(_existingImageUrls[index],
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: 300),
                                  Positioned(
                                    right: 0,
                                    child: IconButton(
                                      icon: Icon(Icons.remove_circle,
                                          color: Colors.red),
                                      onPressed: () {
                                        setState(() {
                                          _existingImageUrls.removeAt(index);
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              );
                            } else {
                              final imageIndex =
                                  index - _existingImageUrls.length;
                              return Stack(
                                children: [
                                  Image.file(_selectedImages[imageIndex],
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: 300),
                                  Positioned(
                                    right: 0,
                                    child: IconButton(
                                      icon: Icon(Icons.remove_circle,
                                          color: Colors.red),
                                      onPressed: () {
                                        setState(() {
                                          _selectedImages.removeAt(imageIndex);
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              );
                            }
                          },
                        )
                      : Center(
                          child: Text(
                            '사진 선택 (1080x1350)',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                ),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _eventController,
                decoration: InputDecoration(
                  labelText: '내용',
                  border: UnderlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: null,
              ),
              SizedBox(height: 10),
              GestureDetector(
                onTap: () {
                  _selectLocation(context);
                },
                child: AbsorbPointer(
                  child: TextField(
                    controller: _locationController,
                    decoration: InputDecoration(
                      labelText: '장소',
                      border: UnderlineInputBorder(),
                      prefixIcon: Icon(Icons.location_on),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      '취소',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontFamily: 'GowunDodum-Regular'),
                    ),
                  ),
                  TextButton(
                    onPressed: _saveEvent,
                    child: Text(
                      '저장',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontFamily: 'GowunDodum-Regular'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SelectLocationPage extends StatefulWidget {
  @override
  _SelectLocationPageState createState() => _SelectLocationPageState();
}

class _SelectLocationPageState extends State<SelectLocationPage> {
  late GoogleMapController mapController;
  LatLng _center = const LatLng(37.715133, 127.269311);
  LatLng _lastMapPosition = const LatLng(37.715133, 127.269311);
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _setInitialLocation();
  }

  Future<void> _setInitialLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(accuracy: LocationAccuracy.high));
    setState(() {
      _center = LatLng(position.latitude, position.longitude);
      _lastMapPosition = _center;
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    mapController.animateCamera(CameraUpdate.newLatLng(_center));
  }

  void _onCameraMove(CameraPosition position) {
    setState(() {
      _lastMapPosition = position.target;
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
          _lastMapPosition = newPosition;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text('위치 선택', style: TextStyle(fontFamily: 'GowunDodum-Regular')),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(_lastMapPosition);
            },
            child: Text(
              '완료',
              style: TextStyle(
                  color: Colors.black,
                  fontFamily: 'GowunDodum-Regular',
                  fontSize: 18),
            ),
          ),
        ],
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
              onCameraMove: _onCameraMove,
              markers: {
                Marker(
                  markerId: MarkerId('selected-location'),
                  position: _lastMapPosition,
                ),
              },
            ),
          ),
        ],
      ),
    );
  }
}
