import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

class DetailPage extends StatefulWidget {
  final String userId;
  final String courseId;
  final String taskId;
  final String tugasData;

  DetailPage({
    required this.userId,
    required this.courseId,
    required this.taskId,
    required this.tugasData,
  });

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  TextEditingController _nilaiController = TextEditingController();
  Map<String, dynamic>? userData;
  StreamSubscription<QuerySnapshot>? _streamSubscription;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .get();

    if (snapshot.exists) {
      setState(() {
        userData = snapshot.data() as Map<String, dynamic>?;
      });
    }
  }

  @override
  void dispose() {
    _streamSubscription?.cancel(); // Cancel the stream subscription
    super.dispose();
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

  Widget _jadul(judul, color, size) {
    return Text(
      judul,
      style: TextStyle(
        color: color,
        fontSize: size,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _space() {
    return SizedBox(height: 10);
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
      ),
    );
  }

  void submitNilai(String nilai) {
    FirebaseFirestore.instance
        .collection('coba/course/courses')
        .doc(widget.courseId)
        .collection('tugas')
        .doc(widget.taskId)
        .collection('tugas')
        .doc(widget.tugasData)
        .collection('submissions')
        .doc(widget.userId)
        .update({'nilai': nilai}).then((value) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Nilai berhasil disimpan'),
        ),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyimpan nilai'),
        ),
      );
    });
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
        body: SingleChildScrollView(
            child: Container(
                child: Column(children: [
          Container(
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                color: Colors.white,
              ),
              child: Column(children: [
                _judul('Detail Mahasiswa', Colors.black, 18),
                _spasi(50),
              ])),
          Container(
            height: MediaQuery.of(context).size.height,
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                  stream: firestore
                      .collection('coba/course/courses')
                      .doc(widget.courseId)
                      .collection('tugas')
                      .doc(widget.taskId)
                      .collection('tugas')
                      .doc(widget.tugasData)
                      .collection('submissions')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    // Mengambil data tugas dari snapshot Firestore
                    final tugas = snapshot.data!.docs;

                    return ListView.builder(
                      itemCount: tugas.length,
                      itemBuilder: (context, index) {
                        final tugasData =
                            tugas[index].data() as Map<String, dynamic>?;

                        final userId = tugasData?['userId'] ?? '';
                        final fileTugas = tugasData?['fileName'] ?? '';
                        final fileUrl = tugasData?['fileURL'] ?? '';
                        final nilai = tugasData?['nilai'] ?? '';

                        return FutureBuilder<DocumentSnapshot>(
                          future:
                              firestore.collection('users').doc(userId).get(),
                          builder: (context, userSnapshot) {
                            if (!userSnapshot.hasData) {
                              return Container();
                            }

                            final userData = userSnapshot.data!.data()
                                as Map<String, dynamic>?;

                            final npm = userData?['npm'] ?? '';
                            final username = userData?['name'] ?? '';
                            final email = userData?['email'] ?? '';
                            final jurusan = userData?['jurusan'] ?? '';
                            final kelas = userData?['kelas'] ?? '';

                            return Container(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _jadul('Npm', Colors.black, 14),
                                  _spasi(6),
                                  _kotak(npm, Colors.black),
                                  _space(),
                                  _jadul('Nama', Colors.black, 14),
                                  _spasi(6),
                                  _kotak(username, Colors.black),
                                  _space(),
                                  _jadul('Email', Colors.black, 14),
                                  _spasi(6),
                                  _kotak(email, Colors.black),
                                  _space(),
                                  _jadul('Prodi', Colors.black, 14),
                                  _spasi(6),
                                  _kotak('$jurusan - $kelas', Colors.black),
                                  _space(),
                                  _jadul('File', Colors.black, 14),
                                  _spasi(6),
                                  _kotak(fileTugas, Colors.blue),
                                  _spasi(6),
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
                                    child: _jadul('Buka', Colors.white, 12),
                                    style: ElevatedButton.styleFrom(
                                      primary: Colors.deepOrange,
                                    ),
                                  ),
                                  _space(),
                                  _jadul('Nilai', Colors.black, 14),
                                  _spasi(6),
                                  _kotak(nilai, Colors.black),
                                  _space(),
                                  _jadul('Input Nilai', Colors.black, 14),
                                  _spasi(6),
                                  Container(
                                      padding: EdgeInsets.all(10),
                                      width: MediaQuery.of(context).size.width,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: Colors.white,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.5),
                                            spreadRadius: 2,
                                            blurRadius: 5,
                                            offset: Offset(0,
                                                3), // changes the position of the shadow
                                          ),
                                        ],
                                      ),
                                      child: TextField(
                                        controller: _nilaiController,
                                        keyboardType: TextInputType.number,
                                        decoration: const InputDecoration(
                                          hintText: 'Masukkan nilai',
                                          labelStyle: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          enabledBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.transparent),
                                          ),
                                          focusedBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.transparent),
                                          ),
                                        ),
                                      )),
                                  // TextFormField(
                                  //   controller: _nilaiController,
                                  //   keyboardType: TextInputType.number,
                                  //   decoration: InputDecoration(
                                  //     hintText: 'Masukkan nilai',
                                  //     border: OutlineInputBorder(),
                                  //   ),
                                  // ),
                                  _space(),
                                  ElevatedButton(
                                    onPressed: () {
                                      String nilai =
                                          _nilaiController.text.trim();
                                      if (nilai.isNotEmpty) {
                                        submitNilai(nilai);
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                                'Masukkan nilai terlebih dahulu'),
                                          ),
                                        );
                                      }
                                    },
                                    child: _jadul(
                                        'Simpan Nilai', Colors.white, 12),
                                    style: ElevatedButton.styleFrom(
                                      primary: Colors.deepOrange,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                )),
              ],
            ),
          ),
        ]))));
  }
}
