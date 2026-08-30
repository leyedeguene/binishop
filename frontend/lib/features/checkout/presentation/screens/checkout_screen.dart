/// BINISHOP — Checkout Screen
library features.checkout.presentation.screens.checkout_screen;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/states/error_state.dart';
import '../../../../shared/states/loading_state.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../checkout_notifier.dart';

class CheckoutScreen extends ConsumerWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final checkout = ref.watch(checkoutNotifierProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: checkout.isLoading && checkout.error == null
          ? const LoadingState()
          : checkout.error != null
          ? ErrorState(
              message: checkout.error!,
              onRetry: () => ref.refresh(checkoutNotifierProvider.notifier),
            )
          : _buildStepBody(context, ref, checkout, theme),
      bottomNavigationBar: checkout.error == null
          ? _buildStepper(checkout.step, theme)
          : null,
    );
  }

  Widget _buildStepBody(
    BuildContext context,
    WidgetRef ref,
    CheckoutState checkout,
    ThemeData theme,
  ) {
    switch (checkout.step) {
      case CheckoutStep.addresses:
        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: _CheckoutAddressForm(
            onSubmit: (addr) async {
              final ok = await ref.read(checkoutNotifierProvider.notifier).submitAddresses(addr);
              if (!ok && context.mounted) {
                final e = ref.read(checkoutNotifierProvider).error;
                if (e != null && e.isNotEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e)));
                }
              }
            },
          ),
        );

      case CheckoutStep.shipping:
        final options = checkout.shippingOptions;
        final selected = checkout.selectedShippingOptionId;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text('Choisissez votre livraison',
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: AppSpacing.lg),
            if (options.isEmpty)
              const Padding(padding: EdgeInsets.only(top: 16),
                child: Text('Aucune option de livraison disponible.', textAlign: TextAlign.center))
            else
              ListView.separated(
                shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                itemCount: options.length,
                separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
                itemBuilder: (_, i) {
                  final opt = options[i];
                  final optId = opt['id'] as String;
                  final name = (opt['name'] ?? 'Livraison').toString();
                  final price = (opt['amount'] as num?)?.toDouble() ?? 0.0;
                  final isSelected = optId == selected;
                  return Material(
                    color: isSelected
                        ? AppColors.primary.withValues(alpha: 0.04)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      onTap: () => ref
                          .read(checkoutNotifierProvider.notifier)
                          .selectShipping(optId),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : Colors.grey.shade300,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Row(children: [
                          Icon(
                            isSelected
                                ? Icons.radio_button_checked
                                : Icons.radio_button_off,
                            color: isSelected
                                ? AppColors.primary
                                : Colors.grey.shade500,
                            size: 22,
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                              child: Text(name, style: theme.textTheme.bodyLarge)),
                          Text(Formatters.currency(price),
                              style: theme.textTheme.bodyMedium
                                  ?.copyWith(color: Colors.grey.shade600)),
                        ]),
                      ),
                    ),
                  );
                },
              ),
          ]),
        );

      case CheckoutStep.payment:
        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text('Paiement', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: AppSpacing.lg),
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(12)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Moyen de paiement', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Text('Test Payment (mode local)', style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey.shade600)),
                const SizedBox(height: 4),
                Text('Aucun paiement réel n\'est effectué.', style: theme.textTheme.bodySmall?.copyWith(color: AppColors.secondary)),
              ]),
            ),
            const SizedBox(height: AppSpacing.lg),
            if (checkout.isLoading) const LoadingState() else AppButton(
              label: 'Finaliser la commande',
              onPressed: () async {
                final ok = await ref.read(checkoutNotifierProvider.notifier).completePayment();
                if (!ok && context.mounted) {
                  final e = ref.read(checkoutNotifierProvider).error;
                  if (e != null && e.isNotEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e)));
                  }
                }
              },
            ),
          ]),
        );

            // --- Confirmation ---
      case CheckoutStep.confirmation:
        final orderId = checkout.orderId;
        return Center(child: Padding(padding: const EdgeInsets.all(AppSpacing.xl), child:
          Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(Icons.check_circle, size: 80, color: AppColors.primary),
            const SizedBox(height: AppSpacing.lg),
            Text('Commande confirmée !', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700)),
            if (orderId != null)
              Padding(padding: const EdgeInsets.only(top: 8), child:
                Text('N° $orderId', style: theme.textTheme.bodyLarge?.copyWith(color: Colors.grey.shade600))),
            const SizedBox(height: AppSpacing.lg),
            AppButton(label: 'Retour à l\'accueil', onPressed: () => context.go('/')),
          ])));
    }
  }

  /// Stepper horizontal
  Widget _buildStepper(CheckoutStep currentStep, ThemeData theme) {
    final steps = [
      ('Adresse', Icons.location_on),
      ('Livraison', Icons.local_shipping),
      ('Paiement', Icons.payment),
      ('Confirmation', Icons.check_circle),
    ];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)],
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children:
        steps.asMap().entries.map((entry) {
          final i = entry.key;
          final (label, icon) = entry.value;
          final isActive = i == currentStep.index;
          return Column(children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: isActive ? AppColors.primary : Colors.grey.shade300,
              child: Icon(icon, color: isActive ? Colors.white : Colors.grey.shade600, size: 20),
            ),
            const SizedBox(height: 4),
            Text(label, style: theme.textTheme.bodySmall?.copyWith(
              color: isActive ? AppColors.primary : Colors.grey.shade500)),
          ]);
        }).toList()),
    );
  }
}

