import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class TaskDetailPage extends StatefulWidget {
  final Map<String, dynamic> taskData;

  TaskDetailPage({required this.taskData});

  @override
  _TaskDetailPageState createState() => _TaskDetailPageState();
}

class _TaskDetailPageState extends State<TaskDetailPage> {
  final TextEditingController _pdfFileController = TextEditingController();
  Uint8List? _selectedPdfBytes;
  String _selectedPdfFileName = '';

  @override
  void dispose() {
    _pdfFileController.dispose();
    super.dispose();
  }

  Future<void> _pickPdfFile() async {
    FilePickerResult? result = await FilePicker.platform
        .pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
    if (result != null) {
      PlatformFile file = result.files.single;
      setState(() {
        _selectedPdfBytes = file.bytes;
        _selectedPdfFileName = file.name;
        _pdfFileController.text = _selectedPdfFileName;
      });
    }
  }

  Future<void> _submitTask() async {
    if (_selectedPdfBytes == null) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Pilih file PDF terlebih dahulu.'),
            actions: [
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      return;
    }

    try {
      String fileName = _selectedPdfFileName;
      firebase_storage.Reference storageRef = firebase_storage
          .FirebaseStorage.instance
          .ref()
          .child('file tugas/$fileName');

      await storageRef.putData(_selectedPdfBytes!);

      // ignore: use_build_context_synchronously
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Sukses'),
            content: Text('Tugas berhasil diunggah.'),
            actions: [
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } catch (e) {
      print('Error uploading file: $e');
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Terjadi kesalahan saat mengunggah file.'),
            actions: [
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    String taskTitle = widget.taskData['materi'] ?? '';
    String taskDescription = widget.taskData['pertemuan'] ?? '';
    Timestamp deadlineTimestamp = widget.taskData['deadline'];
    DateTime deadline = deadlineTimestamp.toDate();

    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Tugas'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nama Tugas: $taskTitle',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Deskripsi: $taskDescription'),
            SizedBox(height: 8),
            Text(
              'Deadline: ${deadline.day}/${deadline.month}/${deadline.year}',
            ),
            SizedBox(height: 16),
            TextField(
              controller: _pdfFileController,
              decoration: InputDecoration(
                labelText: 'Pilih file PDF',
                border: OutlineInputBorder(),
              ),
              readOnly: true,
              onTap: _pickPdfFile,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _submitTask,
              child: Text('Submit Tugas'),
            ),
          ],
        ),
      ),
    );
  }
}
