import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'settings_model.dart';

class SettingsPage extends StatefulWidget {
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  double focus = 2;
  double revision = 1;
  double breakTime = 0.5;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF00413A), // ✅ Set background color
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSlider("Focus Duration", focus, 1, 60, (value) {
            setState(() => focus = value);
          }),
          _buildSlider("Revision Duration", revision, 1, 20, (value) {
            setState(() => revision = value);
          }),
          _buildSlider("Short Break Duration", breakTime, 0.5, 15, (value) {
            setState(() => breakTime = value);
          }),
          const SizedBox(height: 30),
          Center(
            child: SizedBox(
              width: 200, // ⬅️ adjust width as needed
              height: 50, // ⬅️ adjust height as needed
              child: ElevatedButton(
                onPressed: () {
                  Provider.of<SettingsModel>(context, listen: false)
                      .updateDurations(
                    focus: Duration(minutes: focus.toInt()),
                    revision: Duration(minutes: revision.toInt()),
                    breakTime: Duration(seconds: (breakTime * 60).toInt()),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Settings saved")),
                  );
                },
                child:
                    const Text("Save Settings", style: TextStyle(fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Color(0xFF00413A),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16), // ⬅️ corner radius
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
          style: const TextStyle(
              fontSize: 16, color: Colors.white), // ✅ Label color
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
