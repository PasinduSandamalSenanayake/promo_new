import 'dart:async';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:audioplayers/audioplayers.dart';
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // addPostFrameCallback ensures that the context is fully built before accessing it
      final settings = Provider.of<SettingsModel>(context, listen: false);
      durations = settings.allDurations;
      setState(() {
        totalDuration = durations[currentIndex];
        remaining = totalDuration;
        isLoaded = true;
      });
    });
  }

  void startTimer() {
    timer?.cancel(); // Cancel any existing timer
    startTime = DateTime.now();

    timer = Timer.periodic(Duration(milliseconds: 100), (_) {
      final elapsed = DateTime.now().difference(startTime!);
      final elapsedMs = elapsed.inMilliseconds;

      if (elapsedMs < totalDuration.inMilliseconds) {
        setState(() {
          remaining = totalDuration - Duration(milliseconds: elapsedMs);
        });
      } else {
        _playSound();
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

  void _playSound() async {
    await audioPlayer.play(AssetSource('sounds/focus.mp3'));
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
