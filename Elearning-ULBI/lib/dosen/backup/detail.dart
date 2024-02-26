import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TaskViewPage extends StatelessWidget {
  final String courseId;
  final String assignmentId;

  TaskViewPage({required this.courseId, required this.assignmentId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lihat Tugas'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('coba/course/courses')
            .doc(courseId)
            .collection('tugas')
            .doc(assignmentId)
            .collection('submissions')
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Terjadi kesalahan: ${snapshot.error}');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (BuildContext context, int index) {
                DocumentSnapshot submission = snapshot.data!.docs[index];
                String userId = submission.id;
                String fileName = submission['fileName'];

                return ListTile(
                  title: Text('User ID: $userId'),
                  subtitle: Text('File Tugas: $fileName'),
                );
              },
            );
          }

          return Center(child: Text('Belum ada tugas yang diunggah.'));
        },
      ),
    );
  }
}
