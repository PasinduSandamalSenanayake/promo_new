import 'package:flutter/material.dart';

class LeftMenu extends StatelessWidget {
  final Function(String) onSelect;

  const LeftMenu({required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blueGrey.shade900,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Name section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "21.4.5",
              style: TextStyle(
                color: Colors.amberAccent,
                fontSize: 42,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Middle buttons
          Column(
            children: [
              _buildButton(Icons.access_time, "Timer", "time"),
              _buildButton(Icons.timeline, "Daily Tasks", "table"),
              _buildButton(Icons.settings, "Settings", "settings"),
            ],
          ),

          // Bottom button
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: _buildButton(Icons.person, "User", "user"),
          )
        ],
      ),
    );
  }

  Widget _buildButton(IconData icon, String label, String key) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF00413A),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () => onSelect(key),
          icon: Icon(icon),
          label: Text(
            label,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
          ),
        ),
      ),
    );
  }
}
