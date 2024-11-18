import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'profile_edit_dialog.dart';
import 'image_upload_dialog.dart';
import 'date_change_dialog.dart';
import 'auth_utils.dart';
import 'main_page.dart';
import 'calender_page.dart';
import 'map_page.dart';
import 'list_page.dart';
import 'dart:ui'; // ImageFilter를 사용하기 위해 추가
import 'package:cloud_firestore/cloud_firestore.dart';

class AdMobService {
  // 배너 광고
  static String? get bannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3429968328236998/1248939467'; // 테스트 광고 ID
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3429968328236998/8744286102'; // 테스트 광고 ID
    }
    return null;
  }

  // 전면 광고
  static String? get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3429968328236998/4996612788'; // 테스트 광고 ID
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3429968328236998/3311996022'; // 테스트 광고 ID
    }
    return null;
  }

  static final BannerAdListener bannerAdListener = BannerAdListener(
    onAdLoaded: (ad) => debugPrint('Ad loaded'),
    onAdFailedToLoad: (ad, error) {
      ad.dispose();
      debugPrint('Ad fail to load: $error');
    },
    onAdOpened: (ad) => debugPrint('Ad opened'),
    onAdClosed: (ad) => debugPrint('Ad closed'),
  );

  static final InterstitialAdLoadCallback interstitialAdLoadCallback =
      InterstitialAdLoadCallback(
    onAdLoaded: (InterstitialAd ad) {
      debugPrint('Interstitial ad loaded');
      ad.show();
    },
    onAdFailedToLoad: (LoadAdError error) {
      debugPrint('Interstitial ad failed to load: $error');
    },
  );
}

class SettingsPage extends StatefulWidget {
  final String userId;
  final String userName;
  final String backgroundImageUrl;
  final String firstImageUrl;
  final String secondImageUrl;
  final String partnerName;
  final String partnerId;

