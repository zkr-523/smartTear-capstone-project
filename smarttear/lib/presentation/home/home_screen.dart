import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../application/providers/auth_provider.dart';
import '../../application/providers/home_view_model.dart';
import '../../application/providers/simulation_connector_provider.dart';
import '../../domain/entities/analyte_value.dart';
import '../../domain/entities/reading.dart';
import '../../domain/reference/analyte_reference_ranges.dart';
import '../../infrastructure/ml/data_ingestor.dart';
import '../widgets/design_system.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conn = ref.watch(simulationConnectorProvider);
    final homeAsync = ref.watch(homeViewModelProvider);

    return homeAsync.when(
      loading: () => Scaffold(
        backgroundColor: SmartTearColors.bgBase,
        body: const Center(
          child: SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(
              color: SmartTearColors.teal,
              strokeWidth: 2,
            ),
          ),
        ),
      ),
      error: (_, __) => Scaffold(
        backgroundColor: SmartTearColors.bgBase,
        body: Center(
          child: Text(
            'Could not load dashboard',
            style: SmartTearText.body.copyWith(color: SmartTearColors.textMuted),
          ),
        ),
      ),
      data: (vm) => _HomeBody(conn: conn, vm: vm),
    );
  }
}

class _HomeBody extends ConsumerWidget {
  const _HomeBody({
    required this.conn,
    required this.vm,
  });

  final SimulationConnectorState conn;
  final HomeState vm;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topPad = MediaQuery.paddingOf(context).top;
    final user = ref.watch(authServiceProvider).currentUser;
    final email = user?.email ?? '';
    final initial =
        email.isNotEmpty ? email.trim().substring(0, 1).toUpperCase() : '?';

    return Scaffold(
      backgroundColor: SmartTearColors.bgBase,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(20, topPad + 12, 20, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SMARTTEAR',
                      style: SmartTearText.tag.copyWith(
                        color: SmartTearColors.teal,
                        letterSpacing: 2,
                      ),
                    ),
                    Text('Dashboard', style: SmartTearText.headline),
                  ],
                ),
                const Spacer(),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Notifications coming soon')),
                    );
                  },
                  icon: const Icon(
                    Icons.notifications_outlined,
                    size: 22,
                    color: SmartTearColors.textSecond,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 36,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: SmartTearColors.borderTeal),
                  ),
                  child: Text(
                    initial,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: SmartTearColors.teal,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 8),
                  _HeroSamplingRing(
                    conn: conn,
                    isAcquiring: vm.isAcquiring,
                    onPair: () =>
                        ref.read(simulationConnectorProvider.notifier).connect(),
                    onTakeReading: () async {
                      final result = await ref
                          .read(homeViewModelProvider.notifier)
                          .acquireReading();
                      if (!context.mounted) return;
                      switch (result) {
                        case IngestSuccess(:final reading):
                          context.go('/results/${reading.rawPackageRef}');
                        case IngestFailure(:final reason, :final isRetryable):
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(reason),
                              action: isRetryable
                                  ? SnackBarAction(
                                      label: 'Retry',
                                      onPressed: () {
                                        if (ref
                                            .read(simulationConnectorProvider)
                                            .isConnected) {
                                          ref
                                              .read(homeViewModelProvider.notifier)
                                              .acquireReading();
                                        }
                                      },
                                    )
                                  : null,
                            ),
                          );
                        default:
                          break;
                      }
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: _LatestReadingSection(vm: vm),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: _QuickStatsRow(vm: vm),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroSamplingRing extends StatelessWidget {
  const _HeroSamplingRing({
    required this.conn,
    required this.isAcquiring,
    required this.onPair,
    required this.onTakeReading,
  });

  final SimulationConnectorState conn;
  final bool isAcquiring;
  final VoidCallback onPair;
  final Future<void> Function() onTakeReading;

  bool get _connected => conn.isConnected;
  bool get _connecting => conn.isConnecting;

  @override
  Widget build(BuildContext context) {
    final connected = _connected;
    final outerBorder = connected
        ? const Color(0x1500D4C8)
        : const Color(0x15FFFFFF);
    final outerShadow = connected
        ? [
            const BoxShadow(
              color: Color(0x2200D4C8),
              blurRadius: 40,
              spreadRadius: 0,
            ),
          ]
        : const <BoxShadow>[];

    final midBorder = connected
        ? const Color(0x3300D4C8)
        : const Color(0x20FFFFFF);
    final midShadow = connected
        ? [
            BoxShadow(
              color: const Color(0xFF00D4C8).withOpacity(0.25),
              blurRadius: 25,
              spreadRadius: 0,
            ),
          ]
        : const <BoxShadow>[];

    final innerBorder = connected
        ? const Color(0xFF00D4C8)
        : const Color(0x40FFFFFF);
    final innerShadow = connected
        ? [
            const BoxShadow(
              color: Color(0x4400D4C8),
              blurRadius: 20,
              spreadRadius: 0,
            ),
            const BoxShadow(
              color: Color(0x1500D4C8),
              blurRadius: 40,
              spreadRadius: 5,
            ),
          ]
        : const <BoxShadow>[];

    void onTap() {
      if (!_connected) {
        onPair();
        return;
      }
      if (!isAcquiring && !_connecting) {
        onTakeReading();
      }
    }

    final centerChild = isAcquiring
        ? _CenterAcquiring()
        : _connecting
            ? _CenterConnecting()
            : connected
                ? const _CenterReady()
                : const _CenterDisconnected();

    return Column(
      children: [
        Center(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onTap,
            child: SizedBox(
              width: 220,
              height: 220,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 220,
                    height: 220,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: outerBorder, width: 1),
                      boxShadow: outerShadow,
                    ),
                  ),
                  Container(
                    width: 170,
                    height: 170,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: midBorder, width: 1),
                      boxShadow: midShadow,
                    ),
                  ),
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF0D1B2E),
                      border: Border.all(color: innerBorder, width: 2),
                      boxShadow: innerShadow,
                    ),
                    child: Center(child: centerChild),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (connected)
          Text(
            '${conn.deviceId} · Connected',
            style: SmartTearText.label.copyWith(color: SmartTearColors.teal),
            textAlign: TextAlign.center,
          )
        else
          Text(
            'Tap ring to connect',
            style: SmartTearText.micro,
            textAlign: TextAlign.center,
          ),
      ],
    );
  }
}

