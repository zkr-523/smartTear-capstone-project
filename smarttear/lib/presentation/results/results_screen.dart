import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../application/providers/est_bg_settings_notifier.dart';
import '../../application/providers/reading_detail_notifier.dart';
import '../../domain/entities/analyte_value.dart';
import '../../domain/entities/reading.dart';

class ResultsScreen extends ConsumerWidget {
  const ResultsScreen({required this.readingId, super.key});

  final String readingId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final readingAsync = ref.watch(readingDetailNotifierProvider(readingId));
    final estBgEnabledAsync = ref.watch(estBgSettingsNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Results'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/');
            }
          },
        ),
      ),
      endDrawer: const _ChatDrawer(),
      floatingActionButton: Builder(
        builder: (context) {
          return FloatingActionButton(
            onPressed: () => Scaffold.of(context).openEndDrawer(),
            child: const Icon(Icons.chat_bubble_outline),
          );
        },
      ),
      body: readingAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Failed to load: $e')),
        data: (reading) {
          if (reading == null) {
            return Center(child: Text('Reading not found: $readingId'));
          }

          final estBgEnabled = estBgEnabledAsync.valueOrNull ?? false;
          final isValid = reading.isValid;

          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _Header(reading: reading),
                    const SizedBox(height: 12),
                    if (!isValid) ...[
                      _InvalidWarning(
                        invalidReason: reading.invalidReason,
                        onRetake: () => context.go('/'),
                      ),
                      const SizedBox(height: 12),
                    ],
                    ...reading.analytes.map(
                      (a) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _AnalyteCard(
                          analyte: a,
                          showEstimatedBg:
                              estBgEnabled && a.analyteCode == 'TG',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _openAddNoteDialog(
                            context,
                            ref,
                            readingId,
                            reading.note,
                          ),
                          child: const Text('Add Note'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
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
                          child: const Text('Export'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

Future<void> _openAddNoteDialog(
  BuildContext context,
  WidgetRef ref,
  String readingId,
  String? initialNote,
) async {
  final controller = TextEditingController(text: initialNote ?? '');
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Note'),
      content: TextField(
        controller: controller,
        maxLines: 4,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          hintText: 'Optional note for this reading',
        ),
        autofocus: true,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Save'),
        ),
      ],
    ),
  );
  try {
    if (ok == true && context.mounted) {
      final text = controller.text.trim();
      await ref
          .read(readingDetailNotifierProvider(readingId).notifier)
          .saveNote(text.isEmpty ? null : text);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Note saved')),
      );
    }
  } finally {
    controller.dispose();
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.reading});
  final Reading reading;

  @override
  Widget build(BuildContext context) {
    final ts = DateFormat('MMM d, h:mm a').format(reading.takenAt);
    final isValid = reading.isValid;

    return Row(
      children: [
        Expanded(
          child: Text(
            ts,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        Chip(
          label: Text(isValid ? 'Valid' : 'Invalid'),
          backgroundColor: isValid
              ? Colors.green.withOpacity(0.15)
              : Colors.red.withOpacity(0.15),
          labelStyle: TextStyle(
            color: isValid ? Colors.green : Colors.red,
            fontWeight: FontWeight.w600,
          ),
          side: BorderSide.none,
        ),
      ],
    );
  }
}

class _InvalidWarning extends StatelessWidget {
  const _InvalidWarning({required this.invalidReason, required this.onRetake});

  final String? invalidReason;
  final VoidCallback onRetake;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.18),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.withOpacity(0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: scheme.onSurface),
              const SizedBox(width: 8),
              Text(
                'Invalid reading',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(invalidReason ?? 'Quality check failed.'),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: onRetake,
            child: const Text('Retake'),
          ),
        ],
      ),
    );
  }
}

class _AnalyteCard extends StatelessWidget {
  const _AnalyteCard({required this.analyte, required this.showEstimatedBg});

  final AnalyteValue analyte;
  final bool showEstimatedBg;

  @override
  Widget build(BuildContext context) {
    final title = _analyteName(analyte.analyteCode);
    final v = analyte.value;
    final valueText = v.isFinite ? v.toStringAsFixed(1) : v.toString();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              '$valueText ${analyte.unit}',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            if (showEstimatedBg && analyte.estimatedBG != null) ...[
              const SizedBox(height: 6),
              Text(
                'Estimated BG: ${analyte.estimatedBG!.toStringAsFixed(0)} mg/dL',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _analyteName(String code) {
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
}

class _ChatDrawer extends StatelessWidget {
  const _ChatDrawer();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            ListTile(
              title: const Text('Chat'),
              trailing: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).maybePop(),
              ),
            ),
            const Divider(height: 1),
            const Expanded(
              child: Center(
                child: Text('Chat coming soon'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  const Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Message',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
