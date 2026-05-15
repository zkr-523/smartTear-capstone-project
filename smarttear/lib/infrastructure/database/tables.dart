import 'package:drift/drift.dart';

class Users extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get email => text().unique()();

  TextColumn get passwordHash => text()();

  TextColumn get units => text().withDefault(const Constant('mmol/L'))();

  BoolColumn get estBgEnabled => boolean().withDefault(const Constant(false))();

  DateTimeColumn get createdAt => dateTime()();
}

class Devices extends Table {
  TextColumn get deviceId => text()();

  TextColumn get hwRev => text().nullable()();

  TextColumn get fwRev => text().nullable()();

  TextColumn get nickname => text().nullable()();

  @override
  Set<Column> get primaryKey => {deviceId};
}

class DeviceBindings extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get userId => integer()();

  TextColumn get deviceId => text()();

  DateTimeColumn get pairedAt => dateTime()();

  DateTimeColumn get lastSeenAt => dateTime().nullable()();

  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();
}

class Readings extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get userId => integer()();

  TextColumn get deviceId => text()();

  DateTimeColumn get takenAt => dateTime()();

  TextColumn get sampleStatus => text()();

  IntColumn get contactDurationMs => integer().nullable()();

  TextColumn get qcStatus => text()();

  TextColumn get invalidReason => text().nullable()();

  TextColumn get modelVersion => text()();

  TextColumn get rawPackageRef => text()();
}

class Analytes extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get code => text().unique()();

  TextColumn get name => text()();

  TextColumn get defaultUnit => text()();
}

class ReadingAnalytes extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Per-user data: required even though it can be inferred via readingId.
  IntColumn get userId => integer()();

  IntColumn get readingId => integer()();

  IntColumn get analyteId => integer()();

  RealColumn get value => real()();

  TextColumn get unit => text()();

  RealColumn get estimatedBg => real().nullable()();
}

class Notes extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Per-user data: required even though it can be inferred via readingId.
  IntColumn get userId => integer()();

  IntColumn get readingId => integer()();

  TextColumn get content => text()();

  DateTimeColumn get createdAt => dateTime()();
}

class Exports extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get userId => integer()();

  TextColumn get type => text()();

  TextColumn get fileUri => text()();

  DateTimeColumn get createdAt => dateTime()();
}

class ChatMessages extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get userId => integer()();

  IntColumn get readingId => integer().nullable()();

  TextColumn get role => text()();

  TextColumn get textBody => text().named('text')();

  DateTimeColumn get createdAt => dateTime()();
}

class DiagLogs extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get userId => integer().nullable()();

  TextColumn get source => text()();

  TextColumn get level => text()();

  /// CRITICAL: Must never contain analyte values or raw sensor data.
  /// Store operational messages only (e.g., "Package validation failed").
  TextColumn get message => text()();

  DateTimeColumn get createdAt => dateTime()();
}

