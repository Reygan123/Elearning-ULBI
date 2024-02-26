import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elearning/page/tugass/submit_tugas.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TugasPage extends StatefulWidget {
  final String courseId;

  TugasPage({required this.courseId});

  @override
  _TugasPageState createState() => _TugasPageState();
}

class _TugasPageState extends State<TugasPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

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

  Widget _deadlineText(DateTime? deadline, String taskId, String detail) {
    User? user = _auth.currentUser;
    String userId = user?.uid ?? '';
    final DateTime now = DateTime.now();

    if (deadline == null) {
      return const Text(
        'Tidak ada batas waktu',
        style: TextStyle(
          color: Colors.grey,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      );
    }

    if (now.isAfter(deadline)) {
      // Task is late
      return Text(
        'Terlambat',
        style: TextStyle(
          color: Colors.red,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      );
    } else {
      // Task is not late
      final Duration timeLeft = deadline.difference(now);
      final String daysLeft = timeLeft.inDays.toString();
      final String hoursLeft = (timeLeft.inHours % 24).toString();
      final String minutesLeft = (timeLeft.inMinutes % 60).toString();

      // Check if submission exists and get the submit time
      final submitTimeRef = FirebaseFirestore.instance
          .collection('coba/course/courses')
          .doc(widget.courseId)
          .collection('tugas')
          .doc(taskId)
          .collection('tugas')
          .doc(detail)
          .collection('submissions')
          .doc(userId);

      return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: submitTimeRef.get(),
        builder: (BuildContext context,
            AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }

          if (snapshot.hasError) {
            return Text('Terjadi kesalahan.');
          }

          final submitTimeData = snapshot.data?.data();
          final DateTime? submitTime = submitTimeData?['submitTime']?.toDate();

          if (submitTime != null) {
            // Task has been submitted
            return Text(
              'Selesai: ${DateFormat('dd MMM yyyy, HH:mm').format(submitTime)}',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.green,
                fontWeight: FontWeight.w500,
              ),
            );
          } else {
            // Task is still pending
            return Text(
              'Deadline: $daysLeft hari $hoursLeft jam $minutesLeft menit',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.blue,
                fontWeight: FontWeight.w500,
              ),
            );
          }
        },
      );
    }
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
          children: [
            Container(
              height: 160,
              width: MediaQuery.of(context).size.width,
              child: Column(
                children: [
                  Expanded(
                    child:
                        StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                      stream: FirebaseFirestore.instance
                          .collection('coba')
                          .doc('course')
                          .collection('courses')
                          .doc(widget.courseId)
                          .snapshots(),
                      builder: (BuildContext context,
                          AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>>
                              snapshot) {
                        if (snapshot.hasError) {
                          return Text('Terjadi kesalahan.');
                        }

                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        }

                        if (!snapshot.hasData || snapshot.data == null) {
                          return Text('Data kursus tidak ditemukan.');
                        }

                        final Map<String, dynamic>? courseData =
                            snapshot.data!.data();

                        if (courseData == null) {
                          return Text('Data kursus tidak ditemukan.');
                        }

                        // Lakukan sesuatu dengan data kursus

                        return ListView.builder(
                          itemCount: 1, // Hanya ada satu data kursus
                          itemBuilder: (BuildContext context, int index) {
                            final Map<String, dynamic> course = courseData;

                            return Container(
                              width: MediaQuery.of(context).size.width,
                              padding: EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage(course['bg']),
                                  fit: BoxFit.cover,
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  _judul(course['title'], Colors.white, 16),
                                  _biasa(course['description'], Colors.white),
                                  _space(),
                                  _space(),
                                  _space(),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('coba/course/courses')
                    .doc(widget.courseId)
                    .collection('tugas')
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                        snapshot) {
                  if (snapshot.hasError) {
                    return Text('Terjadi kesalahan.');
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  }

                  final List<QueryDocumentSnapshot<Map<String, dynamic>>>
                      tasks = snapshot.data!.docs;

                  if (tasks.isEmpty) {
                    return Text('Tidak ada tugas.');
                  }

                  return ListView.builder(
                    itemCount: tasks.length,
                    itemBuilder: (BuildContext context, int index) {
                      final Map<String, dynamic> taskData = tasks[index].data();

                      final String nama = taskData['nama'] ?? '';
                      final String taskId = tasks[index].id; // Menyimpan taskId

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                          const SizedBox(height: 4),
                          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                            stream: FirebaseFirestore.instance
                                .collection('coba/course/courses')
                                .doc(widget.courseId)
                                .collection('tugas')
                                .doc(taskId) // Menggunakan taskId yang sesuai
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
                                          Map<String, dynamic>>> detailTasks =
                                  snapshot.data!.docs;

                              if (detailTasks.isEmpty) {
                                return Text('Tidak ada detail tugas.');
                              }

                              return ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: detailTasks.length,
                                itemBuilder: (BuildContext context, int index) {
                                  final Map<String, dynamic> Tdata =
                                      detailTasks[index].data();
                                  final String name = Tdata['name'] ?? '';
                                  final String detailTaskId = detailTasks[index]
                                      .id; // Menyimpan detailTaskId

                                  final Timestamp? deadlineTimestamp =
                                      Tdata['deadline'];
                                  final DateTime? deadline =
                                      deadlineTimestamp != null
                                          ? deadlineTimestamp.toDate()
                                          : null;

                                  return Container(
                                    margin:
                                        const EdgeInsets.symmetric(vertical: 8),
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10))),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                const SizedBox(
                                                  width: 40,
                                                  height: 60,
                                                  child: Icon(
                                                    Icons.file_copy,
                                                    size: 30,
                                                    color: Colors.deepOrange,
                                                  ),
                                                ),
                                                const SizedBox(width: 10),
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceEvenly,
                                                  children: [
                                                    SizedBox(
                                                      width: 140,
                                                      child: Text(name,
                                                          style: TextStyle(
                                                              fontSize: 12)),
                                                    ),
                                                    _deadlineText(deadline,
                                                        taskId, detailTaskId),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        DetailTugasPage(
                                                      courseId: widget.courseId,
                                                      taskId:
                                                          taskId, // Menggunakan taskId yang sesuai
                                                      tugasData:
                                                          detailTaskId, // Menggunakan detailTaskId yang sesuai
                                                    ),
                                                  ),
                                                );
                                              },
                                              child: Container(
                                                padding: const EdgeInsets.only(
                                                    top: 8,
                                                    bottom: 8,
                                                    left: 20,
                                                    right: 20),
                                                decoration: BoxDecoration(
                                                  color: Colors.deepOrange,
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: _judul(
                                                    'Lihat', Colors.white, 12),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
