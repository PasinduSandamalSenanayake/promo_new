import 'package:flutter/material.dart';
import 'package:promodoor/pages/google_sign.dart';
import 'package:promodoor/pages/login_page.dart';
import 'package:promodoor/pages/register_page.dart';
import 'package:promodoor/pages/settings_model.dart';
import 'package:provider/provider.dart';
import 'layout/dashboard_layout.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
      home: LoginPage(),
      debugShowCheckedModeBanner: false,

      // ✅ Add this:
      routes: {
        '/login': (context) => LoginPage(),
        '/register': (context) => RegisterPage(),
        '/home': (context) => DashboardLayout(),
        // Add other pages as needed
      },
    );
  }
}
