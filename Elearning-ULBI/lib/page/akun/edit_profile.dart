import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:image_picker/image_picker.dart';

class EditProfilePage extends StatefulWidget {
  final User user;

  EditProfilePage({required this.user});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _alamatController = TextEditingController();
  late Stream<DocumentSnapshot> _userDataStream;
  File? _image;

  @override
  void initState() {
    super.initState();
    // Mengambil data pengguna saat ini dan mengisi controller dengan nilai awal
    _fetchUserData();
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
      style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.w500),
    );
  }

  Future<void> _fetchUserData() async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.user.uid)
          .get();

      if (snapshot.exists) {
        Map<String, dynamic> userData = snapshot.data() as Map<String, dynamic>;
        _nameController.text = userData['name'] ?? '';
        _alamatController.text = userData['alamat'] ?? '';
      }
    } catch (e) {
      // Menangani kesalahan saat mengambil data pengguna
      print('Error fetching user data: $e');
    }
  }

  Future<void> _updateProfile() async {
    try {
      String newName = _nameController.text.trim();
      String newalamat = _alamatController.text.trim();

      // Memperbarui data pengguna di Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.user.uid)
          .update({
        'name': newName,
        'alamat': newalamat,
      });

      // Menampilkan snackbar untuk memberi tahu pengguna bahwa profil telah diperbarui
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Profile updated successfully'),
        ),
      );
    } catch (e) {
      // Menangani kesalahan saat memperbarui profil
      print('Error updating profile: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update profile'),
        ),
      );
    }
  }

  @override
  void dispose() {
    // Menghapus controller saat halaman dihapus
    _nameController.dispose();
    _alamatController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _image = File(pickedImage.path);
      });

      // Upload the image to Firebase Storage
      String userId = widget.user.uid;
      String fileName = 'profile_$userId.jpg';
      firebase_storage.Reference storageRef =
          firebase_storage.FirebaseStorage.instance.ref().child(fileName);
      firebase_storage.UploadTask uploadTask = storageRef.putFile(_image!);

      // Monitor the upload task
      firebase_storage.TaskSnapshot taskSnapshot = await uploadTask;
      String downloadUrl = await taskSnapshot.ref.getDownloadURL();

      // Save the download URL to the user's profile
      FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({'profileImageUrl': downloadUrl});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: const BackButton(
            color: Colors.black,
          ),
        ),
        body: Column(children: [
          Text(
            'Edit Profile',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          StreamBuilder<DocumentSnapshot>(
              stream: _userDataStream,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                Map<String, dynamic>? userData =
                    snapshot.data!.data() as Map<String, dynamic>?;

                return Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      GestureDetector(
                        onTap: _pickImage,
                        child: CircleAvatar(
                          radius: 50,
                          backgroundImage:
                              _image != null ? FileImage(_image!) : null,
                          child: _image == null
                              ? Icon(Icons.person, size: 140)
                              : null,
                        ),
                      ),
                      TextField(
                        controller: _nameController,
                        decoration: InputDecoration(labelText: 'Nama'),
                      ),
                      _judul('${userData?['email'] ?? ''}', Colors.black, 14),
                      _judul('${userData?['npm'] ?? ''}', Colors.black, 14),
                      SizedBox(height: 10),
                      TextField(
                        controller: _alamatController,
                        decoration: InputDecoration(
                          labelText: 'Alamat',
                        ),
                      ),
                      _judul('${userData?['jurusan'] ?? ''}', Colors.black, 14),
                      _judul('${userData?['kelas'] ?? ''}', Colors.black, 14),
                      SizedBox(height: 20),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: ElevatedButton(
                            onPressed: _updateProfile,
                            style: ElevatedButton.styleFrom(
                              primary: Colors.deepOrange,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child:
                                _judul('Simpan Perubahan', Colors.white, 14)),
                      ),
                    ],
                  ),
                );
              })
        ]));
  }
}
