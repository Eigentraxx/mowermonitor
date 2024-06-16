import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _login,
              child: Text('Login'),
            ),
          ],
        ),
      ),
    );
  }

  void _login() async {
    try {
      final user = (await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      ))
          .user;
      if (user != null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to sign in')));
    }
  }
}
