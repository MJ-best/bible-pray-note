import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/supabase_bootstrap.dart';
import '../../auth/application/auth_controller.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authController = ref.watch(authControllerProvider);
    final user = authController.state.user;

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Environment',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                Text(
                  SupabaseBootstrap.isConfigured
                      ? 'Supabase environment variables are present.'
                      : 'Supabase environment variables are missing. The app is running in placeholder mode.',
                ),
                if (SupabaseBootstrap.errorMessage != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    SupabaseBootstrap.errorMessage!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Session', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                Text(
                  user == null ? 'Signed out' : '${user.name} • ${user.email}',
                ),
                const SizedBox(height: 16),
                FilledButton.tonalIcon(
                  onPressed: user == null ? null : authController.signOut,
                  icon: const Icon(Icons.logout),
                  label: const Text('Sign out'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
