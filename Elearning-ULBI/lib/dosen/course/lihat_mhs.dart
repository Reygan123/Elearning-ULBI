import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elearning/dosen/course/detail_mhs.dart';

class DosenListPage extends StatefulWidget {
  final String courseId;
  final String taskId;
  final String tugasData;

  DosenListPage({
    required this.courseId,
    required this.taskId,
    required this.tugasData,
  });

  @override
  _DosenListPageState createState() => _DosenListPageState();
}

class _DosenListPageState extends State<DosenListPage> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Widget _tebal(teks) {
    return Text(
      teks,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _biasa(teks) {
    return Text(
      teks,
      style: TextStyle(
        fontSize: 12,
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
              child: const Column(children: [
                Align(
                    alignment: Alignment.centerLeft,
                    child: Column(children: [
                      Text(
                        'Daftar List Mahasiswa',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Daftar list mahasiswa yang sudah mengerjakan tugas',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      )
                    ])),
                SizedBox(height: 30),
              ])),
          Container(
              height: MediaQuery.of(context).size.height,
              padding: EdgeInsets.all(20),
              child: Column(children: [
                const Column(
                    crossAxisAlignment: CrossAxisAlignment.start, children: []),
                SizedBox(height: 10),
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

                          return FutureBuilder<DocumentSnapshot>(
                            future:
                                firestore.collection('users').doc(userId).get(),
                            builder: (context, userSnapshot) {
                              if (!userSnapshot.hasData) {
                                return Container(); // Menampilkan widget kosong sementara data pengguna dimuat
                              }

                              final userData = userSnapshot.data!.data()
                                  as Map<String, dynamic>?;

                              final npm = userData?['npm'] ?? '';
                              final username = userData?['name'] ?? '';
                              final email = userData?['email'] ?? '';

                              return Container(
                                  margin: EdgeInsets.symmetric(vertical: 8.0),
                                  padding: EdgeInsets.only(
                                      top: 10, bottom: 10, right: 20, left: 20),
                                  width: MediaQuery.of(context).size.width,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              _tebal(npm),
                                              _tebal('-'),
                                              _tebal(username),
                                            ],
                                          ),
                                          SizedBox(height: 4),
                                          _biasa(email),
                                          SizedBox(height: 4),
                                          Container(
                                              width: 200,
                                              child: _biasa(fileTugas)),
                                        ],
                                      ),
                                      InkWell(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => DetailPage(
                                                  userId: userId,
                                                  courseId: widget.courseId,
                                                  taskId: widget.taskId,
                                                  tugasData: widget.tugasData),
                                            ),
                                          );
                                        },
                                        child: Container(
                                          padding: EdgeInsets.only(
                                              top: 8,
                                              bottom: 8,
                                              left: 12,
                                              right: 12),
                                          decoration: BoxDecoration(
                                            color: Colors.deepOrange,
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          child: const Text(
                                            'Lihat',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  ));
                            },
                          );
                        },
                      );
                    },
                  ),
                )
              ]))
        ]))));
  }
}
