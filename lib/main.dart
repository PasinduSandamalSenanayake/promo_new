import 'package:flutter/material.dart';
import 'package:promodoor/pages/settings_model.dart';
import 'package:provider/provider.dart';
import 'layout/dashboard_layout.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => SettingsModel(), // ✅ Provide your model
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Web Dashboard',
      home: DashboardLayout(),
      debugShowCheckedModeBanner: false,
    );
  }
}
