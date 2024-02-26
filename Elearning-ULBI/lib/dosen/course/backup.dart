import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:elearning/dosen/course/tambah.dart';

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

  void _goToAddTaskPage(String courseId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddTaskPage(courseId: courseId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Course'),
      ),
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
                                  ElevatedButton(
                                    onPressed: () {
                                      _goToAddTaskPage(document.id);
                                    },
                                    child: Text('Tambah Tugas'),
                                  ),
                                ],
                              ),
                            ),
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

                                    final String materi =
                                        taskData['materi'] ?? '';
                                    final String pertemuan =
                                        taskData['pertemuan'] ?? '';
                                    final Timestamp deadline =
                                        taskData['deadline'];

                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Materi: $materi',
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        Text(
                                          'Pertemuan: $pertemuan',
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        Text(
                                          'Deadline: ${_formatTimestamp(deadline)}',
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        SizedBox(height: 8),
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
