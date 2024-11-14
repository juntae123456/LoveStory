import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotePage extends StatefulWidget {
  final String title;
  final String listId;

  const NotePage({super.key, required this.title, required this.listId});

  @override
  _NotePageState createState() => _NotePageState();
}

class _NotePageState extends State<NotePage> {
  final TextEditingController _noteController = TextEditingController();

  Future<void> _addNote() async {
    if (_noteController.text.isEmpty) return;

    await FirebaseFirestore.instance
        .collection('lists')
        .doc(widget.listId)
        .collection('notes')
        .add({
      'text': _noteController.text,
      'checked': false,
    });

    _noteController.clear();
    Navigator.of(context).pop(); // 다이얼로그 닫기
  }

  Future<void> _toggleCheck(String noteId, bool currentValue) async {
    await FirebaseFirestore.instance
        .collection('lists')
        .doc(widget.listId)
        .collection('notes')
        .doc(noteId)
        .update({'checked': !currentValue});
  }

  void _showAddNoteDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('노트 내용 입력'),
          content: TextField(
            controller: _noteController,
            decoration: InputDecoration(hintText: '노트 내용을 입력하세요'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 다이얼로그 닫기
              },
              child: Text('취소'),
            ),
            TextButton(
              onPressed: _addNote,
              child: Text('추가'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(String noteId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('삭제 확인'),
          content: Text('이 노트를 삭제하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 다이얼로그 닫기
              },
              child: Text('취소'),
            ),
            TextButton(
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection('lists')
                    .doc(widget.listId)
                    .collection('notes')
                    .doc(noteId)
                    .delete();
                Navigator.of(context).pop(); // 다이얼로그 닫기
              },
              child: Text('삭제'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('lists')
                  .doc(widget.listId)
                  .collection('notes')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }
                final notes = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: notes.length,
                  itemBuilder: (context, index) {
                    final note = notes[index];
                    return ListTile(
                      leading: Checkbox(
                        value: note['checked'],
                        onChanged: (bool? value) {
                          _toggleCheck(note.id, note['checked']);
                        },
                      ),
                      title: Text(
                        note['text'],
                        style: TextStyle(
                          decoration: note['checked']
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                        ),
                      ),
                      onLongPress: () {
                        _showDeleteConfirmationDialog(note.id);
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddNoteDialog,
        child: Icon(Icons.add),
      ),
    );
  }
}
