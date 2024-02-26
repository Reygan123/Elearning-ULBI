// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:intl/intl.dart';
// import 'package:elearning/dosen/course/tambah.dart';
// import 'package:elearning/page/tugas/detail.dart';

// class TaskPage extends StatefulWidget {
//   @override
//   _TaskPageState createState() => _TaskPageState();
// }

// class _TaskPageState extends State<TaskPage> {
//   late Stream<QuerySnapshot> taskStream;

//   @override
//   void initState() {
//     super.initState();
//     taskStream = FirebaseFirestore.instance.collection('coba').snapshots();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Daftar Tugas'),
//       ),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: taskStream,
//         builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
//           if (snapshot.hasError) {
//             return Center(child: Text('Terjadi kesalahan!'));
//           }

//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Center(child: CircularProgressIndicator());
//           }

//           if (snapshot.data!.docs.isEmpty) {
//             return Center(child: Text('Belum ada tugas.'));
//           }

//           return ListView.builder(
//             itemCount: snapshot.data!.docs.length,
//             itemBuilder: (BuildContext context, int index) {
//               Map<String, dynamic> taskData =
//                   snapshot.data!.docs[index].data() as Map<String, dynamic>;
//               String taskTitle = taskData['title'] ?? '';
//               String taskDescription = taskData['description'] ?? '';
//               Timestamp? deadlineTimestamp = taskData['deadline'];
//               DateTime? deadline = deadlineTimestamp?.toDate();

//               String formattedDeadline = deadline != null
//                   ? DateFormat('dd MMM yyyy').format(deadline)
//                   : 'Tidak ada deadline';

//               return ListTile(
//                 title: Text(taskTitle),
//                 subtitle: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Align(
//                       alignment: Alignment.centerRight,
//                       child: ElevatedButton(
//                         onPressed: () {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                                 builder: (context) => AddTaskPage()),
//                           );
//                         },
//                         child: Text('Tambah'),
//                       ),
//                     ),
//                     Text(taskDescription),
//                     Text('Deadline: $formattedDeadline'),
//                     ElevatedButton(
//                       onPressed: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                               builder: (context) =>
//                                   TaskDetailPage(taskData: taskData)),
//                         );
//                       },
//                       child: Text('Detail'),
//                     ),
//                   ],
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }
