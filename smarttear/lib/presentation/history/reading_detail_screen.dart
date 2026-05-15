import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../application/providers/est_bg_settings_notifier.dart';
import '../../application/providers/reading_detail_notifier.dart';
import '../../domain/entities/qc_status.dart';
import '../../domain/reference/analyte_reference_ranges.dart';
import '../../infrastructure/ml/tg_bg_ml_model_provider.dart';
import '../widgets/analyte_card.dart';
import '../widgets/design_system.dart';
import '../widgets/estimated_bg_card.dart';

class ReadingDetailScreen extends ConsumerStatefulWidget {
  const ReadingDetailScreen({required this.id, super.key});

  final String id;

  @override
  ConsumerState<ReadingDetailScreen> createState() =>
      _ReadingDetailScreenState();
}

class _ReadingDetailScreenState extends ConsumerState<ReadingDetailScreen> {
  late final TextEditingController _noteController;
  var _noteDirty = false;

  static const _specs = <String, _AnalyteSpec>{
    'TG': _AnalyteSpec(
      'Tear Glucose',
      'mmol/L',
      AnalyteReferenceRanges.tearGlucoseMinMmolL,
      AnalyteReferenceRanges.tearGlucoseMaxMmolL,
    ),
    'Na': _AnalyteSpec('Sodium', 'mEq/L', 120, 165),
    'K': _AnalyteSpec('Potassium', 'mEq/L', 20, 42),
    'Cl': _AnalyteSpec('Chloride', 'mEq/L', 106, 136),
    'Chol': _AnalyteSpec(
      'Cholesterol',
      'mmol/L',
      AnalyteReferenceRanges.cholesterolMinMmolL,
      AnalyteReferenceRanges.cholesterolMaxMmolL,
    ),
  };

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController();
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  String _analyteLabel(String code) {
    switch (code) {
      case 'TG':
        return 'Glucose';
      case 'Na':
        return 'Sodium';
      case 'K':
        return 'Potassium';
      case 'Cl':
        return 'Chloride';
      case 'Chol':
        return 'Cholesterol';
      default:
        return code;
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(tgBgMlModelReadyProvider);
    final async = ref.watch(readingDetailNotifierProvider(widget.id));

    return async.when(
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Reading')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: const Text('Reading')),
        body: Center(child: Text('Failed to load: $e')),
      ),
      data: (reading) {
        if (reading == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Reading')),
            body: const Center(child: Text('Reading not found')),
          );
        }

        if (!_noteDirty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && _noteController.text != (reading.note ?? '')) {
              _noteController.text = reading.note ?? '';
            }
          });
        }

        final qcOk = reading.qcStatus == QCStatus.valid;
        final estBgOn =
            ref.watch(estBgSettingsNotifierProvider).valueOrNull ?? false;
        final estBgMmol = estBgOn
            ? ref.read(estimatedBgResolverProvider).forReading(reading)
            : null;

        return Scaffold(
          appBar: AppBar(title: const Text('Reading detail')),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                DateFormat.yMMMd().add_jm().format(reading.takenAt),
                style: SmartTearText.title,
              ),
              const SizedBox(height: SmartTearSpacing.sm + 4),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: SmartTearSpacing.sm,
                      vertical: SmartTearSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: qcOk
                          ? SmartTearColors.statusValidBg
                          : SmartTearColors.statusWarningBg,
                      borderRadius: BorderRadius.circular(SmartTearRadius.chip),
                    ),
                    child: Text(
                      qcOk ? 'QC: Valid' : 'QC: Invalid',
                      style: SmartTearText.label.copyWith(
                        fontWeight: FontWeight.w600,
                        color: qcOk
                            ? SmartTearColors.statusValid
                            : SmartTearColors.statusWarning,
                      ),
                    ),
                  ),
                  if (!qcOk && (reading.invalidReason ?? '').isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        reading.invalidReason!,
                        style: SmartTearText.micro,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 12),
              _OverallStatusBanner(
                qcOk: qcOk,
                invalidReason: reading.invalidReason,
                affectedAnalytes: _affectedAnalytes(reading.analytes),
                onRetake: () => context.go('/'),
              ),
              if (estBgMmol != null) ...[
                const SizedBox(height: SmartTearSpacing.md),
                EstimatedBgCard(bgMmol: estBgMmol),
              ],
              const SizedBox(height: SmartTearSpacing.md),
              const STSectionLabel('Analyte values'),
              ...reading.analytes.map((a) {
                final spec = _specs[a.analyteCode];
                if (spec == null) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: AnalyteCard(
                      name: _analyteLabel(a.analyteCode),
                      value: a.value,
                      unit: a.unit,
                      normalMin: a.value,
                      normalMax: a.value,
                    ),
                  );
                }
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: AnalyteCard(
                    name: spec.name,
                    value: a.value,
                    unit: spec.unit,
                    normalMin: spec.normalMin,
                    normalMax: spec.normalMax,
                  ),
                );
              }),
              const SizedBox(height: SmartTearSpacing.md),
              const STSectionLabel('Note'),
              TextField(
                controller: _noteController,
                maxLines: 3,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Add a note…',
                ),
                onChanged: (_) => _noteDirty = true,
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () async {
                    await ref
                        .read(readingDetailNotifierProvider(widget.id).notifier)
                        .saveNote(
                          _noteController.text.trim().isEmpty
                              ? null
                              : _noteController.text.trim(),
                        );
                    if (!context.mounted) return;
                    setState(() => _noteDirty = false);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Note saved')),
                    );
                  },
                  child: const Text('Save note'),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final err = await ref
                            .read(
                              readingDetailNotifierProvider(widget.id).notifier,
                            )
                            .exportReadingCsv();
                        if (!context.mounted) return;
                        if (err != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(err)),
                          );
                        }
                      },
                      icon: const Icon(Icons.ios_share_outlined),
                      label: const Text('Export'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () async {
                        final ok = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Delete reading?'),
                            content: const Text(
                              'This removes the reading from this device.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, false),
                                child: const Text('Cancel'),
                              ),
                              FilledButton(
                                onPressed: () => Navigator.pop(ctx, true),
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                        );
                        if (ok != true || !context.mounted) return;
                        await ref
                            .read(
                              readingDetailNotifierProvider(widget.id).notifier,
                            )
                            .deleteReading();
                        if (!context.mounted) return;
                        context.pop();
                      },
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Delete'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AnalyteSpec {
  const _AnalyteSpec(this.name, this.unit, this.normalMin, this.normalMax);
  final String name;
  final String unit;
  final double normalMin;
  final double normalMax;
}

