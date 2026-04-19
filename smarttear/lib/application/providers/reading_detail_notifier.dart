import 'package:csv/csv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/reading.dart';
import '../../infrastructure/export/save_text_file.dart';
import 'auth_provider.dart';
import 'data_ingestor_provider.dart';
import 'history_notifier.dart';
import 'trends_notifier.dart';

final readingDetailNotifierProvider = AsyncNotifierProvider.family<
    ReadingDetailNotifier,
    Reading?,
    String>(ReadingDetailNotifier.new);

class ReadingDetailNotifier extends FamilyAsyncNotifier<Reading?, String> {
  @override
  Future<Reading?> build(String arg) async {
    final uid = ref.watch(authServiceProvider).currentUser?.uid;
    if (uid == null) return null;
    return ref.read(readingRepositoryProvider).getReadingByRef(arg);
  }

  Future<void> saveNote(String? note) async {
    final uid = ref.read(authServiceProvider).currentUser?.uid;
    if (uid == null) return;
    await ref
        .read(readingRepositoryProvider)
        .updateReadingNote(arg, uid, note);
    ref.invalidateSelf();
    ref.invalidate(historyNotifierProvider);
    ref.invalidate(trendsNotifierProvider);
  }

  Future<void> deleteReading() async {
    final uid = ref.read(authServiceProvider).currentUser?.uid;
    if (uid == null) return;
    await ref.read(readingRepositoryProvider).deleteReading(arg, uid);
    ref.invalidate(historyNotifierProvider);
    ref.invalidate(trendsNotifierProvider);
  }

  Future<String?> exportReadingCsv() async {
    final r = await future;
    if (r == null) return 'Reading not found';
    final rows = <List<String>>[
      [
        'takenAt',
        'rawPackageRef',
        'qcStatus',
        'sampleStatus',
        'invalidReason',
        'analyte',
        'value',
        'unit',
        'estimatedBG',
        'note',
      ],
    ];
    for (final a in r.analytes) {
      rows.add([
        r.takenAt.toIso8601String(),
        r.rawPackageRef,
        r.qcStatus.name,
        r.sampleStatus,
        r.invalidReason ?? '',
        a.analyteCode,
        a.value.toString(),
        a.unit,
        a.estimatedBG?.toString() ?? '',
        r.note ?? '',
      ]);
    }
    final csv = const ListToCsvConverter().convert(rows);
    final safeName = r.rawPackageRef.replaceAll(RegExp(r'[^\w\-.]+'), '_');
    return saveTextFile(
      fileName: 'smarttear_reading_$safeName.csv',
      contents: csv,
    );
  }
}
