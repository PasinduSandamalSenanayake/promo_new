import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:promodoor/pages/time_page.dart';

import '../pages/time_table_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class card_widget extends StatelessWidget {
  const card_widget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('Tasks')
            .orderBy('createdAt', descending: false)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No tasks found."));
          }

          final taskDocs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: taskDocs.length,
            itemBuilder: (context, index) {
              final task = taskDocs[index];
              final taskName = task['taskName'];
              final startTime = task['startTime'];
              final endTime = task['endTime'];
              final color = task['color'] ?? 'yellow'; // fallback color

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                color: color == 'yellow'
                    ? Colors.yellow.shade100
                    : color == 'green'
                        ? Colors.green.shade100
                        : color == 'red'
                            ? Colors.red.shade100
                            : Colors.blue.shade100,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Task ${index + 1}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text('Task: $taskName',
                                style: const TextStyle(fontSize: 20)),
                            Text('Time: $startTime - $endTime'),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              backgroundColor: Colors.yellow,
                              foregroundColor: Colors.black,
                            ),
                            onPressed: () {
                              // Navigator.push(
                              //   context,
                              //   MaterialPageRoute(
                              //       builder: (context) => TimePage()),
                              // );
                            },
                            child: const Text('Start'),
                          ),
                          const SizedBox(width: 4),
                          StatefulBuilder(
                            builder: (context, setInnerState) {
                              bool isConfirmed = false;

                              return ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  backgroundColor:
                                      isConfirmed ? Colors.green : null,
                                ),
                                onPressed: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Confirmation'),
                                      content: const Text(
                                          'Are you complete the task?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, false),
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, true),
                                          child: const Text('OK'),
                                        ),
                                      ],
                                    ),
                                  );

                                  if (confirm == true) {
                                    setInnerState(() {
                                      isConfirmed = true;
                                    });
                                  }
                                },
                                child: Text(
                                    isConfirmed ? 'Completed' : 'Complete'),
                              );
                            },
                          ),
                          const SizedBox(width: 4),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () async {
                              await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(userId)
                                  .collection('Tasks')
                                  .doc(task.id)
                                  .delete();
                            },
                          ),
                          IconButton(
                              onPressed: () async {
                                // TODO: Edit Task Logic
                              },
                              icon: Icon(Icons.edit)),
                        ],
                      )
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
