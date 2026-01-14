import 'package:lablens_ar/screens/home_screen.dart';
import 'package:lablens_ar/screens/library_screen.dart';
import 'package:lablens_ar/services/description.dart';
import 'package:flutter/material.dart';

import 'screens/scanner_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EquipmentManager().loadEquipments();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: NavigatorScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class NavigatorScreen extends StatefulWidget {
  const NavigatorScreen({super.key});
  @override
  State<NavigatorScreen> createState() => _NavigatorScreenState();
}

class _NavigatorScreenState extends State<NavigatorScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    HomeScreen(),
    // ARViewScreen(),
    ScannerScreen(),
    LibraryScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('LabLens AR')),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code),
            label: 'Scanner',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.folder),
            label: 'Library',
          ),
        ],
      ),
    );
  }
}