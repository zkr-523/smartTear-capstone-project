import 'dart:math' as math;

import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../application/providers/est_bg_settings_notifier.dart';
import '../../application/providers/trends_notifier.dart';
import '../../infrastructure/ml/tg_bg_ml_model_provider.dart';
import '../../domain/entities/reading.dart';
import '../widgets/design_system.dart';

class TrendsScreen extends ConsumerWidget {
  const TrendsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(tgBgMlModelReadyProvider);
    final async = ref.watch(trendsNotifierProvider);
    final estBg = ref.watch(estBgSettingsNotifierProvider);
    final top = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor: SmartTearColors.bgBase,
      body: SafeArea(
        bottom: false,
        child: async.when(
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
          data: (vm) {
            final estOn = estBg.valueOrNull ?? false;
            return CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(20, top + 12, 20, 0),
                        child: Text('Trends', style: SmartTearText.headline),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                        child: Row(
                          children: [
                            _TrendRangeChip(
                              label: '7',
                              selected: vm.range == TrendsRange.d7,
                              onTap: () => ref
                                  .read(trendsNotifierProvider.notifier)
                                  .setRange(TrendsRange.d7),
                            ),
                            const SizedBox(width: 8),
                            _TrendRangeChip(
                              label: '30D',
                              selected: vm.range == TrendsRange.d30,
                              onTap: () => ref
                                  .read(trendsNotifierProvider.notifier)
                                  .setRange(TrendsRange.d30),
                            ),
                            const SizedBox(width: 8),
                            _TrendRangeChip(
                              label: '90',
                              selected: vm.range == TrendsRange.d90,
                              onTap: () => ref
                                  .read(trendsNotifierProvider.notifier)
                                  .setRange(TrendsRange.d90),
                            ),
                            const SizedBox(width: 8),
                            _TrendRangeChip(
                              label: 'ALL',
                              selected: vm.range == TrendsRange.all,
                              onTap: () => ref
                                  .read(trendsNotifierProvider.notifier)
                                  .setRange(TrendsRange.all),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (vm.tgReadings.length < 2)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: _TrendsEmptyState(
                          narrowRange: vm.readingsSorted.isNotEmpty,
                          onTakeReading: () => context.go('/'),
                        ),
                      )
                    else ...[
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                          child: _GlucoseTrendCard(vm: vm),
                        ),
                      ),
                      if (estOn &&
                          vm.estimatedBgValues != null &&
                          vm.estimatedBgValues!.length >= 2)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                            child: _EstimatedBgTrendCard(vm: vm),
                          ),
                        ),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                          child: _ElectrolytesTrendCard(readings: vm.readingsSorted),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                          child: _CholesterolTrendCard(readings: vm.readingsSorted),
                        ),
                      ),
                    ],
                  ],
                );
          },
        ),
      ),
    );
  }
}

class _TrendRangeChip extends StatelessWidget {
  const _TrendRangeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: SmartTearColors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          height: 32,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? SmartTearColors.teal : SmartTearColors.bgCard,
            borderRadius: BorderRadius.circular(6),
            border: selected
                ? null
                : Border.all(color: const Color(0x33FFFFFF)),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
              letterSpacing: 0.5,
              color: selected
                  ? SmartTearColors.bgDeep
                  : SmartTearColors.textSecond,
            ),
          ),
        ),
      ),
    );
  }
}

class _TrendsEmptyState extends StatelessWidget {
  const _TrendsEmptyState({
    required this.onTakeReading,
    this.narrowRange = false,
  });

  final VoidCallback onTakeReading;
  /// True when there are readings in the window but fewer than 2 TG points.
  final bool narrowRange;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.show_chart_rounded,
              size: 56,
              color: SmartTearColors.textMuted,
            ),
            const SizedBox(height: 16),
            Text(
              narrowRange
                  ? 'Not enough data for this range'
                  : 'Not enough data',
              style: SmartTearText.title,
            ),
            const SizedBox(height: 8),
            Text(
              narrowRange
                  ? 'Try a longer window or take more glucose readings in this period.'
                  : 'Take at least 2 glucose readings to see trends',
              textAlign: TextAlign.center,
              style: SmartTearText.body.copyWith(color: SmartTearColors.textSecond),
            ),
            const SizedBox(height: 20),
            OutlineTealButton(
              label: 'Take a Reading',
              height: 48,
              onPressed: onTakeReading,
            ),
          ],
        ),
      ),
    );
  }
}

