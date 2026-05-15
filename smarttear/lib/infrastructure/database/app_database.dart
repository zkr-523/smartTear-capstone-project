import 'dart:io';
import 'dart:math';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';

import 'reading_dao.dart';
import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Users,
    Devices,
    DeviceBindings,
    Readings,
    Analytes,
    ReadingAnalytes,
    Notes,
    Exports,
    ChatMessages,
    DiagLogs,
  ],
  daos: [
    ReadingDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    const storage = FlutterSecureStorage();
    const keyName = 'db_encryption_key';

    var key = await storage.read(key: keyName);
    if (key == null || key.isEmpty) {
      key = _generateRandomKey32();
      await storage.write(key: keyName, value: key);
    }

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}${Platform.pathSeparator}smarttear.db');

    return NativeDatabase(
      file,
      setup: (db) {
        // SQLCipher: provide key before any other statements.
        db.execute("PRAGMA key = '$key';");
      },
    );
  });
}

String _generateRandomKey32() {
  const alphabet =
      'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  final rand = Random.secure();
  return List.generate(
    32,
    (_) => alphabet[rand.nextInt(alphabet.length)],
  ).join();
}

