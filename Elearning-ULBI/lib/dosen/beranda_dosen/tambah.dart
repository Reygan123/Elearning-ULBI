import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddCoursePage extends StatelessWidget {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _sksController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tambah Kursus'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Judul Kursus',
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Deskripsi Kursus',
              ),
            ),
            TextField(
              controller: _sksController,
              decoration: InputDecoration(
                labelText: 'Deskripsi Kursus',
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                String title = _titleController.text;
                String description = _descriptionController.text;
                String sks = _descriptionController.text;
                _saveCourse(title, description, sks);
                Navigator.pop(context);
              },
              child: Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  void _saveCourse(String title, String description, String sks) {
    // Melakukan penyimpanan data kursus ke Firestore dengan menggunakan path collection "coba/course/courses"
    FirebaseFirestore.instance.collection('coba/course/courses').add({
      'title': title,
      'description': description,
      'sks': sks,
    });
    print('Kursus disimpan: $title, $description, $sks');
  }
}
