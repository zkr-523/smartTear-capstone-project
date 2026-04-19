import 'package:flutter/material.dart';

/// SmartTear auth surfaces — primary #2459F6, full-width filled buttons (12px),
/// outlined text fields.
abstract final class SmartTearAuthUi {
  static const Color primary = Color(0xFF2459F6);
  static const double radius = 12;

  static RoundedRectangleBorder roundedShape([double r = radius]) =>
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(r));

  static InputDecoration fieldDecoration(
    BuildContext context, {
    required String label,
    String? hint,
    Widget? suffixIcon,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return InputDecoration(
      labelText: label,
      hintText: hint,
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(radius)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius),
        borderSide: BorderSide(color: scheme.outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius),
        borderSide: const BorderSide(color: primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius),
        borderSide: BorderSide(color: scheme.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius),
        borderSide: BorderSide(color: scheme.error, width: 2),
      ),
    );
  }

  static ButtonStyle filledFullWidthButton() {
    return FilledButton.styleFrom(
      minimumSize: const Size(double.infinity, 52),
      shape: roundedShape(),
      backgroundColor: primary,
      foregroundColor: Colors.white,
      disabledBackgroundColor: primary.withOpacity(0.5),
      disabledForegroundColor: Colors.white70,
    );
  }
}
