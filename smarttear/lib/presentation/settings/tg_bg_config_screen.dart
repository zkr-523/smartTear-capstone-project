import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../application/providers/auth_provider.dart';
import '../../application/providers/data_ingestor_provider.dart';
import '../../application/providers/tg_bg_settings_notifier.dart';
import '../../domain/entities/reading.dart';
import '../../infrastructure/ml/tg_to_bg_mapper.dart';

const Color _kBlue = Color(0xFF2459F6);
const Color _kGreen = Color(0xFF1A7A4A);
const Color _kMuted = Color(0xFF64748B);
const Color _kGrid = Color(0xFFF1F5F9);

/// Up to 10 most recent readings, oldest first (for preview chart).
final tgConfigPreviewReadingsProvider =
    FutureProvider<List<Reading>>((ref) async {
  final uid = ref.watch(authServiceProvider).currentUser?.uid;
  if (uid == null) return const [];
  final list = await ref.read(readingRepositoryProvider).listReadingsForUser(uid);
  final last10 = list.take(10).toList();
  return last10.reversed.toList();
});

class TgBgConfigScreen extends ConsumerStatefulWidget {
  const TgBgConfigScreen({super.key});

  @override
  ConsumerState<TgBgConfigScreen> createState() => _TgBgConfigScreenState();
}

class _TgBgConfigScreenState extends ConsumerState<TgBgConfigScreen> {
  late double _lagSeconds;
  late double _scale;
  late double _offset;
  var _seededFromProvider = false;

  @override
  void initState() {
    super.initState();
    _lagSeconds = kDefaultTgLagSeconds;
    _scale = kDefaultTgScale;
    _offset = kDefaultTgOffset;
  }

  void _seedFrom(TgBgSettingsData d) {
    setState(() {
      _lagSeconds = d.lagSeconds;
      _scale = d.scale;
      _offset = d.offset;
      _seededFromProvider = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final saved = ref.watch(tgBgSettingsNotifierProvider);
    saved.whenData((d) {
      if (!_seededFromProvider) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _seedFrom(d);
        });
      }
    });