/// Formulaire d'adresse du checkout (Étape 1)
class _CheckoutAddressForm extends StatefulWidget {
  final Future<void> Function(CheckoutAddress) onSubmit;

  const _CheckoutAddressForm({required this.onSubmit});

  @override
  State<_CheckoutAddressForm> createState() => _CheckoutAddressFormState();
}

class _CheckoutAddressFormState extends State<_CheckoutAddressForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _fnCtrl = TextEditingController();
  final _lnCtrl = TextEditingController();
  final _addr1Ctrl = TextEditingController();
  final _addr2Ctrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _zipCtrl = TextEditingController();
  final _countryCtrl = TextEditingController(text: 'FR');
  final _phoneCtrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _fnCtrl.dispose();
    _lnCtrl.dispose();
    _addr1Ctrl.dispose();
    _addr2Ctrl.dispose();
    _cityCtrl.dispose();
    _zipCtrl.dispose();
    _countryCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final address = CheckoutAddress(
      email: _emailCtrl.text.trim(),
      firstName: _fnCtrl.text.trim(),
      lastName: _lnCtrl.text.trim(),
      address1: _addr1Ctrl.text.trim(),
      address2: _addr2Ctrl.text.trim().isEmpty ? null : _addr2Ctrl.text.trim(),
      city: _cityCtrl.text.trim(),
      postalCode: _zipCtrl.text.trim(),
      countryCode: _countryCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
    );
    await widget.onSubmit(address);
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Adresse de livraison',
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            label: 'Email',
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
            validator: (v) => (v == null || !v.contains('@')) ? 'Email invalide' : null,
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            label: 'Prénom',
            controller: _fnCtrl,
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Prénom requis' : null,
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            label: 'Nom',
            controller: _lnCtrl,
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Nom requis' : null,
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            label: 'Adresse',
            controller: _addr1Ctrl,
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Adresse requise' : null,
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(label: 'Adresse (option)', controller: _addr2Ctrl),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: AppTextField(
                  label: 'Ville',
                  controller: _cityCtrl,
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Ville requise' : null,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: AppTextField(
                  label: 'Code postal',
                  controller: _zipCtrl,
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'CP requis' : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(child: AppTextField(label: 'Pays (code)', controller: _countryCtrl)),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: AppTextField(
                  label: 'Téléphone',
                  controller: _phoneCtrl,
                  keyboardType: TextInputType.phone,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          if (_loading)
            const LoadingState()
          else
            AppButton(label: 'Continuer', expanded: true, onPressed: _submit),
        ],
      ),
    );
  }
}