import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:elearning/dosen/course/tambah_tugas.dart';
import 'package:elearning/dosen/course/lihat_mhs.dart';
import 'package:elearning/dosen/course/edit.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:intl/intl.dart';

class CoursePage extends StatefulWidget {
  final User user;

  CoursePage({required this.user});

  @override
  _CoursePageState createState() => _CoursePageState();
}

class _CoursePageState extends State<CoursePage> {
  Stream<QuerySnapshot<Map<String, dynamic>>>? _coursesStream;

  @override
  void initState() {
    super.initState();

    // Mendapatkan stream courses yang mengandung dokumen dengan userId yang sama dengan userId yang diberikan
    _coursesStream = FirebaseFirestore.instance
        .collection('coba/course/courses')
        .snapshots();
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

  String _formatTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: _coursesStream,
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                        snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Terjadi kesalahan.'),
                    );
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  final List<QueryDocumentSnapshot<Map<String, dynamic>>>
                      courses = snapshot.data!.docs
                          .where(
                              (doc) => doc.data()['userId'] == widget.user.uid)
                          .toList();

                  if (courses.isEmpty) {
                    return Center(
                      child: Text('Tidak ada course yang tersedia.'),
                    );
                  }

                  return ListView(
                    children: courses
                        .map((DocumentSnapshot<Map<String, dynamic>> document) {
                      final Map<String, dynamic> data = document.data()!;

                      return Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width,
                              padding: EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage(data['bg']),
                                  fit: BoxFit.cover,
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  _judul(data['title'], Colors.white, 14),
                                  _biasa(data['description'], Colors.white),
                                  _space(),
                                  _space(),
                                ],
                              ),
                            ),
                            _space(),
                            StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                              stream: FirebaseFirestore.instance
                                  .collection('coba/course/courses')
                                  .doc(document.id)
                                  .collection('tugas')
                                  .snapshots(),
                              builder: (BuildContext context,
                                  AsyncSnapshot<
                                          QuerySnapshot<Map<String, dynamic>>>
                                      snapshot) {
                                if (snapshot.hasError) {
                                  return Text('Terjadi kesalahan.');
                                }

                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return CircularProgressIndicator();
                                }

                                final List<
                                        QueryDocumentSnapshot<
                                            Map<String, dynamic>>> tasks =
                                    snapshot.data!.docs;

