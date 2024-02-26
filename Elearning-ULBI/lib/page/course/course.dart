import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CoursePage extends StatefulWidget {
  @override
  _CoursePageState createState() => _CoursePageState();
}

class _CoursePageState extends State<CoursePage> {
  final CollectionReference _coursesCollection =
      FirebaseFirestore.instance.collection('coba/course/courses');
  final CollectionReference _membersCollection =
      FirebaseFirestore.instance.collection('coba/course/anggota');
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<String> _joinedCourses = [];

  Widget _judul(judul, color, size) {
    return Text(
      judul,
      style:
          TextStyle(color: color, fontSize: size, fontWeight: FontWeight.w700),
    );
  }

  Widget _space() {
    return SizedBox(height: 20);
  }

  Widget _biasa(biasa, color) {
    return Text(
      biasa,
      style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w500),
    );
  }

  @override
  void initState() {
    super.initState();
    fetchJoinedCourses();
  }

  Future<void> fetchJoinedCourses() async {
    User? user = _auth.currentUser;
    String userId = user?.uid ?? '';

    QuerySnapshot snapshot =
        await _membersCollection.where('userId', isEqualTo: userId).get();
    List<String> joinedCourses = [];
    snapshot.docs.forEach((doc) {
      joinedCourses.add(doc['courseId']);
    });

    setState(() {
      _joinedCourses = joinedCourses;
    });
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
                child: StreamBuilder<QuerySnapshot>(
                  stream: _coursesCollection.snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasError) {
                      return Text('Terjadi kesalahan: ${snapshot.error}');
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Text('Memuat...');
                    }

                    if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                      return GridView.builder(
                        itemCount: snapshot.data!.docs.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          childAspectRatio: 1.0,
                        ),
                        itemBuilder: (BuildContext context, int index) {
                          DocumentSnapshot document =
                              snapshot.data!.docs[index];
                          Map<String, dynamic> courseData =
                              document.data() as Map<String, dynamic>;

                          bool isJoined = _joinedCourses.contains(document.id);

                          return Container(
                            padding: EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage(courseData['bg']),
                                fit: BoxFit.cover,
                              ),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _judul(courseData['title'], Colors.white, 16),
                                _biasa(courseData['description'], Colors.white),
                                _space(),
                                isJoined
                                    ? Text(
                                        'Sudah Bergabung',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )
                                    : ButtonTheme(
                                        minWidth:
                                            MediaQuery.of(context).size.width,
                                        height: 30,
                                        child: ElevatedButton(
                                          onPressed: () {
                                            joinCourse(document.id);
                                          },
                                          child: Text(
                                            'Gabung',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.black,
                                            ),
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            primary: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      10), // <-- Radius
                                            ),
                                          ),
                                        )),
                              ],
                            ),
                          );
                        },
                      );
                    }

                    return Text('Tidak ada data kursus.');
                  },
                ),
              )
            ])));
  }

  Future<void> joinCourse(String courseId) async {
    User? user = _auth.currentUser;
    String userId = user?.uid ?? '';

    DocumentReference memberRef = _membersCollection.doc();
    Map<String, dynamic> memberData = {
      'userId': userId,
      'courseId': courseId,
    };

    try {
      await memberRef.set(memberData);
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Bergabung ke Kursus'),
            content: Text('Anda telah berhasil bergabung ke kursus ini.'),
            actions: <Widget>[
              TextButton(
                child: Text('Tutup'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      fetchJoinedCourses(); // Refresh daftar kursus yang telah bergabung
    } catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Terjadi Kesalahan'),
            content: Text('Gagal bergabung ke kursus. Silakan coba lagi.'),
            actions: <Widget>[
              TextButton(
                child: Text('Tutup'),
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
}
