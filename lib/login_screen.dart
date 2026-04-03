import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_provider.dart';
import 'company_provider.dart';
import 'company_model.dart';
import 'settings_provider.dart';
import 'menu_screen.dart';
import 'package:pos_app/floor_plan/floor_plan_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final selectedCo = ref.read(selectedCompanyProvider);
      final defaultCoId = ref.read(defaultCompanyIdProvider);

      if (selectedCo == null) {
        final fallbackId = defaultCoId ??
            2; // Fallback to 2 if no default set hardcoded for debuging
        ref.read(selectedCompanyProvider.notifier).state = Company(
            id: fallbackId, name: "Default Branch", countrySubentity: "DEF");
      }
    });
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
        title: const Text("POS Login"),
        actions: [
          // Quick Settings Toggle on Login Screen
          IconButton(
            icon: Icon(ref.watch(themeModeProvider) == ThemeMode.dark
                ? Icons.light_mode
                : Icons.dark_mode),
            onPressed: () {
              // Simply call our new built-in function to toggle and save!
              ref.read(themeModeProvider.notifier).toggleTheme();
            },
          ),
          TextButton.icon(
            icon: const Icon(Icons.business),
            label: Text(selectedCo.name),
            onPressed: () => Navigator.pushNamed(context, '/select-company'),
          )
        ],
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Select User",
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
              const SizedBox(height: 40),
              Expanded(
                child: asyncUsers.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Center(
                      child: Text("Error loading users: $err",
                          style: const TextStyle(color: Colors.red))),
                  data: (users) {
                    if (users.isEmpty)
                      return const Center(
                          child: Text("No enabled users found."));
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
                          _buildUserCard(context, ref, users[index]),
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

  Widget _buildUserCard(BuildContext context, WidgetRef ref, var user) {
    return InkWell(
      onTap: () {
        ref.read(currentUserProvider.notifier).state = user;
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const FloorPlanScreen()));
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor:
                  user.accessLevel >= 9 ? Colors.orange : Colors.blue,
              child: const Icon(Icons.person, size: 35, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Text(user.displayName,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(user.accessLevel >= 9 ? "Admin" : "Staff",
                style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
