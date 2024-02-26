import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elearning/dosen/course/lihat_mhs.dart';
import 'package:elearning/dosen/course/edit.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:intl/intl.dart';

class LihatPage extends StatefulWidget {
  final String DocId;
  final String TaskId;
  final String DetailId;

  LihatPage(
      {required this.DocId, required this.TaskId, required this.DetailId});

  @override
  _LihatPageState createState() => _LihatPageState();
}

class _LihatPageState extends State<LihatPage> {
  @override
  void initState() {
    super.initState();
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
      ),
    );
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
                _judul('Detail Tugas', Colors.black, 18),
                SizedBox(height: 50),
              ])),
          Container(
              height: MediaQuery.of(context).size.height,
              padding: EdgeInsets.all(20),
              child: Column(children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DosenListPage(
                            courseId: widget.DocId,
                            taskId: widget.TaskId,
                            tugasData: widget.DetailId,
                          ),
                        ),
                      );
                    },
                    child: _jadul('Lihat Mahasiswa', Colors.white, 12),
                    style: ElevatedButton.styleFrom(
                      primary: Colors.deepOrange,
                    ),
                  ),
                ),
                _spasi(15),
                Expanded(
                    child: StreamBuilder<DocumentSnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('coba/course/courses')
                            .doc(widget.DocId)
                            .collection('tugas')
                            .doc(widget.TaskId)
                            .collection('tugas')
                            .doc(widget.DetailId)
                            .snapshots(),
                        builder: (BuildContext context,
                            AsyncSnapshot<DocumentSnapshot> snapshot) {
                          if (snapshot.hasError) {
                            return Text('Terjadi kesalahan.');
                          }

                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return CircularProgressIndicator();
                          }

                          if (snapshot.hasData && snapshot.data!.exists) {
                            Map<String, dynamic> Tdata =
                                snapshot.data!.data() as Map<String, dynamic>;

                            final String name = Tdata['name'] ?? '';
                            final String deskripsi = Tdata['deskripsi'] ?? '';
                            final String fileURL = Tdata['fileURL'] ?? '';
                            final String fileName = Tdata['fileName'] ?? '';
                            final Timestamp? deadlineTimestamp =
                                Tdata['deadline'];
                            final DateTime? deadline = deadlineTimestamp != null
                                ? deadlineTimestamp.toDate()
                                : null;
                            return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _jadul('Nama Tugas', Colors.black, 14),
                                  _spasi(6),
                                  _kotak(name, Colors.black),
                                  _space(),
                                  _jadul('Deskripsi', Colors.black, 14),
                                  _spasi(6),
                                  _kotak(deskripsi, Colors.black),
                                  _space(),
                                  _jadul('Deadline', Colors.black, 14),
                                  _spasi(6),
                                  _kotak(
                                    deadline != null
                                        ? DateFormat('dd MMM yyyy HH:mm')
                                            .format(deadline)
                                        : 'Tidak ada batas waktu',
                                    Colors.red,
                                  ),
                                  _space(),
                                  _jadul('File', Colors.black, 14),
                                  _spasi(6),
                                  _kotak(fileName, Colors.blue),
                                  _space(),
                                  Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        ElevatedButton(
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => PDFView(
                                                  filePath: fileURL,
                                                ),
                                              ),
                                            );
                                          },
                                          child:
                                              _judul('Buka', Colors.white, 12),
                                          style: ElevatedButton.styleFrom(
                                            primary: Colors.deepOrange,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        ElevatedButton(
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    EditTaskPage(
                                                  document: widget.DocId,
                                                  taskDoc: widget.TaskId,
                                                  taskId: widget.DetailId,
                                                ),
                                              ),
                                            );
                                          },
                                          child:
                                              _judul('Ubah', Colors.white, 12),
                                          style: ElevatedButton.styleFrom(
                                            primary: Colors.deepOrange,
                                          ),
                                        ),
                                      ]),
                                  _space(),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: Text('Konfirmasi Hapus'),
                                              content: Text(
                                                  'Apakah Anda yakin ingin menghapus tugas ini?'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                  child: _judul('Batal',
                                                      Colors.white, 12),
                                                ),
                                                TextButton(
                                                  onPressed: () {
                                                    FirebaseFirestore.instance
                                                        .collection(
                                                            'coba/course/courses')
                                                        .doc(widget.DocId)
                                                        .collection('tugas')
                                                        .doc(widget.TaskId)
                                                        .collection('tugas')
                                                        .doc(widget.DetailId)
                                                        .delete()
                                                        .then((value) {
                                                      Navigator.pop(context);
                                                    }).catchError((error) {});
                                                  },
                                                  child: _judul('Hapus',
                                                      Colors.black, 12),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                      child: _judul('Hapus', Colors.white, 12),
                                      style: ElevatedButton.styleFrom(
                                        primary: Colors.red,
                                      ),
                                    ),
                                  )
                                ]);
                          }
                          return Text('Detail Tugas Tidak Di Temukan');
                        }))
              ]))
        ]))));
  }
}