class _CenterReady extends StatelessWidget {
  const _CenterReady();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.water_drop_rounded,
          size: 28,
          color: SmartTearColors.teal,
        ),
        const SizedBox(height: 4),
        Text(
          'READY',
          style: SmartTearText.tag.copyWith(color: SmartTearColors.teal),
        ),
        Text(
          'TO SAMPLE',
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            color: SmartTearColors.tealDim,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }
}

class _CenterAcquiring extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(
            color: SmartTearColors.teal,
            strokeWidth: 2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'ACQUIRING',
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            color: SmartTearColors.teal,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }
}

class _CenterConnecting extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(
            color: SmartTearColors.teal,
            strokeWidth: 2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'CONNECTING',
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            color: SmartTearColors.teal,
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }
}

class _CenterDisconnected extends StatelessWidget {
  const _CenterDisconnected();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.sensors_off_rounded,
          size: 28,
          color: SmartTearColors.textMuted,
        ),
        const SizedBox(height: 4),
        Text('TAP TO', style: SmartTearText.tag),
        Text(
          'CONNECT',
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            color: SmartTearColors.textSecond,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }
}

class _LatestReadingSection extends StatelessWidget {
  const _LatestReadingSection({required this.vm});

  final HomeState vm;

  AnalyteValue? _analyte(Reading r, String code) =>
      r.analytes.where((a) => a.analyteCode == code).firstOrNull;

