import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../layout/dashboard_layout.dart';
import 'login_page.dart';

class AuthPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // User is logged in
        if (snapshot.connectionState == ConnectionState.active) {
          final user = snapshot.data;
          if (user != null) {
            return DashboardLayout();
          } else {
            return LoginPage();
          }
        }

        // While checking auth state
        return Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}