  const SettingsPage({
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
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;
  late String backgroundImageUrl;
  late String firstImageUrl;
  late String secondImageUrl;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    backgroundImageUrl = widget.backgroundImageUrl;
    firstImageUrl = widget.firstImageUrl;
    secondImageUrl = widget.secondImageUrl;
    _createBannerAd();
    _loadInterstitialAd();
  }

  void _createBannerAd() {
    _bannerAd = BannerAd(
      size: AdSize.banner, // 배너 사이즈
      adUnitId: AdMobService.bannerAdUnitId!, // 광고 ID 등록
      listener: AdMobService.bannerAdListener, // 리스너 등록
      request: const AdRequest(),
    )..load();
  }

  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: AdMobService.interstitialAdUnitId!,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          _interstitialAd = ad;
          debugPrint('Interstitial ad loaded');
        },
        onAdFailedToLoad: (LoadAdError error) {
          debugPrint('Interstitial ad failed to load: $error');
        },
      ),
    );
  }

  void _showInterstitialAd() {
    if (_interstitialAd != null) {
      _interstitialAd!.show();
      _interstitialAd = null; // 광고를 한 번만 표시하도록 설정
    } else {
      debugPrint('Interstitial ad is not ready yet');
    }
  }

  Future<void> _onProfileImageChanged(String newImageUrl) async {
    setState(() {
      firstImageUrl = newImageUrl;
    });
    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .update({'firstImageUrl': newImageUrl});
    _showInterstitialAd();
  }

  Future<void> _onBackgroundImageChanged(String newImageUrl) async {
    setState(() {
      backgroundImageUrl = newImageUrl;
    });
    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .update({'backgroundImageUrl': newImageUrl});
    _showInterstitialAd();
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('계정 삭제'),
          content: const Text('정말로 계정을 삭제하시겠습니까? 이 작업은 되돌릴 수 없습니다.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteAccount();
              },
              child: const Text('확인'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteAccount() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Firestore에서 userId와 관련된 모든 문서 삭제
      final userDocs = await FirebaseFirestore.instance
          .collection('users')
          .where('userId', isEqualTo: widget.userId)
          .get();

      for (var doc in userDocs.docs) {
        await doc.reference.delete();
      }

      // 로그아웃 및 초기 화면으로 이동
      await logout(context);
    } catch (e) {
      debugPrint('계정 삭제 중 오류 발생: $e');
      _showErrorDialog('계정 삭제 중 오류가 발생했습니다. 다시 시도해주세요.');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showCopyrightDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('저작권 정보',
              style: TextStyle(fontFamily: 'GowunDodum-Regular')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('폰트:', style: TextStyle(fontFamily: 'Pretendard-Black')),
              Text(
                  'CuteFont-Regular, GowunDodum-Regular, ImperialScript-Regular, Pretendard-Black, Pretendard-ExtraBold, Pretendard-Thin',
                  style: TextStyle(fontFamily: 'Pretendard-Thin')),
              SizedBox(height: 10),
              Text('이미지 출처:', style: TextStyle(fontFamily: 'Pretendard-Black')),
              Text('롯리 무료 이미지 사용',
                  style: TextStyle(fontFamily: 'Pretendard-Thin')),
              SizedBox(height: 10),
              Text('아이콘:', style: TextStyle(fontFamily: 'Pretendard-Black')),
              Text('사랑 아이콘 - 제작자: Andrean Prabowo, 제공처: Flaticon',
                  style: TextStyle(fontFamily: 'Pretendard-Thin')),
              SizedBox(height: 10),
              Text('© 2024 [love story]. All rights reserved.',
                  style: TextStyle(fontFamily: 'Pretendard-Thin')),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('닫기',
                  style: TextStyle(fontFamily: 'Pretendard-Thin')),
            ),
          ],
        );
      },
    );
  }

  void onItemTapped(BuildContext context, int index) {
    String backgroundImageUrl = this.backgroundImageUrl.isNotEmpty
        ? this.backgroundImageUrl
        : 'assets/home_image.png';

    if (index == 0) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => MainPage(
            userId: widget.userId,
            userName: widget.userName,
            partnerName: widget.partnerName,
            backgroundImageUrl: backgroundImageUrl,
            firstImageUrl: firstImageUrl,
            secondImageUrl: widget.secondImageUrl,
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
    } else if (index == 1) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => CalendarPage(
            userId: widget.userId,
            userName: widget.userName,
            backgroundImageUrl: backgroundImageUrl,
            firstImageUrl: firstImageUrl,
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
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => MapPage(
            userId: widget.userId,
            backgroundImageUrl: backgroundImageUrl,
            firstImageUrl: firstImageUrl,
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
    } else if (index == 3) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => ListPage(
            userId: widget.userId,
            backgroundImageUrl: backgroundImageUrl,
            firstImageUrl: firstImageUrl,
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('설정',
            style: TextStyle(fontFamily: 'GowunDodum-Regular', fontSize: 24)),
        backgroundColor: Colors.transparent,
        elevation: 0,
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
          Stack(
            children: [
              Column(
                children: [
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.only(
                          top: 100.0,
                          left: 16.0,
                          right: 16.0,
                          bottom: 16.0), // 상단에 패딩 추가
                      children: [
                        Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ListTile(
                            leading:
                                const Icon(Icons.edit, color: Colors.black),
                            title: const Text('프로필 수정',
                                style: TextStyle(
                                    fontFamily: 'GowunDodum-Regular',
                                    fontSize: 18)),
                            onTap: () {
                              showProfileEditDialog(context, widget.userId);
                            },
                          ),
                        ),
                        const SizedBox(height: 10),
                        Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ListTile(
                            leading: const Icon(Icons.photo_camera,
                                color: Colors.black),
                            title: const Text('프로필 사진 변경',
                                style: TextStyle(
                                    fontFamily: 'GowunDodum-Regular',
                                    fontSize: 18)),
                            onTap: () {
                              showProfileImageUploadDialog(
                                  context,
                                  widget.userId,
                                  widget.userName,
                                  widget.partnerName, (type, url) {
                                _onProfileImageChanged(url);
                              });
                            },
                          ),
                        ),
                        const SizedBox(height: 10),
                        Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ListTile(
                            leading:
                                const Icon(Icons.image, color: Colors.black),
                            title: const Text('배경 사진 변경',
                                style: TextStyle(
                                    fontFamily: 'GowunDodum-Regular',
                                    fontSize: 18)),
                            onTap: () {
                              showBackgroundImageUploadDialog(
                                  context,
                                  widget.userId,
                                  widget.userName,
                                  widget.partnerName, (type, url) {
                                _onBackgroundImageChanged(url);
                              });
                            },
                          ),
                        ),
                        const SizedBox(height: 10),
                        Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ListTile(
                            leading: const Icon(Icons.date_range,
                                color: Colors.black),
                            title: const Text('날짜 변경',
                                style: TextStyle(
                                    fontFamily: 'GowunDodum-Regular',
                                    fontSize: 18)),
                            onTap: () {
                              showDateChangeDialog(context, widget.userId);
                            },
                          ),
                        ),
                        const SizedBox(height: 10),
                        Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ListTile(
                            leading:
                                const Icon(Icons.logout, color: Colors.black),
                            title: const Text('로그아웃',
                                style: TextStyle(
                                    fontFamily: 'GowunDodum-Regular',
                                    fontSize: 18)),
                            onTap: () => logout(context),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ListTile(
                            leading:
                                const Icon(Icons.info, color: Colors.black),
                            title: const Text('저작권 정보',
                                style: TextStyle(
                                    fontFamily: 'GowunDodum-Regular',
                                    fontSize: 18)),
                            onTap: () {
                              _showCopyrightDialog(context);
                            },
                          ),
                        ),
                        const SizedBox(height: 10),
                        Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ListTile(
                            leading:
                                const Icon(Icons.delete, color: Colors.red),
                            title: const Text('계정 삭제',
                                style: TextStyle(
                                    fontFamily: 'GowunDodum-Regular',
                                    fontSize: 18,
                                    color: Colors.red)),
                            onTap: _showDeleteAccountDialog,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (_bannerAd != null)
                Positioned(
                  bottom: 40, // 메뉴바 위에 배치
                  left: 0,
                  right: 0,
                  child: Container(
                    alignment: Alignment.center,
                    child: AdWidget(ad: _bannerAd!),
                    width: _bannerAd!.size.width.toDouble(),
                    height: _bannerAd!.size.height.toDouble(),
                  ),
                ),
            ],
          ),
          if (isLoading)
            const Center(
              child: CircularProgressIndicator(),
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
        currentIndex: 4,
        selectedItemColor: Colors.amber[800],
        unselectedItemColor: Colors.grey,
        onTap: (index) => onItemTapped(context, index),
      ),
    );
  }
}
