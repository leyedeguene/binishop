/// BINISHOP — Admin Categories
/// Gestion des catégories réelles depuis /admin/categories (Medusa).
library features.admin.presentation.screens.admin_categories_screen;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/service_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/states/empty_state.dart';
import '../../../../shared/states/error_state.dart';
import '../../../../shared/states/loading_state.dart';
import '../../../../shared/widgets/app_badge.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../admin_providers.dart';

class AdminCategoriesScreen extends ConsumerStatefulWidget {
  const AdminCategoriesScreen({super.key});

  @override
  ConsumerState<AdminCategoriesScreen> createState() =>
      _AdminCategoriesScreenState();
}

class _AdminCategoriesScreenState extends ConsumerState<AdminCategoriesScreen> {
  int _refresh = 0;

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(adminCategoriesProvider(_refresh));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _header(),
        AppSpacing.gapLg,
        categories.when(
          loading: () => const LoadingState(useSkeleton: true),
          error: (e, _) => ErrorState(
            message: e.toString().replaceAll('StateError: ', ''),
            onRetry: () => setState(() => _refresh++),
          ),
          data: (data) => _list(context, data),
        ),
      ],
    );
  }

  Widget _header() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Catégories',
                  style: AppTypography.headlineLarge.copyWith(color: AppColors.textPrimary)),
              AppSpacing.gapSm,
              Text('Organisez votre catalogue par catégories (source Medusa).',
                  style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary)),
            ],
          ),
        ),
        ElevatedButton.icon(
          onPressed: () => _showCreateDialog(),
          icon: const Icon(Icons.add, size: 20),
          label: const Text('Ajouter une catégorie'),
        ),
      ],
    );
  }

  Widget _list(BuildContext context, Map<String, dynamic> data) {
    final list = (data['product_categories'] as List?) ?? [];
    if (list.isEmpty) {
      return const EmptyState(
        icon: Icons.category_outlined,
        title: 'Aucune catégorie.',
        message: 'Créez votre première catégorie pour organiser le catalogue.',
      );
    }
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: list.length,
      separatorBuilder: (_, __) => AppSpacing.gapMd,
      itemBuilder: (context, i) => _tile(context, list[i]),
    );
  }

  Widget _tile(BuildContext context, dynamic c) {
    final map = (c as Map).cast<String, dynamic>();
    final name = map['name']?.toString() ?? 'Catégorie';
    final handle = map['handle']?.toString() ?? '';
    final isActive = map['is_active'] == true;
    final productCount = (map['products'] as List?)?.length ?? 0;
    return Container(
      padding: AppSpacing.listItemPadding,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.radiusMd,
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: const BoxDecoration(
              color: AppColors.surfaceDark,
              borderRadius: AppRadius.radiusSm,
            ),
            child: const Icon(Icons.category_outlined, color: AppColors.textSecondary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: AppTypography.titleMedium.copyWith(color: AppColors.textPrimary)),
                AppSpacing.gapXs,
                Text('$productCount produit(s) • /$handle',
                    style: AppTypography.bodySmall.copyWith(color: AppColors.textTertiary)),
              ],
            ),
          ),
          AppBadge(
            label: isActive ? 'Active' : 'Inactive',
            type: isActive ? BadgeType.success : BadgeType.info,
          ),
        ],
      ),
    );
  }

  void _showCreateDialog() {
    showDialog<bool>(
      context: context,
      builder: (_) => const _AddCategoryDialog(),
    ).then((created) {
      if (created == true) setState(() => _refresh++);
    });
  }
}
class _AddCategoryDialog extends ConsumerStatefulWidget {
  const _AddCategoryDialog();

  @override
  ConsumerState<_AddCategoryDialog> createState() =>
      _AddCategoryDialogState();
}

class _AddCategoryDialogState extends ConsumerState<_AddCategoryDialog> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _handle = TextEditingController();
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _handle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nouvelle catégorie'),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppTextField(
                label: 'Nom *',
                controller: _name,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Le nom est requis' : null,
              ),
              AppSpacing.gapMd,
              AppTextField(
                label: 'Slug (handle)',
                controller: _handle,
                hint: 'robe-ete',
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!, style: const TextStyle(color: AppColors.error)),
              ],
            ],
          ),
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
    final handle = _handle.text.trim().isEmpty
        ? _slugify(_name.text.trim())
        : _handle.text.trim();
    final result = await ref.read(adminServiceProvider).createCategory({
      'name': _name.text.trim(),
      'handle': handle,
      'is_active': true,
    });
    if (!mounted) return;
    setState(() => _saving = false);
    if (result.data != null) {
      Navigator.pop(context, true);
    } else {
      setState(() => _error = result.error ?? 'Erreur lors de la création.');
    }
  }

  String _slugify(String text) {
    final lower = text.toLowerCase().trim();
    return lower
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
  }
}