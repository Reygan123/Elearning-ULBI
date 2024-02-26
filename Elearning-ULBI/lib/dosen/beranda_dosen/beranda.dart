import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:elearning/dosen/beranda_dosen/tambah.dart';
import 'package:elearning/auth.dart';

class BerandaDosen extends StatefulWidget {
  final User user;

  BerandaDosen({required this.user});

  @override
  _BerandaDosenState createState() => _BerandaDosenState();
}

Future<void> signOut() async {
  await Auth().signOut();
}

class _BerandaDosenState extends State<BerandaDosen> {
  late Stream<DocumentSnapshot> _userDataStream;
  void initState() {
    super.initState();
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
                          'Selamat datang kembali',
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
            )
          ])),
      Container(
        height: MediaQuery.of(context).size.height,
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _judul('Open Enrollment', Colors.white, 14),
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
                ),
              ],
            ),
          ),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            _judul('Last Access', Colors.black, 14),
            _judul('See All', Colors.blue, 14)
          ]),
          const SizedBox(height: 10),
          SizedBox(
              height: 150,
              child: Flex(direction: Axis.horizontal, children: [
                Container(
                  padding: EdgeInsets.all(20),
                  height: 150,
                  width: MediaQuery.of(context).size.width * 0.5,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/intro/bg1.png'),
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _judul('Pemograman Web Perangkat Bergerak',
                              Colors.white, 14),
                          _biasa('Marwanto Rahmatuloh', Colors.white),
                        ],
                      ),
                      _space(),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          primary: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Check',
                          style:
                              TextStyle(fontSize: 12, color: Colors.blueAccent),
                        ),
                      ),
                    ],
                  ),
                ),
              ])),
          // ElevatedButton(
          //   onPressed: () {
          //     Navigator.push(
          //       context,
          //       MaterialPageRoute(builder: (context) => AddCoursePage()),
          //     );
          //   },
          //   child: Text('Login'),
          //   style: ButtonStyle(
          //     fixedSize: MaterialStateProperty.all(
          //       Size(
          //         MediaQuery.of(context).size.width,
          //         50.0, // Sesuaikan tinggi button sesuai kebutuhan
          //       ),
          //     ),
          //     backgroundColor:
          //         MaterialStateProperty.all<Color>(Colors.deepOrange),
          //   ),
          // ),
        ]),
      ),
    ]))));
  }
}