  @override
  Widget build(BuildContext context) {
    final reading = vm.latestReading;

    return TealGlowCard(
      padding: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(
                'LATEST VALID READING',
                style: SmartTearText.tag,
              ),
              const Spacer(),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => context.go('/history'),
                  borderRadius: BorderRadius.circular(8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.trending_up_rounded,
                        size: 14,
                        color: SmartTearColors.teal,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'View All',
                        style: SmartTearText.micro.copyWith(
                          fontSize: 11,
                          color: SmartTearColors.teal,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.only(top: 8, bottom: 12),
            child: STDivider(),
          ),
          if (reading == null)
            SizedBox(
              height: 80,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'No readings yet',
                      style: SmartTearText.body.copyWith(
                        color: SmartTearColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tap the ring above to take your first reading',
                      textAlign: TextAlign.center,
                      style: SmartTearText.micro,
                    ),
                  ],
                ),
              ),
            )
          else
            InkWell(
              onTap: () =>
                  context.push('/history/${reading.rawPackageRef}'),
              borderRadius: BorderRadius.circular(8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              reading.glucose == null
                                  ? '—'
                                  : reading.glucose!.value.toStringAsFixed(1),
                              style: TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.w700,
                                color: SmartTearColors.textPrimary,
                                letterSpacing: -2,
                                height: 1,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              reading.glucose?.unit ?? 'mmol/L',
                              style: SmartTearText.label,
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            if (reading.glucose != null)
                              _GlucoseRangeBadge(value: reading.glucose!.value),
                            if (reading.glucose != null)
                              const SizedBox(width: 6),
                            Text(
                              'Tear Glucose',
                              style: SmartTearText.micro,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: _miniStatColumns(reading),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  List<Widget> _miniStatColumns(Reading r) {
    final na = _analyte(r, 'Na');
    final chol = _analyte(r, 'Chol');
    final out = <Widget>[];

    void add(String name, AnalyteValue? a) {
      if (a == null) return;
      if (out.isNotEmpty) out.add(const SizedBox(height: 6));
      out.add(
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(name, style: SmartTearText.micro),
            Text(
              '${a.value.toStringAsFixed(a.value.abs() >= 10 ? 0 : 1)} ${a.unit}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: SmartTearColors.textPrimary,
              ),
            ),
          ],
        ),
      );
    }

    add('Sodium', na);
    add('Cholesterol', chol);
    return out;
  }
}

enum _TgBand { low, normal, high }

_TgBand _tgBand(double v) {
  if (v < AnalyteReferenceRanges.tearGlucoseMinMmolL) return _TgBand.low;
  if (v > AnalyteReferenceRanges.tearGlucoseMaxMmolL) return _TgBand.high;
  return _TgBand.normal;
}

class _GlucoseRangeBadge extends StatelessWidget {
  const _GlucoseRangeBadge({required this.value});

  final double value;

  @override
  Widget build(BuildContext context) {
    final band = _tgBand(value);
    final (label, fg, bg) = switch (band) {
      _TgBand.normal => (
          'NORMAL',
          SmartTearColors.rangeNormal,
          SmartTearColors.validDim,
        ),
      _TgBand.high => (
          'HIGH',
          SmartTearColors.rangeHigh,
          SmartTearColors.invalidDim,
        ),
      _TgBand.low => (
          'LOW',
          SmartTearColors.rangeLow,
          SmartTearColors.warningDim,
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: fg.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.5,
          color: fg,
        ),
      ),
    );
  }
}

class _QuickStatsRow extends StatelessWidget {
  const _QuickStatsRow({required this.vm});

  final HomeState vm;

  @override
  Widget build(BuildContext context) {
    final avg = vm.avgTearGlucose;
    final avgText = avg == null ? '—' : avg.toStringAsFixed(2);

    return Row(
      children: [
        Expanded(
          child: _QuickStatTile(
            value: '${vm.totalReadings}',
            label: 'TOTAL',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _QuickStatTile(
            value: '${vm.validReadings}',
            label: 'VALID',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _QuickStatTile(
            value: avgText,
            label: 'AVG TG',
          ),
        ),
      ],
    );
  }
}

class _QuickStatTile extends StatelessWidget {
  const _QuickStatTile({
    required this.value,
    required this.label,
  });

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF112236),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0x33FFFFFF)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00D4C8).withOpacity(0.06),
            blurRadius: 16,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: SmartTearColors.textPrimary,
              letterSpacing: -1,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 2),
          Text(label, style: SmartTearText.tag),
        ],
      ),
    );
  }
}
