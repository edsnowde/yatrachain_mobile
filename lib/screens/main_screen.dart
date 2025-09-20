import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:yatrachain/providers/app_provider.dart';
import 'package:yatrachain/screens/home_screen.dart';
import 'package:yatrachain/screens/trips_screen.dart';
import 'package:yatrachain/screens/map_screen.dart';
import 'package:yatrachain/screens/chatbot_screen.dart';
import 'package:yatrachain/screens/profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  late PageController _pageController;

  final List<Widget> _screens = const [
    HomeScreen(),
    TripsScreen(),
    MapScreen(),
    ChatbotScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    
    // Load app data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppProvider>().loadData();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      body: PageView(
        controller: _pageController,
        children: _screens,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SalomonBottomBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
            _pageController.animateToPage(
              index,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          },
          selectedItemColor: theme.colorScheme.primary,
          unselectedItemColor: theme.colorScheme.outline,
          backgroundColor: theme.colorScheme.surface,
          items: [
            SalomonBottomBarItem(
              icon: const Icon(Icons.home_rounded),
              title: const Text('Home'),
            ),
            SalomonBottomBarItem(
              icon: const Icon(Icons.route_rounded),
              title: const Text('Trips'),
            ),
            SalomonBottomBarItem(
              icon: const Icon(Icons.map_rounded),
              title: const Text('Map'),
            ),
            SalomonBottomBarItem(
              icon: const Icon(Icons.smart_toy_rounded),
              title: const Text('YatraBot'),
            ),
            SalomonBottomBarItem(
              icon: const Icon(Icons.person_rounded),
              title: const Text('Profile'),
            ),
          ],
        ),
      ),
    );
  }
}