import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:floating_bottom_navigation_bar/floating_bottom_navigation_bar.dart';
import 'package:elearning/page/course/my_course.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:elearning/page/beranda/beranda.dart';
import 'package:elearning/page/akun/account.dart';

import 'package:elearning/page/course/prodi.dart';


class homePage extends StatefulWidget {
  final User user;

  homePage(this.user);

  @override
  _homeeState createState() => _homeeState();
}

class _homeeState extends State<homePage> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  List<QueryDocumentSnapshot> tugas = [];
  int _selectedindex = 0;

  void _navigateBottombar(int index) {
    setState(() {
      _selectedindex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = [
      Beranda(user: widget.user),
      MyCoursePage(),
      JurusanPage(),
      AccountPage(user: widget.user),
    ];
    return Scaffold(
      extendBody: true,
      bottomNavigationBar: Container(
        margin: EdgeInsets.symmetric(horizontal: 20.0),
        child: FloatingNavbar(
          borderRadius: 20,
          backgroundColor: Colors.white,
          elevation: 0,
          unselectedItemColor: Colors.grey,
          selectedItemColor: Colors.deepOrange,
          onTap: (index) {
            _navigateBottombar(index);
          },
          currentIndex: _selectedindex,
          items: [
            FloatingNavbarItem(
              icon: Icons.home,
            ),
            FloatingNavbarItem(
              icon: Icons.menu_book,
            ),
            FloatingNavbarItem(icon: Icons.chat_bubble_outline),
            FloatingNavbarItem(
              icon: Icons.settings,
            ),
          ],
        ),
      ),
      body: _pages[_selectedindex],
    );
  }
}
