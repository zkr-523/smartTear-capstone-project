import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../application/providers/est_bg_settings_notifier.dart';
import '../../application/providers/tg_bg_settings_notifier.dart';
import '../../application/providers/trends_notifier.dart';
import '../../domain/entities/reading.dart';
const Color _kPrimaryBlue = Color(0xFF2459F6);
const Color _kCardBg = Color(0xFFF8FAFF);
const Color _kBorder = Color(0xFFE2E8F0);
const Color _kGreen = Color(0xFF1A7A4A);
const Color _kMuted = Color(0xFF64748B);
const Color _kGridLine = Color(0xFFF1F5F9);
const Color _kChipOutline = Color(0xFFCBD5E1);

class TrendsScreen extends ConsumerWidget {
  const TrendsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(trendsNotifierProvider);
    final estBg = ref.watch(estBgSettingsNotifierProvider);
    final tgCfg = ref.watch(tgBgSettingsNotifierProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: async.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Failed to load: $e')),
          data: (vm) {
            return tgCfg.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const Center(child: Text('Settings error')),
              data: (cfg) {
                final estOn = estBg.valueOrNull ?? false;
                return CustomScrollView(
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                      sliver: SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              'Trends',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(height: 16),
                            _RangeChipsRow(
                              range: vm.range,
                              onSelect: (r) => ref
                                  .read(trendsNotifierProvider.notifier)
                                  .setRange(r),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (vm.tgReadings.length < 2)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: _EmptyState(onTakeReading: () => context.go('/')),
                      )
                    else ...[
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: _GlucoseTrendCard(
                            tgReadings: vm.tgReadings,
                            estBgEnabled: estOn,
                            estValues: vm.estimatedBgValues,
                          ),
                        ),
                      ),
                      if (estOn) ...[
                        const SliverToBoxAdapter(child: SizedBox(height: 12)),
                        SliverToBoxAdapter(
                          child: _LegendRow(cfg: cfg),
                        ),
                      ],
                      const SliverToBoxAdapter(child: SizedBox(height: 16)),
                      if (vm.stats != null)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: _StatsRow(
                              stats: vm.stats!,
                              estBgEnabled: estOn,
                            ),
                          ),
                        ),
                      const SliverToBoxAdapter(child: SizedBox(height: 16)),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: _ElectrolytesCard(readings: vm.readingsSorted),
                        ),
                      ),
                      const SliverToBoxAdapter(child: SizedBox(height: 16)),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                          child: _CholesterolCard(readings: vm.readingsSorted),
                        ),
                      ),
                    ],
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _RangeChipsRow extends StatelessWidget {
  const _RangeChipsRow({
    required this.range,
    required this.onSelect,
  });

  final TrendsRange range;
  final void Function(TrendsRange) onSelect;

  @override
  Widget build(BuildContext context) {
    Widget chip(String label, TrendsRange r) {
      final sel = range == r;
      return Material(
        color: sel ? _kPrimaryBlue : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => onSelect(r),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: sel ? _kPrimaryBlue : _kChipOutline,
              ),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: sel ? Colors.white : _kMuted,
              ),
            ),
          ),
        ),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        chip('7D', TrendsRange.d7),
        chip('30D', TrendsRange.d30),
        chip('90D', TrendsRange.d90),
        chip('All', TrendsRange.all),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onTakeReading});

  final VoidCallback onTakeReading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.show_chart_outlined, size: 64, color: _kChipOutline),
          const SizedBox(height: 12),
          const Text(
            'Not enough data',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: _kMuted,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Take at least 2 readings to see trends',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Color(0xFF94A3B8)),
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: onTakeReading,
            style: OutlinedButton.styleFrom(
              foregroundColor: _kPrimaryBlue,
              side: const BorderSide(color: _kPrimaryBlue),
            ),
            child: const Text('Take a Reading'),
          ),
        ],
      ),
    );
  }
}

class _GlucoseTrendCard extends StatelessWidget {
  const _GlucoseTrendCard({
    required this.tgReadings,
    required this.estBgEnabled,
    required this.estValues,
  });

  final List<Reading> tgReadings;
  final bool estBgEnabled;
  final List<double>? estValues;

