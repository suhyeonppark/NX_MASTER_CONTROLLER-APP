import 'package:flutter/material.dart';

import '../models/button_config.dart';
import '../widgets/grouped_buttons_view.dart';
import '../widgets/status_bar.dart';
import 'home_screen.dart';
import 'ir_screen.dart';
import 'relay_screen.dart';
import 'settings_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  static const _titles = ['NX 제어', '전원제어', 'IR제어', 'Serial', 'IO', '설정'];

  static const _screens = [
    HomeScreen(),
    RelayScreen(),
    IrScreen(),
    SerialScreen(),
    IoScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_index]),
        centerTitle: true,
        actions: const [ConnectionDots(), SizedBox(width: 8)],
      ),
      body: SafeArea(child: IndexedStack(index: _index, children: _screens)),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        height: 72,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: '홈'),
          NavigationDestination(icon: Icon(Icons.power), label: '전원제어'),
          NavigationDestination(icon: Icon(Icons.settings_remote), label: 'IR제어'),
          NavigationDestination(icon: Icon(Icons.cable), label: 'Serial'),
          NavigationDestination(icon: Icon(Icons.input), label: 'IO'),
          NavigationDestination(icon: Icon(Icons.settings), label: '설정'),
        ],
      ),
    );
  }
}

class SerialScreen extends StatelessWidget {
  const SerialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const GroupedScreen(screen: ButtonScreen.serial);
  }
}

class IoScreen extends StatelessWidget {
  const IoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const GroupedScreen(screen: ButtonScreen.io);
  }
}