    final preview = ref.watch(tgConfigPreviewReadingsProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('TG → BG Mapping'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2FF),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _kBlue),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline, color: _kBlue, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'This feature estimates blood glucose from tear glucose '
                    'using a lag-and-scale model. Adjust parameters to match '
                    'your personal physiology.',
                    style: TextStyle(
                      color: Colors.grey.shade800,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _PreviewSection(
            preview: preview,
            lagSeconds: _lagSeconds,
            scale: _scale,
            offset: _offset,
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _SliderBlock(
                  title: 'Lag',
                  valueLabel: '${(_lagSeconds / 60).round()} min',
                  subtitle: 'Time delay between tear and blood glucose',
                  child: Slider(
                    value: _lagSeconds.clamp(0, 1800),
                    min: 0,
                    max: 1800,
                    divisions: 30,
                    onChanged: (v) =>
                        setState(() => _lagSeconds = v),
                  ),
                ),
                const Divider(height: 32),
                _SliderBlock(
                  title: 'Scale',
                  valueLabel: '×${_scale.toStringAsFixed(1)}',
                  subtitle: 'Multiplier applied to tear glucose',
                  child: Slider(
                    value: _scale.clamp(0.5, 2.0),
                    min: 0.5,
                    max: 2.0,
                    divisions: 15,
                    onChanged: (v) => setState(() => _scale = v),
                  ),
                ),
                const Divider(height: 32),
                _SliderBlock(
                  title: 'Offset',
                  valueLabel: _offset >= 0
                      ? '+${_offset.toStringAsFixed(1)}'
                      : _offset.toStringAsFixed(1),
                  subtitle: 'Constant added after scaling',
                  child: Slider(
                    value: _offset.clamp(-2.0, 2.0),
                    min: -2.0,
                    max: 2.0,
                    divisions: 40,
                    onChanged: (v) => setState(() => _offset = v),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Current Formula',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 8),
                Text.rich(
                  TextSpan(
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 13,
                      color: Color(0xFF0F172A),
                    ),
                    children: [
                      const TextSpan(text: 'Est. BG = (Tear Glucose × '),
                      TextSpan(
                        text: _scale.toStringAsFixed(1),
                        style: const TextStyle(
                          color: _kBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const TextSpan(text: ') + '),
                      TextSpan(
                        text: _offset.toStringAsFixed(1),
                        style: const TextStyle(
                          color: _kBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Text.rich(
                  TextSpan(
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 13,
                      color: Color(0xFF0F172A),
                    ),
                    children: [
                      const TextSpan(text: 'Applied with '),
                      TextSpan(
                        text: _lagSeconds.round().toString(),
                        style: const TextStyle(
                          color: _kBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const TextSpan(text: ' second lag ('),
                      TextSpan(
                        text: '${(_lagSeconds / 60).round()}',
                        style: const TextStyle(
                          color: _kBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const TextSpan(text: ' minutes)'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () async {
              await ref.read(tgBgSettingsNotifierProvider.notifier).save(
                    lagSeconds: _lagSeconds,
                    scale: _scale,
                    offset: _offset,
                  );
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Settings saved')),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: _kBlue,
              minimumSize: const Size(double.infinity, 48),
            ),
            child: const Text('Save Settings'),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () async {
              await ref.read(tgBgSettingsNotifierProvider.notifier).resetToDefaults();
              final d = TgBgSettingsData.defaults;
              if (mounted) {
                setState(() {
                  _lagSeconds = d.lagSeconds;
                  _scale = d.scale;
                  _offset = d.offset;
                });
              }
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Reset to defaults')),
              );
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: _kBlue,
              side: const BorderSide(color: _kBlue),
              minimumSize: const Size(double.infinity, 48),
            ),
            child: const Text('Reset to Defaults'),
          ),
        ],
      ),
    );
  }
}

class _SliderBlock extends StatelessWidget {
  const _SliderBlock({
    required this.title,
    required this.valueLabel,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String valueLabel;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
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
              valueLabel,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: _kBlue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
        child,
      ],
    );
  }
}

class _PreviewSection extends StatelessWidget {
  const _PreviewSection({
    required this.preview,
    required this.lagSeconds,
    required this.scale,
    required this.offset,
  });

  final AsyncValue<List<Reading>> preview;
  final double lagSeconds;
  final double scale;
  final double offset;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Text(
                'Preview',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFF0F172A),
                ),
              ),
              const Spacer(),
              Text(
                'Last 10 readings',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),
            ],
          ),
          const SizedBox(height: 12),
          preview.when(
            loading: () => const SizedBox(
              height: 160,
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => Text('Error: $e'),
            data: (readings) {
              final withG = readings.where((r) => r.glucose != null).toList();
              if (withG.length < 2) {
                return const SizedBox(
                  height: 160,
                  child: Center(
                    child: Text(
                      'Take readings to see preview',
                      style: TextStyle(color: _kMuted),
                    ),
                  ),
                );
              }
              const mapper = TGtoBGMapper();
              final tgSpots = <FlSpot>[];
              final estSpots = <FlSpot>[];
              for (final r in withG) {
                final x = r.takenAt.millisecondsSinceEpoch.toDouble();
                final tg = r.glucose!.value;
                tgSpots.add(FlSpot(x, tg));
                final est = mapper.mapWithLag(
                  tg,
                  r.takenAt,
                  withG,
                  lagSeconds: lagSeconds,
                  scale: scale,
                  offset: offset,
                );
                estSpots.add(FlSpot(x, est));
              }
              final allY = [...tgSpots.map((s) => s.y), ...estSpots.map((s) => s.y)];
              var minY = allY.reduce((a, b) => a < b ? a : b);
              var maxY = allY.reduce((a, b) => a > b ? a : b);
              if ((maxY - minY).abs() < 1e-6) {
                minY -= 1;
                maxY += 1;
              }
              final p = (maxY - minY) * 0.1;
              minY -= p;
              maxY += p;
              final minX = tgSpots.first.x;
              final maxX = tgSpots.last.x;

              return SizedBox(
                height: 160,
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
                        color: _kGrid,
                        strokeWidth: 1,
                        dashArray: const [4, 4],
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 32,
                          getTitlesWidget: (v, m) => Text(
                            v.toStringAsFixed(0),
                            style: const TextStyle(fontSize: 10, color: _kMuted),
                          ),
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 24,
                          getTitlesWidget: (v, m) {
                            final d = DateTime.fromMillisecondsSinceEpoch(
                              v.round(),
                              isUtc: false,
                            );
                            return Text(
                              DateFormat.Md().format(d),
                              style: const TextStyle(fontSize: 9, color: _kMuted),
                            );
                          },
                        ),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    lineBarsData: [
                      LineChartBarData(
                        spots: tgSpots,
                        color: _kBlue,
                        barWidth: 2.5,
                        dotData: FlDotData(
                          show: true,
                          getDotPainter: (s, p, b, i) => FlDotCirclePainter(
                            radius: 4,
                            color: Colors.white,
                            strokeWidth: 2,
                            strokeColor: _kBlue,
                          ),
                        ),
                      ),
                      LineChartBarData(
                        spots: estSpots,
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
                    ],
                    lineTouchData: LineTouchData(
                      touchTooltipData: LineTouchTooltipData(
                        getTooltipItems: (spots) {
                          if (spots.isEmpty) return [];
                          final idx = spots.first.spotIndex;
                          if (idx < 0 || idx >= withG.length) return [];
                          final r = withG[idx];
                          final tg = r.glucose!.value;
                          final est = mapper.mapWithLag(
                            tg,
                            r.takenAt,
                            withG,
                            lagSeconds: lagSeconds,
                            scale: scale,
                            offset: offset,
                          );
                          final dt =
                              DateFormat.yMMMd().add_jm().format(r.takenAt);
                          final item = LineTooltipItem(
                            '$dt\nTG: ${tg.toStringAsFixed(1)}\nEst. BG: ${est.toStringAsFixed(1)}',
                            const TextStyle(
                              color: Color(0xFF0F172A),
                              fontSize: 11,
                            ),
                          );
                          return List<LineTooltipItem?>.generate(
                            spots.length,
                            (i) => i == 0 ? item : null,
                          );
                        },
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
