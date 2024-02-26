import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:intl/intl.dart';

class DetailTugasPage extends StatefulWidget {
  final String courseId;
  final String taskId;
  final String tugasData;

  DetailTugasPage(
      {required this.courseId, required this.taskId, required this.tugasData});

  @override
  _DetailTugasPageState createState() => _DetailTugasPageState();
}

class _DetailTugasPageState extends State<DetailTugasPage> {
  final TextEditingController _pdfFileController = TextEditingController();
  Uint8List? _selectedPdfBytes;
  String _selectedPdfFileName = '';
  bool _hasSubmitted = false;
  String? _submittedFileName;
  // String? _nilai;
  Timestamp? _submitTime;

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

  Widget _biasa(biasa, color) {
    return Text(
      biasa,
      style: TextStyle(
        color: color,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _kotak(teks, color) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.all(20),
      child: Text(
        teks,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
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
    );
  }

  Future<void> checkSubmissionStatus() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String userId = user.uid;
      DocumentSnapshot submissionSnapshot = await FirebaseFirestore.instance
          .collection('coba/course/courses')
          .doc(widget.courseId)
          .collection('tugas')
          .doc(widget.taskId)
          .collection('tugas')
          .doc(widget.tugasData)
          .collection('submissions')
          .doc(userId)
          .get();

      if (submissionSnapshot.exists) {
        setState(() {
          _hasSubmitted = true;
          _submittedFileName = submissionSnapshot['fileName'];
          _submitTime = submissionSnapshot['submitTime'] as Timestamp?;
          // _nilai = submissionSnapshot['nilai'] ?? '';
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
              'Mata Kuliah/${widget.courseId}/Pertemuan/${widget.taskId}/Tugas/${widget.tugasData}/$fileName');

      await storageRef.putData(_selectedPdfBytes!);

      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String userId = user.uid;

        // Mendapatkan waktu submit
        DateTime submitTime = DateTime.now();

        await FirebaseFirestore.instance
            .collection('coba/course/courses')
            .doc(widget.courseId)
            .collection('tugas')
            .doc(widget.taskId)
            .collection('tugas')
            .doc(widget.tugasData)
            .collection('submissions')
            .doc(userId)
            .set({
          'fileName': fileName,
          'userId': userId,
          'submitTime': submitTime
        });

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
          backgroundColor: Colors.white,
          elevation: 0,
          leading: const BackButton(
            color: Colors.black,
          ),
        ),
        body: Column(children: [
          Container(
            width: MediaQuery.of(context).size.width,
            height: 120,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(children: [
              Align(
                  alignment: Alignment
                      .bottomCenter, // Menempatkan widget di pojok kiri atas
                  child: _judul('Detail Tugas', Colors.black, 18)),
            ]),
          ),
          _space(),
          Expanded(
            child: StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('coba/course/courses')
                  .doc(widget.courseId)
                  .collection('tugas')
                  .doc(widget.taskId)
                  .collection('tugas')
                  .doc(widget.tugasData)
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<DocumentSnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Text('Terjadi kesalahan: ${snapshot.error}');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Text('Memuat...');
                }

                if (snapshot.hasData && snapshot.data!.exists) {
                  Map<String, dynamic> taskData =
                      snapshot.data!.data() as Map<String, dynamic>;

                  String taskTitle = taskData['name'] ?? '';
                  String taskDescription = taskData['deskripsi'] ?? '';
                  String fileName = taskData['fileName'] ?? '';
                  String fileUrl = taskData['fileURL'] ?? '';
                  // String nilai = _nilai ?? '';
                  final Timestamp? time = _submitTime;
                  final DateTime? submit = time != null ? time.toDate() : null;
                  final Timestamp? deadlineTimestamp = taskData['deadline'];
                  final DateTime? deadline = deadlineTimestamp != null
                      ? deadlineTimestamp.toDate()
                      : null;

                  bool isSubmitted =
                      _hasSubmitted || _submittedFileName != null;
                  String status = isSubmitted ? 'Selesai' : 'Belum';
                  Color statusColor = isSubmitted
                      ? Color.fromARGB(255, 47, 255, 0)
                      : Colors.red;

                  return Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width,
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(children: [
                                  Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: Colors.deepOrange,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      Icons.file_copy,
                                      size: 30,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Container(
                                    width: 160,
                                    child: Text(
                                      '$taskTitle',
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ]),
                                ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    primary:
                                        statusColor, // Ubah warna latar belakang sesuai kebutuhan
                                  ),
                                  child: Text(
                                    '$status',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors
                                          .white, // Ubah warna teks sesuai kebutuhan
                                    ),
                                  ),
                                ),
                              ]),
                        ),
                        SizedBox(height: 10),
                        Container(
                            width: MediaQuery.of(context).size.width,
                            padding: EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (deadline != null)
                                    Text(
                                      '${DateFormat('dd MMM yyyy HH:mm').format(deadline)}',
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.red,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  SizedBox(height: 4),
                                  _judul('Deskripsi', Colors.black, 14),
                                  _biasa('$taskDescription', Colors.black)
                                ])),
                        SizedBox(height: 10),
                        Container(
                          width: MediaQuery.of(context).size.width,
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _judul('File Tugas', Colors.black, 14),
                                _biasa('$fileName', Colors.blue),
                              ]),
                        ),
                        SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PDFView(
                                  filePath: fileUrl,
                                ),
                              ),
                            );
                          },
                          child: _judul('Buka', Colors.white, 12),
                          style: ElevatedButton.styleFrom(
                            primary: Colors.deepOrange,
                          ),
                        ),
                        SizedBox(height: 10),
                        if (isSubmitted)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                  padding: EdgeInsets.all(20),
                                  width: MediaQuery.of(context).size.width,
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Tugas sudah diunggah: ${_submittedFileName ?? ''}',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.blue,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          'Selesai: ${DateFormat('dd MMM yyyy HH:mm').format(submit!)}',
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.green,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        // Container(
                                        //     child: Row(children: [
                                        //   _judul('Nilai : ', Colors.black, 14),
                                        //   _judul(nilai, Colors.blue, 14),
                                        //   _judul('/100', Colors.black, 14),
                                        // ]))
                                      ])),
                              SizedBox(height: 8),
                              ElevatedButton(
                                onPressed: _changeFile,
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                          Colors.deepOrange),
                                  fixedSize: MaterialStateProperty.all<Size>(
                                    Size(120,
                                        30), // Menggunakan lebar layar perangkat
                                  ),
                                ),
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
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                          Colors.deepOrange),
                                  fixedSize: MaterialStateProperty.all<Size>(
                                    Size(MediaQuery.of(context).size.width,
                                        30), // Menggunakan lebar layar perangkat
                                  ),
                                ),
                                child: Text('Submit Tugas'),
                              ),
                            ],
                          ),
                        SizedBox(height: 16),
                      ],
                    ),
                  );
                }

                return Text('Tugas tidak ditemukan.');
              },
            ),
          )
        ]));
  }
}
