import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:csv/csv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/reading.dart';
import '../../infrastructure/export/save_text_file.dart';
import 'auth_provider.dart';
import 'data_ingestor_provider.dart';
import 'history_notifier.dart';
import 'trends_notifier.dart';

class SettingsVm {
  const SettingsVm({this.email});

  final String? email;
}

final settingsNotifierProvider =
    AsyncNotifierProvider<SettingsNotifier, SettingsVm>(SettingsNotifier.new);

class SettingsNotifier extends AsyncNotifier<SettingsVm> {
  @override
  Future<SettingsVm> build() async {
    final user = ref.watch(authStateProvider).valueOrNull ??
        ref.watch(authServiceProvider).currentUser;
    return SettingsVm(email: user?.email);
  }

  Future<String?> exportReadingsCsv() async {
    final uid = ref.read(authServiceProvider).currentUser?.uid;
    if (uid == null) return 'Not signed in';
    final list = await ref.read(readingRepositoryProvider).listReadingsForUser(uid);
    if (list.isEmpty) {
      return 'No readings to export';
    }
    final rows = <List<String>>[
      [
        'takenAt',
        'rawPackageRef',
        'qcStatus',
        'sampleStatus',
        'invalidReason',
        'TG',
        'Na',
        'K',
        'Cl',
        'Chol',
        'note',
      ],
    ];
    for (final r in list) {
      double? v(String code) {
        final a = r.analytes.firstWhereOrNull((x) => x.analyteCode == code);
        return a?.value;
      }
      rows.add([
        r.takenAt.toIso8601String(),
        r.rawPackageRef,
        r.qcStatus.name,
        r.sampleStatus,
        r.invalidReason ?? '',
        v('TG')?.toString() ?? '',
        v('Na')?.toString() ?? '',
        v('K')?.toString() ?? '',
        v('Cl')?.toString() ?? '',
        v('Chol')?.toString() ?? '',
        r.note ?? '',
      ]);
    }
    final csv = const ListToCsvConverter().convert(rows);
    final stamp = DateTime.now().toIso8601String().replaceAll(':', '-');
    return saveTextFile(
      fileName: 'smarttear_readings_$stamp.csv',
      contents: csv,
    );
  }

  Future<String?> backupReadingsJson() async {
    final uid = ref.read(authServiceProvider).currentUser?.uid;
    if (uid == null) return 'Not signed in';
    final list = await ref.read(readingRepositoryProvider).listReadingsForUser(uid);
    final jsonStr = jsonEncode(list.map((e) => e.toJson()).toList());
    final stamp = DateTime.now().toIso8601String().replaceAll(':', '-');
    return saveTextFile(
      fileName: 'smarttear_backup_$stamp.json',
      contents: jsonStr,
    );
  }

  Future<String?> restoreReadingsFromJson(String jsonStr) async {
    final uid = ref.read(authServiceProvider).currentUser?.uid;
    if (uid == null) return 'Not signed in';
    final decoded = jsonDecode(jsonStr);
    if (decoded is! List) return 'Invalid backup format';
    final readings = <Reading>[];
    for (final item in decoded) {
      if (item is! Map<String, dynamic>) return 'Invalid backup format';
      readings.add(Reading.fromJson(item));
    }
    await ref.read(readingRepositoryProvider).mergeReadings(readings, uid);
    ref.invalidate(historyNotifierProvider);
    ref.invalidate(trendsNotifierProvider);
    return null;
  }

  Future<String?> signOut() async {
    await ref.read(authServiceProvider).signOut();
    return null;
  }

  Future<String?> deleteAccount() async {
    final err = await ref.read(authServiceProvider).deleteAccount();
    return err;
  }
}
