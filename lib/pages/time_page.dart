import 'dart:async';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'settings_model.dart';

class TimePage extends StatefulWidget {
  @override
  _TimePageState createState() => _TimePageState();
}

class _TimePageState extends State<TimePage> {
  final AudioPlayer audioPlayer = AudioPlayer();

  late List<Duration> durations;
  int currentIndex = 0;
  late Duration totalDuration;
  late Duration remaining;
  DateTime? startTime;
  Timer? timer;
  bool isRunning = false;
  bool isLoaded = false;

  // @override
  // void initState() {
  //   super.initState();
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     // addPostFrameCallback ensures that the context is fully built before accessing it
  //     final settings = Provider.of<SettingsModel>(context, listen: false);
  //     durations = settings.allDurations;
  //     setState(() {
  //       totalDuration = durations[currentIndex];
  //       remaining = totalDuration;
  //       isLoaded = true;
  //     });
  //   });
  // }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        final data = doc.data();

        final focusTime = data?['focusTime'] ?? 25;
        final revisionTime = data?['revisionTime'] ?? 4;
        final shortBreak = data?['shortBreak'] ?? 5;

        durations = [
          Duration(minutes: focusTime),
          Duration(minutes: revisionTime),
          Duration(minutes: shortBreak),
        ];

        setState(() {
          totalDuration = durations[currentIndex];
          remaining = totalDuration;
          isLoaded = true;
        });
      }
    });
  }

  void _startFocusSound() async {
    await audioPlayer.play(AssetSource('sounds/start_focus.mp3'));
  }

  void _overFocusSound() async {
    await audioPlayer.play(AssetSource('sounds/over_focus.mp3'));
  }

  void _startRevisionSound() async {
    await audioPlayer.play(AssetSource('sounds/start_revision.mp3'));
  }

  void _overRevisionSound() async {
    await audioPlayer.play(AssetSource('sounds/over_revision.mp3'));
  }

  void _startBreakSound() async {
    await audioPlayer.play(AssetSource('sounds/start_break.mp3'));
  }

  void _overBreakSound() async {
    await audioPlayer.play(AssetSource('sounds/over_break.mp3'));
  }

  void startTimer() {
    timer?.cancel(); // Cancel any existing timer
    startTime = DateTime.now();

    timer = Timer.periodic(Duration(milliseconds: 100), (_) {
      final elapsed =
          DateTime.now().difference(startTime!); // Calculate elapsed time
      final elapsedMs = elapsed.inMilliseconds; // Convert to milliseconds
      // _startFocusSound();
      if (elapsedMs < totalDuration.inMilliseconds) {
        setState(() {
          remaining = totalDuration - Duration(milliseconds: elapsedMs);
        });
      } else {
        if (currentIndex + 1 == 1) {
          _overFocusSound(); // Play sound only for the first step
          _startRevisionSound();
        } else if (currentIndex + 1 == 2) {
          _overRevisionSound();
          _startBreakSound();
        } else if (currentIndex + 1 == 3) {
          _overBreakSound();
        }
        print("Timer finished for step ${currentIndex + 1}");
        _overFocusSound();
        timer?.cancel();

        if (currentIndex < durations.length - 1) {
          setState(() {
            currentIndex++;
            totalDuration = durations[currentIndex];
            remaining = totalDuration;
          });
          startTimer();
        } else {
          setState(() {
            remaining = Duration.zero;
            isRunning = false;
          });
        }
      }
    });

    setState(() => isRunning = true);
  }

  void pauseTimer() {
    timer?.cancel();
    setState(() => isRunning = false);
  }

  void resetTimer() {
    timer?.cancel();
    setState(() {
      currentIndex = 0;
      totalDuration = durations[currentIndex];
      remaining = totalDuration;
      isRunning = false;
    });
  }

  double get progress {
    final elapsed = totalDuration - remaining;
    return (elapsed.inMilliseconds / totalDuration.inMilliseconds)
        .clamp(0.0, 1.0);
  }

  @override
  void dispose() {
    timer?.cancel();
    audioPlayer.dispose(); // Clean up audio player
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!isLoaded) {
      return Center(child: CircularProgressIndicator());
    }

    final timeText =
        '${remaining.inMinutes.toString().padLeft(2, '0')}:${(remaining.inSeconds % 60).toString().padLeft(2, '0')}';

    return Container(
      color: const Color(0xFF00413A), // ✅ Background color
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Step ${currentIndex + 1} of ${durations.length}",
              style: const TextStyle(
                  fontSize: 18, color: Colors.white), // ✅ Text color
            ),
            const SizedBox(height: 20),
            CircularPercentIndicator(
              radius: 180.0,
              lineWidth: 18.0,
              animation: true,
              animateFromLastPercent: true,
              percent: progress,
              center: Text(
                timeText,
                style: const TextStyle(
                    fontSize: 56,
                    fontWeight: FontWeight.bold,
                    color: Colors.white), // ✅ Time text color
              ),
              circularStrokeCap: CircularStrokeCap.round,
              backgroundColor: Colors.white24,
              progressColor: Colors.tealAccent, // ✅ Progress color
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  iconSize: 40,
                  onPressed: resetTimer,
                ),
                IconButton(
                  icon: const Icon(Icons.pause, color: Colors.white),
                  iconSize: 40,
                  onPressed: isRunning ? pauseTimer : null,
                ),
                IconButton(
                  icon: const Icon(Icons.play_arrow, color: Colors.white),
                  iconSize: 40,
                  onPressed: !isRunning ? startTimer : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