TextStyle get _axisLabelStyle => SmartTearText.micro.copyWith(
      color: Colors.white.withOpacity(0.5),
    );

FlGridData _chartGrid() => FlGridData(
      show: true,
      drawVerticalLine: false,
      getDrawingHorizontalLine: (_) => const FlLine(
        color: Color(0x1AFFFFFF),
        strokeWidth: 1,
      ),
    );

LineTouchTooltipData _tgTooltip({
  required List<Reading> tgReadings,
  required bool estBgEnabled,
  required List<double>? estValues,
}) {
  return LineTouchTooltipData(
    fitInsideHorizontally: true,
    fitInsideVertically: true,
    getTooltipColor: (_) => SmartTearColors.bgCard,
    tooltipRoundedRadius: 10,
    tooltipPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    tooltipBorder: const BorderSide(color: SmartTearColors.teal, width: 1),
    getTooltipItems: (touched) {
      if (touched.isEmpty) return [];
      final idx = touched.first.spotIndex;
      if (idx < 0 || idx >= tgReadings.length) return [];
      final r = tgReadings[idx];
      final tg = r.glucose!.value;
      final dt = DateFormat.yMMMd().add_jm().format(r.takenAt);
      final ev = estValues;
      final estLine = estBgEnabled &&
              ev != null &&
              idx < ev.length
          ? '\nEst. BG: ${ev[idx].toStringAsFixed(1)} mmol/L '
              '(${ (ev[idx] * 18).toStringAsFixed(0)} mg/dL)'
          : '';
      final item = LineTooltipItem(
        '$dt\nTG: ${tg.toStringAsFixed(2)}$estLine',
        SmartTearText.body.copyWith(
          color: SmartTearColors.textPrimary,
          fontSize: 12,
        ),
      );
      return List<LineTooltipItem?>.generate(
        touched.length,
        (i) => i == 0 ? item : null,
      );
    },
  );
}

class _GlucoseTrendCard extends StatelessWidget {
  const _GlucoseTrendCard({required this.vm});

  final TrendsVm vm;

  @override
  Widget build(BuildContext context) {
    final tgReadings = vm.tgReadings;
    final spotsTg = <FlSpot>[];
    for (final r in tgReadings) {
      final x = r.takenAt.millisecondsSinceEpoch.toDouble();
      spotsTg.add(FlSpot(x, r.glucose!.value));
    }

    final allY = spotsTg.map((s) => s.y).toList();
    var minY = allY.reduce(math.min);
    var maxY = allY.reduce(math.max);
    if ((maxY - minY).abs() < 1e-6) {
      minY -= 1;
      maxY += 1;
    }
    final pad = (maxY - minY) * 0.08;
    minY -= pad;
    maxY += pad;

    final minX = spotsTg.first.x;
    final maxX = spotsTg.last.x;

    final tgVals = tgReadings.map((r) => r.glucose!.value).toList();

    final lineBars = <LineChartBarData>[
      LineChartBarData(
        spots: spotsTg,
        isCurved: true,
        curveSmoothness: 0.3,
        color: SmartTearColors.chartTG,
        barWidth: 2.5,
        dotData: FlDotData(
          show: true,
          getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
            radius: 4,
            color: SmartTearColors.chartTG,
            strokeWidth: 2,
            strokeColor: Colors.white,
          ),
        ),
        belowBarData: BarAreaData(
          show: true,
          gradient: LinearGradient(
            colors: [
              SmartTearColors.chartTG.withOpacity(0.2),
              Colors.transparent,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [0.0, 1.0],
          ),
        ),
      ),
    ];

    return TealGlowCard(
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
                    Text('TEAR GLUCOSE', style: SmartTearText.tag),
                    Text('mmol/L', style: SmartTearText.micro),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 180,
            child: Padding(
              padding: const EdgeInsets.only(right: 8, left: 4),
              child: LineChart(
                LineChartData(
                  minX: minX,
                  maxX: maxX,
                  minY: minY,
                  maxY: maxY,
                  gridData: _chartGrid(),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 38,
                        interval: (maxY - minY) / 3,
                        getTitlesWidget: (v, _) => Text(
                          v.toStringAsFixed(1),
                          style: _axisLabelStyle,
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        interval: (maxX - minX) / 4,
                        getTitlesWidget: (v, _) {
                          final d = DateTime.fromMillisecondsSinceEpoch(
                            v.round(),
                            isUtc: false,
                          );
                          return Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              DateFormat.MMMd().format(d),
                              style: _axisLabelStyle,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  lineTouchData: LineTouchData(
                    enabled: true,
                    handleBuiltInTouches: true,
                    touchTooltipData: _tgTooltip(
                      tgReadings: tgReadings,
                      estBgEnabled: false,
                      estValues: null,
                    ),
                  ),
                  lineBarsData: lineBars,
                ),
              ),
            ),
          ),
          if (vm.stats != null) ...[
            const SizedBox(height: 12),
            Container(height: 1, color: SmartTearColors.divider),
            const SizedBox(height: 12),
            _GlucoseStatsRow(
              stats: vm.stats!,
              tgValues: tgVals,
            ),
          ],
        ],
      ),
    );
  }
}

