// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:floating_bottom_navigation_bar/floating_bottom_navigation_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:elearning/dosen/beranda_dosen/beranda.dart';
import 'package:elearning/dosen/course/my_course.dart';
import 'package:elearning/dosen/course/anggota.dart';
import 'package:elearning/page/akun/account.dart';

class HomePageDosen extends StatefulWidget {
  final User user;

  const HomePageDosen(this.user, {super.key});

  @override
  _HomeeState createState() => _HomeeState();
}

class _HomeeState extends State<HomePageDosen> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  int _selectedindexx = 0;

  void _navigateBottombar(int indexx) {
    setState(() {
      _selectedindexx = indexx;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pagess = [
      BerandaDosen(user: widget.user),
      MyCoursePage(user: widget.user),
      AnggotaPage(user: widget.user),
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
          onTap: (indexx) {
            _navigateBottombar(indexx);
          },
          currentIndex: _selectedindexx,
          items: [
            FloatingNavbarItem(
              icon: Icons.home,
            ),
            FloatingNavbarItem(
              icon: Icons.book,
            ),
            FloatingNavbarItem(icon: Icons.chat_bubble_outline),
            FloatingNavbarItem(
              icon: Icons.settings,
            ),
          ],
        ),
      ),
      body: pagess[_selectedindexx],
    );
  }
}
