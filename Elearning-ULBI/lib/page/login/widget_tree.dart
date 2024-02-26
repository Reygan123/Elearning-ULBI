import 'package:flutter/material.dart';
import 'package:elearning/page/beranda/home.dart';
import 'package:elearning/page/login/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:elearning/auth.dart';

class WidgetTree extends StatefulWidget {
  const WidgetTree({Key? key}) : super(key: key);

  @override
  State<WidgetTree> createState() => _WidgetTreeState();
}

class _WidgetTreeState extends State<WidgetTree> {
  User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: Auth().authStateChanges,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return homePage(user!);
          } else {
            return LoginPage();
          }
        });
  }
}
