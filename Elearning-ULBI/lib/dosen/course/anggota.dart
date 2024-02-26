import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:elearning/dosen/course/list_anggota.dart';

class AnggotaPage extends StatefulWidget {
  final User user;

  AnggotaPage({required this.user});

  @override
  _AnggotaPageState createState() => _AnggotaPageState();
}

class _AnggotaPageState extends State<AnggotaPage> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
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
            Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _space(),
                  _judul('Anggota', Colors.black, 20),
                  SizedBox(height: 10),
                  _biasa(
                    'Kamu bisa melihat anggota dari course kamu disini',
                    Colors.black,
                  ),
                ],
              ),
            ),
            _space(),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: const Row(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(left: 8, right: 4),
                            child: Icon(
                              Icons.search,
                              color: Colors.grey,
                            ),
                          ),
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: 'Cari...',
                                labelStyle: TextStyle(
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
            ),
          ])),
      Expanded(
        child: Container(
          padding: EdgeInsets.all(20),
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: _coursesStream,
            builder: (BuildContext context,
                AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
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

              final List<QueryDocumentSnapshot<Map<String, dynamic>>> courses =
                  snapshot.data!.docs
                      .where((doc) => doc.data()['userId'] == widget.user.uid)
                      .toList();

              if (courses.isEmpty) {
                return Center(
                  child: Text('Tidak ada course yang tersedia.'),
                );
              }

              return GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // Menentukan jumlah kolom dalam grid
                  crossAxisSpacing: 10, // Menentukan jarak antara kolom
                  mainAxisSpacing: 10, // Menentukan jarak antara baris
                ),
                itemCount: courses.length,
                itemBuilder: (BuildContext context, int index) {
                  final Map<String, dynamic> data = courses[index].data();

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
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _judul(data['title'], Colors.white, 14),
                              _biasa(data['description'], Colors.white),
                              _space(),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AnggotaListPage(
                                          courseId: courses[index].id),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  primary: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(10), // <-- Radius
                                  ),
                                ),
                                child: const Text(
                                  'Lihat Anggota',
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.blueAccent),
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    ])));
  }
}
