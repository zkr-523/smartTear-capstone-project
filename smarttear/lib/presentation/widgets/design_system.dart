import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smarttear/domain/entities/qc_status.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SmartTear — futuristic dark clinical design system (navy + teal glow).
// ─────────────────────────────────────────────────────────────────────────────

abstract final class SmartTearColors {
  SmartTearColors._();

  // Base backgrounds — dark navy layers
  static const Color bgDeep = Color(0xFF070E1A);
  static const Color bgBase = Color(0xFF0D1B2E);
  static const Color bgCard = Color(0xFF112236);
  static const Color bgCardAlt = Color(0xFF162840);
  static const Color bgInput = Color(0xFF0D1B2E);

  // Teal glow accent
  static const Color teal = Color(0xFF00D4C8);
  static const Color tealBright = Color(0xFF26EDE0);
  static const Color tealDim = Color(0xFF00897B);
  static const Color tealGlow = Color(0x3300D4C8);
  static const Color tealLight = Color(0x1A00D4C8);

  // Text
  static const Color textWhite = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFFE8F4F8);
  static const Color textSecond = Color(0xFF7FA8C0);
  static const Color textMuted = Color(0xFF4A7090);

  // Status — vivid for dark backgrounds
  static const Color valid = Color(0xFF00E676);
  static const Color validDim = Color(0x2200E676);
  static const Color invalid = Color(0xFFFF5252);
  static const Color invalidDim = Color(0x22FF5252);
  static const Color warning = Color(0xFFFFAB40);
  static const Color warningDim = Color(0x22FFAB40);

  // Analyte chart colors — vivid on dark
  static const Color chartTG = Color(0xFF00D4C8);
  static const Color chartBG = Color(0xFF448AFF);
  static const Color chartNa = Color(0xFFFFAB40);
  static const Color chartK = Color(0xFFE040FB);
  static const Color chartCl = Color(0xFF40C4FF);
  static const Color chartChol = Color(0xFFFF6E6E);

  // Range status on dark
  static const Color rangeNormal = Color(0xFF00E676);
  static const Color rangeHigh = Color(0xFFFF5252);
  static const Color rangeLow = Color(0xFFFFAB40);

  // Borders — subtle on dark
  static const Color border = Color(0x33FFFFFF);
  static const Color borderTeal = Color(0x4400D4C8);
  static const Color divider = Color(0x1AFFFFFF);

  // ─── Legacy aliases (existing screens) ───────────────────────────────────
  static const Color background = bgBase;
  static const Color surface = bgCard;
  static const Color surfaceAlt = bgCardAlt;
  static const Color accent = teal;
  static const Color accentLight = tealLight;
  static const Color accentDark = tealDim;
  static const Color textSecondary = textSecond;
  static const Color textOnAccent = textWhite;
  static const Color statusValid = valid;
  static const Color statusValidBg = validDim;
  static const Color statusInvalid = invalid;
  static const Color statusInvalidBg = invalidDim;
  static const Color statusWarning = warning;
  static const Color statusWarningBg = warningDim;
  static const Color chartPrimary = chartTG;
  static const Color chartSecondary = chartBG;
  static const Color transparent = Color(0x00000000);
  static const Color buttonDisabled = Color(0xFF4A7090);
  static const Color rangeBg = Color(0xFF0A1525);

  static Color overlayHint(double opacity) =>
      Color.fromRGBO(232, 244, 248, opacity);
}

abstract final class SmartTearText {
  SmartTearText._();

  static const TextStyle hero = TextStyle(
    fontSize: 56,
    fontWeight: FontWeight.w700,
    color: Color(0xFFE8F4F8),
    letterSpacing: -2.0,
    height: 1.0,
  );

