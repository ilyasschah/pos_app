// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Imports
import 'login_screen.dart';
import 'kitchen_screen.dart'; // <--- IMPORT KITCHEN SCREEN
import 'company_selection_screen.dart';
import 'menu_screen.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'POS System',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      // ROUTING LOGIC
      initialRoute: '/select-company',
      routes: {
        '/select-company': (context) => const CompanySelectionScreen(),
        '/login': (context) => const LoginScreen(),
        '/menu': (context) => const MenuScreen(),
        '/kitchen': (context) => const KitchenScreen(),
      },
    );
  }
}
