import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/reading.dart';
import 'auth_provider.dart';
import 'data_ingestor_provider.dart';

enum HistoryFilter { all, valid, invalid }

class HistoryDayGroup {
  const HistoryDayGroup({required this.day, required this.readings});

  final DateTime day;
  final List<Reading> readings;
}

class HistoryVm {
  const HistoryVm({required this.filter, required this.groups});

  final HistoryFilter filter;
  final List<HistoryDayGroup> groups;
}

final historyNotifierProvider =
    AsyncNotifierProvider<HistoryNotifier, HistoryVm>(HistoryNotifier.new);

class HistoryNotifier extends AsyncNotifier<HistoryVm> {
  @override
  Future<HistoryVm> build() async {
    return _load(HistoryFilter.all);
  }

  Future<void> setFilter(HistoryFilter filter) async {
    state = const AsyncLoading();
    state = AsyncData(await _load(filter));
  }

  Future<HistoryVm> _load(HistoryFilter filter) async {
    final uid = ref.watch(authServiceProvider).currentUser?.uid;
    if (uid == null) {
      return HistoryVm(filter: filter, groups: const []);
    }
    final repo = ref.read(readingRepositoryProvider);
    final all = await repo.listReadingsForUser(uid);
    final filtered = _applyFilter(all, filter);
    final groups = _groupByDay(filtered);
    return HistoryVm(filter: filter, groups: groups);
  }

  List<Reading> _applyFilter(List<Reading> all, HistoryFilter filter) {
    switch (filter) {
      case HistoryFilter.all:
        return all;
      case HistoryFilter.valid:
        return all.where((r) => r.isValid).toList();
      case HistoryFilter.invalid:
        return all.where((r) => !r.isValid).toList();
    }
  }

  List<HistoryDayGroup> _groupByDay(List<Reading> readings) {
    if (readings.isEmpty) return const [];
    final byDay = <DateTime, List<Reading>>{};
    for (final r in readings) {
      final d = DateTime(r.takenAt.year, r.takenAt.month, r.takenAt.day);
      byDay.putIfAbsent(d, () => []).add(r);
    }
    final days = byDay.keys.toList()..sort((a, b) => b.compareTo(a));
    return days
        .map((d) {
          final list = byDay[d]!
            ..sort((a, b) => b.takenAt.compareTo(a.takenAt));
          return HistoryDayGroup(day: d, readings: list);
        })
        .toList(growable: false);
  }
}
