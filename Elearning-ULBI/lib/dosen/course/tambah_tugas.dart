import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';

class AddTaskPage extends StatefulWidget {
  final String document;
  final String taskDoc;

  const AddTaskPage({required this.document, required this.taskDoc});

  @override
  _AddTaskPageState createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  TextEditingController _taskNameController = TextEditingController();
  TextEditingController _taskDescriptionController = TextEditingController();
  PlatformFile? _selectedFile;
  DateTime? _deadline;

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

  void _selectDeadline() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (selectedDate != null) {
      final selectedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (selectedTime != null) {
        setState(() {
          _deadline = DateTime(
            selectedDate.year,
            selectedDate.month,
            selectedDate.day,
            selectedTime.hour,
            selectedTime.minute,
          );
        });
      }
    }
  }

  Future<void> _addTask() async {
    String taskName = _taskNameController.text.trim();
    String taskDescription = _taskDescriptionController.text.trim();

    if (taskName.isNotEmpty &&
        taskDescription.isNotEmpty &&
        _selectedFile != null) {
      try {
        String fileName = _selectedFile!.name;
        Uint8List? fileBytes = _selectedFile!.bytes;

        if (fileBytes != null) {
          // Upload file PDF ke Firebase Storage
          Reference storageRef = FirebaseStorage.instance.ref().child(fileName);
          UploadTask uploadTask = storageRef.putData(fileBytes);
          TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() {});

          // Ambil URL download file PDF yang diunggah
          String downloadURL = await taskSnapshot.ref.getDownloadURL();

          // Dapatkan pengguna saat ini
          User? user = FirebaseAuth.instance.currentUser;
          String userId = user != null ? user.uid : '';

          // Tambahkan data tugas ke Firestore
          FirebaseFirestore.instance
              .collection('coba/course/courses')
              .doc(widget.document)
              .collection('tugas')
              .doc(widget.taskDoc)
              .collection('tugas')
              .add({
            'name': taskName,
            'deskripsi': taskDescription,
            'fileURL': downloadURL,
            'fileName': fileName,
            'uploadedBy': userId,
            'deadline':
                _deadline != null ? Timestamp.fromDate(_deadline!) : null,
          }).then((value) {
            // Tugas berhasil ditambahkan
            Navigator.pop(context);
          }).catchError((error) {
            // Terjadi kesalahan dalam menambahkan tugas
            // Tampilkan pesan kesalahan atau lakukan penanganan yang sesuai
            print('Terjadi kesalahan saat menambahkan tugas: $error');
          });
        } else {
          // File tidak valid atau tidak ada bytes yang ditemukan
          print('File tidak valid atau tidak ada bytes yang ditemukan.');
        }
      } catch (error) {
        // Terjadi kesalahan dalam mengunggah file
        // Tampilkan pesan kesalahan atau lakukan penanganan yang sesuai
        print('Terjadi kesalahan saat mengunggah file: $error');
      }
    }
  }

  Widget _judul(judul, color, size) {
    return Text(
      judul,
      style: TextStyle(
        color: color,
        fontSize: size,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _space() {
    return SizedBox(height: 20);
  }

  Widget _spasi(jarak) {
    return SizedBox(height: jarak);
  }

  Widget _controller(controller, text) {
    return Container(
        padding: EdgeInsets.all(10),
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
          border: Border.all(
            color: Colors.grey.withOpacity(0.5),
            width: 1.0,
          ),
        ),
        child: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: text,
            labelStyle: TextStyle(
              color: Colors.grey,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.transparent),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.transparent),
            ),
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(
          color: Colors.black,
        ),
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
                alignment: Alignment.center,
                child: _judul('Tambah Tugas', Colors.black, 18)),
            _space(),
            _judul('Nama Tugas', Colors.black, 14),
            _spasi(6),
            _controller(_taskNameController, 'Nama Tugas'),
            _space(),
            _judul('Deskripsi', Colors.black, 14),
            _spasi(6),
            _controller(_taskDescriptionController, 'Deskripsi Tugas'),
            _space(),
            _judul('Tambah File', Colors.black, 14),
            _spasi(6),
            ElevatedButton(
              onPressed: _selectFile,
              child: Text('Pilih File PDF'),
              style: ElevatedButton.styleFrom(
                primary: Colors.deepOrange,
                minimumSize: Size(MediaQuery.of(context).size.width, 40),
              ),
            ),
            _spasi(6),
            if (_selectedFile != null)
              Container(
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset:
                            Offset(0, 3), // changes the position of the shadow
                      ),
                    ],
                  ),
                  child: Text('File terpilih: ${_selectedFile!.name}')),
            _space(),
            _judul('Deadline', Colors.black, 14),
            _spasi(6),
            Container(
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3), // changes the position of the shadow
                  ),
                ],
              ),
              child: GestureDetector(
                onTap: _selectDeadline,
                child: Row(
                  children: [
                    Icon(Icons.calendar_today),
                    SizedBox(width: 8.0),
                    Text(
                      _deadline != null
                          ? DateFormat('dd MMM yyyy HH:mm').format(_deadline!)
                          : 'Pilih Batas Waktu',
                    ),
                  ],
                ),
              ),
            ),
            _space(),
            ElevatedButton(
              onPressed: _addTask,
              style: ElevatedButton.styleFrom(
                primary: Colors.deepOrange,
                minimumSize: Size(MediaQuery.of(context).size.width, 40),
              ),
              child: Text('Tambah Tugas'),
            ),
          ],
        ),
      ),
    );
  }
}
