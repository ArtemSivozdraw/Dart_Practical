import 'package:flutter/material.dart';

// Імпортуємо файли з вашими лабораторними роботами
import 'labs/lab1_fuel.dart';
import 'labs/lab2_emissions.dart';
import 'labs/lab3_solar.dart';
import 'labs/lab4_short_circuit.dart';
import 'labs/lab5_reliability.dart';
import 'labs/lab6_loads.dart';

void main() {
  runApp(const EnergyLabsApp());
}

class EnergyLabsApp extends StatelessWidget {
  const EnergyLabsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Енергетичні розрахунки',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
        useMaterial3: true,
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      home: const MainLayout(),
    );
  }
}

// Загальний каркас із навігацією
class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;

  // Тут ми просто викликаємо класи з інших файлів!
  final List<Widget> _pages = const [
    Lab1FuelPage(),
    Lab2EmissionsPage(),
    Lab3SolarPage(),
    Lab4ShortCircuitPage(),
    Lab5ReliabilityPage(),
    Lab6LoadsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            labelType: NavigationRailLabelType.all,
            destinations: const [
              NavigationRailDestination(icon: Icon(Icons.local_fire_department), label: Text('ЛР1')),
              NavigationRailDestination(icon: Icon(Icons.cloud), label: Text('ЛР2')),
              NavigationRailDestination(icon: Icon(Icons.solar_power), label: Text('ЛР3')),
              NavigationRailDestination(icon: Icon(Icons.bolt), label: Text('ЛР4')),
              NavigationRailDestination(icon: Icon(Icons.security), label: Text('ЛР5')),
              NavigationRailDestination(icon: Icon(Icons.power), label: Text('ЛР6')),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: _pages[_selectedIndex], // Відмальовує вибрану сторінку
          ),
        ],
      ),
    );
  }
}