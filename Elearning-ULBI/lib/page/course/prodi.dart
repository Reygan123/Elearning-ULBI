import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elearning/page/course/list.dart';

class JurusanPage extends StatelessWidget {
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
          Column(children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _space(),
                  _judul('Prodi', Colors.black, 18),
                  SizedBox(height: 4),
                  _biasa(
                    'Daftar prodi Universitas Logistik Bisnis Internasional',
                    Colors.black,
                  ),
                  _space(),
                  _space(),
                  _space(),
                ],
              ),
            ),
          ]),
        ]),
      ),
      _space(),
      Expanded(
          child: Container(
        padding: const EdgeInsets.all(20),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('course').snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return CircularProgressIndicator();
            }
            List<QueryDocumentSnapshot> documents = snapshot.data!.docs;

            return ListView.builder(
              itemCount: documents.length,
              itemBuilder: (context, index) {
                Map<String, dynamic> data =
                    documents[index].data() as Map<String, dynamic>;

                return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              MataKuliahPage(jurusanId: documents[index].id),
                        ),
                      );
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      margin: EdgeInsets.only(bottom: 20),
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(data['bg']),
                          fit: BoxFit.cover,
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(children: [
                        Container(
                          margin: const EdgeInsets.only(right: 20),
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage(data['img'] ?? ''),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _judul(data['nama'], Colors.white, 16),
                            SizedBox(
                              width: 194,
                              child: _biasa(data['deskripsi'], Colors.white),
                            ),
                            _space(),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MataKuliahPage(
                                        jurusanId: documents[index].id),
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
                                'Check',
                                style:
                                    TextStyle(fontSize: 12, color: Colors.blue),
                              ),
                            )
                          ],
                        ),
                      ]),
                    ));
              },
            );
          },
        ),
      )),
    ])));
  }
}
