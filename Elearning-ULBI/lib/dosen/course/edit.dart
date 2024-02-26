import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class EditTaskPage extends StatefulWidget {
  final String document;
  final String taskDoc;
  final String taskId;

  const EditTaskPage({
    required this.document,
    required this.taskDoc,
    required this.taskId,
  });

  @override
  _EditTaskPageState createState() => _EditTaskPageState();
}

class _EditTaskPageState extends State<EditTaskPage> {
  TextEditingController _taskNameController = TextEditingController();
  TextEditingController _taskDescriptionController = TextEditingController();
  PlatformFile? _selectedFile;

  @override
  void initState() {
    super.initState();
    _fetchTaskData();
  }

  void _fetchTaskData() {
    FirebaseFirestore.instance
        .collection('coba/course/courses')
        .doc(widget.document)
        .collection('tugas')
        .doc(widget.taskDoc)
        .collection('tugas')
        .doc(widget.taskId)
        .get()
        .then((taskSnapshot) {
      if (taskSnapshot.exists) {
        Map<String, dynamic> taskData =
            taskSnapshot.data() as Map<String, dynamic>;
        _taskNameController.text = taskData['name'] ?? '';
        _taskDescriptionController.text = taskData['deskripsi'] ?? '';
      }
    }).catchError((error) {
      // Error handling
      print('Terjadi kesalahan saat mengambil data tugas: $error');
    });
  }

  void _selectFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      setState(() {
        _selectedFile = result.files.first;
      });
    }
  }

  Future<void> _updateTask() async {
    String taskName = _taskNameController.text.trim();
    String taskDescription = _taskDescriptionController.text.trim();

    if (taskName.isNotEmpty && taskDescription.isNotEmpty) {
      try {
        String fileName = _selectedFile?.name ?? '';
        Uint8List? fileBytes = _selectedFile?.bytes;

        if (fileBytes != null) {
          // Upload file PDF ke Firebase Storage jika ada perubahan
          Reference storageRef = FirebaseStorage.instance.ref().child(fileName);
          UploadTask uploadTask = storageRef.putData(fileBytes);
          TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() {});

          // Ambil URL download file PDF yang diunggah
          String downloadURL = await taskSnapshot.ref.getDownloadURL();

          // Dapatkan pengguna saat ini
          User? user = FirebaseAuth.instance.currentUser;
          String userId = user != null ? user.uid : '';

          // Perbarui data tugas di Firestore
          FirebaseFirestore.instance
              .collection('coba/course/courses')
              .doc(widget.document)
              .collection('tugas')
              .doc(widget.taskDoc)
              .collection('tugas')
              .doc(widget.taskId)
              .update({
            'name': taskName,
            'deskripsi': taskDescription,
            'fileURL': downloadURL,
            'fileName': fileName,
            'uploadedBy': userId,
          }).then((value) {
            // Tugas berhasil diperbarui
            Navigator.pop(context);
          }).catchError((error) {
            // Terjadi kesalahan dalam memperbarui tugas
            // Tampilkan pesan kesalahan atau lakukan penanganan yang sesuai
          });
        } else {
          // Jika tidak ada perubahan file, hanya perbarui data tugas tanpa mengunggah file
          FirebaseFirestore.instance
              .collection('coba/course/courses')
              .doc(widget.document)
              .collection('tugas')
              .doc(widget.taskDoc)
              .collection('tugas')
              .doc(widget.taskId)
              .update({
            'name': taskName,
            'deskripsi': taskDescription,
          }).then((value) {
            // Tugas berhasil diperbarui
            Navigator.pop(context);
          }).catchError((error) {
            // Terjadi kesalahan dalam memperbarui tugas
            // Tampilkan pesan kesalahan atau lakukan penanganan yang sesuai
          });
        }
      } catch (error) {
        // Terjadi kesalahan dalam mengunggah file
        // Tampilkan pesan kesalahan atau lakukan penanganan yang sesuai
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ubah Tugas'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _taskNameController,
              decoration: InputDecoration(
                labelText: 'Nama Tugas',
              ),
            ),
            TextField(
              controller: _taskDescriptionController,
              decoration: InputDecoration(
                labelText: 'Deskripsi Tugas',
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _selectFile,
              child: Text('Ubah File PDF'),
            ),
            SizedBox(height: 16.0),
            if (_selectedFile != null)
              Text('File terpilih: ${_selectedFile!.name}'),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _updateTask,
              child: Text('Simpan Perubahan'),
            ),
          ],
        ),
      ),
    );
  }
}
