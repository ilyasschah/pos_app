import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_app/auth/auth_storage.dart';
import 'package:pos_app/auth/master_login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pos_app/auth/login_screen.dart';
import 'package:pos_app/settings/settings_provider.dart';
import 'package:pos_app/app_settings/app_settings_model.dart';
import 'package:pos_app/app_settings/app_settings_provider.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const MyApp(),
    ),
  );
}

ThemeData _buildTheme(String mode, Color seed) {
  switch (mode) {
    case 'light':
      return ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: seed,
          brightness: Brightness.light,
        ),
      );

    case 'dimmed':
      final cs = ColorScheme.fromSeed(
        seedColor: seed,
        brightness: Brightness.dark,
      );
      return ThemeData(
        useMaterial3: true,
        colorScheme: cs.copyWith(
          surface: const Color(0xFF1C2333),
          surfaceContainerLowest: const Color(0xFF111927),
          surfaceContainerLow: const Color(0xFF1A2030),
          surfaceContainer: const Color(0xFF202736),
          surfaceContainerHigh: const Color(0xFF263040),
          surfaceContainerHighest: const Color(0xFF283045),
        ),
        scaffoldBackgroundColor: const Color(0xFF15202B),
        cardColor: const Color(0xFF1C2333),
      );

    case 'night':
      final cs = ColorScheme.fromSeed(
        seedColor: seed,
        brightness: Brightness.dark,
      );
      return ThemeData(
        useMaterial3: true,
        colorScheme: cs.copyWith(
          surface: const Color(0xFF080808),
          surfaceContainerLowest: Colors.black,
          surfaceContainerLow: const Color(0xFF0D0D0D),
          surfaceContainer: const Color(0xFF111111),
          surfaceContainerHigh: const Color(0xFF161616),
          surfaceContainerHighest: const Color(0xFF1C1C1C),
          onSurface: Colors.white,
          onSurfaceVariant: const Color(0xFFCCCCCC),
        ),
        scaffoldBackgroundColor: Colors.black,
        cardColor: const Color(0xFF0D0D0D),
      );

    case 'gray':
      final cs = ColorScheme.fromSeed(
        seedColor: const Color(0xFF808080),
        brightness: Brightness.dark,
      ).copyWith(primary: seed, secondary: seed, tertiary: seed);
      return ThemeData(
        useMaterial3: true,
        colorScheme: cs,
        scaffoldBackgroundColor: const Color(0xFF1A1A1A),
        cardColor: const Color(0xFF262626),
      );

    case 'high_contrast':
      final cs = ColorScheme.fromSeed(
        seedColor: seed,
        brightness: Brightness.dark,
      );
      return ThemeData(
        useMaterial3: true,
        colorScheme: cs.copyWith(
          surface: Colors.black,
          surfaceContainerLowest: Colors.black,
          surfaceContainerLow: const Color(0xFF0A0A0A),
          surfaceContainer: const Color(0xFF0F0F0F),
          surfaceContainerHigh: const Color(0xFF1A1A1A),
          surfaceContainerHighest: const Color(0xFF222222),
          onSurface: Colors.white,
          onSurfaceVariant: const Color(0xFFE0E0E0),
          outline: const Color(0xFF777777),
          outlineVariant: const Color(0xFF444444),
        ),
        scaffoldBackgroundColor: Colors.black,
        cardColor: const Color(0xFF111111),
      );

    default: // 'dark'
      return ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: seed,
          brightness: Brightness.dark,
        ),
      );
  }
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  late Future<bool> _deviceRegisteredFuture;

  @override
  void initState() {
    super.initState();
    _deviceRegisteredFuture = ref
        .read(authStorageProvider)
        .isDeviceRegistered();
  }

  Color _parseAccentColor(String? hex) {
    if (hex == null) return Colors.blue;
    try {
      final clean = hex.replaceAll('#', '');
      return Color(int.parse('FF$clean', radix: 16));
    } catch (_) {
      return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(appSettingsProvider);
    final isRtl =
        settings[SettingKeys.writingDirection]?.toUpperCase() == 'RTL';
    final seed = _parseAccentColor(settings[SettingKeys.themeAccentColor]);
    final themeString = settings[SettingKeys.themeMode] ?? 'dark';
    final themeData = _buildTheme(themeString, seed);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'POS System',
      themeMode: ThemeMode.light,
      theme: themeData,
      builder: (context, child) => Directionality(
        textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
        child: child!,
      ),
      home: FutureBuilder<bool>(
        future: _deviceRegisteredFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          final isRegistered = snapshot.data ?? false;
          return isRegistered ? const LoginScreen() : const MasterLoginScreen();
        },
      ),
    );
  }
}
