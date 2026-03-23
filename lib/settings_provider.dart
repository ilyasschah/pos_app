import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 1. Synchronous Shared Preferences Provider (Initialized in main.dart)
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
      'sharedPreferencesProvider must be overridden in main.dart');
});

// 2. Theme Mode Notifier
class ThemeModeNotifier extends Notifier<ThemeMode> {
  static const _themeKey = 'theme_mode';

  @override
  ThemeMode build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final isDark = prefs.getBool(_themeKey);
    if (isDark == null) return ThemeMode.light; // Default to light mode
    return isDark ? ThemeMode.dark : ThemeMode.light;
  }

  void toggleTheme() {
    final prefs = ref.read(sharedPreferencesProvider);
    if (state == ThemeMode.light) {
      state = ThemeMode.dark;
      prefs.setBool(_themeKey, true);
    } else {
      state = ThemeMode.light;
      prefs.setBool(_themeKey, false);
    }
  }
}

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(() {
  return ThemeModeNotifier();
});

// 3. Default Company ID Notifier
class DefaultCompanyNotifier extends Notifier<int?> {
  static const _companyKey = 'default_company_id';

  @override
  int? build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    // Returns null if the user has never set a default company
    return prefs.getInt(_companyKey);
  }

  void setDefaultCompany(int companyId) {
    state = companyId;
    ref.read(sharedPreferencesProvider).setInt(_companyKey, companyId);
  }
}

final defaultCompanyIdProvider =
    NotifierProvider<DefaultCompanyNotifier, int?>(() {
  return DefaultCompanyNotifier();
});