class _EstimatedBgTrendCard extends StatelessWidget {
  const _EstimatedBgTrendCard({required this.vm});

  final TrendsVm vm;

  @override
  Widget build(BuildContext context) {
    final tgReadings = vm.tgReadings;
    final estValues = vm.estimatedBgValues!;
    final spots = <FlSpot>[];
    for (var i = 0; i < tgReadings.length; i++) {
      spots.add(
        FlSpot(
          tgReadings[i].takenAt.millisecondsSinceEpoch.toDouble(),
          estValues[i],
        ),
      );
    }

    var minY = estValues.reduce(math.min);
    var maxY = estValues.reduce(math.max);
    if ((maxY - minY).abs() < 1e-6) {
      minY -= 0.5;
      maxY += 0.5;
    }
    final pad = (maxY - minY) * 0.08;
    minY -= pad;
    maxY += pad;

    final minX = spots.first.x;
    final maxX = spots.last.x;
    final stats = vm.stats;

    return TealGlowCard(
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
                    Text('EST. BLOOD GLUCOSE', style: SmartTearText.tag),
                    Text('mmol/L · ML (Park et al. 2024)', style: SmartTearText.micro),
                  ],
                ),
              ),
              _LegendDot(color: SmartTearColors.chartBG, label: 'Est. BG'),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 160,
            child: Padding(
              padding: const EdgeInsets.only(right: 8, left: 4),
              child: LineChart(
                LineChartData(
                  minX: minX,
                  maxX: maxX,
                  minY: minY,
                  maxY: maxY,
                  gridData: _chartGrid(),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 38,
                        getTitlesWidget: (v, _) => Text(
                          v.toStringAsFixed(1),
                          style: SmartTearText.micro,
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 22,
                        interval: (maxX - minX) / 3,
                        getTitlesWidget: (v, _) {
                          final dt = DateTime.fromMillisecondsSinceEpoch(v.toInt());
                          return Text(
                            DateFormat.Md().format(dt),
                            style: SmartTearText.micro,
                          );
                        },
                      ),
                    ),
                  ),
                  lineTouchData: LineTouchData(
                    enabled: true,
                    touchTooltipData: _tgTooltip(
                      tgReadings: tgReadings,
                      estBgEnabled: true,
                      estValues: estValues,
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      curveSmoothness: 0.3,
                      color: SmartTearColors.chartBG,
                      barWidth: 2.5,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
                          radius: 4,
                          color: SmartTearColors.chartBG,
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        ),
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            SmartTearColors.chartBG.withOpacity(0.15),
                            Colors.transparent,
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (stats != null &&
              stats.estMin != null &&
              stats.estMax != null &&
              stats.estAvg != null) ...[
            const SizedBox(height: 12),
            Container(height: 1, color: SmartTearColors.divider),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _StatColumn(
                    value: stats.estMin!.toStringAsFixed(1),
                    label: 'MIN',
                  ),
                ),
                Expanded(
                  child: _StatColumn(
                    value: stats.estAvg!.toStringAsFixed(1),
                    label: 'AVG',
                  ),
                ),
                Expanded(
                  child: _StatColumn(
                    value: stats.estMax!.toStringAsFixed(1),
                    label: 'MAX',
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: SmartTearText.micro.copyWith(color: SmartTearColors.textSecond),
        ),
      ],
    );
  }
}

