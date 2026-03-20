import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_provider.dart';
import 'menu_screen.dart'; // We will navigate here after login

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncUsers = ref.watch(allUsersProvider);

    return Scaffold(
      backgroundColor: Colors.blueGrey[900], // Dark background for Login
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Select User",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 40),

              // THE USER GRID
              Expanded(
                child: asyncUsers.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Center(
                    child: Text("Error loading users: $err",
                        style: const TextStyle(color: Colors.red)),
                  ),
                  data: (users) {
                    if (users.isEmpty) {
                      return const Center(
                          child: Text("No enabled users found.",
                              style: TextStyle(color: Colors.white)));
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
                      itemBuilder: (context, index) {
                        final user = users[index];
                        return _buildUserCard(context, ref, user);
                      },
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
        // 1. Set the global Current User
        ref.read(currentUserProvider.notifier).state = user;

        // 2. Navigate to POS Menu
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MenuScreen()),
        );
      },
      child: Card(
        elevation: 4,
        color: Colors.blueGrey[800],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.blueGrey[600]!, width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // User Icon (You can check accessLevel here to change icon color)
            CircleAvatar(
              radius: 30,
              backgroundColor:
                  user.accessLevel >= 9 ? Colors.orange : Colors.blue,
              child: const Icon(Icons.person, size: 35, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Text(
              user.displayName,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              user.accessLevel >= 9 ? "Admin" : "Staff",
              style: TextStyle(color: Colors.grey[400], fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
