import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class TaskDetailPage extends StatefulWidget {
  final String courseId;
  final String assignmentId;

  TaskDetailPage({required this.courseId, required this.assignmentId});

  @override
  _TaskDetailPageState createState() => _TaskDetailPageState();
}

class _TaskDetailPageState extends State<TaskDetailPage> {
  final TextEditingController _pdfFileController = TextEditingController();
  Uint8List? _selectedPdfBytes;
  String _selectedPdfFileName = '';
  bool _hasSubmitted = false;
  String? _submittedFileName;

  @override
  void dispose() {
    _pdfFileController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    checkSubmissionStatus();
  }

  Future<void> checkSubmissionStatus() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String userId = user.uid;
      DocumentSnapshot submissionSnapshot = await FirebaseFirestore.instance
          .collection('coba/course/courses')
          .doc(widget.courseId)
          .collection('tugas')
          .doc(widget.assignmentId)
          .collection('submissions')
          .doc(userId)
          .get();

      if (submissionSnapshot.exists) {
        setState(() {
          _hasSubmitted = true;
          _submittedFileName = submissionSnapshot['fileName'];
        });
      }
    }
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
    if (_hasSubmitted) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Anda sudah mengunggah tugas sebelumnya.'),
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
      firebase_storage.Reference storageRef =
          firebase_storage.FirebaseStorage.instance.ref().child(
              'course/${widget.courseId}/assignments/${widget.assignmentId}/$fileName');

      await storageRef.putData(_selectedPdfBytes!);

      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String userId = user.uid;

        await FirebaseFirestore.instance
            .collection('coba/course/courses')
            .doc(widget.courseId)
            .collection('tugas')
            .doc(widget.assignmentId)
            .collection('submissions')
            .doc(userId)
            .set({'fileName': fileName});

        setState(() {
          _hasSubmitted = true;
          _submittedFileName = fileName;
        });

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
                  },
                ),
              ],
            );
          },
        );
      }
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

  Future<void> _changeFile() async {
    FilePickerResult? result = await FilePicker.platform
        .pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
    if (result != null) {
      PlatformFile file = result.files.single;
      setState(() {
        _selectedPdfBytes = file.bytes;
        _selectedPdfFileName = file.name;
        _pdfFileController.text = _selectedPdfFileName;
      });

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Sukses'),
            content: Text('File berhasil diubah.'),
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Tugas'),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('coba/course/courses')
            .doc(widget.courseId)
            .collection('tugas')
            .doc(widget.assignmentId)
            .snapshots(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Terjadi kesalahan: ${snapshot.error}');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Text('Memuat...');
          }

          if (snapshot.hasData && snapshot.data!.exists) {
            Map<String, dynamic> taskData =
                snapshot.data!.data() as Map<String, dynamic>;

            String taskTitle = taskData['materi'] ?? '';
            String taskDescription = taskData['pertemuan'] ?? '';
            Timestamp deadlineTimestamp = taskData['deadline'];
            DateTime deadline = deadlineTimestamp.toDate();

            return Padding(
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
                  if (_hasSubmitted)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tugas sudah diunggah: $_submittedFileName',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: _changeFile,
                          child: Text('Ubah File'),
                        ),
                      ],
                    )
                  else
                    Column(
                      children: [
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
                ],
              ),
            );
          }

          return Text('Tugas tidak ditemukan.');
        },
      ),
    );
  }
}
