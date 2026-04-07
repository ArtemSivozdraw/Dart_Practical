import 'package:flutter/material.dart';

class Lab2EmissionsPage extends StatelessWidget {
  const Lab2EmissionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.engineering_outlined, size: 80, color: Colors.blueGrey.withOpacity(0.5)),
          const SizedBox(height: 24),
          const Text(
            'Сторінка в розробці',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}