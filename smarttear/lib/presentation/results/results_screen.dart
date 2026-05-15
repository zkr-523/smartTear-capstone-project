import 'dart:math' show pi;

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../application/providers/est_bg_settings_notifier.dart';
import '../../application/providers/reading_detail_notifier.dart';
import '../../infrastructure/ml/tg_bg_ml_model_provider.dart';
import '../../domain/entities/analyte_value.dart';
import '../../domain/entities/reading.dart';
import '../../domain/reference/analyte_reference_ranges.dart';
import '../widgets/design_system.dart';
import '../widgets/estimated_bg_card.dart';

class ResultsScreen extends ConsumerWidget {
  const ResultsScreen({required this.readingId, super.key});

  final String readingId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final readingAsync = ref.watch(readingDetailNotifierProvider(readingId));
    final estBgEnabledAsync = ref.watch(estBgSettingsNotifierProvider);

    return Scaffold(
      backgroundColor: SmartTearColors.bgBase,
      body: readingAsync.when(
        loading: () => const Center(
          child: SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(
              color: SmartTearColors.teal,
              strokeWidth: 2,
            ),
          ),
        ),
        error: (e, _) => Center(
          child: Text(
            'Failed to load: $e',
            style: SmartTearText.body.copyWith(color: SmartTearColors.textMuted),
          ),
        ),
        data: (reading) {
          if (reading == null) {
            return Center(
              child: Text(
                'Reading not found: $readingId',
                style: SmartTearText.body.copyWith(color: SmartTearColors.textMuted),
              ),
            );
          }
          final estBgEnabled = estBgEnabledAsync.valueOrNull ?? false;
          return _ResultsBody(
            reading: reading,
            readingId: readingId,
            estBgEnabled: estBgEnabled,
          );
        },
      ),
    );
  }
}

class _ResultsBody extends ConsumerWidget {
  const _ResultsBody({
    required this.reading,
    required this.readingId,
    required this.estBgEnabled,
  });

  final Reading reading;
  final String readingId;
  final bool estBgEnabled;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final top = MediaQuery.paddingOf(context).top;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(20, top + 8, 20, 12),
          child: Row(
            children: [
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go('/');
                  }
                },
                icon: const Icon(
                  Icons.arrow_back_rounded,
                  color: SmartTearColors.textPrimary,
                ),
              ),
              Text('Reading Details', style: SmartTearText.title),
              const Spacer(),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                onPressed: () async {
                  final err = await ref
                      .read(readingDetailNotifierProvider(readingId).notifier)
                      .exportReadingCsv();
                  if (!context.mounted) return;
                  if (err != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(err)),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Download started')),
                    );
                  }
                },
                icon: const Icon(
                  Icons.share_outlined,
                  color: SmartTearColors.textSecond,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  child: TealGlowCard(
                    padding: 0,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  DateFormat.yMMMd()
                                      .add_jm()
                                      .format(reading.takenAt),
                                  style: SmartTearText.body.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Reading ID ${reading.rawPackageRef}',
                                  style: SmartTearText.micro,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          StatusBadge(status: reading.qcStatus),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: _TearGlucoseGaugeCard(reading: reading),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: _ElectrolytesCard(reading: reading),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: _CholesterolCard(reading: reading),
                ),
                if (estBgEnabled) ...[
                  Builder(
                    builder: (context) {
                      final bgMmol =
                          ref.read(estimatedBgResolverProvider).forReading(reading);
                      if (bgMmol == null) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                        child: EstimatedBgCard(bgMmol: bgMmol),
                      );
                    },
                  ),
                ],
                if (!reading.isValid) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                    child: _InvalidBanner(
                      reason: reading.invalidReason ?? 'Quality check failed.',
                      onRetake: () => context.go('/'),
                    ),
                  ),
                ],
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlineTealButton(
                          label: 'Export',
                          onPressed: () async {
                            final err = await ref
                                .read(
                                  readingDetailNotifierProvider(readingId)
                                      .notifier,
                                )
                                .exportReadingCsv();
                            if (!context.mounted) return;
                            if (err != null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(err)),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Download started'),
                                ),
                              );
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TealButton(
                          label: 'Ask ZKR',
                          onPressed: () => context.push('/chat'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

Widget _pill(String label, bool active, Color color) {
  return Container(
    height: 36,
    decoration: BoxDecoration(
      color: active ? color.withOpacity(0.15) : Colors.transparent,
      border: Border.all(
        color: active ? color : const Color(0x33FFFFFF),
        width: 1,
      ),
      borderRadius: BorderRadius.circular(6),
    ),
    alignment: Alignment.center,
    child: Text(
      label,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
        color: active ? color : const Color(0xFF4A7090),
      ),
    ),
  );
}

class _GaugeArc extends StatelessWidget {
  const _GaugeArc({required this.fraction, required this.color});

  final double fraction;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(200, 105),
      painter: _ArcPainter(fraction: fraction, color: color),
    );
  }
}