class _DashPainter extends CustomPainter {
  _DashPainter({
    required this.color,
    required this.dash,
    required this.gap,
  });

  final Color color;
  final double dash;
  final double gap;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    var x = 0.0;
    final y = size.height / 2;
    while (x < size.width) {
      final end = math.min(x + dash, size.width);
      canvas.drawLine(Offset(x, y), Offset(end, y), p);
      x += dash + gap;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

double? _firstLastPct(List<double> v) {
  if (v.length < 2) return null;
  final a = v.first;
  final b = v.last;
  if (a.abs() < 1e-9) return null;
  return (b - a) / a * 100;
}

double? _halfSegmentPct(List<double> v, bool useMin) {
  if (v.length < 4) return null;
  final mid = v.length ~/ 2;
  final lo = useMin
      ? v.sublist(0, mid).reduce(math.min)
      : v.sublist(0, mid).reduce(math.max);
  final hi = useMin
      ? v.sublist(mid).reduce(math.min)
      : v.sublist(mid).reduce(math.max);
  if (lo.abs() < 1e-9) return null;
  return (hi - lo) / lo * 100;
}

class _GlucoseStatsRow extends StatelessWidget {
  const _GlucoseStatsRow({
    required this.stats,
    required this.tgValues,
  });

  final TgTrendStats stats;
  final List<double> tgValues;

  @override
  Widget build(BuildContext context) {
    String fmt(double v) => v.toStringAsFixed(2);
    final minP = _halfSegmentPct(tgValues, true);
    final maxP = _halfSegmentPct(tgValues, false);
    final avgP = _firstLastPct(tgValues);

    return Row(
      children: [
        Expanded(
          child: _StatColumn(
            value: fmt(stats.tgMin),
            label: 'MIN',
            pct: minP,
          ),
        ),
        Expanded(
          child: _StatColumn(
            value: fmt(stats.tgAvg),
            label: 'AVG',
            pct: avgP,
          ),
        ),
        Expanded(
          child: _StatColumn(
            value: fmt(stats.tgMax),
            label: 'MAX',
            pct: maxP,
          ),
        ),
      ],
    );
  }
}

class _StatColumn extends StatelessWidget {
  const _StatColumn({
    required this.value,
    required this.label,
    this.pct,
  });

  final String value;
  final String label;
  final double? pct;

  @override
  Widget build(BuildContext context) {
    final p = pct;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
            color: SmartTearColors.teal,
          ),
        ),
        Text(label, style: SmartTearText.tag),
        if (p != null) ...[
          const SizedBox(height: 6),
          _PctBadge(pct: p),
        ],
      ],
    );
  }
}

class _PctBadge extends StatelessWidget {
  const _PctBadge({required this.pct});

  final double pct;