                                if (tasks.isEmpty) {
                                  return Text('Tidak ada tugas.');
                                }

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: tasks.map((taskDoc) {
                                    final Map<String, dynamic> taskData =
                                        taskDoc.data();

                                    final String nama = taskData['nama'] ?? '';

                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '$nama',
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        // ...
                                        StreamBuilder<
                                            QuerySnapshot<
                                                Map<String, dynamic>>>(
                                          stream: FirebaseFirestore.instance
                                              .collection('coba/course/courses')
                                              .doc(document.id)
                                              .collection('tugas')
                                              .doc(taskDoc.id)
                                              .collection('tugas')
                                              .snapshots(),
                                          builder: (BuildContext context,
                                              AsyncSnapshot<
                                                      QuerySnapshot<
                                                          Map<String, dynamic>>>
                                                  snapshot) {
                                            if (snapshot.hasError) {
                                              return Text('Terjadi kesalahan.');
                                            }

                                            if (snapshot.connectionState ==
                                                ConnectionState.waiting) {
                                              return CircularProgressIndicator();
                                            }

                                            final List<
                                                    QueryDocumentSnapshot<
                                                        Map<String, dynamic>>>
                                                detailTasks =
                                                snapshot.data!.docs;

                                            if (detailTasks.isEmpty) {
                                              return Text(
                                                  'Tidak ada detail tugas.');
                                            }

                                            return ListView.builder(
                                              shrinkWrap: true,
                                              physics:
                                                  NeverScrollableScrollPhysics(),
                                              itemCount: detailTasks.length,
                                              itemBuilder:
                                                  (BuildContext context,
                                                      int index) {
                                                final Map<String, dynamic>
                                                    Tdata =
                                                    detailTasks[index].data();
                                                final String name =
                                                    Tdata['name'] ?? '';
                                                final String deskripsi =
                                                    Tdata['deskripsi'] ?? '';
                                                final String fileURL =
                                                    Tdata['fileURL'] ?? '';
                                                final String fileName =
                                                    Tdata['fileName'] ?? '';
                                                final Timestamp?
                                                    deadlineTimestamp =
                                                    Tdata['deadline'];
                                                final DateTime? deadline =
                                                    deadlineTimestamp != null
                                                        ? deadlineTimestamp
                                                            .toDate()
                                                        : null;
                                                return Column(children: [
                                                  Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        ElevatedButton(
                                                            onPressed: () {
                                                              Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                  builder:
                                                                      (context) =>
                                                                          AddTaskPage(
                                                                    document:
                                                                        document
                                                                            .id,
                                                                    taskDoc:
                                                                        taskDoc
                                                                            .id,
                                                                  ),
                                                                ),
                                                              );
                                                            },
                                                            child: _judul(
                                                                'Tambah',
                                                                Colors.white,
                                                                12),
                                                            style:
                                                                ElevatedButton
                                                                    .styleFrom(
                                                              primary: Colors
                                                                  .deepOrange,
                                                            )),
                                                        ElevatedButton(
                                                          onPressed: () {
                                                            showDialog(
                                                              context: context,
                                                              builder:
                                                                  (BuildContext
                                                                      context) {
                                                                return AlertDialog(
                                                                  title: Text(
                                                                      'Konfirmasi Hapus'),
                                                                  content: Text(
                                                                    'Apakah Anda yakin ingin menghapus tugas ini?',
                                                                  ),
                                                                  actions: [
                                                                    TextButton(
                                                                        onPressed:
                                                                            () {
                                                                          Navigator.pop(
                                                                              context);
                                                                        },
                                                                        child: _judul(
                                                                            'Batal',
                                                                            Colors.white,
                                                                            12)),
                                                                    TextButton(
                                                                        onPressed:
                                                                            () {
                                                                          FirebaseFirestore
                                                                              .instance
                                                                              .collection('coba/course/courses')
                                                                              .doc(document.id)
                                                                              .collection('tugas')
                                                                              .doc(taskDoc.id)
                                                                              .collection('tugas')
                                                                              .doc(detailTasks[index].id)
                                                                              .delete()
                                                                              .then((value) {
                                                                            Navigator.pop(context);
                                                                          }).catchError((error) {});
                                                                        },
                                                                        child: _judul(
                                                                            'Hapus',
                                                                            Colors.white,
                                                                            12)),
                                                                  ],
                                                                );
                                                              },
                                                            );
                                                          },
                                                          child: _judul('Hapus',
                                                              Colors.white, 12),
                                                          style: ElevatedButton
                                                              .styleFrom(
                                                            primary: Colors.red,
                                                          ),
                                                        ),
                                                      ]),
                                                  Container(
                                                    margin:
                                                        EdgeInsets.symmetric(
                                                            vertical: 8.0),
                                                    padding:
                                                        EdgeInsets.all(16.0),
                                                    decoration: BoxDecoration(
                                                      border: Border.all(
                                                          color: Colors.grey),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8.0),
                                                    ),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        if (deadline != null)
                                                          Text(
                                                            'Deadline: ${DateFormat('dd MMM yyyy HH:mm').format(deadline)}',
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                        Text(
                                                          name,
                                                          style: TextStyle(
                                                            fontSize: 16.0,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                        SizedBox(height: 8.0),
                                                        Text(deskripsi),
                                                        SizedBox(height: 8.0),
                                                        Text(fileName),
                                                        SizedBox(height: 8.0),
                                                        Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              Row(
                                                                children: [
                                                                  ElevatedButton(
                                                                    onPressed:
                                                                        () {
                                                                      Navigator
                                                                          .push(
                                                                        context,
                                                                        MaterialPageRoute(
                                                                          builder: (context) =>
                                                                              PDFView(
                                                                            filePath:
                                                                                fileURL,
                                                                          ),
                                                                        ),
                                                                      );
                                                                    },
                                                                    child: _judul(
                                                                        'Buka',
                                                                        Colors
                                                                            .white,
                                                                        12),
                                                                    style: ElevatedButton
                                                                        .styleFrom(
                                                                      primary:
                                                                          Colors
                                                                              .deepOrange,
                                                                    ),
                                                                  ),
                                                                  const SizedBox(
                                                                      width:
                                                                          10),
                                                                  ElevatedButton(
                                                                    onPressed:
                                                                        () {
                                                                      Navigator
                                                                          .push(
                                                                        context,
                                                                        MaterialPageRoute(
                                                                          builder: (context) =>
                                                                              EditTaskPage(
                                                                            document:
                                                                                document.id,
                                                                            taskDoc:
                                                                                taskDoc.id,
                                                                            taskId:
                                                                                detailTasks[index].id,
                                                                          ),
                                                                        ),
                                                                      );
                                                                    },
                                                                    child: _judul(
                                                                        'Ubah',
                                                                        Colors
                                                                            .white,
                                                                        12),
                                                                    style: ElevatedButton
                                                                        .styleFrom(
                                                                      primary:
                                                                          Colors
                                                                              .deepOrange,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                              ElevatedButton(
                                                                onPressed: () {
                                                                  Navigator
                                                                      .push(
                                                                    context,
                                                                    MaterialPageRoute(
                                                                      builder:
                                                                          (context) =>
                                                                              DosenListPage(
                                                                        courseId:
                                                                            document.id,
                                                                        taskId:
                                                                            taskDoc.id,
                                                                        tugasData:
                                                                            detailTasks[index].id,
                                                                      ),
                                                                    ),
                                                                  );
                                                                },
                                                                child: _judul(
                                                                    'Lihat Mahasiswa',
                                                                    Colors
                                                                        .white,
                                                                    12),
                                                                style: ElevatedButton
                                                                    .styleFrom(
                                                                  primary: Colors
                                                                      .deepOrange,
                                                                ),
                                                              ),
                                                            ])
                                                      ],
                                                    ),
                                                  )
                                                ]);
                                              },
                                            );
                                          },
// ...
                                        )
                                      ],
                                    );
                                  }).toList(),
                                );
                              },
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
