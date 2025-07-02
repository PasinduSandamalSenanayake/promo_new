import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../widgets/card_widget.dart';

final userId = FirebaseAuth.instance.currentUser?.uid;

class DailyTaskPage extends StatefulWidget {
  const DailyTaskPage({super.key});

  @override
  State<DailyTaskPage> createState() => _DailyTaskPageState();
}

class _DailyTaskPageState extends State<DailyTaskPage> {
  final List<Map<String, String>> tasks = List.generate(10, (index) {
    final startHour = index + 8;
    final endHour = startHour + 1;
    return {
      'task': 'Task ${index + 1}',
      'taskName': 'Sample Task ${index + 1}',
      'time': '${startHour}:00 AM - ${endHour}:00 AM',
    };
  });

  String getCurrentDate() {
    final now = DateTime.now();
    return DateFormat('yyyy-MM-dd').format(now);
  }

  void showAddTaskDialog() {
    String taskName = '';
    TimeOfDay? startTime;
    TimeOfDay? endTime;
    Color? selectedColor;
    String? selectedColorName;

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          backgroundColor: const Color(0xFF00413A), // Custom dark green
          child: StatefulBuilder(
            builder: (context, setState) {
              return Container(
                width: MediaQuery.of(context).size.width * 0.25,
                height: 420,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Text(
                        "Add New Task",
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Task Name',
                        labelStyle: const TextStyle(color: Colors.white70),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.white54),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.white),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onChanged: (value) => taskName = value,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () async {
                              final picked = await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.now());
                              if (picked != null) {
                                setState(() => startTime = picked);
                              }
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: Colors.white),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(startTime == null
                                ? 'Start Time'
                                : 'Start: ${startTime!.format(context)}'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () async {
                              final picked = await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.now());
                              if (picked != null) {
                                setState(() => endTime = picked);
                              }
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: Colors.white),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(endTime == null
                                ? 'End Time'
                                : 'End: ${endTime!.format(context)}'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Select Task Priority:",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _buildColorOption(
                          'Green - Important and Urgent',
                          Colors.green,
                          selectedColor,
                          (color) {
                            setState(() {
                              selectedColor = color;
                              selectedColorName = 'green';
                            });
                          },
                        ),
                        const SizedBox(height: 8),
                        _buildColorOption(
                          'Blue - Important but Not Urgent',
                          Colors.blue,
                          selectedColor,
                          (color) {
                            setState(() {
                              selectedColor = color;
                              selectedColorName = 'blue';
                            });
                          },
                        ),
                        const SizedBox(height: 8),
                        _buildColorOption(
                          'Yellow - Not Important but Urgent',
                          Colors.yellow,
                          selectedColor,
                          (color) {
                            setState(() {
                              selectedColor = color;
                              selectedColorName = 'yellow';
                            });
                          },
                        ),
                        const SizedBox(height: 8),
                        _buildColorOption(
                          'Red - Not Important and Not Urgent',
                          Colors.red,
                          selectedColor,
                          (color) {
                            setState(() {
                              selectedColor = color;
                              selectedColorName = 'red';
                            });
                          },
                        ),
                      ],
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                          ),
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 8),
                        TextButton(
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                          ),
                          onPressed: () async {
                            if (taskName.isNotEmpty &&
                                startTime != null &&
                                endTime != null &&
                                selectedColor != null) {
                              final userId =
                                  FirebaseAuth.instance.currentUser?.uid;

                              if (userId == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text("User not logged in.")),
                                );
                                return;
                              }

                              // Save locally (if needed for UI)
                              setState(() {
                                tasks.add({
                                  'task': 'Class ${tasks.length + 1}',
                                  'taskName': taskName,
                                  'time':
                                      '${startTime!.format(context)} - ${endTime!.format(context)}',
                                  'color': selectedColorName!,
                                });
                              });

                              // Save to Firestore under users/{userId}/Tasks
                              await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(userId)
                                  .collection('Tasks')
                                  .add({
                                'taskName': taskName,
                                'startTime': startTime!.format(context),
                                'endTime': endTime!.format(context),
                                'color': selectedColorName,
                                'createdAt': Timestamp.now(),
                              });

                              Navigator.pop(context);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content:
                                        Text("Please fill in all fields.")),
                              );
                            }
                          },
                          child: const Text('Add'),
                        ),
                      ],
                    )
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildColorOption(String label, Color color, Color? selectedColor,
      Function(Color) onSelect) {
    return GestureDetector(
      onTap: () => onSelect(color),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            backgroundColor: color,
            radius: 10,
            child: selectedColor == color
                ? const Icon(Icons.check, color: Colors.white, size: 14)
                : null,
          ),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                color: selectedColor == color ? Colors.white : Colors.white70,
                fontSize: 16,
              )),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Header with Title and Buttons
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              height: 100,
              decoration: BoxDecoration(
                color: Color(0xFF00413A), // Change to any color you like
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Daily Tasks - ${getCurrentDate()}',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color:
                              Colors.white, // 🔁 Change to any color you want
                        ),
                  ),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          showAddTaskDialog();
                        },
                        icon: const Icon(Icons.add),
                        label: const Text("Add Task"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: () {
                          // TODO: Implement delete all tasks logic
                        },
                        icon: const Icon(Icons.delete),
                        label: const Text("Delete All"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16.0),
            // Task Cards
            card_widget(),
          ],
        ),
      ),
    );
  }
}
