import 'package:flutter/material.dart';

class SettingsModel extends ChangeNotifier {
  Duration focusDuration = Duration(minutes: 2);
  Duration revisionDuration = Duration(minutes: 1);
  Duration shortBreakDuration = Duration(seconds: 30);

  void updateDurations({
    required Duration focus,
    required Duration revision,
    required Duration breakTime,
  }) {
    focusDuration = focus;
    revisionDuration = revision;
    shortBreakDuration = breakTime;
    notifyListeners();
  }

  List<Duration> get allDurations => [
        focusDuration,
        revisionDuration,
        shortBreakDuration,
      ];
}
