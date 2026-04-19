import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../application/providers/history_notifier.dart';
import '../../domain/entities/reading.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(historyNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('History')),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Failed to load: $e')),
        data: (vm) {
          if (vm.groups.isEmpty) {
            return const Center(child: Text('No readings yet'));
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Wrap(
                  spacing: 8,
                  children: [
                    _FilterChip(
                      label: 'All',
                      selected: vm.filter == HistoryFilter.all,
                      onTap: () => ref
                          .read(historyNotifierProvider.notifier)
                          .setFilter(HistoryFilter.all),
                    ),
                    _FilterChip(
                      label: 'Valid',
                      selected: vm.filter == HistoryFilter.valid,
                      onTap: () => ref
                          .read(historyNotifierProvider.notifier)
                          .setFilter(HistoryFilter.valid),
                    ),
                    _FilterChip(
                      label: 'Invalid',
                      selected: vm.filter == HistoryFilter.invalid,
                      onTap: () => ref
                          .read(historyNotifierProvider.notifier)
                          .setFilter(HistoryFilter.invalid),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.only(bottom: 24),
                  itemCount: vm.groups.length,
                  itemBuilder: (context, gi) {
                    final g = vm.groups[gi];
                    final dayLabel = DateFormat.yMMMd().format(g.day);
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                          child: Text(
                            dayLabel,
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                        ...g.readings.map(
                          (r) => _ReadingTile(reading: r),
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

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
    );
  }
}

class _ReadingTile extends StatelessWidget {
  const _ReadingTile({required this.reading});

  final Reading reading;

  @override
  Widget build(BuildContext context) {
    final r = reading;
    final time = DateFormat.jm().format(r.takenAt);
    final g = r.glucose;
    final glucosePreview = g != null
        ? '${g.value.toStringAsFixed(1)} ${g.unit}'
        : '—';
    final valid = r.isValid;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      title: Text(time),
      subtitle: Text('Glucose: $glucosePreview'),
      trailing: Chip(
        label: Text(valid ? 'Valid' : 'Invalid'),
        visualDensity: VisualDensity.compact,
        backgroundColor: valid
            ? Colors.green.withOpacity(0.15)
            : Colors.orange.withOpacity(0.15),
      ),
      onTap: () => context.push('/history/${reading.rawPackageRef}'),
    );
  }
}