  static const TextStyle display = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.w700,
    color: Color(0xFFE8F4F8),
    letterSpacing: -1.5,
    height: 1.0,
  );

  static const TextStyle headline = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: Color(0xFFE8F4F8),
    letterSpacing: -0.5,
  );

  static const TextStyle title = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Color(0xFFE8F4F8),
    letterSpacing: -0.2,
  );

  static const TextStyle body = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: Color(0xFFE8F4F8),
    height: 1.5,
  );

  static const TextStyle label = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: Color(0xFF7FA8C0),
    letterSpacing: 0.3,
  );

  static const TextStyle tag = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w700,
    color: Color(0xFF7FA8C0),
    letterSpacing: 1.5,
  );

  static const TextStyle micro = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: Color(0xFF4A7090),
    letterSpacing: 0.2,
  );

  static const TextStyle teal = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: Color(0xFF00D4C8),
    letterSpacing: -0.2,
  );

  static const TextStyle mono = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: Color(0xFFE8F4F8),
    letterSpacing: -0.3,
    fontFeatures: [FontFeature.tabularFigures()],
  );
}

abstract final class SmartTearSpacing {
  SmartTearSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
}

abstract final class SmartTearRadius {
  SmartTearRadius._();

  static const double card = 16;
  static const double chip = 4;
  static const double button = 12;
  static const double input = 12;
}

abstract final class SmartTearTheme {
  SmartTearTheme._();

  static ThemeData dark() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: SmartTearColors.bgBase,
      colorScheme: const ColorScheme.dark(
        brightness: Brightness.dark,
        primary: SmartTearColors.teal,
        onPrimary: SmartTearColors.textWhite,
        secondary: SmartTearColors.tealBright,
        onSecondary: SmartTearColors.bgDeep,
        surface: SmartTearColors.bgCard,
        onSurface: SmartTearColors.textPrimary,
        onSurfaceVariant: SmartTearColors.textSecond,
        error: SmartTearColors.invalid,
        onError: SmartTearColors.textWhite,
        outline: SmartTearColors.border,
      ).copyWith(
        surfaceContainerHighest: SmartTearColors.bgCardAlt,
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: SmartTearColors.bgBase,
        foregroundColor: SmartTearColors.textPrimary,
        centerTitle: false,
        titleTextStyle: SmartTearText.headline,
        iconTheme: const IconThemeData(color: SmartTearColors.textWhite),
        systemOverlayStyle: SystemUiOverlayStyle.light,
        surfaceTintColor: SmartTearColors.transparent,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: SmartTearColors.bgCard,
        selectedItemColor: SmartTearColors.teal,
        unselectedItemColor: SmartTearColors.textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: SmartTearText.label,
        unselectedLabelStyle: SmartTearText.label,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: SmartTearColors.bgCard,
        elevation: 0,
        height: 64,
        shadowColor: SmartTearColors.transparent,
        surfaceTintColor: SmartTearColors.transparent,
        indicatorColor: SmartTearColors.tealLight,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            size: 24,
            color: selected ? SmartTearColors.teal : SmartTearColors.textMuted,
          );
        }),
      ),
      dividerTheme: const DividerThemeData(
        color: SmartTearColors.divider,
        thickness: 1,
      ),
      dividerColor: SmartTearColors.divider,
      cardTheme: CardTheme(
        elevation: 0,
        color: SmartTearColors.bgCard,
        surfaceTintColor: SmartTearColors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SmartTearRadius.card),
          side: const BorderSide(color: SmartTearColors.border),
        ),
        margin: EdgeInsets.zero,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(double.infinity, 56),
          backgroundColor: SmartTearColors.teal,
          foregroundColor: SmartTearColors.textWhite,
          disabledBackgroundColor:
              SmartTearColors.tealDim.withOpacity(0.4),
          elevation: 0,
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: SmartTearColors.textWhite,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SmartTearRadius.button),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(double.infinity, 56),
          foregroundColor: SmartTearColors.teal,
          side: const BorderSide(color: SmartTearColors.teal),
          backgroundColor: SmartTearColors.transparent,
          textStyle: SmartTearText.teal.copyWith(fontSize: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SmartTearRadius.button),
          ),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: SmartTearColors.teal,
        foregroundColor: SmartTearColors.textWhite,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: SmartTearColors.bgInput,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SmartTearRadius.input),
          borderSide: const BorderSide(color: SmartTearColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SmartTearRadius.input),
          borderSide: const BorderSide(color: SmartTearColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SmartTearRadius.input),
          borderSide: const BorderSide(color: SmartTearColors.borderTeal),
        ),
        hintStyle: SmartTearText.micro,
        labelStyle: SmartTearText.label,
      ),
    );
  }
}

