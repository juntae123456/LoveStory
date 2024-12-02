import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

class PDFViewerPage extends StatefulWidget {
  final String pdfUrl; // Firebase URL

  const PDFViewerPage({super.key, required this.pdfUrl});

  @override
  _PDFViewerPageState createState() => _PDFViewerPageState();
}

class _PDFViewerPageState extends State<PDFViewerPage> {
  String? _localPath; // 로컬 파일 경로
  bool _isLoading = true; // 로딩 상태
  String _errorMessage = ''; // 에러 메시지

  @override
  void initState() {
    super.initState();
    _downloadAndSaveFile();
  }

  Future<void> _downloadAndSaveFile() async {
    try {
      final ref = FirebaseStorage.instance.refFromURL(widget.pdfUrl);

      // Firebase Storage에서 파일 데이터를 가져옴
      final data = await ref.getData();
      if (data == null) throw Exception("파일 데이터를 가져오지 못했습니다.");

      // 임시 디렉터리에 파일 저장
      final tempDir = await getTemporaryDirectory();
      final localFile = File('${tempDir.path}/temp_pdf.pdf');
      await localFile.writeAsBytes(data);

      // 로컬 파일 경로 설정
      setState(() {
        _localPath = localFile.path;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
      debugPrint("Error downloading PDF: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('개인정보처리방침'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text('에러 발생: $_errorMessage'))
              : PDFView(
                  filePath: _localPath, // 로컬 파일 경로
                  enableSwipe: true,
                  swipeHorizontal: true,
                  autoSpacing: false,
                  pageFling: false,
                  onError: (error) {
                    debugPrint("PDF 뷰어 에러: $error");
                  },
                  onPageError: (page, error) {
                    debugPrint("페이지 $page 에러: $error");
                  },
                ),
    );
  }
}
