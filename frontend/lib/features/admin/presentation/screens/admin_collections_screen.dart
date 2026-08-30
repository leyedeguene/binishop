/// BINISHOP — Admin Collections
/// Collections réelles depuis /admin/collections.
library features.admin.presentation.screens.admin_collections_screen;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/service_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/states/error_state.dart';
import '../../../../shared/states/loading_state.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../admin_providers.dart';
import '../shared/admin_widgets.dart';

class AdminCollectionsScreen extends ConsumerStatefulWidget {
  const AdminCollectionsScreen({super.key});

  @override
  ConsumerState<AdminCollectionsScreen> createState() =>
      _AdminCollectionsScreenState();
}

class _AdminCollectionsScreenState extends ConsumerState<AdminCollectionsScreen> {
  int _refresh = 0;

  @override
  Widget build(BuildContext context) {
    final collections = ref.watch(adminCollectionsProvider(_refresh));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AdminPageHeader(
          title: 'Collections',
          subtitle: 'Regroupez vos produits en collections (source Medusa).',
          actions: [
            ElevatedButton.icon(
              onPressed: () => _showCreateDialog(),
              icon: const Icon(Icons.add, size: 20),
              label: const Text('Ajouter une collection'),
            ),
          ],
        ),
        AppSpacing.gapLg,
        collections.when(
          loading: () => const LoadingState(useSkeleton: true),
          error: (e, _) => ErrorState(
            message: e.toString().replaceAll('StateError: ', ''),
            onRetry: () => setState(() => _refresh++),
          ),
          data: (data) {
            final list = (data['collections'] as List?) ?? [];
            if (list.isEmpty) {
              return const AdminEmpty(
                icon: Icons.collections_bookmark_outlined,
                message: 'Aucune collection pour le moment.',
              );
            }
            return Column(
              children: [
                for (final c in list) _tile(c),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _tile(dynamic c) {
    final map = (c as Map).cast<String, dynamic>();
    final title = map['title']?.toString() ?? 'Collection';
    final handle = map['handle']?.toString() ?? '';
    final count = (map['products'] as List?)?.length ?? 0;
    return AdminListTile(
      title: title,
      subtitle: '$count produit(s) • /$handle',
      leading: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          color: AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.collections_bookmark_outlined, color: AppColors.textSecondary),
      ),
    );
  }

  void _showCreateDialog() {
    showDialog<bool>(
      context: context,
      builder: (_) => const _AddCollectionDialog(),
    ).then((created) {
      if (created == true) setState(() => _refresh++);
    });
  }
}

class _AddCollectionDialog extends ConsumerStatefulWidget {
  const _AddCollectionDialog();

  @override
  ConsumerState<_AddCollectionDialog> createState() =>
      _AddCollectionDialogState();
}

class _AddCollectionDialogState extends ConsumerState<_AddCollectionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
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
      title: const Text('Nouvelle collection'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppTextField(
              label: 'Titre *',
              controller: _title,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Le titre est requis' : null,
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: const TextStyle(color: AppColors.error)),
            ],
          ],
        ),
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
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() { _saving = true; _error = null; });
    final result = await ref
        .read(adminServiceProvider)
        .createCollection({'title': _title.text.trim()});
    if (!mounted) return;
    setState(() => _saving = false);
    if (result.data != null) {
      Navigator.pop(context, true);
    } else {
      setState(() => _error = result.error ?? 'Erreur lors de la création.');
    }
  }
}