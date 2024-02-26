import 'package:flutter/material.dart';
import 'package:elearning/page/beranda/home.dart';
import 'package:elearning/dosen/beranda_dosen/home_dosen.dart';
import 'package:elearning/page/login/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elearning/page/welcome/components/introduction_animation_screen.dart';

class WidgetTree extends StatefulWidget {
  const WidgetTree({Key? key}) : super(key: key);

  @override
  State<WidgetTree> createState() => _WidgetTreeState();
}

class _WidgetTreeState extends State<WidgetTree> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _auth.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }

        if (snapshot.hasData) {
          final User? user = snapshot.data;
          if (user != null) {
            return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              future: _firestore.collection('users').doc(user.uid).get(),
              builder: (BuildContext context,
                  AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>>
                      snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }

                if (snapshot.hasData) {
                  final role = snapshot.data!.data()!['role'];

                  if (role == 'mahasiswa') {
                    return homePage(user);
                  } else if (role == 'dosen') {
                    return HomePageDosen(user);
                  }
                }

                // Peran tidak terdeteksi atau error saat mengambil data
                return LoginPage();
              },
            );
          }
        }

        // Pengguna tidak login
        return IntroductionAnimationScreen();
      },
    );
  }
}