  @override
  Widget build(BuildContext context) {
    final up = pct >= 0;
    final color = up ? SmartTearColors.valid : SmartTearColors.invalid;
    final bg = up ? SmartTearColors.validDim : SmartTearColors.invalidDim;
    final arrow = up ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded;
    final text = '${pct.abs().toStringAsFixed(0)}%';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(arrow, size: 11, color: color),
          Text(
            text,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

double? _analyteVal(Reading r, String code) {
  return r.analytes.firstWhereOrNull((a) => a.analyteCode == code)?.value;
}

LineTouchTooltipData _multiLineTooltip(
  List<FlSpot> spotsNa,
  List<FlSpot> spotsK,
  List<FlSpot> spotsCl,
) {
  return LineTouchTooltipData(
    getTooltipColor: (_) => SmartTearColors.bgCard,
    tooltipRoundedRadius: 10,
    tooltipPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    tooltipBorder: const BorderSide(color: SmartTearColors.teal, width: 1),
    getTooltipItems: (touched) {
      if (touched.isEmpty) return [];
      final s = touched.first;
      final t = DateTime.fromMillisecondsSinceEpoch(s.x.toInt(), isUtc: false);
      final buf = StringBuffer(DateFormat.yMMMd().add_jm().format(t));
      for (final sp in touched) {
        final lab = switch (sp.barIndex) {
          0 => 'Na',
          1 => 'K',
          _ => 'Cl',
        };
        buf.write('\n$lab: ${sp.y.toStringAsFixed(1)}');
      }
      final item = LineTooltipItem(
        buf.toString(),
        SmartTearText.body.copyWith(color: SmartTearColors.textPrimary, fontSize: 12),
      );
      return List<LineTooltipItem?>.generate(
        touched.length,
        (i) => i == 0 ? item : null,
      );
    },
  );
}

class _ElectrolytesTrendCard extends StatelessWidget {
  const _ElectrolytesTrendCard({required this.readings});

  final List<Reading> readings;

  @override
  Widget build(BuildContext context) {
    final na = <FlSpot>[];
    final k = <FlSpot>[];
    final cl = <FlSpot>[];
    for (final r in readings) {
      final x = r.takenAt.millisecondsSinceEpoch.toDouble();
      final nv = _analyteVal(r, 'Na');
      final kv = _analyteVal(r, 'K');
      final clv = _analyteVal(r, 'Cl');
      if (nv != null) na.add(FlSpot(x, nv));
      if (kv != null) k.add(FlSpot(x, kv));
      if (clv != null) cl.add(FlSpot(x, clv));
    }
    if (na.isEmpty && k.isEmpty && cl.isEmpty) {
      return TealGlowCard(
        padding: 16,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('ELECTROLYTES', style: SmartTearText.tag),
            Text('mEq/L', style: SmartTearText.micro),
            const SizedBox(height: 40),
            Center(
              child: Text(
                'No electrolyte data in range',
                style: SmartTearText.body.copyWith(color: SmartTearColors.textMuted),
              ),
            ),
          ],
        ),
      );
    }

    final allSpots = [...na, ...k, ...cl];
    final xs = allSpots.map((s) => s.x).toList()..sort();
    final ys = allSpots.map((s) => s.y).toList()..sort();
    final minX = xs.first;
    final maxX = xs.last;
    var minY = ys.first;
    var maxY = ys.last;
    final pady = (maxY - minY).abs() < 1e-6 ? 1.0 : (maxY - minY) * 0.1;
    minY -= pady;
    maxY += pady;

    final cNa = SmartTearColors.chartNa;
    final cK = SmartTearColors.chartK;
    final cCl = SmartTearColors.chartCl;

    LineChartBarData line(
      List<FlSpot> spots,
      Color color,
    ) {
      return LineChartBarData(
        spots: spots,
        isCurved: true,
        curveSmoothness: 0.3,
        color: color,
        barWidth: 2.5,
        dotData: FlDotData(
          show: true,
          getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
            radius: 3,
            color: color,
            strokeWidth: 1.5,
            strokeColor: Colors.white,
          ),
        ),
        belowBarData: BarAreaData(
          show: true,
          gradient: LinearGradient(
            colors: [color.withOpacity(0.1), Colors.transparent],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
      );
    }

    return TealGlowCard(
      padding: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('ELECTROLYTES', style: SmartTearText.tag),
                    Text('mEq/L', style: SmartTearText.micro),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _LegendDot(color: cNa, label: 'Na'),
              const SizedBox(width: 12),
              _LegendDot(color: cK, label: 'K'),
              const SizedBox(width: 12),
              _LegendDot(color: cCl, label: 'Cl'),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 180,
            child: Padding(
              padding: const EdgeInsets.only(right: 8, left: 4),
              child: LineChart(
                LineChartData(
                  minX: minX,
                  maxX: maxX,
                  minY: minY,
                  maxY: maxY,
                  gridData: _chartGrid(),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 38,
                        interval: (maxY - minY) / 3,
                        getTitlesWidget: (v, _) =>
                            Text(v.toStringAsFixed(0), style: _axisLabelStyle),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        interval: (maxX - minX) / 4,
                        getTitlesWidget: (v, _) {
                          final d = DateTime.fromMillisecondsSinceEpoch(
                            v.round(),
                            isUtc: false,
                          );
                          return Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              DateFormat.MMMd().format(d),
                              style: _axisLabelStyle,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  lineTouchData: LineTouchData(
                    touchTooltipData: _multiLineTooltip(na, k, cl),
                  ),
                  lineBarsData: [
                    line(na, cNa),
                    line(k, cK),
                    line(cl, cCl),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CholesterolTrendCard extends StatelessWidget {
  const _CholesterolTrendCard({required this.readings});

  final List<Reading> readings;

  @override
  Widget build(BuildContext context) {
    final spots = <FlSpot>[];
    for (final r in readings) {
      final v = _analyteVal(r, 'Chol');
      if (v != null) {
        spots.add(FlSpot(r.takenAt.millisecondsSinceEpoch.toDouble(), v));
      }
    }
    if (spots.isEmpty) {
      return TealGlowCard(
        padding: 16,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('CHOLESTEROL', style: SmartTearText.tag),
            Text('mmol/L', style: SmartTearText.micro),
            const SizedBox(height: 40),
            Center(
              child: Text(
                'No cholesterol data in range',
                style: SmartTearText.body.copyWith(color: SmartTearColors.textMuted),
              ),
            ),
          ],
        ),
      );
    }

    final ys = spots.map((s) => s.y).toList()..sort();
    var minY = ys.first;
    var maxY = ys.last;
    final pad = (maxY - minY).abs() < 1e-6 ? 0.5 : (maxY - minY) * 0.1;
    minY -= pad;
    maxY += pad;
    final minX = spots.first.x;
    final maxX = spots.last.x;
    final col = SmartTearColors.chartChol;

    return TealGlowCard(
      padding: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('CHOLESTEROL', style: SmartTearText.tag),
                    Text('mmol/L', style: SmartTearText.micro),
                  ],
                ),
              ),
              _LegendDot(color: col, label: 'Chol'),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 180,
            child: Padding(
              padding: const EdgeInsets.only(right: 8, left: 4),
              child: LineChart(
                LineChartData(
                  minX: minX,
                  maxX: maxX,
                  minY: minY,
                  maxY: maxY,
                  gridData: _chartGrid(),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 38,
                        interval: (maxY - minY) / 3,
                        getTitlesWidget: (v, _) => Text(
                          v.toStringAsFixed(1),
                          style: _axisLabelStyle,
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        interval: (maxX - minX) / 4,
                        getTitlesWidget: (v, _) {
                          final d = DateTime.fromMillisecondsSinceEpoch(
                            v.round(),
                            isUtc: false,
                          );
                          return Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              DateFormat.MMMd().format(d),
                              style: _axisLabelStyle,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipColor: (_) => SmartTearColors.bgCard,
                      tooltipRoundedRadius: 10,
                      tooltipPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      tooltipBorder: const BorderSide(
                        color: SmartTearColors.teal,
                        width: 1,
                      ),
                      getTooltipItems: (touched) {
                        if (touched.isEmpty) return [];
                        final s = touched.first;
                        final t = DateTime.fromMillisecondsSinceEpoch(
                          s.x.toInt(),
                          isUtc: false,
                        );
                        final item = LineTooltipItem(
                          '${DateFormat.yMMMd().add_jm().format(t)}\n'
                          'Chol: ${s.y.toStringAsFixed(2)}',
                          SmartTearText.body.copyWith(
                            color: SmartTearColors.textPrimary,
                            fontSize: 12,
                          ),
                        );
                        return List<LineTooltipItem?>.generate(
                          touched.length,
                          (i) => i == 0 ? item : null,
                        );
                      },
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      curveSmoothness: 0.3,
                      color: col,
                      barWidth: 2.5,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (_, __, ___, ____) =>
                            FlDotCirclePainter(
                          radius: 3,
                          color: col,
                          strokeWidth: 1.5,
                          strokeColor: Colors.white,
                        ),
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            col.withOpacity(0.1),
                            Colors.transparent,
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