  @override
  Widget build(BuildContext context) {
    final spotsTg = <FlSpot>[];
    final spotsEst = <FlSpot>[];
    for (var i = 0; i < tgReadings.length; i++) {
      final r = tgReadings[i];
      final x = r.takenAt.millisecondsSinceEpoch.toDouble();
      spotsTg.add(FlSpot(x, r.glucose!.value));
      if (estBgEnabled && estValues != null && i < estValues!.length) {
        spotsEst.add(FlSpot(x, estValues![i]));
      }
    }

    final allY = <double>[
      ...spotsTg.map((s) => s.y),
      ...spotsEst.map((s) => s.y),
    ];
    var minY = allY.reduce((a, b) => a < b ? a : b);
    var maxY = allY.reduce((a, b) => a > b ? a : b);
    if ((maxY - minY).abs() < 1e-6) {
      minY -= 1;
      maxY += 1;
    }
    final pad = (maxY - minY) * 0.08;
    minY -= pad;
    maxY += pad;

    final minX = spotsTg.first.x;
    final maxX = spotsTg.last.x;

    final lineBars = <LineChartBarData>[
      LineChartBarData(
        spots: spotsTg,
        isCurved: false,
        color: _kPrimaryBlue,
        barWidth: 2.5,
        dotData: FlDotData(
          show: true,
          getDotPainter: (s, p, b, i) => FlDotCirclePainter(
            radius: 4,
            color: Colors.white,
            strokeWidth: 2,
            strokeColor: _kPrimaryBlue,
          ),
        ),
      ),
      if (spotsEst.isNotEmpty)
        LineChartBarData(
          spots: spotsEst,
          isCurved: false,
          color: _kGreen,
          barWidth: 2.5,
          dashArray: const [6, 4],
          dotData: FlDotData(
            show: true,
            getDotPainter: (s, p, b, i) => FlDotCirclePainter(
              radius: 4,
              color: Colors.white,
              strokeWidth: 2,
              strokeColor: _kGreen,
            ),
          ),
        ),
    ];

    return _TrendCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Text(
                'Tear Glucose',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFF0F172A),
                ),
              ),
              const Spacer(),
              Text(
                'mmol/L',
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 220,
            child: Padding(
              padding: const EdgeInsets.only(left: 8, right: 16),
              child: LineChart(
                LineChartData(
                  minX: minX,
                  maxX: maxX,
                  minY: minY,
                  maxY: maxY,
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 2,
                    getDrawingHorizontalLine: (v) => FlLine(
                      color: _kGridLine,
                      strokeWidth: 1,
                      dashArray: const [4, 4],
                    ),
                  ),
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
                        reservedSize: 36,
                        interval: (maxY - minY) / 3,
                        getTitlesWidget: (v, m) => Text(
                          v.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 11,
                            color: _kMuted,
                          ),
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 36,
                        interval: (maxX - minX) / 4,
                        getTitlesWidget: (v, m) {
                          final d = DateTime.fromMillisecondsSinceEpoch(
                            v.round(),
                            isUtc: false,
                          );
                          return Transform.rotate(
                            angle: -0.785398,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                DateFormat.MMMd().format(d),
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: _kMuted,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  lineTouchData: LineTouchData(
                    enabled: true,
                    handleBuiltInTouches: true,
                    touchTooltipData: LineTouchTooltipData(
                      fitInsideHorizontally: true,
                      fitInsideVertically: true,
                      getTooltipItems: (touched) {
                        if (touched.isEmpty) return [];
                        final idx = touched.first.spotIndex;
                        if (idx < 0 || idx >= tgReadings.length) {
                          return [];
                        }
                        final r = tgReadings[idx];
                        final tg = r.glucose!.value;
                        final dt = DateFormat.yMMMd()
                            .add_jm()
                            .format(r.takenAt);
                        final estLine = estBgEnabled &&
                                estValues != null &&
                                idx < estValues!.length
                            ? '\nEst. BG: ${estValues![idx].toStringAsFixed(1)}'
                            : '';
                        final item = LineTooltipItem(
                          '$dt\nTG: ${tg.toStringAsFixed(1)}$estLine',
                          const TextStyle(
                            color: Color(0xFF0F172A),
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
                  lineBarsData: lineBars,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({required this.cfg});

  final TgBgSettingsData cfg;

  @override
  Widget build(BuildContext context) {
    final lagSec = cfg.lagSeconds.round();
    final lagMin = (cfg.lagSeconds / 60).round();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _LegendDot(color: _kPrimaryBlue, label: 'Tear Glucose'),
              const SizedBox(width: 24),
              Row(
                children: [
                  CustomPaint(
                    size: const Size(24, 2),
                    painter: _DashedLinePainter(color: _kGreen),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'Est. Blood Glucose',
                    style: TextStyle(fontSize: 13, color: Color(0xFF0F172A)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Est. BG uses ${lagSec}s lag ($lagMin min) · scale ${cfg.scale}×',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: _kMuted),
          ),
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
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A))),
      ],
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  _DashedLinePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    const dash = 6.0;
    const gap = 4.0;
    var x = 0.0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, size.height / 2),
          Offset((x + dash).clamp(0, size.width), size.height / 2), p);
      x += dash + gap;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({
    required this.stats,
    required this.estBgEnabled,
  });

  final TgTrendStats stats;
  final bool estBgEnabled;

  @override
  Widget build(BuildContext context) {
    String fmt(double v) => v.toStringAsFixed(1);
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: 'Min',
            tg: fmt(stats.tgMin),
            est: stats.estMin != null ? fmt(stats.estMin!) : null,
            estBgEnabled: estBgEnabled,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            label: 'Avg',
            tg: fmt(stats.tgAvg),
            est: stats.estAvg != null ? fmt(stats.estAvg!) : null,
            estBgEnabled: estBgEnabled,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            label: 'Max',
            tg: fmt(stats.tgMax),
            est: stats.estMax != null ? fmt(stats.estMax!) : null,
            estBgEnabled: estBgEnabled,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.tg,
    required this.estBgEnabled,
    this.est,
  });

  final String label;
  final String tg;
  final String? est;
  final bool estBgEnabled;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 11,
              letterSpacing: 0.5,
              color: _kMuted,
            ),
          ),
          const SizedBox(height: 8),
          if (!estBgEnabled || est == null)
            Text(
              tg,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            )
          else ...[
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: _kPrimaryBlue,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  tg,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: _kGreen,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  est!,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
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

double? _analyteVal(Reading r, String code) {
  return r.analytes.firstWhereOrNull((a) => a.analyteCode == code)?.value;
}

class _ElectrolytesCard extends StatelessWidget {
  const _ElectrolytesCard({required this.readings});

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
      return _TrendCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _chartHeader('Electrolytes', 'mEq/L'),
            const SizedBox(height: 40),
            const Center(
              child: Text(
                'No electrolyte data in range',
                style: TextStyle(color: _kMuted),
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

    return _TrendCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _chartHeader('Electrolytes', 'mEq/L'),
          const SizedBox(height: 8),
          SizedBox(
            height: 200,
            child: Padding(
              padding: const EdgeInsets.only(left: 8, right: 16),
              child: LineChart(
                LineChartData(
                  minX: minX,
                  maxX: maxX,
                  minY: minY,
                  maxY: maxY,
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 2,
                    getDrawingHorizontalLine: (v) => FlLine(
                      color: _kGridLine,
                      strokeWidth: 1,
                      dashArray: const [4, 4],
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  titlesData: _defaultTitles(minY, maxY, minX, maxX),
                  lineTouchData: LineTouchData(
                    enabled: true,
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (spots) {
                        if (spots.isEmpty) return [];
                        final s = spots.first;
                        final t = DateTime.fromMillisecondsSinceEpoch(
                          s.x.toInt(),
                          isUtc: false,
                        );
                        final lines = spots.map((sp) {
                          final lab = switch (sp.barIndex) {
                            0 => 'Na',
                            1 => 'K',
                            _ => 'Cl',
                          };
                          return '$lab: ${sp.y.toStringAsFixed(1)}';
                        }).join('\n');
                        final item = LineTooltipItem(
                          '${DateFormat.yMMMd().add_jm().format(t)}\n$lines',
                          const TextStyle(color: Color(0xFF0F172A), fontSize: 12),
                        );
                        return List<LineTooltipItem?>.generate(
                          spots.length,
                          (i) => i == 0 ? item : null,
                        );
                      },
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: na,
                      color: const Color(0xFFF59E0B),
                      barWidth: 2,
                      dotData: const FlDotData(show: true),
                    ),
                    LineChartBarData(
                      spots: k,
                      color: const Color(0xFF8B5CF6),
                      barWidth: 2,
                      dotData: const FlDotData(show: true),
                    ),
                    LineChartBarData(
                      spots: cl,
                      color: const Color(0xFF06B6D4),
                      barWidth: 2,
                      dotData: const FlDotData(show: true),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 16,
            children: const [
              _DotLegend(color: Color(0xFFF59E0B), label: 'Na'),
              _DotLegend(color: Color(0xFF8B5CF6), label: 'K'),
              _DotLegend(color: Color(0xFF06B6D4), label: 'Cl'),
            ],
          ),
        ],
      ),
    );
  }
}

class _DotLegend extends StatelessWidget {
  const _DotLegend({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

class _CholesterolCard extends StatelessWidget {
  const _CholesterolCard({required this.readings});

  final List<Reading> readings;

  @override
  Widget build(BuildContext context) {
    final spots = <FlSpot>[];
    for (final r in readings) {
      final v = _analyteVal(r, 'Chol');
      if (v != null) {
        spots.add(
          FlSpot(r.takenAt.millisecondsSinceEpoch.toDouble(), v),
        );
      }
    }
    if (spots.isEmpty) {
      return _TrendCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _chartHeader('Cholesterol', 'mmol/L'),
            const SizedBox(height: 40),
            const Center(
              child: Text(
                'No cholesterol data in range',
                style: TextStyle(color: _kMuted),
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

    return _TrendCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _chartHeader('Cholesterol', 'mmol/L'),
          const SizedBox(height: 8),
          SizedBox(
            height: 200,
            child: Padding(
              padding: const EdgeInsets.only(left: 8, right: 16),
              child: LineChart(
                LineChartData(
                  minX: minX,
                  maxX: maxX,
                  minY: minY,
                  maxY: maxY,
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 2,
                    getDrawingHorizontalLine: (v) => FlLine(
                      color: _kGridLine,
                      strokeWidth: 1,
                      dashArray: const [4, 4],
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  titlesData: _defaultTitles(minY, maxY, minX, maxX),
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (spots) {
                        if (spots.isEmpty) return [];
                        final s = spots.first;
                        final t = DateTime.fromMillisecondsSinceEpoch(
                          s.x.toInt(),
                          isUtc: false,
                        );
                        return [
                          LineTooltipItem(
                            '${DateFormat.yMMMd().add_jm().format(t)}\n'
                            'Chol: ${s.y.toStringAsFixed(2)}',
                            const TextStyle(color: Color(0xFF0F172A), fontSize: 12),
                          ),
                        ];
                      },
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      color: const Color(0xFFEF4444),
                      barWidth: 2.5,
                      dotData: const FlDotData(show: true),
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

FlTitlesData _defaultTitles(double minY, double maxY, double minX, double maxX) {
  return FlTitlesData(
    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    leftTitles: AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        reservedSize: 36,
        interval: (maxY - minY) / 3,
        getTitlesWidget: (v, m) => Text(
          v.toStringAsFixed(1),
          style: const TextStyle(fontSize: 11, color: _kMuted),
        ),
      ),
    ),
    bottomTitles: AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        reservedSize: 32,
        interval: (maxX - minX) / 4,
        getTitlesWidget: (v, m) {
          final d = DateTime.fromMillisecondsSinceEpoch(v.round(), isUtc: false);
          return Transform.rotate(
            angle: -0.785398,
            child: Text(
              DateFormat.MMMd().format(d),
              style: const TextStyle(fontSize: 10, color: _kMuted),
            ),
          );
        },
      ),
    ),
  );
}

Widget _chartHeader(String title, String unit) {
  return Row(
    children: [
      Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: Color(0xFF0F172A),
        ),
      ),
      const Spacer(),
      Text(
        unit,
        style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
      ),
    ],
  );
}

class _TrendCard extends StatelessWidget {
  const _TrendCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _kCardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}
