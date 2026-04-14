import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/qc_status.dart';
import '../../domain/entities/reading.dart';
import '../home/home_view_model.dart';

/// Resolves a [Reading] from the in-memory store by route id string.
final readingByRouteIdProvider = Provider.family<Reading?, String>((ref, idStr) {
  final id = int.tryParse(idStr);
  if (id == null) return null;
  return ref.watch(readingsStoreProvider).firstWhereOrNull((r) => r.id == id);
});

class ResultsScreen extends ConsumerWidget {
  const ResultsScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reading = ref.watch(readingByRouteIdProvider(id));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
          tooltip: 'Back',
        ),
        title: const Text('Reading results'),
      ),
      body: reading == null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('No data for this reading.'),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () => context.pop(),
                      child: const Text('Go back'),
                    ),
                  ],
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _StatusBanner(reading: reading),
                const SizedBox(height: 20),
                Text(
                  DateFormat('MMMM d, y • h:mm a').format(reading.takenAt),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text('Device: ${reading.deviceId}', style: Theme.of(context).textTheme.bodyLarge),
                const SizedBox(height: 24),
                const Text('Analytes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                for (final a in reading.analytes)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(a.analyteCode),
                    trailing: Text(
                      '${a.value.toStringAsFixed(1)} ${a.unit}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                if (reading.note != null && reading.note!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text('Note: ${reading.note}', style: Theme.of(context).textTheme.bodyMedium),
                ],
                const SizedBox(height: 32),
                FilledButton(
                  onPressed: () => context.pop(),
                  child: const Text('Done'),
                ),
              ],
            ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({required this.reading});

  final Reading reading;

  @override
  Widget build(BuildContext context) {
    final ok = reading.qcStatus == QCStatus.valid;
    return Material(
      color: ok ? Colors.green.shade50 : Colors.red.shade50,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(ok ? Icons.check_circle : Icons.error_outline, color: ok ? Colors.green : Colors.red),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ok ? 'Quality check passed' : 'Quality check: review needed',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  if (reading.invalidReason != null) ...[
                    const SizedBox(height: 4),
                    Text(reading.invalidReason!, style: Theme.of(context).textTheme.bodySmall),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
