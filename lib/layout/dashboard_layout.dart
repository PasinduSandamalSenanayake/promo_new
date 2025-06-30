import 'package:flutter/material.dart';
import 'package:promodoor/pages/time_table_page.dart';
import '../pages/user_page.dart';
import '../widgets/left_menu.dart';
import '../pages/time_page.dart';
import '../pages/settings_page.dart';
// import '../pages/mode_page.dart';

class DashboardLayout extends StatefulWidget {
  @override
  _DashboardLayoutState createState() => _DashboardLayoutState();
}

class _DashboardLayoutState extends State<DashboardLayout> {
  Widget _currentPage = TimePage(); // Initial blank

  void _setPage(String page) {
    setState(() {
      switch (page) {
        case 'time':
          _currentPage = TimePage();
          break;
        case 'table':
          _currentPage = TimeTablePage();
          break;
        case 'settings':
          _currentPage = SettingsPage();
          break;
        case 'user':
          _currentPage = UserPage();
          break;
        default:
          _currentPage = TimePage();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.2,
            child: LeftMenu(onSelect: _setPage),
          ),
          Expanded(child: _currentPage),
        ],
      ),
    );
  }
}
