import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:elearning/dosen/course/tambah_tugas.dart';
import 'package:elearning/dosen/course/detail_tgs.dart';
import 'package:intl/intl.dart';

class CoursePage extends StatefulWidget {
  final User user;
  final String courseId;

  CoursePage({required this.user, required this.courseId});

  @override
  _CoursePageState createState() => _CoursePageState();
}

class _CoursePageState extends State<CoursePage> {
  Stream<DocumentSnapshot<Map<String, dynamic>>>? _courseStream;

  @override
  void initState() {
    super.initState();

    // Mendapatkan stream course dengan courseId yang diberikan
    _courseStream = FirebaseFirestore.instance
        .collection('coba/course/courses')
        .doc(widget.courseId)
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(
          color: Colors.black,
        ),
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        child: Column(children: [
          Expanded(
            child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                stream: _courseStream,
                builder: (BuildContext context,
                    AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>>
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

                  final Map<String, dynamic>? courseData =
                      snapshot.data!.data();

                  if (courseData == null) {
                    return Center(
                      child: Text('Course tidak ditemukan.'),
                    );
                  }

                  return ListView(children: [
                    Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width,
                            padding: EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage(courseData['bg']),
                                fit: BoxFit.cover,
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _judul(courseData['title'], Colors.white, 14),
                                _biasa(courseData['description'], Colors.white),
                                _space(),
                                _space(),
                              ],
                            ),
                          ),
                          _space(),
                          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                            stream: FirebaseFirestore.instance
                                .collection('coba/course/courses')
                                .doc(widget.courseId)
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
                                      Row(children: [
                                        const SizedBox(width: 40),
                                        Text(
                                          nama,
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ]),
                                      StreamBuilder<
                                          QuerySnapshot<Map<String, dynamic>>>(
                                        stream: FirebaseFirestore.instance
                                            .collection('coba/course/courses')
                                            .doc(widget.courseId)
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
                                              detailTasks = snapshot.data!.docs;

                                          if (detailTasks.isEmpty) {
                                            return Text(
                                                'Tidak ada detail tugas.');
                                          }

                                          return ListView.builder(
                                            shrinkWrap: true,
                                            physics:
                                                NeverScrollableScrollPhysics(),
                                            itemCount: detailTasks.length,
                                            itemBuilder: (BuildContext context,
                                                int index) {
                                              final Map<String, dynamic> Tdata =
                                                  detailTasks[index].data();
                                              final String name =
                                                  Tdata['name'] ?? '';
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
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.end,
                                                    children: [
                                                      Container(
                                                        width: 108,
                                                        height: 30,
                                                        child: TextButton(
                                                          onPressed: () {
                                                            Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        AddTaskPage(
                                                                  document: widget
                                                                      .courseId,
                                                                  taskDoc:
                                                                      taskDoc
                                                                          .id,
                                                                ),
                                                              ),
                                                            );
                                                          },
                                                          child: Row(
                                                            children: [
                                                              Icon(Icons.add,
                                                                  color: Colors
                                                                      .blue), // Replace Icons.add with the desired icon
                                                              SizedBox(
                                                                  width: 8),
                                                              _judul(
                                                                  'Tambah',
                                                                  Colors.blue,
                                                                  12),
                                                            ],
                                                          ),
                                                        ),
                                                      )
                                                    ]),
                                                Container(
                                                    margin:
                                                        EdgeInsets.symmetric(
                                                            vertical: 8.0),
                                                    padding: EdgeInsets.only(
                                                        top: 10,
                                                        bottom: 10,
                                                        right: 20,
                                                        left: 20),
                                                    width:
                                                        MediaQuery.of(context)
                                                            .size
                                                            .width,
                                                    decoration:
                                                        const BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  10)),
                                                    ),
                                                    child: Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                _biasa(
                                                                    name,
                                                                    Colors
                                                                        .black),
                                                                if (deadline !=
                                                                    null)
                                                                  _biasa(
                                                                      'Deadline: ${DateFormat('dd MMM yyyy HH:mm').format(deadline)}',
                                                                      Colors
                                                                          .red),
                                                                if (deadline ==
                                                                    null)
                                                                  _biasa(
                                                                      'Tidak ada batas waktu',
                                                                      Colors
                                                                          .grey),
                                                              ]),
                                                          Container(
                                                            width: 72,
                                                            height: 30,
                                                            child:
                                                                ElevatedButton(
                                                              onPressed: () {
                                                                Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                    builder:
                                                                        (context) =>
                                                                            LihatPage(
                                                                      DocId: widget
                                                                          .courseId,
                                                                      TaskId:
                                                                          taskDoc
                                                                              .id,
                                                                      DetailId:
                                                                          detailTasks[index]
                                                                              .id,
                                                                    ),
                                                                  ),
                                                                );
                                                              },
                                                              child: _judul(
                                                                  'Detail',
                                                                  Colors.white,
                                                                  12),
                                                              style:
                                                                  ElevatedButton
                                                                      .styleFrom(
                                                                primary: Colors
                                                                    .deepOrange,
                                                                shape:
                                                                    RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              6),
                                                                ),
                                                              ),
                                                            ),
                                                          )
                                                        ]))
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
                    )
                  ]);
                }),
          )
        ]),
      ),
    );
  }
}
