import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class AccountPage extends StatefulWidget {
  final User user;

  AccountPage(this.user);

  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  late Stream<DocumentSnapshot> _userDataStream;
  late File _imageFile;
  bool _isUploading = false;
  bool _isImageLoaded = false;
  String _imageURL = '';

  @override
  void initState() {
    super.initState();
    _userDataStream = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.user.uid)
        .snapshots();
  }

  Future<void> _uploadImage() async {
    setState(() {
      _isUploading = true;
    });

    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference storageReference =
          FirebaseStorage.instance.ref().child('profile_images/$fileName');
      UploadTask uploadTask = storageReference.putFile(_imageFile);
      TaskSnapshot taskSnapshot = await uploadTask;
      String downloadURL = await taskSnapshot.ref.getDownloadURL();

      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.user.uid)
          .update({'profileImageURL': downloadURL});

      setState(() {
        _isUploading = false;
        _isImageLoaded = true;
        _imageURL = downloadURL;
      });
    } catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Upload Error'),
            content: Text(e.toString()),
            actions: [
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        _isImageLoaded = true;
      });
    }
  }

  Future<void> _deleteImage() async {
    try {
      await FirebaseStorage.instance.refFromURL(_imageURL).delete();

      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.user.uid)
          .update({'profileImageURL': ''});

      setState(() {
        _isImageLoaded = false;
        _imageURL = '';
      });
    } catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Delete Error'),
            content: Text(e.toString()),
            actions: [
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Account'),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _userDataStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          Map<String, dynamic>? userData =
              snapshot.data!.data() as Map<String, dynamic>?;

          return Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _isImageLoaded
                    ? CircleAvatar(
                        radius: 80.0,
                        backgroundImage: _isImageLoaded
                            ? FileImage(_imageFile)
                            : NetworkImage(userData?['profileImageURL'] ?? '')
                                as ImageProvider,
                      )
                    : Container(),
                SizedBox(height: 16.0),
                _isUploading
                    ? CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: _pickImage,
                        child: Text('Pick Image'),
                      ),
                SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: _isImageLoaded ? _uploadImage : null,
                  child: Text('Upload Image'),
                ),
                SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: _isImageLoaded ? _deleteImage : null,
                  child: Text('Delete Image'),
                ),
                SizedBox(height: 16.0),
                Text('Email: ${userData?['email'] ?? ''}'),
                SizedBox(height: 16.0),
                Text('Password: ${userData?['password'] ?? ''}'),
              ],
            ),
          );
        },
      ),
    );
  }
}