/// Top hairline used above the shell [NavigationBar] (theme has no border hook).
const BorderSide smartTearNavBarTopBorder =
    BorderSide(color: Color(0x33FFFFFF), width: 1);

/// Glass-style card: navy panel, soft border, teal ambient glow.
class GlassCard extends StatelessWidget {
  const GlassCard({super.key, required this.child, this.padding = 16});

  final Widget child;
  final double padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF112236),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x33FFFFFF), width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00D4C8).withOpacity(0.08),
            blurRadius: 20,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: child,
      ),
    );
  }
}

/// Elevated card with stronger teal border and glow.
class TealGlowCard extends StatelessWidget {
  const TealGlowCard({super.key, required this.child, this.padding = 16});

  final Widget child;
  final double padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF112236),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x4400D4C8), width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00D4C8).withOpacity(0.08),
            blurRadius: 20,
            spreadRadius: 0,
          ),
          BoxShadow(
            color: const Color(0xFF00D4C8).withOpacity(0.15),
            blurRadius: 30,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: child,
      ),
    );
  }
}

/// QC badge: VALID / INVALID.
class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.status});

  final QCStatus status;

  @override
  Widget build(BuildContext context) {
    final valid = status == QCStatus.valid;
    final bg = valid ? SmartTearColors.validDim : SmartTearColors.invalidDim;
    final fg = valid ? SmartTearColors.valid : SmartTearColors.invalid;
    final label = valid ? 'VALID' : 'INVALID';

    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 56),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: fg.withOpacity(0.3)),
        ),
        child: Text(
          label,
          softWrap: false,
          maxLines: 1,
          overflow: TextOverflow.clip,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
            color: fg,
          ),
        ),
      ),
    );
  }
}

/// Primary CTA — full width, teal gradient, glow shadow.
class TealButton extends StatelessWidget {
  const TealButton({
    super.key,
    required this.label,
    this.onPressed,
    this.enabled = true,
    this.isLoading = false,
    this.height = 56,
    this.fontSize = 15,
    this.expandWidth = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool enabled;
  final bool isLoading;
  final double height;
  final double fontSize;
  final bool expandWidth;

  @override
  Widget build(BuildContext context) {
    final effectiveOnPressed =
        (enabled && !isLoading) ? onPressed : null;
    final interactive = effectiveOnPressed != null;
    Widget inner = DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(
          colors: [Color(0xFF00D4C8), Color(0xFF00897B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00D4C8).withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: SmartTearColors.transparent,
        child: InkWell(
          onTap: effectiveOnPressed,
          borderRadius: BorderRadius.circular(12),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: SmartTearColors.textWhite,
                    ),
                  )
                : Text(
                    label,
                    style: TextStyle(
                      fontSize: fontSize,
                      fontWeight: FontWeight.w700,
                      color: SmartTearColors.textWhite,
                    ),
                  ),
          ),
        ),
      ),
    );
    if (!interactive && !isLoading) {
      inner = Opacity(opacity: 0.45, child: inner);
    }
    return SizedBox(
      width: expandWidth ? double.infinity : null,
      height: height,
      child: inner,
    );
  }
}

/// Secondary CTA — teal outline on transparent field.
class OutlineTealButton extends StatelessWidget {
  const OutlineTealButton({
    super.key,
    required this.label,
    this.onPressed,
    this.enabled = true,
    this.height = 56,
    this.expandWidth = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool enabled;
  final double height;
  final bool expandWidth;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: expandWidth ? double.infinity : null,
      height: height,
      child: OutlinedButton(
        onPressed: enabled ? onPressed : null,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: SmartTearColors.teal, width: 1),
          backgroundColor: SmartTearColors.transparent,
          foregroundColor: SmartTearColors.teal,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: SmartTearColors.teal,
          ),
        ),
        child: Text(label),
      ),
    );
  }
}

enum STAnalyteRange { normal, high, low }

