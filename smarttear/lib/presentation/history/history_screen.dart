import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../application/providers/est_bg_settings_notifier.dart';
import '../../application/providers/history_notifier.dart';
import '../../domain/entities/analyte_value.dart';
import '../../domain/entities/reading.dart';
import '../../infrastructure/ml/tg_bg_ml_model_provider.dart';
import '../widgets/design_system.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  static int _readingCount(HistoryVm vm) =>
      vm.groups.fold<int>(0, (s, g) => s + g.readings.length);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(tgBgMlModelReadyProvider);
    final async = ref.watch(historyNotifierProvider);
    final top = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor: SmartTearColors.bgBase,
      body: async.when(
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
          final n = _readingCount(vm);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(20, top + 12, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('History', style: SmartTearText.headline),
                    const SizedBox(height: 4),
                    Text(
                      '$n total readings',
                      style: SmartTearText.label,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: Row(
                  children: [
                    _HistoryFilterChip(
                      label: 'ALL',
                      selected: vm.filter == HistoryFilter.all,
                      onTap: () => ref
                          .read(historyNotifierProvider.notifier)
                          .setFilter(HistoryFilter.all),
                    ),
                    const SizedBox(width: 8),
                    _HistoryFilterChip(
                      label: 'VALID',
                      selected: vm.filter == HistoryFilter.valid,
                      onTap: () => ref
                          .read(historyNotifierProvider.notifier)
                          .setFilter(HistoryFilter.valid),
                    ),
                    const SizedBox(width: 8),
                    _HistoryFilterChip(
                      label: 'INVALID',
                      selected: vm.filter == HistoryFilter.invalid,
                      onTap: () => ref
                          .read(historyNotifierProvider.notifier)
                          .setFilter(HistoryFilter.invalid),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: vm.groups.isEmpty
                    ? const _HistoryEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 24),
                        itemCount: vm.groups.length,
                        itemBuilder: (context, gi) {
                          final g = vm.groups[gi];
                          final now = DateTime.now();
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _DateSectionHeader(day: g.day, now: now),
                              ...g.readings.map(
                                (r) => Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    20,
                                    0,
                                    20,
                                    8,
                                  ),
                                  child: _ReadingCard(reading: r),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _HistoryFilterChip extends StatelessWidget {
  const _HistoryFilterChip({
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

class _DateSectionHeader extends StatelessWidget {
  const _DateSectionHeader({
    required this.day,
    required this.now,
  });

  final DateTime day;
  final DateTime now;

  String get _label {
    final t = DateTime(now.year, now.month, now.day);
    if (day == t) return 'TODAY';
    return DateFormat('MMM d').format(day).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Row(
        children: [
          Text(_label, style: SmartTearText.tag),
          const SizedBox(width: 8),
          const Expanded(
            child: SizedBox(
              height: 1,
              child: ColoredBox(color: SmartTearColors.divider),
            ),
          ),
        ],
      ),
    );
  }
}

AnalyteValue? _analyte(Reading r, String code) =>
    r.analytes.where((a) => a.analyteCode == code).firstOrNull;

String _fmtSmall(AnalyteValue? a) {
  if (a == null) return '—';
  if (a.value.abs() >= 10) return a.value.toStringAsFixed(0);
  return a.value.toStringAsFixed(1);
}

class _ReadingCard extends ConsumerWidget {
  const _ReadingCard({required this.reading});

  final Reading reading;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final time = DateFormat.jm().format(reading.takenAt);
    final tg = _analyte(reading, 'TG');
    final na = _analyte(reading, 'Na');
    final chol = _analyte(reading, 'Chol');
    final estBgOn = ref.watch(estBgSettingsNotifierProvider).valueOrNull ?? false;
    final estBgMmol = estBgOn
        ? ref.read(estimatedBgResolverProvider).forReading(reading)
        : null;
    var preview =
        'TG: ${_fmtSmall(tg)} · Na: ${_fmtSmall(na)} · Chol: ${_fmtSmall(chol)}';
    if (estBgMmol != null) {
      preview +=
          ' · Est BG: ${estBgMmol.toStringAsFixed(1)} (${(estBgMmol * 18).toStringAsFixed(0)} mg/dL)';
    }
    final barColor =
        reading.isValid ? SmartTearColors.valid : SmartTearColors.invalid;

    return GlassCard(
      padding: 14,
      child: Material(
        color: SmartTearColors.transparent,
        child: InkWell(
          onTap: () =>
              context.push('/history/${reading.rawPackageRef}'),
          borderRadius: BorderRadius.circular(16),
          splashColor: SmartTearColors.tealLight,
          highlightColor: SmartTearColors.tealLight.withOpacity(0.08),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 3,
                height: 40,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: barColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      time,
                      style: SmartTearText.body.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      preview,
                      style: SmartTearText.micro,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Transform.scale(
                scale: 0.92,
                alignment: Alignment.centerRight,
                child: StatusBadge(status: reading.qcStatus),
              ),
              const SizedBox(width: 6),
              const Icon(
                Icons.chevron_right_rounded,
                size: 16,
                color: SmartTearColors.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HistoryEmptyState extends StatelessWidget {
  const _HistoryEmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: SmartTearColors.borderTeal),
              ),
              child: const Icon(
                Icons.history_rounded,
                size: 28,
                color: SmartTearColors.teal,
              ),
            ),
            const SizedBox(height: 16),
            Text('No readings yet', style: SmartTearText.title),
            const SizedBox(height: 6),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 220),
              child: Text(
                'Your completed readings will appear here',
                textAlign: TextAlign.center,
                style: SmartTearText.body.copyWith(
                  color: SmartTearColors.textSecond,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
