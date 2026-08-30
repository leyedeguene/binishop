/// BINISHOP — Admin Products List
/// Liste des produits réels depuis /admin/products (Medusa).
/// États Loading / Empty / Error / Success (règle #52).
library features.admin.presentation.screens.admin_products_screen;

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

class AdminProductsScreen extends ConsumerStatefulWidget {
  const AdminProductsScreen({super.key});

  @override
  ConsumerState<AdminProductsScreen> createState() => _AdminProductsScreenState();
}

class _AdminProductsScreenState extends ConsumerState<AdminProductsScreen> {
  int _refresh = 0;

  @override
  Widget build(BuildContext context) {
    final products = ref.watch(adminProductsProvider(_refresh));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _header(),
        AppSpacing.gapLg,
        products.when(
          loading: () => const LoadingState(useSkeleton: true),
          error: (e, _) => ErrorState(
            message: e.toString().replaceAll('StateError: ', ''),
            onRetry: () => setState(() => _refresh++),
          ),
          data: (data) => _product(context, data),
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
              Text('Produits',
                  style: AppTypography.headlineLarge.copyWith(color: AppColors.textPrimary)),
              AppSpacing.gapSm,
              Text('Gérez votre catalogue depuis la source de vérité Medusa.',
                  style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary)),
            ],
          ),
        ),
        ElevatedButton.icon(
          onPressed: () => _showProductDialog(),
          icon: const Icon(Icons.add, size: 20),
          label: const Text('Ajouter un produit'),
        ),
      ],
    );
  }

  Widget _product(BuildContext context, Map<String, dynamic> data) {
    final list = (data['products'] as List?) ?? [];
    if (list.isEmpty) {
      return const EmptyState(
        title: 'Aucun produit disponible.',
        message: 'Commencez par ajouter votre premier produit.',
      );
    }
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: list.length,
      separatorBuilder: (_, __) => AppSpacing.gapMd,
      itemBuilder: (context, i) => _productTile(context, list[i]),
    );
  }

  Widget _productTile(BuildContext context, dynamic p) {
    final map = (p as Map).cast<String, dynamic>();
    final title = map['title']?.toString() ?? 'Produit';
    final status = map['status']?.toString() ?? 'draft';
    final thumbnail = map['thumbnail']?.toString();
    final variants = (map['variants'] as List?) ?? [];
    return Container(
      padding: AppSpacing.listItemPadding,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.radiusMd,
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: AppRadius.radiusSm,
            child: thumbnail != null && thumbnail.isNotEmpty
                ? Image.network(thumbnail, width: 48, height: 48, fit: BoxFit.cover)
                : Container(
                    width: 48, height: 48,
                    color: AppColors.surfaceDark,
                    child: const Icon(Icons.image_outlined, color: AppColors.textTertiary),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: AppTypography.titleMedium.copyWith(color: AppColors.textPrimary)),
                AppSpacing.gapXs,
                Text('${variants.length} variante(s)',
                    style: AppTypography.bodySmall.copyWith(color: AppColors.textTertiary)),
              ],
            ),
          ),
          _statusBadge(status),
        ],
      ),
    );
  }

  Widget _statusBadge(String status) {
    final (label, type) = switch (status) {
      'published' => ('Publié', BadgeType.success),
      'draft' => ('Brouillon', BadgeType.warning),
      'archived' => ('Archivé', BadgeType.custom),
      _ => ('Non publié', BadgeType.info),
    };
    return AppBadge(label: label, type: type);
  }

  void _showProductDialog() {
    showDialog<bool>(
      context: context,
      builder: (_) => const _AddProductDialog(),
    ).then((created) {
      if (created == true) setState(() => _refresh++);
    });
  }
}

/// Dialogue de création de produit — envoie réellement les données à Medusa.
class _AddProductDialog extends ConsumerStatefulWidget {
  const _AddProductDialog();

  @override
  ConsumerState<_AddProductDialog> createState() => _AddProductDialogState();
}

class _AddProductDialogState extends ConsumerState<_AddProductDialog> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _subtitle = TextEditingController();
  final _description = TextEditingController();
  String _status = 'draft';
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _title.dispose();
    _subtitle.dispose();
    _description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nouveau produit'),
      content: SizedBox(
        width: 420,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppTextField(
                  label: 'Nom *',
                  controller: _title,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Le nom est requis'
                      : null,
                ),
                AppSpacing.gapMd,
                AppTextField(
                  label: 'Sous-titre',
                  controller: _subtitle,
                ),
                AppSpacing.gapMd,
                AppTextField(
                  label: 'Description',
                  controller: _description,
                  maxLines: 3,
                ),
                AppSpacing.gapMd,
                DropdownButtonFormField<String>(
                  initialValue: _status,
                  decoration: const InputDecoration(labelText: 'Statut'),
                  items: const [
                    DropdownMenuItem(value: 'draft', child: Text('Brouillon')),
                    DropdownMenuItem(value: 'published', child: Text('Publié')),
                  ],
                  onChanged: (v) => _status = v ?? 'draft',
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(_error!, style: const TextStyle(color: AppColors.error)),
                ],
              ],
            ),
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
    final result = await ref.read(adminProductServiceProvider).createProduct({
      'title': _title.text.trim(),
      'subtitle': _subtitle.text.trim().isEmpty ? null : _subtitle.text.trim(),
      'description': _description.text.trim().isEmpty ? null : _description.text.trim(),
      'status': _status,
      'is_giftcard': false,
      'discountable': true,
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

/// Champ de formulaire léger réutilisable (label + validation).
class FormTextField extends StatelessWidget {
  final String label;
  final TextEditingController? controller;
  final int maxLines;
  final String? Function(String?)? validator;
  const FormTextField({
    super.key,
    required this.label,
    this.controller,
    this.maxLines = 1,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      label: label,
      controller: controller,
      maxLines: maxLines,
      validator: validator,
    );
  }
}