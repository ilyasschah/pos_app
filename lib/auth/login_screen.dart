import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_app/auth/auth_provider.dart';
import 'package:pos_app/auth/auth_storage.dart';
import 'package:pos_app/auth/user_model.dart';
import 'package:pos_app/auth/master_login_screen.dart';
import 'package:pos_app/company/company_provider.dart';
import 'package:pos_app/app_settings/app_settings_model.dart';
import 'package:pos_app/app_settings/app_settings_provider.dart';
import 'package:pos_app/navigation/main_layout.dart';
import 'package:pos_app/settings/settings_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final selectedCo = ref.read(selectedCompanyProvider);
      final defaultCoId = ref.read(defaultCompanyIdProvider);

      if (selectedCo == null) {
        final fallbackId = defaultCoId ?? 2;
        // ✨ Cleanly delegated to the Auth Provider!
        await ref.read(authServiceProvider).loadFallbackCompany(fallbackId);
      }
    });
  }

  void _handleUnlinkDevice() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Developer Mode"),
        content: const Text("Are you sure you want to unlink this device?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await ref.read(authStorageProvider).unlinkDevice();
              if (mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const MasterLoginScreen()),
                  (route) => false,
                );
              }
            },
            child: const Text("Unlink Device"),
          ),
        ],
      ),
    );
  }

  Future<void> _showPinPad(User user) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _PinPadModal(user: user),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedCo = ref.watch(selectedCompanyProvider);
    if (selectedCo == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final asyncUsers = ref.watch(allUsersProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: GestureDetector(
          onLongPress: _handleUnlinkDevice,
          child: const Text("POS Login"),
        ),
        actions: [
          IconButton(
            icon: Icon(
              ref.watch(themeModeProvider) == ThemeMode.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed: () {
              ref.read(themeModeProvider.notifier).toggleTheme();
            },
          ),
          TextButton.icon(
            icon: const Icon(Icons.business),
            label: Text(selectedCo.name),
            onPressed: () => Navigator.pushNamed(context, '/select-company'),
          ),
        ],
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Select User",
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 40),
              Expanded(
                child: asyncUsers.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Center(
                    child: Text(
                      "Error loading users: $err",
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                  data: (users) {
                    if (users.isEmpty) {
                      return const Center(
                        child: Text("No enabled users found."),
                      );
                    }
                    return GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 200,
                            childAspectRatio: 1.0,
                            crossAxisSpacing: 20,
                            mainAxisSpacing: 20,
                          ),
                      itemCount: users.length,
                      itemBuilder: (context, index) =>
                          _buildUserCard(context, users[index]),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserCard(BuildContext context, User user) {
    return InkWell(
      onTap: () => _showPinPad(user),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: user.accessLevel == 0
                  ? Colors.orange
                  : Colors.blue,
              child: const Icon(Icons.person, size: 35, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Text(
              user.displayName,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              user.accessLevel == 0 ? "Admin" : "Cashier",
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _PinPadModal extends ConsumerStatefulWidget {
  final User user;
  const _PinPadModal({required this.user});

  @override
  ConsumerState<_PinPadModal> createState() => _PinPadModalState();
}

class _PinPadModalState extends ConsumerState<_PinPadModal> {
  String _pin = "";
  String _confirmPin = "";
  bool _isConfirming = false;
  bool _isLoading = false;

  void _onKeyPress(String value) {
    if (_pin.length < 4) {
      setState(() => _pin += value);
      if (_pin.length == 4) {
        _processCompletePin();
      }
    }
  }

  void _onBackspace() {
    if (_pin.isNotEmpty) {
      setState(() => _pin = _pin.substring(0, _pin.length - 1));
    }
  }

  Future<void> _processCompletePin() async {
    if (!widget.user.hasPinForThisDevice) {
      if (!_isConfirming) {
        setState(() {
          _confirmPin = _pin;
          _pin = "";
          _isConfirming = true;
        });
      } else {
        if (_pin == _confirmPin) {
          await _setNewPin();
        } else {
          _showError("PINs do not match. Try again.");
          setState(() {
            _pin = "";
            _confirmPin = "";
            _isConfirming = false;
          });
        }
      }
    } else {
      _verifyPin();
    }
  }

  void _verifyPin() {
    final bytes = utf8.encode(_pin);
    final digest = sha256.convert(bytes);
    final hashedAttempt = base64Encode(digest.bytes);

    if (hashedAttempt == widget.user.hashedPin) {
      _loginUser();
    } else {
      _showError("Incorrect PIN.");
      setState(() => _pin = "");
    }
  }

  Future<void> _setNewPin() async {
    setState(() => _isLoading = true);
    try {
      // ✨ Cleanly delegated to the Auth Provider!
      await ref
          .read(authServiceProvider)
          .setDevicePin(
            userId: widget.user.id,
            companyId: widget.user.companyId,
            pin: _pin,
          );

      _loginUser();
    } catch (e) {
      _showError("Failed to save PIN.");
      setState(() {
        _pin = "";
        _confirmPin = "";
        _isConfirming = false;
        _isLoading = false;
      });
    }
  }

  void _loginUser() {
    ref.read(currentUserProvider.notifier).setUser(widget.user);
    final settings = ref.read(appSettingsProvider);
    final bookingEnabled =
        settings[SettingKeys.featureBookingEnabled]?.toLowerCase() == 'true';
    final floorPlanEnabled =
        settings[SettingKeys.featureFloorPlanEnabled]?.toLowerCase() == 'true';

    int startingIndex = 0;
    if (bookingEnabled) {
      startingIndex = 2;
    } else if (floorPlanEnabled) {
      startingIndex = 3;
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => MainLayout(initialIndex: startingIndex),
      ),
      (route) => false,
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = !widget.user.hasPinForThisDevice
        ? (_isConfirming ? "Confirm New PIN" : "Create 4-Digit PIN")
        : "Enter PIN";

    return Container(
      height: 550,
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: widget.user.accessLevel == 0
                ? Colors.orange
                : Colors.blue,
            child: const Icon(Icons.person, size: 35, color: Colors.white),
          ),
          const SizedBox(height: 12),
          Text(
            widget.user.displayName,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(color: theme.colorScheme.primary, fontSize: 16),
          ),
          const SizedBox(height: 24),

          if (_isLoading)
            const CircularProgressIndicator()
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: index < _pin.length
                        ? theme.colorScheme.primary
                        : theme.colorScheme.surfaceContainerHighest,
                  ),
                );
              }),
            ),

          const SizedBox(height: 32),

          SizedBox(
            width: 280,
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 1.2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: 12,
              itemBuilder: (context, index) {
                if (index == 9) return const SizedBox.shrink();
                if (index == 11) {
                  return IconButton(
                    onPressed: _onBackspace,
                    icon: const Icon(Icons.backspace, size: 28),
                  );
                }
                final number = index == 10 ? "0" : "${index + 1}";
                return InkWell(
                  onTap: () => _onKeyPress(number),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      number,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
