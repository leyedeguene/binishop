/// BINISHOP — Admin Homepage
/// Gestion des blocs dynamiques de la page d'accueil (module custom Medusa).
/// Aucun contenu codé en dur : tout provient de la base (règles #6, #34).
library features.admin.presentation.screens.admin_homepage_screen;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/service_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/states/error_state.dart';
import '../../../../shared/states/loading_state.dart';
import '../../../../shared/widgets/app_badge.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../admin_providers.dart';
import '../shared/admin_widgets.dart';

class AdminHomepageScreen extends ConsumerStatefulWidget {
  const AdminHomepageScreen({super.key});

  @override
  ConsumerState<AdminHomepageScreen> createState() =>
      _AdminHomepageScreenState();
}

class _AdminHomepageScreenState extends ConsumerState<AdminHomepageScreen> {
  int _refresh = 0;
  void _reload() => setState(() => _refresh++);

  @override
  Widget build(BuildContext context) {
    final blocks = ref.watch(adminHomepageProvider(_refresh));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AdminPageHeader(
          title: 'Homepage',
          subtitle: 'Construisez la page d\'accueil par blocs dynamiques.',
          actions: [
            ElevatedButton.icon(
              onPressed: () => _showCreateDialog(),
              icon: const Icon(Icons.add, size: 20),
              label: const Text('Ajouter un bloc'),
            ),
          ],
        ),
        AppSpacing.gapLg,
        blocks.when(
          loading: () => const LoadingState(useSkeleton: true),
          error: (e, _) => ErrorState(
            message: e.toString().replaceAll('StateError: ', ''),
            onRetry: _reload,
          ),
          data: (data) {
            final list = (data['homepage_blocks'] as List?) ?? [];
            if (list.isEmpty) {
              return const AdminEmpty(
                icon: Icons.home_outlined,
                message: 'Aucun bloc homepage.\nAjoutez un bloc pour construire l\'accueil.',
              );
            }
            return Column(children: [for (final b in list) _tile(b)]);
          },
        ),
      ],
    );
  }

  Widget _tile(dynamic b) {
    final map = (b as Map).cast<String, dynamic>();
    final type = map['type']?.toString() ?? 'bloc';
    final title = map['title']?.toString() ?? '';
    final active = map['is_active'] == true;
    final rank = map['rank'] ?? 0;
    final id = map['id']?.toString() ?? '';
    return Row(
      children: [
        Expanded(
          child: AdminListTile(
            title: title.isEmpty ? _typeLabel(type) : title,
            subtitle: '${_typeLabel(type)} • rang $rank',
            leading: Container(
              width: 44, height: 44,
              decoration: const BoxDecoration(
                color: AppColors.surfaceDark,
                borderRadius: AppRadius.radiusSm,
              ),
              child: Icon(_typeIcon(type), color: AppColors.secondary),
            ),
            trailing: AppBadge(
              label: active ? 'Actif' : 'Inactif',
              type: active ? BadgeType.success : BadgeType.info,
            ),
          ),
        ),
        IconButton(
          tooltip: active ? 'Désactiver' : 'Activer',
          icon: Icon(active ? Icons.visibility_outlined : Icons.visibility_off_outlined,
              color: AppColors.textSecondary),
          onPressed: () => _toggleActive(id, active),
        ),
        IconButton(
          tooltip: 'Supprimer',
          icon: const Icon(Icons.delete_outline, color: AppColors.error),
          onPressed: () => _deleteBlock(id),
        ),
      ],
    );
  }

  String _typeLabel(String type) {
    return switch (type) {
      'hero' => 'Hero',
      'banner' => 'Bannière',
      'collection' => 'Collection',
      'category' => 'Catégorie',
      'featured_products' => 'Produits sélectionnés',
      'new_arrivals' => 'Nouveautés',
      'bestsellers' => 'Bestsellers',
      'promotion' => 'Promotion',
      'text_block' => 'Bloc de texte',
      'image_block' => 'Image',
      'cta_block' => 'Appel à l\'action',
      _ => type,
    };
  }

  IconData _typeIcon(String type) {
    return switch (type) {
      'hero' => Icons.landscape_outlined,
      'banner' => Icons.image_outlined,
      'collection' => Icons.collections_bookmark_outlined,
      'category' => Icons.category_outlined,
      'featured_products' => Icons.star_outline,
      'new_arrivals' => Icons.fiber_new_outlined,
      'bestsellers' => Icons.trending_up,
      'promotion' => Icons.local_offer_outlined,
      'text_block' => Icons.notes_outlined,
      'image_block' => Icons.photo_outlined,
      'cta_block' => Icons.touch_app_outlined,
      _ => Icons.dashboard_outlined,
    };
  }

  Future<void> _toggleActive(String id, bool active) async {
    await ref
        .read(adminServiceProvider)
        .updateHomepageBlock(id, {'is_active': !active});
    if (mounted) _reload();
  }

  Future<void> _deleteBlock(String id) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Supprimer ce bloc ?'),
        content: const Text('Cette action est irréversible.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await ref.read(adminServiceProvider).deleteHomepageBlock(id);
      if (mounted) _reload();
    }
  }

  void _showCreateDialog() {
    showDialog<bool>(
      context: context,
      builder: (_) => const _AddBlockDialog(),
    ).then((created) {
      if (created == true) _reload();
    });
  }
}

class _AddBlockDialog extends ConsumerStatefulWidget {
  const _AddBlockDialog();

  @override
  ConsumerState<_AddBlockDialog> createState() => _AddBlockDialogState();
}

class _AddBlockDialogState extends ConsumerState<_AddBlockDialog> {
  static const _types = [
    'hero', 'banner', 'collection', 'category', 'featured_products',
    'new_arrivals', 'bestsellers', 'promotion', 'text_block', 'image_block', 'cta_block',
  ];
  final _title = TextEditingController();
  String _type = 'hero';
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Ajouter un bloc homepage'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<String>(
            initialValue: _type,
            decoration: const InputDecoration(labelText: 'Type de bloc'),
            items: [
              for (final t in _types) DropdownMenuItem(value: t, child: Text(t)),
            ],
            onChanged: (v) => _type = v ?? 'hero',
          ),
          const SizedBox(height: 12),
          AppTextField(label: 'Titre', controller: _title),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: const TextStyle(color: AppColors.error)),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context, false),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: _saving ? null : _save,
          child: _saving
              ? const SizedBox(
                  width: 18, height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Créer'),
        ),
      ],
    );
  }

  Future<void> _save() async {
    setState(() { _saving = true; _error = null; });
    final result = await ref.read(adminServiceProvider).createHomepageBlock({
      'type': _type,
      'title': _title.text.trim().isEmpty ? null : _title.text.trim(),
    });
    if (!mounted) return;
    setState(() => _saving = false);
    if (result.data != null) {
      Navigator.pop(context, true);
    } else {
      setState(() => _error = result.error ?? 'Erreur lors de la création.');
    }
  }
}