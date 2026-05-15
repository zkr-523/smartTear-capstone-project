import 'package:flutter/material.dart';

import '../widgets/design_system.dart';

/// Legacy hook for non-auth screens that referenced auth primary.
abstract final class SmartTearAuthUi {
  static Color get primary => SmartTearColors.teal;
}

/// Shared logo block for login / register / forgot password.
class SmartTearAuthLogoBlock extends StatelessWidget {
  const SmartTearAuthLogoBlock({super.key});

  static const Color _ringOuter = Color(0x2200D4C8);
  static const Color _ringInner = Color(0x4400D4C8);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 80,
          height: 80,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: _ringOuter, width: 1),
                ),
              ),
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: _ringInner, width: 1),
                ),
              ),
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: SmartTearColors.bgCard,
                  border: Border.all(
                    color: SmartTearColors.teal,
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: SmartTearColors.teal.withOpacity(0.35),
                      blurRadius: 12,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.water_drop_rounded,
                  size: 20,
                  color: SmartTearColors.teal,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Smart',
              style: SmartTearText.headline.copyWith(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: SmartTearColors.textPrimary,
              ),
            ),
            Text(
              'Tear',
              style: SmartTearText.headline.copyWith(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: SmartTearColors.teal,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Label above field + styled text field (no prefix icons).
class AuthLabeledField extends StatefulWidget {
  const AuthLabeledField({
    super.key,
    required this.label,
    required this.controller,
    this.validator,
    this.keyboardType,
    this.textInputAction,
    this.onFieldSubmitted,
    this.obscureText = false,
    this.autofillHints,
    this.enabled = true,
    this.suffixIcon,
  });

  final String label;
  final TextEditingController controller;
  final FormFieldValidator<String>? validator;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final void Function(String)? onFieldSubmitted;
  final bool obscureText;
  final Iterable<String>? autofillHints;
  final bool enabled;
  final Widget? suffixIcon;

  @override
  State<AuthLabeledField> createState() => _AuthLabeledFieldState();
}

class _AuthLabeledFieldState extends State<AuthLabeledField> {
  final _focusNode = FocusNode();
  var _focused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() => _focused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  static const _radius = 12.0;
  static const _borderIdle = BorderSide(color: Color(0x33FFFFFF), width: 1);
  static const _borderFocus =
      BorderSide(color: SmartTearColors.teal, width: 1);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(widget.label, style: SmartTearText.label),
        const SizedBox(height: 6),
        AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(_radius),
            boxShadow: _focused
                ? [
                    BoxShadow(
                      color: SmartTearColors.teal.withOpacity(0.2),
                      blurRadius: 8,
                      spreadRadius: 0,
                    ),
                  ]
                : const [],
          ),
          child: TextFormField(
            controller: widget.controller,
            focusNode: _focusNode,
            enabled: widget.enabled,
            validator: widget.validator,
            keyboardType: widget.keyboardType,
            textInputAction: widget.textInputAction,
            onFieldSubmitted: widget.onFieldSubmitted,
            obscureText: widget.obscureText,
            autofillHints: widget.autofillHints,
            cursorColor: SmartTearColors.teal,
            style: SmartTearText.body.copyWith(color: SmartTearColors.textPrimary),
            decoration: InputDecoration(
              isDense: true,
              filled: true,
              fillColor: SmartTearColors.bgCard,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(_radius),
                borderSide: _borderIdle,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(_radius),
                borderSide: _borderIdle,
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(_radius),
                borderSide: const BorderSide(
                  color: Color(0x22FFFFFF),
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(_radius),
                borderSide: _borderFocus,
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(_radius),
                borderSide: BorderSide(
                  color: SmartTearColors.invalid.withOpacity(0.9),
                  width: 1,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(_radius),
                borderSide: const BorderSide(
                  color: SmartTearColors.invalid,
                  width: 1,
                ),
              ),
              suffixIcon: widget.suffixIcon,
              suffixIconConstraints: const BoxConstraints(
                minWidth: 48,
                minHeight: 48,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// SafeArea + optional back + logo + scrollable [belowLogo].
class AuthScreenShell extends StatelessWidget {
  const AuthScreenShell({
    super.key,
    this.onBack,
    required this.belowLogo,
  });

  final VoidCallback? onBack;
  final Widget belowLogo;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SmartTearColors.bgDeep,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (onBack != null)
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: onBack,
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 18,
                      color: SmartTearColors.textMuted,
                    ),
                  ),
                ),
              SizedBox(height: onBack != null ? 12 : 40),
              const Center(child: SmartTearAuthLogoBlock()),
              belowLogo,
            ],
          ),
        ),
      ),
    );
  }
}