/// Analyte summary row inside a glass panel with range tint bar + status dot.
class AnalyteValueTile extends StatelessWidget {
  const AnalyteValueTile({
    super.key,
    required this.code,
    required this.name,
    required this.value,
    required this.unit,
    required this.status,
  });

  final String code;
  final String name;
  final String value;
  final String unit;
  final STAnalyteRange status;

  Color get _rangeColor => switch (status) {
        STAnalyteRange.normal => SmartTearColors.rangeNormal,
        STAnalyteRange.high => SmartTearColors.rangeHigh,
        STAnalyteRange.low => SmartTearColors.rangeLow,
      };

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        GlassCard(
          padding: 16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name, style: SmartTearText.title),
                        const SizedBox(height: 2),
                        Text(
                          code.toUpperCase(),
                          style: SmartTearText.tag,
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(value, style: SmartTearText.display),
                      Text(unit, style: SmartTearText.label),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: SizedBox(
                  height: 3,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          _rangeColor,
                          _rangeColor.withOpacity(0),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: 10,
          right: 10,
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: _rangeColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: _rangeColor.withOpacity(0.55),
                  blurRadius: 8,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Legacy / shared atoms (used across screens) ───────────────────────────

/// Standard glass card (replaces flat white ST card).
class STCard extends StatelessWidget {
  const STCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(SmartTearSpacing.md),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF112236),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x33FFFFFF), width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00D4C8).withOpacity(0.08),
            blurRadius: 20,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}

class STStatusChip extends StatelessWidget {
  const STStatusChip({super.key, required this.isValid});

  final bool isValid;

  @override
  Widget build(BuildContext context) {
    return StatusBadge(
      status: isValid ? QCStatus.valid : QCStatus.invalid,
    );
  }
}

class STSectionLabel extends StatelessWidget {
  const STSectionLabel(
    this.text, {
    super.key,
    this.bottomSpacing = SmartTearSpacing.sm,
  });

  final String text;
  final double bottomSpacing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: bottomSpacing),
      child: Text(
        text.toUpperCase(),
        style: SmartTearText.tag.copyWith(color: SmartTearColors.textMuted),
      ),
    );
  }
}

class STDivider extends StatelessWidget {
  const STDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return const Divider(
      height: 1,
      thickness: 1,
      color: SmartTearColors.divider,
    );
  }
}

class STAnalyteRow extends StatelessWidget {
  const STAnalyteRow({
    super.key,
    required this.name,
    required this.value,
    required this.unit,
    required this.range,
  });

  final String name;
  final String value;
  final String unit;
  final STAnalyteRange range;

  Color get _dotColor => switch (range) {
        STAnalyteRange.normal => SmartTearColors.rangeNormal,
        STAnalyteRange.high => SmartTearColors.rangeHigh,
        STAnalyteRange.low => SmartTearColors.rangeLow,
      };

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              name,
              style: SmartTearText.body.copyWith(fontWeight: FontWeight.w500),
            ),
          ),
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(right: SmartTearSpacing.sm),
            decoration: BoxDecoration(
              color: _dotColor,
              shape: BoxShape.circle,
            ),
          ),
          Text(value, style: SmartTearText.mono),
          const SizedBox(width: 4),
          Text(unit, style: SmartTearText.label),
        ],
      ),
    );
  }
}

class STButton extends StatelessWidget {
  const STButton({
    super.key,
    required this.label,
    this.onPressed,
    this.expandWidth = true,
    this.height = 56,
    this.fontSize = 15,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool expandWidth;
  final double height;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return TealButton(
      label: label,
      onPressed: onPressed,
      height: height,
      fontSize: fontSize,
      expandWidth: expandWidth,
    );
  }
}

class STOutlineButton extends StatelessWidget {
  const STOutlineButton({
    super.key,
    required this.label,
    this.onPressed,
    this.expandWidth = true,
    this.height = 56,
    this.fontSize = 15,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool expandWidth;
  final double height;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return OutlineTealButton(
      label: label,
      onPressed: onPressed,
      height: height,
      expandWidth: expandWidth,
    );
  }
}
