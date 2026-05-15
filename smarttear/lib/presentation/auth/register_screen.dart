import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../application/providers/auth_provider.dart';
import '../../domain/services/auth_service_port.dart';
import '../widgets/design_system.dart';
import 'auth_ui.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  var _obscurePassword = true;
  var _obscureConfirm = true;
  var _submitting = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    final auth = ref.read(authServiceProvider);
    final result = await auth.register(_email.text.trim(), _password.text);
    if (!mounted) return;
    setState(() => _submitting = false);
    switch (result) {
      case AuthSuccess():
        context.go('/');
      case AuthFailure(:final message):
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
    }
  }

  void _goBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/auth/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScreenShell(
      onBack: _goBack,
      belowLogo: Padding(
        padding: const EdgeInsets.fromLTRB(28, 40, 28, 32),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Create account', style: SmartTearText.headline),
              const SizedBox(height: 4),
              Text(
                'Start monitoring your tear biomarkers',
                style: SmartTearText.body.copyWith(
                  color: SmartTearColors.textSecondary,
                ),
              ),
              const SizedBox(height: 32),
              AuthLabeledField(
                label: 'Email',
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.email],
                validator: (v) {
                  final s = v?.trim() ?? '';
                  if (s.isEmpty) return 'Enter your email';
                  if (!s.contains('@')) return 'Enter a valid email';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              AuthLabeledField(
                label: 'Password',
                controller: _password,
                obscureText: _obscurePassword,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.newPassword],
                suffixIcon: IconButton(
                  tooltip:
                      _obscurePassword ? 'Show password' : 'Hide password',
                  color: SmartTearColors.textMuted,
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: SmartTearColors.textMuted,
                  ),
                ),
                validator: (v) {
                  final s = v ?? '';
                  if (s.isEmpty) return 'Enter a password';
                  if (s.length < 8) {
                    return 'Password must be at least 8 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              AuthLabeledField(
                label: 'Confirm Password',
                controller: _confirm,
                obscureText: _obscureConfirm,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) {
                  if (!_submitting) _register();
                },
                autofillHints: const [AutofillHints.newPassword],
                suffixIcon: IconButton(
                  tooltip:
                      _obscureConfirm ? 'Show password' : 'Hide password',
                  color: SmartTearColors.textMuted,
                  onPressed: () =>
                      setState(() => _obscureConfirm = !_obscureConfirm),
                  icon: Icon(
                    _obscureConfirm
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: SmartTearColors.textMuted,
                  ),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Confirm your password';
                  if (v != _password.text) return 'Passwords do not match';
                  return null;
                },
              ),
              const SizedBox(height: 28),
              TealButton(
                label: 'Create Account',
                onPressed: _register,
                enabled: !_submitting,
                isLoading: _submitting,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already have an account? ',
                    style: SmartTearText.micro,
                  ),
                  GestureDetector(
                    onTap: _submitting ? null : _goBack,
                    child: const Text(
                      'Sign in',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: SmartTearColors.teal,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
