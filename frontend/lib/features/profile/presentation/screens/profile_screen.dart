import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../auth/presentation/auth_notifier.dart';

/// Écran profil client — données réelles de la session Medusa.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);

    if (authState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!authState.isAuthenticated || authState.email == null) {
      return const _NotAuthenticated();
    }

    final email = authState.email!;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  child: Text(
                    email.isNotEmpty ? email[0].toUpperCase() : '?',
                    style: AppTypography.headlineSmall
                        .copyWith(color: AppColors.primary),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(email,
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Client BINISHOP',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        _MenuSection(title: 'Mon compte', items: [
          _MenuItem(
            icon: Icons.receipt_long_outlined,
            label: 'Mes commandes',
            onTap: () => context.push('/orders'),
          ),
          _MenuItem(
            icon: Icons.favorite_border,
            label: 'Mes favoris',
            onTap: () => context.push('/wishlist'),
          ),
          _MenuItem(
            icon: Icons.location_on_outlined,
            label: 'Mes adresses',
            onTap: () => _showInfo(
                context, 'Gestion des adresses — bientôt disponible'),
          ),
        ]),
        const SizedBox(height: AppSpacing.md),
        _MenuSection(title: 'Préférences', items: [
          _MenuItem(
            icon: Icons.settings_outlined,
            label: 'Paramètres',
            onTap: () =>
                _showInfo(context, 'Paramètres — bientôt disponible'),
          ),
        ]),
        const SizedBox(height: AppSpacing.xl),
        OutlinedButton.icon(
          onPressed: authState.isLoading
              ? null
              : () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Déconnexion'),
                      content:
                          const Text('Voulez-vous vraiment vous déconnecter ?'),
                      actions: [
                        TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('Annuler')),
                        TextButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: const Text('Déconnexion')),
                      ],
                    ),
                  );
                  if (confirmed == true && context.mounted) {
                    await ref.read(authNotifierProvider.notifier).logout();
                    if (context.mounted) context.go('/');
                  }
                },
          icon: const Icon(Icons.logout),
          label: const Text('Se déconnecter'),
          style: OutlinedButton.styleFrom(foregroundColor: AppColors.error),
        ),
      ],
    );
  }

  void _showInfo(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}

class _NotAuthenticated extends StatelessWidget {
  const _NotAuthenticated();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.account_circle_outlined,
                size: 80, color: AppColors.textTertiary),
            const SizedBox(height: 24),
            Text('Non connecté',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
              'Connectez-vous pour accéder à votre profil.',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => context.go('/auth/login'),
              icon: const Icon(Icons.login),
              label: const Text('Se connecter'),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuSection extends StatelessWidget {
  final String title;
  final List<_MenuItem> items;

  const _MenuSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context)
              .textTheme
              .titleSmall
              ?.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: AppSpacing.sm),
        Card(
          child: Column(
            children: [
              for (int i = 0; i < items.length; i++) ...[
                if (i > 0) const Divider(height: 1),
                items[i],
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _MenuItem({required this.icon, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(label),
      trailing: const Icon(Icons.chevron_right, size: 20),
      onTap: onTap,
    );
  }
}