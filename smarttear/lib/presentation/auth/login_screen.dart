import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../application/providers/auth_provider.dart';
import '../../domain/services/auth_service_port.dart';
import '../widgets/design_system.dart';
import 'auth_ui.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  var _obscurePassword = true;
  var _submitting = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    final auth = ref.read(authServiceProvider);
    final result = await auth.signIn(_email.text.trim(), _password.text);
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

  @override
  Widget build(BuildContext context) {
    return AuthScreenShell(
      belowLogo: Padding(
        padding: const EdgeInsets.fromLTRB(28, 40, 28, 32),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Welcome back', style: SmartTearText.headline),
              const SizedBox(height: 4),
              Text(
                'Sign in to your account',
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
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) {
                  if (!_submitting) _signIn();
                },
                autofillHints: const [AutofillHints.password],
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
                  if (v == null || v.isEmpty) return 'Enter your password';
                  return null;
                },
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _submitting
                      ? null
                      : () => context.push('/auth/forgot'),
                  style: TextButton.styleFrom(
                    foregroundColor: SmartTearColors.teal,
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    textStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  child: const Text('Forgot password?'),
                ),
              ),
              const SizedBox(height: 28),
              TealButton(
                label: 'Sign In',
                onPressed: _signIn,
                enabled: !_submitting,
                isLoading: _submitting,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'New to SmartTear? ',
                    style: SmartTearText.micro,
                  ),
                  GestureDetector(
                    onTap: _submitting
                        ? null
                        : () => context.push('/auth/register'),
                    child: const Text(
                      'Create account',
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
