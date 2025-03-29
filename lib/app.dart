import 'package:Finspense/screens/investment_news/investments_page.dart';
import 'package:flutter/material.dart';

import 'screens/analytics/ai_analytics_page.dart';
import 'screens/goals/goals.dart';
import 'screens/home_screen/home.dart';
import 'screens/profile/settings.dart';

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  int _selectedIndex = 0;

  static final List<Widget> _pages = [
    const HomePage(),
    const AIAnalyticsPage(),
    const GoalsPage(),
    InvestmentsPage(),
    SettingsPage(),
  ];

  void _onItemTapped(int index) {
    if (_selectedIndex != index) {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: _pages,
        ),
      ),
      bottomNavigationBar: Container(
        height: 65,
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          child: BottomAppBar(
            height: 65,
            padding: EdgeInsets.zero, // Ensure padding is non-negative
            elevation: 0,
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.home_outlined, Icons.home, 'Home'),
                _buildNavItem(
                    1, Icons.analytics_outlined, Icons.analytics, 'Analytics'),
                _buildNavItem(2, Icons.flag_outlined, Icons.flag, 'Goals'),
                _buildNavItem(3, Icons.account_balance_outlined,
                    Icons.account_balance, 'Investments'),
                _buildNavItem(
                    4, Icons.settings_outlined, Icons.settings, 'Settings'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
      int index, IconData icon, IconData activeIcon, String label) {
    final isSelected = _selectedIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => _onItemTapped(index),
        customBorder: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(15)),
        ),
        splashColor: const Color(0xFF2C3E50).withOpacity(0.1),
        highlightColor: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? const Color(0xFF2C3E50) : Colors.grey,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? const Color(0xFF2C3E50) : Colors.grey,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
