import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:pos_app/app_settings/app_settings_model.dart';
import 'package:pos_app/app_settings/app_settings_provider.dart';
import 'package:pos_app/auth/auth_provider.dart';
import 'package:pos_app/auth/auth_storage.dart';
import 'package:pos_app/auth/master_login_screen.dart';
import 'package:pos_app/auth/user_model.dart';
import 'package:pos_app/company/company_provider.dart';
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
        await ref.read(authServiceProvider).loadFallbackCompany(fallbackId);
      }
    });
  }

  void _handleUnlinkDevice() {
    final cs = Theme.of(context).colorScheme;
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
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: cs.error,
              foregroundColor: cs.onError,
            ),
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

  Widget _buildUserCard(BuildContext context, User user, int index) {
    final cs = Theme.of(context).colorScheme;
    final isAdmin = user.accessLevel == 0;
    final avatarBg = isAdmin ? cs.primaryContainer : cs.secondaryContainer;
    final avatarFg = isAdmin ? cs.onPrimaryContainer : cs.onSecondaryContainer;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => _showPinPad(user),
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: avatarBg,
              child: Icon(
                PhosphorIcons.user(PhosphorIconsStyle.fill),
                size: 32,
                color: avatarFg,
              ),
            ),
            const Gap(14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                user.displayName,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface,
                ),
              ),
            ),
            const Gap(4),
            Text(
              isAdmin ? "Admin" : "Cashier",
              style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12),
            ),
          ],
        ),
      ),
    ).animate(delay: (index * 60).ms).fadeIn(duration: 280.ms).slideY(begin: 0.12);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final selectedCo = ref.watch(selectedCompanyProvider);

    if (selectedCo == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final asyncUsers = ref.watch(allUsersProvider);

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: GestureDetector(
          onLongPress: _handleUnlinkDevice,
          child: const Text("POS Login"),
        ),
        actions: [
          IconButton(
            icon: Icon(
              ref.watch(themeModeProvider) == ThemeMode.dark
                  ? PhosphorIcons.sun()
                  : PhosphorIcons.moon(),
            ),
            onPressed: () => ref.read(themeModeProvider.notifier).toggleTheme(),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.business, size: 18),
                const SizedBox(width: 6),
                Text(selectedCo.name),
              ],
            ),
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
              Text(
                "Select User",
                style: GoogleFonts.inter(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: cs.onSurface,
                ),
              ).animate().fadeIn(duration: 300.ms),
              const Gap(40),
              Expanded(
                child: asyncUsers.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (err, _) => Center(
                    child: Text(
                      "Error loading users: $err",
                      style: TextStyle(color: cs.error),
                    ),
                  ),
                  data: (users) {
                    if (users.isEmpty) {
                      return Center(
                        child: Text(
                          "No enabled users found.",
                          style: TextStyle(color: cs.onSurfaceVariant),
                        ),
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
                          _buildUserCard(context, users[index], index),
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
}

// ---------------------------------------------------------------------------
// PIN Pad Bottom Sheet
// ---------------------------------------------------------------------------

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
      if (_pin.length == 4) _processCompletePin();
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
      await ref.read(authServiceProvider).setDevicePin(
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
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: Theme.of(context).colorScheme.error,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isAdmin = widget.user.accessLevel == 0;
    final avatarBg = isAdmin ? cs.primaryContainer : cs.secondaryContainer;
    final avatarFg = isAdmin ? cs.onPrimaryContainer : cs.onSecondaryContainer;
    final title = !widget.user.hasPinForThisDevice
        ? (_isConfirming ? "Confirm New PIN" : "Create 4-Digit PIN")
        : "Enter PIN";

    return Container(
      height: 560,
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: cs.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          CircleAvatar(
            radius: 32,
            backgroundColor: avatarBg,
            child: Icon(
              PhosphorIcons.user(PhosphorIconsStyle.fill),
              size: 32,
              color: avatarFg,
            ),
          ),
          const Gap(12),
          Text(
            widget.user.displayName,
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: cs.onSurface,
            ),
          ),
          const Gap(4),
          Text(title, style: TextStyle(color: cs.primary, fontSize: 15)),
          const Gap(28),

          // PIN dots
          if (_isLoading)
            const CircularProgressIndicator()
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: index < _pin.length
                        ? cs.primary
                        : cs.surfaceContainerHighest,
                  ),
                );
              }),
            ),

          const Gap(32),

          // Number grid
          SizedBox(
            width: 290,
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 1.5,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: 12,
              itemBuilder: (context, index) {
                // Empty slot below "7 8 9"
                if (index == 9) return const SizedBox.shrink();

                // Backspace
                if (index == 11) {
                  return FilledButton.tonal(
                    onPressed: _onBackspace,
                    style: FilledButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: EdgeInsets.zero,
                    ),
                    child: Icon(PhosphorIcons.backspace(), size: 24),
                  );
                }

                final number = index == 10 ? "0" : "${index + 1}";
                return FilledButton.tonal(
                  onPressed: () => _onKeyPress(number),
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: EdgeInsets.zero,
                  ),
                  child: Text(
                    number,
                    style: GoogleFonts.inter(
                      fontSize: 26,
                      fontWeight: FontWeight.w600,
                      color: cs.onSecondaryContainer,
                    ),
                  ),
                );
              },
            ),
          ),
          const Gap(16),
        ],
      ),
    ).animate().slideY(begin: 0.08, duration: 300.ms, curve: Curves.easeOut);
  }
}
