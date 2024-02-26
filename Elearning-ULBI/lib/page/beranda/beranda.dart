import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:elearning/auth.dart';
import 'package:elearning/page/tugass/tugas.dart';
// import 'package:elearning/page/tugass/submit_tugas.dart';

class Beranda extends StatefulWidget {
  final User user;

  Beranda({required this.user});

  @override
  _BerandaState createState() => _BerandaState();
}

Future<void> signOut() async {
  await Auth().signOut();
}

class _BerandaState extends State<Beranda> {
  final CollectionReference _coursesCollection =
      FirebaseFirestore.instance.collection('coba/course/courses');
  final CollectionReference _membersCollection =
      FirebaseFirestore.instance.collection('coba/course/anggota');
  late Stream<DocumentSnapshot> _userDataStream;
  late Future<DocumentSnapshot?> _lastAccessCourseFuture;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void initState() {
    super.initState();

    _userDataStream = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.user.uid)
        .snapshots();
    _lastAccessCourseFuture = fetchLastAccessCourse();
  }

  Future<DocumentSnapshot?> fetchLastAccessCourse() async {
    User? user = _auth.currentUser;
    String userId = user?.uid ?? '';

    QuerySnapshot snapshot =
        await _membersCollection.where('userId', isEqualTo: userId).get();
    List<String> joinedCourses = [];
    snapshot.docs.forEach((doc) {
      joinedCourses.add(doc['courseId']);
    });

    if (joinedCourses.isNotEmpty) {
      DocumentSnapshot lastCourseSnapshot =
          await _coursesCollection.doc(joinedCourses.last).get();
      return lastCourseSnapshot;
    } else {
      return null;
    }
  }

  Widget _deadlineText(DateTime? deadline) {
    if (deadline == null) {
      return const Text('Deadline tidak ditentukan');
    }

    final remainingDays = deadline.difference(DateTime.now()).inDays;
    final text = remainingDays > 0
        ? 'Deadline dalam $remainingDays hari'
        : 'Deadline hari ini';

    return Text(text,
        style: const TextStyle(
            fontSize: 12, color: Colors.red, fontWeight: FontWeight.bold));
  }

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> fetchTasks() async {
    final now = DateTime.now();
    final sevenDaysFromNow = now.add(const Duration(days: 7));

    final coursesSnapshot = await FirebaseFirestore.instance
        .collection('coba/course/courses')
        .get();

    final courses = coursesSnapshot.docs;
    final List<QueryDocumentSnapshot<Map<String, dynamic>>> tasksWithDeadline =
        [];

    for (final course in courses) {
      final courseId = course.id;
      final tasksSnapshot = await FirebaseFirestore.instance
          .collection('coba/course/courses')
          .doc(courseId)
          .collection('tugas')
          .get();

      final tasks = tasksSnapshot.docs;

      for (final task in tasks) {
        final taskId = task.id;
        final detailTasksSnapshot = await FirebaseFirestore.instance
            .collection('coba/course/courses')
            .doc(courseId)
            .collection('tugas')
            .doc(taskId)
            .collection('tugas')
            .get();

        final detailTasks = detailTasksSnapshot.docs;

        for (final detailTask in detailTasks) {
          final detailTaskData = detailTask.data();

          final deadlineTimestamp = detailTaskData['deadline'] as Timestamp?;
          final deadline =
              deadlineTimestamp != null ? deadlineTimestamp.toDate() : null;

          if (deadline != null && deadline.isBefore(sevenDaysFromNow)) {
            tasksWithDeadline.add(detailTask);
          }
        }
      }
    }

    return tasksWithDeadline;
  }

  Widget _judul(judul, color, size) {
    return Text(
      judul ?? '',
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

  Widget _spasi() {
    return SizedBox(height: 10);
  }

  Widget _biasa(biasa, color) {
    return Text(
      biasa ?? '',
      style: TextStyle(
        color: color,
        fontSize: 12,
        fontWeight: FontWeight.normal,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
            child: Container(
                child: Column(children: [
      Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
            color: Colors.white,
          ),
          child: Column(children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              StreamBuilder<DocumentSnapshot>(
                stream: _userDataStream,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }

                  Map<String, dynamic>? userData =
                      snapshot.data!.data() as Map<String, dynamic>?;

                  return Container(
                    margin: EdgeInsets.only(top: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _judul('Halo, ${userData?['name']}', Colors.black, 16),
                        const SizedBox(height: 4),
                        _biasa(
                          '${userData?['jurusan'] ?? ''} - ${userData?['kelas'] ?? ''}',
                          Colors.black,
                        ),
                      ],
                    ),
                  );
                },
              ),
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withOpacity(0.7),
                ),
                child: IconButton(
                  onPressed: signOut,
                  icon: Icon(Icons.logout),
                  color: Colors.white,
                  iconSize: 24,
                ),
              ),
            ]),
            _spasi(),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(left: 8, right: 4),
                            child: Icon(
                              Icons.search,
                              color: Colors.grey[600],
                            ),
                          ),
                          const Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: 'Cari...',
                                hintStyle: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            )
          ])),
      Container(
        height: MediaQuery.of(context).size.height,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 190,
              width: MediaQuery.of(context).size.width,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Container(
                    height: 170,
                    width: MediaQuery.of(context).size.width,
                    padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                    child: Card(
                      color: Colors.purple.shade900,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                width: 240,
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _judul(
                                          'Open Enrollment', Colors.white, 14),
                                      const SizedBox(
                                        height: 4,
                                      ),
                                      _biasa(
                                          'Penerimaan Mahasiswa Baru Tahun Akademik 2023/2024',
                                          Colors.white),
                                    ]),
                              ),
                              ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 4, horizontal: 8),
                                  backgroundColor: Colors.deepOrange,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: _biasa('S.D 31 Juli 2023', Colors.white),
                              )
                            ]),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 4,
                    top: 0,
                    child: Image.network(
                      'assets/intro/news.png',
                      fit: BoxFit.cover,
                      height: 180,
                    ),
                  )
                ],
              ),
            ),
            _spasi(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _judul('Last Enrolled', Colors.black, 14),
                _judul('See All', Colors.blue, 14)
              ],
            ),
            _spasi(),
            SizedBox(
                height: 140,
                child: Container(
                    height: 140,
                    child: Flex(direction: Axis.horizontal, children: [
                      Expanded(
                        child: FutureBuilder<DocumentSnapshot?>(
                          future: _lastAccessCourseFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return CircularProgressIndicator();
                            }

                            if (snapshot.hasData && snapshot.data != null) {
                              DocumentSnapshot lastAccessCourse =
                                  snapshot.data!;

                              Map<String, dynamic> courseData = lastAccessCourse
                                  .data() as Map<String, dynamic>;

                              return Container(
                                padding: EdgeInsets.all(20),
                                height: 140,
                                width: 180,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: AssetImage(courseData['bg']),
                                    fit: BoxFit.cover,
                                  ),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _judul(courseData['title'] ?? '',
                                            Colors.white, 14),
                                        _biasa(courseData['description'] ?? '',
                                            Colors.white),
                                      ],
                                    ),
                                    _space(),
                                    ElevatedButton(
                                      onPressed: () {
                                        navigateToLastAccessCourse(
                                            lastAccessCourse);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        primary: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              10), // <-- Radius
                                        ),
                                      ),
                                      child: const Text(
                                        'Check',
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.blueAccent),
                                      ),
                                    )
                                  ],
                                ),
                              );
                            } else {
                              return const SizedBox.shrink();
                            }
                          },
                        ),
                      ),
                    ]))),
            _space(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _judul('Task', Colors.black, 14),
                _judul('See All', Colors.blue, 14)
              ],
            ),
            _spasi(),
            Expanded(
              child: FutureBuilder<
                  List<QueryDocumentSnapshot<Map<String, dynamic>>>>(
                future: fetchTasks(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Terjadi kesalahan. Silakan coba lagi.'),
                    );
                  }

                  final tasks = snapshot.data;

                  if (tasks == null || tasks.isEmpty) {
                    return Center(
                      child: Text(
                          'Tidak ada tugas dengan deadline kurang dari 7 hari.'),
                    );
                  }

                  return ListView.builder(
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final detailTaskData = tasks[index].data();
                      final title = detailTaskData['name'] as String?;

                      final deadlineTimestamp =
                          detailTaskData['deadline'] as Timestamp?;
                      final deadline = deadlineTimestamp != null
                          ? deadlineTimestamp.toDate()
                          : null;

                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(children: [
                                  const SizedBox(
                                    width: 40,
                                    height: 60,
                                    child: Icon(
                                      Icons.file_copy,
                                      size: 30,
                                      color: Colors.deepOrange,
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _biasa(title, Colors.black),
                                        _deadlineText(deadline),
                                      ]),
                                ]),
                                GestureDetector(
                                  onTap: () {
                                    // Navigator.push(
                                    //   context,
                                    //   MaterialPageRoute(
                                    //     builder: (context) =>
                                    //         DetailTugasPage(
                                    //       courseId: ,
                                    //       taskId:
                                    //           , // Menggunakan taskId yang sesuai
                                    //       tugasData:
                                    //           tasks[index].id, // Menggunakan detailTaskId yang sesuai
                                    //     ),
                                    //   ),
                                    // );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.only(
                                        top: 8, bottom: 8, left: 20, right: 20),
                                    decoration: BoxDecoration(
                                      color: Colors.deepOrange,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: _judul('Lihat', Colors.white, 12),
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
            ),
          ],
        ),
      ),
    ]))));
  }

  void navigateToLastAccessCourse(DocumentSnapshot courseSnapshot) {
    // Extract the courseId from the document snapshot
    String courseId = courseSnapshot.id;

    // Navigate to the course page using the courseId
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TugasPage(courseId: courseId),
      ),
    );
  }
}
