// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:elearning/page/tugass/tugas.dart';

// class MyCoursePage extends StatefulWidget {
//   @override
//   _MyCoursePageState createState() => _MyCoursePageState();
// }

// class _MyCoursePageState extends State<MyCoursePage> {
//   final CollectionReference _coursesCollection =
//       FirebaseFirestore.instance.collection('coba/course/courses');
//   final CollectionReference _membersCollection =
//       FirebaseFirestore.instance.collection('coba/course/anggota');
//   final FirebaseAuth _auth = FirebaseAuth.instance;

//   List<String> _joinedCourses = [];
//   TextEditingController _searchController = TextEditingController();
//   String _searchQuery = '';

//   @override
//   void initState() {
//     super.initState();
//     fetchJoinedCourses();
//   }

//   Widget _judul(judul, color, size) {
//     return Text(
//       judul,
//       style:
//           TextStyle(color: color, fontSize: size, fontWeight: FontWeight.w700),
//     );
//   }

//   Widget _space() {
//     return SizedBox(height: 20);
//   }

//   Widget _biasa(biasa, color) {
//     return Text(
//       biasa,
//       style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w500),
//     );
//   }

//   Future<void> fetchJoinedCourses() async {
//     User? user = _auth.currentUser;
//     String userId = user?.uid ?? '';

//     QuerySnapshot snapshot =
//         await _membersCollection.where('userId', isEqualTo: userId).get();
//     List<String> joinedCourses = [];
//     snapshot.docs.forEach((doc) {
//       joinedCourses.add(doc['courseId']);
//     });

//     setState(() {
//       _joinedCourses = joinedCourses;
//     });
//   }

//   void navigateToAssignments(String courseId) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//           builder: (context) => TugasPage(
//                 courseId: courseId,
//               )),
//     );
//   }

//   void _handleSearch(String query) {
//     setState(() {
//       _searchQuery = query;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         margin: EdgeInsets.only(top: 20),
//         padding: EdgeInsets.all(20),
//         child: Column(
//           children: [
//             Align(
//               alignment: Alignment.centerLeft,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   _judul('My Course', Colors.black, 20),
//                   _space(),
//                   _biasa(
//                     'Lorem Ipsum Dolor Sir Amet Lorem Ipsum Dolor Sir Amet',
//                     Colors.black,
//                   ),
//                 ],
//               ),
//             ),
//             _space(),
//             Container(
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(10.0),
//                 ),
//                 child: TextField(
//                     controller: _searchController,
//                     onChanged: _handleSearch,
//                     decoration: InputDecoration(
//                       hintText: 'Search...',
//                       prefixIcon: IconButton(
//                           icon: Icon(Icons.search), onPressed: () {}),
//                       enabledBorder: UnderlineInputBorder(
//                           borderSide: BorderSide(color: Colors.transparent)),
//                       focusedBorder: UnderlineInputBorder(
//                         borderSide: BorderSide(color: Colors.transparent),
//                       ),
//                     ))),
//             _space(),
//             Expanded(
//               child: StreamBuilder<QuerySnapshot>(
//                 stream: _coursesCollection.snapshots(),
//                 builder: (BuildContext context,
//                     AsyncSnapshot<QuerySnapshot> snapshot) {
//                   if (snapshot.hasError) {
//                     return Text('Terjadi kesalahan: ${snapshot.error}');
//                   }

//                   if (snapshot.connectionState == ConnectionState.waiting) {
//                     return Text('Memuat...');
//                   }

//                   if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
//                     List<DocumentSnapshot> joinedCourseDocuments = snapshot
//                         .data!.docs
//                         .where((doc) => _joinedCourses.contains(doc.id))
//                         .toList();

//                     List<DocumentSnapshot> filteredCourseDocuments =
//                         joinedCourseDocuments.where((doc) {
//                       Map<String, dynamic> courseData =
//                           doc.data() as Map<String, dynamic>;
//                       String courseTitle =
//                           courseData['title'].toString().toLowerCase();
//                       return courseTitle.contains(_searchQuery.toLowerCase());
//                     }).toList();

//                     if (filteredCourseDocuments.isNotEmpty) {
//                       return GridView.builder(
//                         itemCount: filteredCourseDocuments.length,
//                         gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                           crossAxisCount: 2,
//                           mainAxisSpacing: 10,
//                           crossAxisSpacing: 10,
//                           childAspectRatio: 1.0,
//                         ),
//                         itemBuilder: (BuildContext context, int index) {
//                           DocumentSnapshot document =
//                               filteredCourseDocuments[index];
//                           Map<String, dynamic> courseData =
//                               document.data() as Map<String, dynamic>;

//                           return Container(
//                             padding: EdgeInsets.all(20),
//                             decoration: BoxDecoration(
//                               image: DecorationImage(
//                                 image: AssetImage(courseData['bg']),
//                                 fit: BoxFit.cover,
//                               ),
//                               borderRadius: BorderRadius.circular(15),
//                             ),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     _judul(
//                                         courseData['title'], Colors.white, 14),
//                                     _biasa(courseData['description'],
//                                         Colors.white),
//                                   ],
//                                 ),
//                                 ElevatedButton(
//                                   onPressed: () {
//                                     navigateToAssignments(document.id);
//                                   },
//                                   style: ElevatedButton.styleFrom(
//                                     primary: Colors.white,
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(
//                                           10), // <-- Radius
//                                     ),
//                                   ),
//                                   child: const Text(
//                                     'Check',
//                                     style: TextStyle(
//                                         fontSize: 12, color: Colors.blueAccent),
//                                   ),
//                                 )
//                               ],
//                             ),
//                           );
//                         },
//                       );
//                     } else {
//                       return Text('Belum ada kursus yang diikuti.');
//                     }
//                   }

//                   return Text('Belum ada kursus yang diikuti.');
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
