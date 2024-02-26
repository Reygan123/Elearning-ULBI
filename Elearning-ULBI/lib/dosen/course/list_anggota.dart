import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AnggotaListPage extends StatelessWidget {
  final String courseId;

  AnggotaListPage({required this.courseId});

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
        body: Container(
            child: Column(children: [
          Container(
              padding: const EdgeInsets.only(
                bottom: 20,
                left: 20,
                right: 20,
              ),
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
                      _judul('Daftar Anggota', Colors.black, 18),
                      SizedBox(height: 10),
                      _biasa(
                        'Daftar Mahasiswa Yang Bergabung Pada Course Kamu',
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
                stream: FirebaseFirestore.instance
                    .collection('coba/course/anggota')
                    .where('courseId', isEqualTo: courseId)
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                        snapshot) {
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

                  final List<QueryDocumentSnapshot<Map<String, dynamic>>>
                      anggota = snapshot.data!.docs;

                  if (anggota.isEmpty) {
                    return Center(
                      child: Text('Tidak ada anggota dalam course ini.'),
                    );
                  }

                  return ListView.builder(
                    itemCount: anggota.length,
                    itemBuilder: (BuildContext context, int index) {
                      final Map<String, dynamic> data = anggota[index].data();
                      final String userId = data['userId'];

                      return StreamBuilder<
                          DocumentSnapshot<Map<String, dynamic>>>(
                        stream: FirebaseFirestore.instance
                            .collection('users')
                            .doc(userId)
                            .snapshots(),
                        builder: (BuildContext context,
                            AsyncSnapshot<
                                    DocumentSnapshot<Map<String, dynamic>>>
                                userSnapshot) {
                          if (userSnapshot.hasError ||
                              !userSnapshot.hasData ||
                              userSnapshot.data!.data() == null) {
                            return ListTile(
                              title: Text('Error'),
                              subtitle: Text('Error'),
                            );
                          }

                          final Map<String, dynamic> userData =
                              userSnapshot.data!.data()!;

                          final String npm = userData['npm'] ?? '';
                          final String name = userData['name'] ?? '';
                          final String email = userData['email'] ?? '';

                          return Container(
                            margin: const EdgeInsets.only(bottom: 4, top: 4),
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _judul(
                                            '$npm - $name', Colors.black, 14),
                                        _biasa(email, Colors.black),
                                      ],
                                    ),
                                    _biasa(" ", Colors.white),
                                  ],
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
            ),
          )
        ])));
  }
}
