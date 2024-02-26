import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddTaskPage extends StatefulWidget {
  final String courseId;

  AddTaskPage({required this.courseId});

  @override
  _AddTaskPageState createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _taskNameController = TextEditingController();
  final TextEditingController _materiController = TextEditingController();
  final TextEditingController _pertemuanController = TextEditingController();
  final TextEditingController _deadlineController = TextEditingController();

  void _addTask() {
    if (_formKey.currentState!.validate()) {
      final String taskName = _taskNameController.text.trim();
      final String materi = _materiController.text.trim();
      final String pertemuan = _pertemuanController.text.trim();
      final Timestamp deadline =
          Timestamp.fromDate(DateTime.parse(_deadlineController.text));

      FirebaseFirestore.instance
          .collection('coba/course/courses')
          .doc(widget.courseId)
          .collection('tugas')
          .add({
        'taskName': taskName,
        'materi': materi,
        'pertemuan': pertemuan,
        'deadline': deadline,
      }).then((value) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Tugas berhasil ditambahkan.'),
        ));
        Navigator.pop(context);
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Terjadi kesalahan. Tugas gagal ditambahkan.'),
        ));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tambah Tugas'),
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _taskNameController,
                decoration: InputDecoration(
                  labelText: 'Nama Tugas',
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Nama tugas tidak boleh kosong';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _materiController,
                decoration: InputDecoration(
                  labelText: 'Materi',
                ),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _pertemuanController,
                decoration: InputDecoration(
                  labelText: 'Pertemuan',
                ),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _deadlineController,
                decoration: InputDecoration(
                  labelText: 'Deadline (yyyy-mm-dd)',
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Deadline tidak boleh kosong';
                  }
                  // Validasi format tanggal
                  final pattern = r'^\d{4}-\d{2}-\d{2}$';
                  final regex = RegExp(pattern);
                  if (!regex.hasMatch(value)) {
                    return 'Format tanggal tidak valid';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _addTask,
                child: Text('Tambah'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
