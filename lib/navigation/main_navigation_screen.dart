import 'package:flutter/material.dart';
import 'bottom_nav_bar.dart';
import '../features/wardrobe/screens/wardrobe_screen.dart';
import '../features/home/screens/home_dashboard_screen.dart';
import '../features/outfit_generator/screens/outfit_generator_screen.dart';
import '../features/profile/screens/profile_screen.dart';
import '../features/rate_outfit/screens/rate_outfit_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeDashboardScreen(),
    const WardrobeScreen(),
    const OutfitGeneratorScreen(),
    const RateOutfitScreen(),
    const ProfileScreen(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}
