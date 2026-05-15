import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../application/providers/auth_provider.dart';
import '../widgets/design_system.dart';
import 'auth_ui.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  var _sending = false;
  var _sent = false;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _sending = true);
    final auth = ref.read(authServiceProvider);
    final error = await auth.sendPasswordResetEmail(_email.text.trim());
    if (!mounted) return;
    setState(() => _sending = false);
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
      return;
    }
    setState(() => _sent = true);
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
              Text('Reset password', style: SmartTearText.headline),
              const SizedBox(height: 4),
              Text(
                'Enter your email to receive a reset link',
                style: SmartTearText.body.copyWith(
                  color: SmartTearColors.textSecondary,
                ),
              ),
              const SizedBox(height: 32),
              AuthLabeledField(
                label: 'Email',
                controller: _email,
                enabled: !_sent,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) {
                  if (!_sending && !_sent) _send();
                },
                validator: (v) {
                  final s = v?.trim() ?? '';
                  if (s.isEmpty) return 'Enter your email';
                  if (!s.contains('@')) return 'Enter a valid email';
                  return null;
                },
              ),
              const SizedBox(height: 28),
              if (_sent)
                Container(
                  decoration: BoxDecoration(
                    color: SmartTearColors.tealLight,
                    border: Border.all(color: SmartTearColors.teal),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle_rounded,
                        color: SmartTearColors.teal,
                        size: 22,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Reset link sent!',
                          style: SmartTearText.body.copyWith(
                            color: SmartTearColors.teal,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else
                TealButton(
                  label: 'Send Reset Link',
                  onPressed: _send,
                  enabled: !_sending,
                  isLoading: _sending,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
