/// BINISHOP — Register Screen (client)
library features.auth.presentation.screens.register_screen;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/states/loading_state.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../auth_notifier.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final success = await ref.read(authNotifierProvider.notifier).register(
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text,
          firstName: _firstNameCtrl.text.trim(),
          lastName: _lastNameCtrl.text.trim(),
        );
    if (success && mounted) {
      context.go('/');
    } else if (mounted) {
      final error = ref.read(authNotifierProvider).error;
      if (error != null && error.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error), backgroundColor: Colors.red.shade100));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authNotifierProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Créer mon compte',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Rejoignez BINISHOP et profitez d\'une expérience shopping premium',
                    style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  AppTextField(
                    label: 'Prénom',
                    controller: _firstNameCtrl,
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Prénom requis' : null,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    label: 'Nom',
                    controller: _lastNameCtrl,
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Nom requis' : null,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    label: 'Email',
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) =>
                        (v == null || !v.contains('@')) ? 'Email invalide' : null,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    label: 'Mot de passe',
                    controller: _passwordCtrl,
                    obscureText: true,
                    validator: (v) =>
                        (v == null || v.length < 6) ? '6 caractères minimum' : null,
                  ),
                  const SizedBox(height: 24),
                  if (auth.isLoading)
                    const LoadingState()
                  else
                    AppButton(
                      label: 'Créer mon compte',
                      onPressed: _submit,
                    ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => context.push('/auth/login'),
                    child: Text.rich(
                      TextSpan(
                        text: 'Déjà un compte ? ',
                        style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
                        children: [
                          WidgetSpan(
                            alignment: PlaceholderAlignment.baseline,
                            baseline: TextBaseline.alphabetic,
                            child: Text(
                              'Connectez-vous',
                              style: TextStyle(color: theme.colorScheme.primary),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )),
          ),
        ),
      ),
    );
  }
}