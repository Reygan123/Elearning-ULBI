import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:elearning/page/login/daftar.dart';
import 'package:elearning/page/login/lupa.dart';
import 'package:elearning/page/beranda/home.dart';
import 'package:elearning/dosen/beranda_dosen/home_dosen.dart';

class LoginPage extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> _login(BuildContext context) async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      // Cek apakah email admin
      if (emailController.text == "dosen@gmail.com") {
        // Navigasi ke halaman admin setelah login berhasil
        // ignore: use_build_context_synchronously
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => HomePageDosen(userCredential.user!)),
        );
      } else {
        // Navigasi ke halaman user setelah login berhasil
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => homePage(userCredential.user!)),
        );
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Login Error'),
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

  Widget _judul(judul, color, size) {
    return Text(
      judul ?? '',
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

  Widget _spasi() {
    return SizedBox(height: 10);
  }

  Widget _biasa(biasa, color) {
    return Text(
      biasa ?? '',
      style: TextStyle(
        color: color,
        fontSize: 12,
        fontWeight: FontWeight.normal,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            child: Column(children: [
      Container(
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
            color: Colors.white,
          ),
          child: Column(children: [
            _space(),
            _space(),
            _judul('Login', Colors.black, 18),
            _space(),
            _space(),
          ])),
      _space(),
      _space(),
      Container(
        height: 50,
        width: 140,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
                'assets/intro/logo_ulbi.png'), // Ganti dengan path gambar yang sesuai
            fit: BoxFit.cover, // Menyesuaikan gambar dengan kotak
          ),
        ),
      ),
      _space(),
      _space(),
      Container(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                color: Colors.white,
              ),
              padding: EdgeInsets.only(left: 10, right: 10),
              child: Row(
                children: [
                  Icon(
                    Icons.email,
                    size: 24,
                    color: Colors.grey,
                  ),
                  SizedBox(width: 8.0),
                  Expanded(
                    child: TextField(
                      controller: emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        border: InputBorder
                            .none, // Menghilangkan garis bawah pada InputDecoration
                        labelStyle: TextStyle(
                          fontSize: 12.0, // Memperkecil ukuran teks label
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            _space(),
            Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                color: Colors.white,
              ),
              padding: EdgeInsets.only(left: 10, right: 10),
              child: Row(
                children: [
                  Icon(
                    Icons.lock,
                    size: 24,
                    color: Colors.grey,
                  ),
                  SizedBox(width: 8.0),
                  Expanded(
                    child: TextField(
                      controller: passwordController,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        border: InputBorder
                            .none, // Menghilangkan garis bawah pada InputDecoration
                        labelStyle: TextStyle(
                          fontSize: 12.0, // Memperkecil ukuran teks label
                        ),
                      ),
                      obscureText: true,
                    ),
                  ),
                ],
              ),
            ),
            _space(),
            Align(
                alignment: Alignment.centerLeft,
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ForgotPasswordPage()),
                    );
                  },
                  child: Text(
                    'Lupa password',
                    style: TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                )),
            _space(),
            _space(),
            ElevatedButton(
              onPressed: () => _login(context),
              child: Text('Login'),
              style: ButtonStyle(
                fixedSize: MaterialStateProperty.all(
                  Size(
                    MediaQuery.of(context).size.width,
                    20, // Sesuaikan tinggi button sesuai kebutuhan
                  ),
                ),
                backgroundColor:
                    MaterialStateProperty.all<Color>(Colors.deepOrange),
              ),
            ),
            // ElevatedButton(
            //   onPressed: () {
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(builder: (context) => SignUpPage()),
            //     );
            //   },
            //   child: Text('Daftar'),
            // ),
          ],
        ),
      ),
    ])));
  }
}
