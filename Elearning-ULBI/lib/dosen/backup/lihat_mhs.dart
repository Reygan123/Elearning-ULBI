import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Daftar Tugas Mahasiswa'),
      ),
      body: StreamBuilder<QuerySnapshot>(
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
              final tugasData = tugas[index].data() as Map<String, dynamic>?;

              final userId = tugasData?['userId'] ?? '';
              final fileTugas = tugasData?['fileName'] ?? '';

              return FutureBuilder<DocumentSnapshot>(
                future: firestore.collection('users').doc(userId).get(),
                builder: (context, userSnapshot) {
                  if (!userSnapshot.hasData) {
                    return Container(); // Menampilkan widget kosong sementara data pengguna dimuat
                  }

                  final userData =
                      userSnapshot.data!.data() as Map<String, dynamic>?;

                  final npm = userData?['npm'] ?? '';
                  final username = userData?['name'] ?? '';
                  final email = userData?['email'] ?? '';

                  return Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.grey[300]!,
                          width: 1,
                        ),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              npm,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              username,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          email,
                          style: TextStyle(fontSize: 14),
                        ),
                        SizedBox(height: 8),
                        Text(
                          fileTugas,
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
