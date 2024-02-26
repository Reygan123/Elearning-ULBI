import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddCoursePage extends StatefulWidget {
  @override
  _AddCoursePageState createState() => _AddCoursePageState();
}

class _AddCoursePageState extends State<AddCoursePage> {
  final TextEditingController _userIdController = TextEditingController();
  final TextEditingController _courseNameController = TextEditingController();

  void _addCourse() {
    String userId = _userIdController.text;
    String courseName = _courseNameController.text;

    if (userId.isNotEmpty && courseName.isNotEmpty) {
      // Menambahkan dokumen ke dalam koleksi "courses"
      FirebaseFirestore.instance
          .collection('courses')
          .doc(courseName)
          .set({'userId': userId}).then((value) {
        // Menampilkan notifikasi jika berhasil
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Sukses'),
              content: Text('Dokumen berhasil ditambahkan ke koleksi.'),
              actions: [
                TextButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    // Kembali ke halaman sebelumnya
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }).catchError((error) {
        // Menampilkan notifikasi jika terjadi kesalahan
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Error'),
              content: Text('Terjadi kesalahan saat menambahkan dokumen.'),
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
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tambahkan Course'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _userIdController,
              decoration: InputDecoration(
                labelText: 'User/ID Dosen',
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _courseNameController,
              decoration: InputDecoration(
                labelText: 'Nama Course',
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _addCourse,
              child: Text('Tambahkan Course'),
            ),
          ],
        ),
      ),
    );
  }
}
