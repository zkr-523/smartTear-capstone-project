import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../application/providers/reading_detail_notifier.dart';
import '../../domain/entities/qc_status.dart';

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

        return Scaffold(
          appBar: AppBar(title: const Text('Reading detail')),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                DateFormat.yMMMd().add_jm().format(reading.takenAt),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Chip(
                    label: Text(qcOk ? 'QC: Valid' : 'QC: Invalid'),
                    backgroundColor: qcOk
                        ? Colors.green.withOpacity(0.15)
                        : Colors.orange.withOpacity(0.15),
                  ),
                  if (!qcOk && (reading.invalidReason ?? '').isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        reading.invalidReason!,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Analytes',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              ...reading.analytes.map(
                (a) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(_analyteLabel(a.analyteCode)),
                  subtitle: a.estimatedBG != null
                      ? Text(
                          'Est. BG: ${a.estimatedBG!.toStringAsFixed(1)} mg/dL',
                          style: Theme.of(context).textTheme.bodySmall,
                        )
                      : null,
                  trailing: Text(
                    '${a.value.toStringAsFixed(2)} ${a.unit}',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Note',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
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
