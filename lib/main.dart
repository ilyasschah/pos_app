import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'login_screen.dart';
import 'kitchen_screen.dart';
import 'company_selection_screen.dart';
import 'menu_screen.dart';
import 'settings_provider.dart';

void main() async {
  // 1. Ensure Flutter bindings are initialized before calling native code
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Load SharedPreferences into memory
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      // 3. Inject the loaded preferences directly into our Riverpod tree
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the current theme mode
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'POS System',
      themeMode: themeMode, // Apply the toggleable theme
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue, brightness: Brightness.light),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue, brightness: Brightness.dark),
        useMaterial3: true,
      ),
      initialRoute: '/login',
      routes: {
        '/select-company': (context) => const CompanySelectionScreen(),
        '/login': (context) => const LoginScreen(),
        '/menu': (context) => const MenuScreen(),
        '/kitchen': (context) => const KitchenScreen(),
      },
    );
  }
}
