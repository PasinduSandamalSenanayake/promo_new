import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'settings_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SettingsPage extends StatefulWidget {
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  double focus = 25;
  double revision = 20;
  double breakTime = 5;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserSettings();
  }

  Future<void> _loadUserSettings() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final data = doc.data();
      if (data != null) {
        setState(() {
          focus = (data['focusTime'] ?? 25).toDouble();
          revision = (data['revisionTime'] ?? 20).toDouble();
          breakTime = (data['shortBreak'] ?? 5).toDouble();
          isLoading = false;
        });
      }
    }
  }

  Future<void> _saveSettingsToFirestore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'focusTime': focus.toInt(),
        'revisionTime': revision.toInt(),
        'shortBreak': breakTime.toInt(),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Container(
      color: const Color(0xFF00413A),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSlider("Focus Duration", focus, 1, 60, (value) {
            setState(() => focus = value);
          }),
          _buildSlider("Revision Duration", revision, 1, 30, (value) {
            setState(() => revision = value);
          }),
          _buildSlider("Short Break Duration", breakTime, 1, 15, (value) {
            setState(() => breakTime = value);
          }),
          const SizedBox(height: 30),
          Center(
            child: SizedBox(
              width: 200,
              height: 50,
              child: ElevatedButton(
                onPressed: () async {
                  // Save to SettingsModel if needed in app state
                  Provider.of<SettingsModel>(context, listen: false)
                      .updateDurations(
                    focus: Duration(minutes: focus.toInt()),
                    revision: Duration(minutes: revision.toInt()),
                    breakTime: Duration(minutes: breakTime.toInt()),
                  );

                  // ✅ Save to Firestore
                  await _saveSettingsToFirestore();

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Settings saved")),
                  );
                },
                child:
                    const Text("Save Settings", style: TextStyle(fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF00413A),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlider(String label, double value, double min, double max,
      ValueChanged<double> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label (${value.toStringAsFixed(1)} min)',
          style: const TextStyle(fontSize: 16, color: Colors.white),
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: ((max - min) * 2).toInt(),
          label: "${value.toStringAsFixed(1)} min",
          onChanged: onChanged,
          activeColor: Colors.tealAccent,
          inactiveColor: Colors.white24,
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
