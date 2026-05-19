import 'dart:ffi';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:smarttear/infrastructure/database/app_database.dart';
import 'package:sqlite3/open.dart' as sqlite_open;

const _pathProviderChannel =
    MethodChannel('plugins.flutter.io/path_provider');
const _secureStorageChannel =
    MethodChannel('plugins.it_nomads.com/flutter_secure_storage');

void _registerSqliteLibrary() {
  if (!Platform.isWindows) return;
  final candidates = <String>[
    r'C:\Users\momex\AppData\Local\Programs\Python\Python310\DLLs\sqlite3.dll',
  ];
  for (final c in candidates) {
    if (File(c).existsSync()) {
      sqlite_open.open.overrideFor(
        sqlite_open.OperatingSystem.windows,
        () => DynamicLibrary.open(c),
      );
      return;
    }
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  _registerSqliteLibrary();

  late Directory tempDir;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('perf_db_');

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_pathProviderChannel, (call) async {
      switch (call.method) {
        case 'getApplicationDocumentsDirectory':
        case 'getApplicationSupportDirectory':
        case 'getTemporaryDirectory':
        case 'getLibraryDirectory':
          return tempDir.path;
        case 'getExternalStorageDirectory':
        case 'getDownloadsDirectory':
          return tempDir.path;
      }
      return null;
    });

    final secureBacking = <String, String>{
      'db_encryption_key':
          '0123456789abcdef0123456789abcdef',
    };
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_secureStorageChannel, (call) async {
      final args = (call.arguments as Map?) ?? const {};
      final key = args['key'] as String?;
      switch (call.method) {
        case 'read':
          return secureBacking[key];
        case 'write':
          secureBacking[key!] = args['value'] as String;
          return null;
        case 'delete':
          secureBacking.remove(key);
          return null;
        case 'readAll':
          return Map<String, String>.from(secureBacking);
        case 'deleteAll':
          secureBacking.clear();
          return null;
        case 'containsKey':
          return secureBacking.containsKey(key);
      }
      return null;
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_pathProviderChannel, null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_secureStorageChannel, null);
    try {
      tempDir.deleteSync(recursive: true);
    } catch (_) {}
  });

  test('db growth: 100 readings', () async {
    final db = AppDatabase();

    final dbFile = File(p.join(tempDir.path, 'smarttear.db'));

    Future<void> checkpoint() async {
      try {
        await db.customStatement('PRAGMA wal_checkpoint(TRUNCATE);');
      } catch (_) {}
    }

    final seedTime = DateTime(2026, 1, 1);

    // Insert one seed row so the schema is materialized.
    final seedId = await db.readingDao.insertReading(ReadingsCompanion.insert(
      userId: 1,
      deviceId: 'PERF-DEV',
      takenAt: seedTime,
      sampleStatus: 'complete',
      contactDurationMs: const Value(1500),
      qcStatus: 'valid',
      modelVersion: 'fake-v1',
      rawPackageRef: 'ref-seed',
    ));
    await checkpoint();
    final baselineBytes = dbFile.existsSync() ? dbFile.lengthSync() : 0;

    // Insert 100 representative readings with 5 analytes each.
    const analyteCodes = ['TG', 'Na', 'K', 'Cl', 'Chol'];
    const analyteUnits = ['mmol/L', 'mEq/L', 'mEq/L', 'mEq/L', 'mmol/L'];
    final analyteIdMap = <String, int>{};
    for (var i = 0; i < analyteCodes.length; i++) {
      final aid = await db.into(db.analytes).insert(AnalytesCompanion.insert(
            code: analyteCodes[i],
            name: analyteCodes[i],
            defaultUnit: analyteUnits[i],
          ));
      analyteIdMap[analyteCodes[i]] = aid;
    }

    for (var i = 0; i < 100; i++) {
      final readingId =
          await db.readingDao.insertReading(ReadingsCompanion.insert(
        userId: 1,
        deviceId: 'PERF-DEV',
        takenAt: seedTime.add(Duration(minutes: i)),
        sampleStatus: 'complete',
        contactDurationMs: Value(1400 + (i % 5) * 50),
        qcStatus: i % 7 == 0 ? 'invalid' : 'valid',
        modelVersion: 'fake-v1',
        rawPackageRef: 'ref-$i',
      ));

      final companions = <ReadingAnalytesCompanion>[];
      for (var a = 0; a < analyteCodes.length; a++) {
        companions.add(ReadingAnalytesCompanion.insert(
          userId: 1,
          readingId: readingId,
          analyteId: analyteIdMap[analyteCodes[a]]!,
          value: 0.5 + (i % 10) * 0.07 + a * 0.03,
          unit: analyteUnits[a],
        ));
      }
      await db.readingDao.insertReadingAnalytes(companions);
    }

    await checkpoint();
    final afterBytes = dbFile.existsSync() ? dbFile.lengthSync() : 0;
    final deltaBytes = afterBytes - baselineBytes;
    final deltaKb = deltaBytes / 1024.0;
    final deltaPerReading = deltaBytes / 100.0;

    print('=== DB growth benchmark ===');
    print('db_file: ${dbFile.path}');
    print('seed_reading_id: $seedId');
    print('readings_inserted: 100');
    print('analytes_per_reading: 5');
    print('baseline_bytes: $baselineBytes');
    print('after_100_bytes: $afterBytes');
    print('delta_bytes: $deltaBytes');
    print('delta_kb: ${deltaKb.toStringAsFixed(2)}');
    print('delta_per_reading_bytes: ${deltaPerReading.toStringAsFixed(2)}');

    await db.close();
  }, timeout: const Timeout(Duration(minutes: 5)));
}
