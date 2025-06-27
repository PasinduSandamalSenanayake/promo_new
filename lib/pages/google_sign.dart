// lib/google_sign.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GoogleSignInPage extends StatefulWidget {
  const GoogleSignInPage({super.key});

  @override
  State<GoogleSignInPage> createState() => _GoogleSignInPageState();
}

class _GoogleSignInPageState extends State<GoogleSignInPage> {
  User? _user;
  String _error = '';

  Future<void> signInWithGoogle() async {
    try {
      GoogleAuthProvider googleProvider = GoogleAuthProvider();

      // Sign in using a popup for web
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithPopup(googleProvider);

      setState(() {
        _user = userCredential.user;
        _error = '';
      });
    } on FirebaseAuthException catch (e) {
      setState(() {
        _error = e.message ?? 'An unknown error occurred.';
      });
    } catch (e) {
      setState(() {
        _error = 'Error: $e';
      });
    }
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    setState(() {
      _user = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Google Sign-In'),
        actions: [
          if (_user != null)
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: signOut,
            ),
        ],
      ),
      body: Center(
        child: _user == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: signInWithGoogle,
                    child: const Text("Sign in with Google"),
                  ),
                  if (_error.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        _error,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(_user!.photoURL ?? ''),
                    radius: 40,
                  ),
                  const SizedBox(height: 16),
                  Text('Hello, ${_user!.displayName ?? "User"}'),
                  Text(_user!.email ?? ''),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: signOut,
                    child: const Text("Sign Out"),
                  ),
                ],
              ),
      ),
    );
  }
}
