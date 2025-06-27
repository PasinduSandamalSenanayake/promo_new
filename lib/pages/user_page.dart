// pages/user_page.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserPage extends StatelessWidget {
  final User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF00413A),
      padding: const EdgeInsets.all(24),
      child: user == null
          ? const Center(
              child: Text(
                "No user is signed in.",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "User Profile",
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 32),

                // Profile Image
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white,
                  backgroundImage: user!.photoURL != null
                      ? NetworkImage(user!.photoURL!)
                      : null,
                  child: user!.photoURL == null
                      ? const Icon(Icons.person,
                          size: 50, color: Color(0xFF00413A))
                      : null,
                ),

                const SizedBox(height: 32),
                _buildInfoRow("Name", user!.displayName ?? 'N/A'),
                _buildInfoRow("Email", user!.email ?? 'N/A'),
                _buildInfoRow("UID", user!.uid, fontSize: 13, grey: true),

                const SizedBox(height: 48),
                SizedBox(
                  width: 200,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () => _showLogoutDialog(context),
                    icon: const Icon(Icons.logout),
                    label:
                        const Text("Sign Out", style: TextStyle(fontSize: 16)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF00413A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text("Confirm Logout"),
        content: const Text("Are you sure you want to sign out?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Close the dialog
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacementNamed(context, '/login');
            },
            child: const Text("Sign Out", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value,
      {double fontSize = 16, bool grey = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        "$label: $value",
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: fontSize,
          color: grey ? Colors.white70 : Colors.white,
        ),
      ),
    );
  }
}