class _ArcPainter extends CustomPainter {
  const _ArcPainter({required this.fraction, required this.color});

  final double fraction;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = size.width / 2 - 8;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final bgPaint = Paint()
      ..color = const Color(0xFF1A2E40)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, pi, pi, false, bgPaint);

    if (fraction > 0) {
      final fgPaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 14
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(rect, pi, pi * fraction, false, fgPaint);
    }
  }

  @override
  bool shouldRepaint(_ArcPainter old) =>
      old.fraction != fraction || old.color != color;
}

class _TearGlucoseGaugeCard extends StatelessWidget {
  const _TearGlucoseGaugeCard({required this.reading});

  final Reading reading;

  @override
  Widget build(BuildContext context) {
    final glucoseAnalyte = reading.glucose;
    final v = glucoseAnalyte?.value;

    final String valueText =
        v == null || !v.isFinite ? '—' : v.toStringAsFixed(1);

    final Color gaugeColor;
    final String gaugeStatus;
    final double gaugeFraction;

    final tgMin = AnalyteReferenceRanges.tearGlucoseMinMmolL;
    final tgMax = AnalyteReferenceRanges.tearGlucoseMaxMmolL;
    final tgSpan = tgMax - tgMin;

    if (v == null || !v.isFinite) {
      gaugeColor = const Color(0xFF7FA8C0);
      gaugeStatus = 'none';
      gaugeFraction = 0.0;
    } else if (v < tgMin) {
      gaugeColor = const Color(0xFFFFAB40);
      gaugeStatus = 'low';
      gaugeFraction = 0.0;
    } else if (v > tgMax) {
      gaugeColor = const Color(0xFFFF5252);
      gaugeStatus = 'high';
      gaugeFraction = 1.0;
    } else {
      gaugeColor = const Color(0xFF00D4C8);
      gaugeStatus = 'normal';
      gaugeFraction = tgSpan > 0 ? (v - tgMin) / tgSpan : 0.5;
    }

    return TealGlowCard(
      padding: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'TEAR GLUCOSE',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Color(0xFF7FA8C0),
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                valueText,
                style: TextStyle(
                  fontSize: 52,
                  fontWeight: FontWeight.w700,
                  color: gaugeColor,
                  letterSpacing: -2,
                  height: 1.0,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                glucoseAnalyte?.unit ?? 'mmol/L',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF7FA8C0),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Center(
            child: Text(
              'Normal: ${AnalyteReferenceRanges.tearGlucoseRangeLabel()}',
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF4A7090),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: _GaugeArc(
              fraction: gaugeFraction.clamp(0.0, 1.0),
              color: gaugeColor,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AnalyteReferenceRanges.tearGlucoseMinMmolL.toStringAsFixed(1),
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF4A7090),
                  ),
                ),
                Text(
                  AnalyteReferenceRanges.tearGlucoseMaxMmolL.toStringAsFixed(2),
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF4A7090),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _pill(
                  'LOW',
                  gaugeStatus == 'low',
                  const Color(0xFFFFAB40),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _pill(
                  'NORMAL',
                  gaugeStatus == 'normal',
                  const Color(0xFF00D4C8),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _pill(
                  'HIGH',
                  gaugeStatus == 'high',
                  const Color(0xFFFF5252),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

STAnalyteRange _rangeFor(double v, double min, double max) {
  if (v < min) return STAnalyteRange.low;
  if (v > max) return STAnalyteRange.high;
  return STAnalyteRange.normal;
}

Color _rangeColor(STAnalyteRange r) => switch (r) {
      STAnalyteRange.normal => SmartTearColors.rangeNormal,
      STAnalyteRange.high => SmartTearColors.rangeHigh,
      STAnalyteRange.low => SmartTearColors.rangeLow,
    };

class _ElectrolytesCard extends StatelessWidget {
  const _ElectrolytesCard({required this.reading});

  final Reading reading;

  AnalyteValue? _a(String c) =>
      reading.analytes.where((e) => e.analyteCode == c).firstOrNull;

  @override
  Widget build(BuildContext context) {
    const specs = {
      'Na': (
        AnalyteReferenceRanges.sodiumMin,
        AnalyteReferenceRanges.sodiumMax,
      ),
      'K': (
        AnalyteReferenceRanges.potassiumMin,
        AnalyteReferenceRanges.potassiumMax,
      ),
      'Cl': (
        AnalyteReferenceRanges.chlorideMin,
        AnalyteReferenceRanges.chlorideMax,
      ),
    };

    Widget divider() => Center(
          child: Container(
            width: 1,
            height: 40,
            color: const Color(0x33FFFFFF),
          ),
        );

    Widget cell(String code) {
      final a = _a(code);
      final sp = specs[code]!;
      final range = a == null
          ? STAnalyteRange.normal
          : _rangeFor(a.value, sp.$1, sp.$2);
      final col = a == null ? SmartTearColors.textMuted : _rangeColor(range);
      final text = a == null
          ? '—'
          : (a.value.abs() >= 10
              ? a.value.toStringAsFixed(0)
              : a.value.toStringAsFixed(1));

      return Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              code,
              style: SmartTearText.tag,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                letterSpacing: -1,
                color: col,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              a?.unit ?? '',
              style: SmartTearText.micro,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return GlassCard(
      padding: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('ELECTROLYTES', style: SmartTearText.tag),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              cell('Na'),
              divider(),
              cell('K'),
              divider(),
              cell('Cl'),
            ],
          ),
        ],
      ),
    );
  }
}

class _CholesterolCard extends StatelessWidget {
  const _CholesterolCard({required this.reading});

  final Reading reading;

  @override
  Widget build(BuildContext context) {
    final a = reading.analytes.where((e) => e.analyteCode == 'Chol').firstOrNull;
    const minN = AnalyteReferenceRanges.cholesterolMinMmolL;
    const maxN = AnalyteReferenceRanges.cholesterolMaxMmolL;
    final v = a?.value;
    final text = v == null || !v.isFinite
        ? '—'
        : v.toStringAsFixed(v.abs() >= 10 ? 0 : 1);

    return GlassCard(
      padding: 16,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('CHOLESTEROL', style: SmartTearText.tag),
                const SizedBox(height: 8),
                Text(
                  'Normal: ${AnalyteReferenceRanges.cholesterolRangeLabel()}',
                  style: SmartTearText.micro,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                text,
                textAlign: TextAlign.end,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -1,
                  color: v == null
                      ? SmartTearColors.textPrimary
                      : _rangeColor(_rangeFor(v, minN, maxN)),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                a?.unit ?? 'mmol/L',
                style: SmartTearText.micro,
                textAlign: TextAlign.end,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InvalidBanner extends StatelessWidget {
  const _InvalidBanner({
    required this.reason,
    required this.onRetake,
  });

  final String reason;
  final VoidCallback onRetake;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: SmartTearColors.invalidDim,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: SmartTearColors.invalid.withOpacity(0.3),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.warning_amber_outlined,
                color: SmartTearColors.invalid,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  reason,
                  style: SmartTearText.body.copyWith(
                    color: SmartTearColors.invalid,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        TealButton(
          label: 'Retake Reading',
          height: 44,
          fontSize: 14,
          onPressed: onRetake,
        ),
      ],
    );
  }
}
