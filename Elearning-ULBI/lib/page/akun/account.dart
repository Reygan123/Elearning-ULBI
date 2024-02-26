// import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:image_picker/image_picker.dart';
import 'package:elearning/page/akun/edit_profile.dart';

class AccountPage extends StatefulWidget {
  final User user;

  AccountPage({required this.user});

  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final CollectionReference _coursesCollection =
      FirebaseFirestore.instance.collection('coba/course/courses');
  final CollectionReference _membersCollection =
      FirebaseFirestore.instance.collection('coba/course/anggota');
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<String> _joinedCourses = [];
  String _searchQuery = '';
  late Stream<DocumentSnapshot> _userDataStream;

  void _navigateToEditProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => EditProfilePage(user: widget.user)),
    );
  }

  @override
  void initState() {
    super.initState();
    fetchJoinedCourses();
    _userDataStream = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.user.uid)
        .snapshots();
  }

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
        body: Container(
            child: CustomScrollView(scrollDirection: Axis.vertical, slivers: [
      SliverFillRemaining(
        hasScrollBody: false,
        child: StreamBuilder<DocumentSnapshot>(
          stream: _userDataStream,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }

            Map<String, dynamic>? userData =
                snapshot.data!.data() as Map<String, dynamic>?;

            String? profileImageUrl = userData?['profileImageUrl'];

            return Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                      alignment: Alignment.centerLeft,
                      child: _judul('Profil', Colors.black, 16)),
                  _space(),
                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        fit: BoxFit.fill,
                        image: profileImageUrl != null
                            ? NetworkImage(profileImageUrl)
                                as ImageProvider<Object>
                            : AssetImage('assets/intro/default.jpg'),
                      ),
                    ),
                  ),
                  _space(),
                  Align(
                      alignment: Alignment.center,
                      child: Column(children: [
                        _judul('${userData?['name'] ?? ''}', Colors.black, 18),
                        _biasa('${userData?['role'] ?? ''}', Colors.black),
                      ])),
                  Container(
                      width: MediaQuery.of(context).size.width,
                      margin: EdgeInsets.symmetric(vertical: 20),
                      padding: EdgeInsets.all(20),
                      height: 320,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(children: [
                        _judul('User Detail', Colors.black, 16),
                        Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: _navigateToEditProfile,
                            child: Text(
                              'Edit Profile',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                        _space(),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _judul("Email", Colors.black, 12),
                              _biasa(
                                  '${userData?['email'] ?? ''}', Colors.black),
                            ]),
                        _space(),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _judul("Npm", Colors.black, 12),
                              _biasa('${userData?['npm'] ?? ''}', Colors.black),
                            ]),
                        _space(),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _judul("Alamat", Colors.black, 12),
                              _biasa(
                                  '${userData?['alamat'] ?? ''}', Colors.black),
                            ]),
                        _space(),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _judul("Jurusan", Colors.black, 12),
                              _biasa('${userData?['jurusan'] ?? ''}',
                                  Colors.black),
                            ]),
                        _space(),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _judul("Kelas", Colors.black, 12),
                              _biasa(
                                  '${userData?['kelas'] ?? ''}', Colors.black),
                            ]),
                        _space(),
                      ])),
                  Container(
                      height: 400,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(children: [
                        _space(),
                        _judul('Course details', Colors.black, 16),
                        _biasa('Daftar course yang kamu ikuti', Colors.black),
                        SizedBox(height: 10),
                        Expanded(
                            child: StreamBuilder<QuerySnapshot>(
                                stream: _coursesCollection.snapshots(),
                                builder: (BuildContext context,
                                    AsyncSnapshot<QuerySnapshot> snapshot) {
                                  if (snapshot.hasError) {
                                    return Text(
                                        'Terjadi kesalahan: ${snapshot.error}');
                                  }

                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return Text('Memuat...');
                                  }

                                  if (snapshot.hasData &&
                                      snapshot.data!.docs.isNotEmpty) {
                                    List<DocumentSnapshot>
                                        joinedCourseDocuments = snapshot
                                            .data!.docs
                                            .where((doc) =>
                                                _joinedCourses.contains(doc.id))
                                            .toList();

                                    List<DocumentSnapshot>
                                        filteredCourseDocuments =
                                        joinedCourseDocuments.where((doc) {
                                      Map<String, dynamic> courseData =
                                          doc.data() as Map<String, dynamic>;
                                      String courseTitle = courseData['title']
                                          .toString()
                                          .toLowerCase();
                                      return courseTitle
                                          .contains(_searchQuery.toLowerCase());
                                    }).toList();

                                    if (filteredCourseDocuments.isNotEmpty) {
                                      return ListView.builder(
                                        itemCount:
                                            filteredCourseDocuments.length,
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          DocumentSnapshot document =
                                              filteredCourseDocuments[index];
                                          Map<String, dynamic> courseData =
                                              document.data()
                                                  as Map<String, dynamic>;

                                          return Container(
                                            padding: EdgeInsets.only(
                                                top: 2,
                                                bottom: 2,
                                                left: 20,
                                                right: 20),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    _biasa(courseData['title'],
                                                        Colors.blueAccent),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      );
                                    }
                                  }
                                  return Text('Belum ada kursus yang diikuti.');
                                }))
                      ]))
                ],
              ),
            );
          },
        ),
      )
    ])));
  }
}