List<String> _affectedAnalytes(List<dynamic> analytes) {
  // `dynamic` to avoid importing domain types at file scope; values accessed via fields.
  final affected = <String>[];
  for (final a in analytes) {
    final code = a.analyteCode as String;
    final value = a.value as double;
    final spec = _ReadingDetailScreenState._specs[code];
    if (spec == null) continue;
    if (value < spec.normalMin || value > spec.normalMax) affected.add(spec.name);
  }
  return affected;
}

class _OverallStatusBanner extends StatelessWidget {
  const _OverallStatusBanner({
    required this.qcOk,
    required this.invalidReason,
    required this.affectedAnalytes,
    required this.onRetake,
  });

  final bool qcOk;
  final String? invalidReason;
  final List<String> affectedAnalytes;
  final VoidCallback onRetake;

  @override
  Widget build(BuildContext context) {
    const greenBg = SmartTearColors.statusValidBg;
    const greenBorder = SmartTearColors.statusValid;
    const amberBg = SmartTearColors.statusWarningBg;
    const amberBorder = SmartTearColors.statusWarning;
    const redBg = SmartTearColors.statusInvalidBg;
    const redBorder = SmartTearColors.statusInvalid;

    final isInvalid = !qcOk;
    final allNormal = qcOk && affectedAnalytes.isEmpty;

    final bg = isInvalid
        ? redBg
        : allNormal
            ? greenBg
            : amberBg;
    final border = isInvalid
        ? redBorder
        : allNormal
            ? greenBorder
            : amberBorder;

    final title = isInvalid
        ? '✗ Invalid reading — ${invalidReason ?? 'Quality check failed.'}'
        : allNormal
            ? '✓ All values within normal range'
            : '⚠ ${affectedAnalytes.length} value(s) outside normal range';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(SmartTearRadius.card),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: SmartTearText.title.copyWith(fontWeight: FontWeight.w700),
          ),
          if (!isInvalid && !allNormal) ...[
            const SizedBox(height: SmartTearSpacing.sm),
            Text(
              affectedAnalytes.join(', '),
              style: SmartTearText.body.copyWith(color: SmartTearColors.textSecondary),
            ),
          ],
          if (isInvalid) ...[
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton(
                onPressed: onRetake,
                child: const Text('Retake'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
