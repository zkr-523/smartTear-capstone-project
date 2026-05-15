// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $UsersTable extends Users with TableInfo<$UsersTable, User> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UsersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
      'email', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _passwordHashMeta =
      const VerificationMeta('passwordHash');
  @override
  late final GeneratedColumn<String> passwordHash = GeneratedColumn<String>(
      'password_hash', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _unitsMeta = const VerificationMeta('units');
  @override
  late final GeneratedColumn<String> units = GeneratedColumn<String>(
      'units', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('mmol/L'));
  static const VerificationMeta _estBgEnabledMeta =
      const VerificationMeta('estBgEnabled');
  @override
  late final GeneratedColumn<bool> estBgEnabled = GeneratedColumn<bool>(
      'est_bg_enabled', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("est_bg_enabled" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, email, passwordHash, units, estBgEnabled, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'users';
  @override
  VerificationContext validateIntegrity(Insertable<User> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('email')) {
      context.handle(
          _emailMeta, email.isAcceptableOrUnknown(data['email']!, _emailMeta));
    } else if (isInserting) {
      context.missing(_emailMeta);
    }
    if (data.containsKey('password_hash')) {
      context.handle(
          _passwordHashMeta,
          passwordHash.isAcceptableOrUnknown(
              data['password_hash']!, _passwordHashMeta));
    } else if (isInserting) {
      context.missing(_passwordHashMeta);
    }
    if (data.containsKey('units')) {
      context.handle(
          _unitsMeta, units.isAcceptableOrUnknown(data['units']!, _unitsMeta));
    }
    if (data.containsKey('est_bg_enabled')) {
      context.handle(
          _estBgEnabledMeta,
          estBgEnabled.isAcceptableOrUnknown(
              data['est_bg_enabled']!, _estBgEnabledMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  User map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return User(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      email: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}email'])!,
      passwordHash: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}password_hash'])!,
      units: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}units'])!,
      estBgEnabled: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}est_bg_enabled'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $UsersTable createAlias(String alias) {
    return $UsersTable(attachedDatabase, alias);
  }
}

class User extends DataClass implements Insertable<User> {
  final int id;
  final String email;
  final String passwordHash;
  final String units;
  final bool estBgEnabled;
  final DateTime createdAt;
  const User(
      {required this.id,
      required this.email,
      required this.passwordHash,
      required this.units,
      required this.estBgEnabled,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['email'] = Variable<String>(email);
    map['password_hash'] = Variable<String>(passwordHash);
    map['units'] = Variable<String>(units);
    map['est_bg_enabled'] = Variable<bool>(estBgEnabled);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  UsersCompanion toCompanion(bool nullToAbsent) {
    return UsersCompanion(
      id: Value(id),
      email: Value(email),
      passwordHash: Value(passwordHash),
      units: Value(units),
      estBgEnabled: Value(estBgEnabled),
      createdAt: Value(createdAt),
    );
  }

  factory User.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return User(
      id: serializer.fromJson<int>(json['id']),
      email: serializer.fromJson<String>(json['email']),
      passwordHash: serializer.fromJson<String>(json['passwordHash']),
      units: serializer.fromJson<String>(json['units']),
      estBgEnabled: serializer.fromJson<bool>(json['estBgEnabled']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'email': serializer.toJson<String>(email),
      'passwordHash': serializer.toJson<String>(passwordHash),
      'units': serializer.toJson<String>(units),
      'estBgEnabled': serializer.toJson<bool>(estBgEnabled),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  User copyWith(
          {int? id,
          String? email,
          String? passwordHash,
          String? units,
          bool? estBgEnabled,
          DateTime? createdAt}) =>
      User(
        id: id ?? this.id,
        email: email ?? this.email,
        passwordHash: passwordHash ?? this.passwordHash,
        units: units ?? this.units,
        estBgEnabled: estBgEnabled ?? this.estBgEnabled,
        createdAt: createdAt ?? this.createdAt,
      );
  User copyWithCompanion(UsersCompanion data) {
    return User(
      id: data.id.present ? data.id.value : this.id,
      email: data.email.present ? data.email.value : this.email,
      passwordHash: data.passwordHash.present
          ? data.passwordHash.value
          : this.passwordHash,
      units: data.units.present ? data.units.value : this.units,
      estBgEnabled: data.estBgEnabled.present
          ? data.estBgEnabled.value
          : this.estBgEnabled,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('User(')
          ..write('id: $id, ')
          ..write('email: $email, ')
          ..write('passwordHash: $passwordHash, ')
          ..write('units: $units, ')
          ..write('estBgEnabled: $estBgEnabled, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, email, passwordHash, units, estBgEnabled, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is User &&
          other.id == this.id &&
          other.email == this.email &&
          other.passwordHash == this.passwordHash &&
          other.units == this.units &&
          other.estBgEnabled == this.estBgEnabled &&
          other.createdAt == this.createdAt);
}

class UsersCompanion extends UpdateCompanion<User> {
  final Value<int> id;
  final Value<String> email;
  final Value<String> passwordHash;
  final Value<String> units;
  final Value<bool> estBgEnabled;
  final Value<DateTime> createdAt;
  const UsersCompanion({
    this.id = const Value.absent(),
    this.email = const Value.absent(),
    this.passwordHash = const Value.absent(),
    this.units = const Value.absent(),
    this.estBgEnabled = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  UsersCompanion.insert({
    this.id = const Value.absent(),
    required String email,
    required String passwordHash,
    this.units = const Value.absent(),
    this.estBgEnabled = const Value.absent(),
    required DateTime createdAt,
  })  : email = Value(email),
        passwordHash = Value(passwordHash),
        createdAt = Value(createdAt);
  static Insertable<User> custom({
    Expression<int>? id,
    Expression<String>? email,
    Expression<String>? passwordHash,
    Expression<String>? units,
    Expression<bool>? estBgEnabled,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (email != null) 'email': email,
      if (passwordHash != null) 'password_hash': passwordHash,
      if (units != null) 'units': units,
      if (estBgEnabled != null) 'est_bg_enabled': estBgEnabled,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  UsersCompanion copyWith(
      {Value<int>? id,
      Value<String>? email,
      Value<String>? passwordHash,
      Value<String>? units,
      Value<bool>? estBgEnabled,
      Value<DateTime>? createdAt}) {
    return UsersCompanion(
      id: id ?? this.id,
      email: email ?? this.email,
      passwordHash: passwordHash ?? this.passwordHash,
      units: units ?? this.units,
      estBgEnabled: estBgEnabled ?? this.estBgEnabled,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (passwordHash.present) {
      map['password_hash'] = Variable<String>(passwordHash.value);
    }
    if (units.present) {
      map['units'] = Variable<String>(units.value);
    }
    if (estBgEnabled.present) {
      map['est_bg_enabled'] = Variable<bool>(estBgEnabled.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UsersCompanion(')
          ..write('id: $id, ')
          ..write('email: $email, ')
          ..write('passwordHash: $passwordHash, ')
          ..write('units: $units, ')
          ..write('estBgEnabled: $estBgEnabled, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $DevicesTable extends Devices with TableInfo<$DevicesTable, Device> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DevicesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _deviceIdMeta =
      const VerificationMeta('deviceId');
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
      'device_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _hwRevMeta = const VerificationMeta('hwRev');
  @override
  late final GeneratedColumn<String> hwRev = GeneratedColumn<String>(
      'hw_rev', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _fwRevMeta = const VerificationMeta('fwRev');
  @override
  late final GeneratedColumn<String> fwRev = GeneratedColumn<String>(
      'fw_rev', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _nicknameMeta =
      const VerificationMeta('nickname');
  @override
  late final GeneratedColumn<String> nickname = GeneratedColumn<String>(
      'nickname', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [deviceId, hwRev, fwRev, nickname];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'devices';
  @override
  VerificationContext validateIntegrity(Insertable<Device> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('device_id')) {
      context.handle(_deviceIdMeta,
          deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta));
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('hw_rev')) {
      context.handle(
          _hwRevMeta, hwRev.isAcceptableOrUnknown(data['hw_rev']!, _hwRevMeta));
    }
    if (data.containsKey('fw_rev')) {
      context.handle(
          _fwRevMeta, fwRev.isAcceptableOrUnknown(data['fw_rev']!, _fwRevMeta));
    }
    if (data.containsKey('nickname')) {
      context.handle(_nicknameMeta,
          nickname.isAcceptableOrUnknown(data['nickname']!, _nicknameMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {deviceId};
  @override
  Device map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Device(
      deviceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}device_id'])!,
      hwRev: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}hw_rev']),
      fwRev: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}fw_rev']),
      nickname: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}nickname']),
    );
  }

  @override
  $DevicesTable createAlias(String alias) {
    return $DevicesTable(attachedDatabase, alias);
  }
}

class Device extends DataClass implements Insertable<Device> {
  final String deviceId;
  final String? hwRev;
  final String? fwRev;
  final String? nickname;
  const Device({required this.deviceId, this.hwRev, this.fwRev, this.nickname});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['device_id'] = Variable<String>(deviceId);
    if (!nullToAbsent || hwRev != null) {
      map['hw_rev'] = Variable<String>(hwRev);
    }
    if (!nullToAbsent || fwRev != null) {
      map['fw_rev'] = Variable<String>(fwRev);
    }
    if (!nullToAbsent || nickname != null) {
      map['nickname'] = Variable<String>(nickname);
    }
    return map;
  }

  DevicesCompanion toCompanion(bool nullToAbsent) {
    return DevicesCompanion(
      deviceId: Value(deviceId),
      hwRev:
          hwRev == null && nullToAbsent ? const Value.absent() : Value(hwRev),
      fwRev:
          fwRev == null && nullToAbsent ? const Value.absent() : Value(fwRev),
      nickname: nickname == null && nullToAbsent
          ? const Value.absent()
          : Value(nickname),
    );
  }

  factory Device.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Device(
      deviceId: serializer.fromJson<String>(json['deviceId']),
      hwRev: serializer.fromJson<String?>(json['hwRev']),
      fwRev: serializer.fromJson<String?>(json['fwRev']),
      nickname: serializer.fromJson<String?>(json['nickname']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'deviceId': serializer.toJson<String>(deviceId),
      'hwRev': serializer.toJson<String?>(hwRev),
      'fwRev': serializer.toJson<String?>(fwRev),
      'nickname': serializer.toJson<String?>(nickname),
    };
  }

  Device copyWith(
          {String? deviceId,
          Value<String?> hwRev = const Value.absent(),
          Value<String?> fwRev = const Value.absent(),
          Value<String?> nickname = const Value.absent()}) =>
      Device(
        deviceId: deviceId ?? this.deviceId,
        hwRev: hwRev.present ? hwRev.value : this.hwRev,
        fwRev: fwRev.present ? fwRev.value : this.fwRev,
        nickname: nickname.present ? nickname.value : this.nickname,
      );
  Device copyWithCompanion(DevicesCompanion data) {
    return Device(
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      hwRev: data.hwRev.present ? data.hwRev.value : this.hwRev,
      fwRev: data.fwRev.present ? data.fwRev.value : this.fwRev,
      nickname: data.nickname.present ? data.nickname.value : this.nickname,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Device(')
          ..write('deviceId: $deviceId, ')
          ..write('hwRev: $hwRev, ')
          ..write('fwRev: $fwRev, ')
          ..write('nickname: $nickname')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(deviceId, hwRev, fwRev, nickname);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Device &&
          other.deviceId == this.deviceId &&
          other.hwRev == this.hwRev &&
          other.fwRev == this.fwRev &&
          other.nickname == this.nickname);
}

class DevicesCompanion extends UpdateCompanion<Device> {
  final Value<String> deviceId;
  final Value<String?> hwRev;
  final Value<String?> fwRev;
  final Value<String?> nickname;
  final Value<int> rowid;
  const DevicesCompanion({
    this.deviceId = const Value.absent(),
    this.hwRev = const Value.absent(),
    this.fwRev = const Value.absent(),
    this.nickname = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DevicesCompanion.insert({
    required String deviceId,
    this.hwRev = const Value.absent(),
    this.fwRev = const Value.absent(),
    this.nickname = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : deviceId = Value(deviceId);
  static Insertable<Device> custom({
    Expression<String>? deviceId,
    Expression<String>? hwRev,
    Expression<String>? fwRev,
    Expression<String>? nickname,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (deviceId != null) 'device_id': deviceId,
      if (hwRev != null) 'hw_rev': hwRev,
      if (fwRev != null) 'fw_rev': fwRev,
      if (nickname != null) 'nickname': nickname,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DevicesCompanion copyWith(
      {Value<String>? deviceId,
      Value<String?>? hwRev,
      Value<String?>? fwRev,
      Value<String?>? nickname,
      Value<int>? rowid}) {
    return DevicesCompanion(
      deviceId: deviceId ?? this.deviceId,
      hwRev: hwRev ?? this.hwRev,
      fwRev: fwRev ?? this.fwRev,
      nickname: nickname ?? this.nickname,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (hwRev.present) {
      map['hw_rev'] = Variable<String>(hwRev.value);
    }
    if (fwRev.present) {
      map['fw_rev'] = Variable<String>(fwRev.value);
    }
    if (nickname.present) {
      map['nickname'] = Variable<String>(nickname.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DevicesCompanion(')
          ..write('deviceId: $deviceId, ')
          ..write('hwRev: $hwRev, ')
          ..write('fwRev: $fwRev, ')
          ..write('nickname: $nickname, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DeviceBindingsTable extends DeviceBindings
    with TableInfo<$DeviceBindingsTable, DeviceBinding> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DeviceBindingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<int> userId = GeneratedColumn<int>(
      'user_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _deviceIdMeta =
      const VerificationMeta('deviceId');
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
      'device_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _pairedAtMeta =
      const VerificationMeta('pairedAt');
  @override
  late final GeneratedColumn<DateTime> pairedAt = GeneratedColumn<DateTime>(
      'paired_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _lastSeenAtMeta =
      const VerificationMeta('lastSeenAt');
  @override
  late final GeneratedColumn<DateTime> lastSeenAt = GeneratedColumn<DateTime>(
      'last_seen_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _isDefaultMeta =
      const VerificationMeta('isDefault');
  @override
  late final GeneratedColumn<bool> isDefault = GeneratedColumn<bool>(
      'is_default', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_default" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns =>
      [id, userId, deviceId, pairedAt, lastSeenAt, isDefault];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'device_bindings';
  @override
  VerificationContext validateIntegrity(Insertable<DeviceBinding> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('device_id')) {
      context.handle(_deviceIdMeta,
          deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta));
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('paired_at')) {
      context.handle(_pairedAtMeta,
          pairedAt.isAcceptableOrUnknown(data['paired_at']!, _pairedAtMeta));
    } else if (isInserting) {
      context.missing(_pairedAtMeta);
    }
    if (data.containsKey('last_seen_at')) {
      context.handle(
          _lastSeenAtMeta,
          lastSeenAt.isAcceptableOrUnknown(
              data['last_seen_at']!, _lastSeenAtMeta));
    }
    if (data.containsKey('is_default')) {
      context.handle(_isDefaultMeta,
          isDefault.isAcceptableOrUnknown(data['is_default']!, _isDefaultMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DeviceBinding map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DeviceBinding(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}user_id'])!,
      deviceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}device_id'])!,
      pairedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}paired_at'])!,
      lastSeenAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}last_seen_at']),
      isDefault: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_default'])!,
    );
  }

  @override
  $DeviceBindingsTable createAlias(String alias) {
    return $DeviceBindingsTable(attachedDatabase, alias);
  }
}

class DeviceBinding extends DataClass implements Insertable<DeviceBinding> {
  final int id;
  final int userId;
  final String deviceId;
  final DateTime pairedAt;
  final DateTime? lastSeenAt;
  final bool isDefault;
  const DeviceBinding(
      {required this.id,
      required this.userId,
      required this.deviceId,
      required this.pairedAt,
      this.lastSeenAt,
      required this.isDefault});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['user_id'] = Variable<int>(userId);
    map['device_id'] = Variable<String>(deviceId);
    map['paired_at'] = Variable<DateTime>(pairedAt);
    if (!nullToAbsent || lastSeenAt != null) {
      map['last_seen_at'] = Variable<DateTime>(lastSeenAt);
    }
    map['is_default'] = Variable<bool>(isDefault);
    return map;
  }

  DeviceBindingsCompanion toCompanion(bool nullToAbsent) {
    return DeviceBindingsCompanion(
      id: Value(id),
      userId: Value(userId),
      deviceId: Value(deviceId),
      pairedAt: Value(pairedAt),
      lastSeenAt: lastSeenAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSeenAt),
      isDefault: Value(isDefault),
    );
  }

  factory DeviceBinding.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DeviceBinding(
      id: serializer.fromJson<int>(json['id']),
      userId: serializer.fromJson<int>(json['userId']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      pairedAt: serializer.fromJson<DateTime>(json['pairedAt']),
      lastSeenAt: serializer.fromJson<DateTime?>(json['lastSeenAt']),
      isDefault: serializer.fromJson<bool>(json['isDefault']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'userId': serializer.toJson<int>(userId),
      'deviceId': serializer.toJson<String>(deviceId),
      'pairedAt': serializer.toJson<DateTime>(pairedAt),
      'lastSeenAt': serializer.toJson<DateTime?>(lastSeenAt),
      'isDefault': serializer.toJson<bool>(isDefault),
    };
  }

  DeviceBinding copyWith(
          {int? id,
          int? userId,
          String? deviceId,
          DateTime? pairedAt,
          Value<DateTime?> lastSeenAt = const Value.absent(),
          bool? isDefault}) =>
      DeviceBinding(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        deviceId: deviceId ?? this.deviceId,
        pairedAt: pairedAt ?? this.pairedAt,
        lastSeenAt: lastSeenAt.present ? lastSeenAt.value : this.lastSeenAt,
        isDefault: isDefault ?? this.isDefault,
      );
  DeviceBinding copyWithCompanion(DeviceBindingsCompanion data) {
    return DeviceBinding(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      pairedAt: data.pairedAt.present ? data.pairedAt.value : this.pairedAt,
      lastSeenAt:
          data.lastSeenAt.present ? data.lastSeenAt.value : this.lastSeenAt,
      isDefault: data.isDefault.present ? data.isDefault.value : this.isDefault,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DeviceBinding(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('deviceId: $deviceId, ')
          ..write('pairedAt: $pairedAt, ')
          ..write('lastSeenAt: $lastSeenAt, ')
          ..write('isDefault: $isDefault')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, userId, deviceId, pairedAt, lastSeenAt, isDefault);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DeviceBinding &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.deviceId == this.deviceId &&
          other.pairedAt == this.pairedAt &&
          other.lastSeenAt == this.lastSeenAt &&
          other.isDefault == this.isDefault);
}

class DeviceBindingsCompanion extends UpdateCompanion<DeviceBinding> {
  final Value<int> id;
  final Value<int> userId;
  final Value<String> deviceId;
  final Value<DateTime> pairedAt;
  final Value<DateTime?> lastSeenAt;
  final Value<bool> isDefault;
  const DeviceBindingsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.pairedAt = const Value.absent(),
    this.lastSeenAt = const Value.absent(),
    this.isDefault = const Value.absent(),
  });
  DeviceBindingsCompanion.insert({
    this.id = const Value.absent(),
    required int userId,
    required String deviceId,
    required DateTime pairedAt,
    this.lastSeenAt = const Value.absent(),
    this.isDefault = const Value.absent(),
  })  : userId = Value(userId),
        deviceId = Value(deviceId),
        pairedAt = Value(pairedAt);
  static Insertable<DeviceBinding> custom({
    Expression<int>? id,
    Expression<int>? userId,
    Expression<String>? deviceId,
    Expression<DateTime>? pairedAt,
    Expression<DateTime>? lastSeenAt,
    Expression<bool>? isDefault,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (deviceId != null) 'device_id': deviceId,
      if (pairedAt != null) 'paired_at': pairedAt,
      if (lastSeenAt != null) 'last_seen_at': lastSeenAt,
      if (isDefault != null) 'is_default': isDefault,
    });
  }

  DeviceBindingsCompanion copyWith(
      {Value<int>? id,
      Value<int>? userId,
      Value<String>? deviceId,
      Value<DateTime>? pairedAt,
      Value<DateTime?>? lastSeenAt,
      Value<bool>? isDefault}) {
    return DeviceBindingsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      deviceId: deviceId ?? this.deviceId,
      pairedAt: pairedAt ?? this.pairedAt,
      lastSeenAt: lastSeenAt ?? this.lastSeenAt,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<int>(userId.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (pairedAt.present) {
      map['paired_at'] = Variable<DateTime>(pairedAt.value);
    }
    if (lastSeenAt.present) {
      map['last_seen_at'] = Variable<DateTime>(lastSeenAt.value);
    }
    if (isDefault.present) {
      map['is_default'] = Variable<bool>(isDefault.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DeviceBindingsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('deviceId: $deviceId, ')
          ..write('pairedAt: $pairedAt, ')
          ..write('lastSeenAt: $lastSeenAt, ')
          ..write('isDefault: $isDefault')
          ..write(')'))
        .toString();
  }
}

class $ReadingsTable extends Readings with TableInfo<$ReadingsTable, Reading> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReadingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<int> userId = GeneratedColumn<int>(
      'user_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _deviceIdMeta =
      const VerificationMeta('deviceId');
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
      'device_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _takenAtMeta =
      const VerificationMeta('takenAt');
  @override
  late final GeneratedColumn<DateTime> takenAt = GeneratedColumn<DateTime>(
      'taken_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _sampleStatusMeta =
      const VerificationMeta('sampleStatus');
  @override
  late final GeneratedColumn<String> sampleStatus = GeneratedColumn<String>(
      'sample_status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _contactDurationMsMeta =
      const VerificationMeta('contactDurationMs');
  @override
  late final GeneratedColumn<int> contactDurationMs = GeneratedColumn<int>(
      'contact_duration_ms', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _qcStatusMeta =
      const VerificationMeta('qcStatus');
  @override
  late final GeneratedColumn<String> qcStatus = GeneratedColumn<String>(
      'qc_status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _invalidReasonMeta =
      const VerificationMeta('invalidReason');
  @override
  late final GeneratedColumn<String> invalidReason = GeneratedColumn<String>(
      'invalid_reason', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _modelVersionMeta =
      const VerificationMeta('modelVersion');
  @override
  late final GeneratedColumn<String> modelVersion = GeneratedColumn<String>(
      'model_version', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _rawPackageRefMeta =
      const VerificationMeta('rawPackageRef');
  @override
  late final GeneratedColumn<String> rawPackageRef = GeneratedColumn<String>(
      'raw_package_ref', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        userId,
        deviceId,
        takenAt,
        sampleStatus,
        contactDurationMs,
        qcStatus,
        invalidReason,
        modelVersion,
        rawPackageRef
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'readings';
  @override
  VerificationContext validateIntegrity(Insertable<Reading> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('device_id')) {
      context.handle(_deviceIdMeta,
          deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta));
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('taken_at')) {
      context.handle(_takenAtMeta,
          takenAt.isAcceptableOrUnknown(data['taken_at']!, _takenAtMeta));
    } else if (isInserting) {
      context.missing(_takenAtMeta);
    }
    if (data.containsKey('sample_status')) {
      context.handle(
          _sampleStatusMeta,
          sampleStatus.isAcceptableOrUnknown(
              data['sample_status']!, _sampleStatusMeta));
    } else if (isInserting) {
      context.missing(_sampleStatusMeta);
    }
    if (data.containsKey('contact_duration_ms')) {
      context.handle(
          _contactDurationMsMeta,
          contactDurationMs.isAcceptableOrUnknown(
              data['contact_duration_ms']!, _contactDurationMsMeta));
    }
    if (data.containsKey('qc_status')) {
      context.handle(_qcStatusMeta,
          qcStatus.isAcceptableOrUnknown(data['qc_status']!, _qcStatusMeta));
    } else if (isInserting) {
      context.missing(_qcStatusMeta);
    }
    if (data.containsKey('invalid_reason')) {
      context.handle(
          _invalidReasonMeta,
          invalidReason.isAcceptableOrUnknown(
              data['invalid_reason']!, _invalidReasonMeta));
    }
    if (data.containsKey('model_version')) {
      context.handle(
          _modelVersionMeta,
          modelVersion.isAcceptableOrUnknown(
              data['model_version']!, _modelVersionMeta));
    } else if (isInserting) {
      context.missing(_modelVersionMeta);
    }
    if (data.containsKey('raw_package_ref')) {
      context.handle(
          _rawPackageRefMeta,
          rawPackageRef.isAcceptableOrUnknown(
              data['raw_package_ref']!, _rawPackageRefMeta));
    } else if (isInserting) {
      context.missing(_rawPackageRefMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Reading map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Reading(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}user_id'])!,
      deviceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}device_id'])!,
      takenAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}taken_at'])!,
      sampleStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sample_status'])!,
      contactDurationMs: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}contact_duration_ms']),
      qcStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}qc_status'])!,
      invalidReason: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}invalid_reason']),
      modelVersion: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}model_version'])!,
      rawPackageRef: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}raw_package_ref'])!,
    );
  }

  @override
  $ReadingsTable createAlias(String alias) {
    return $ReadingsTable(attachedDatabase, alias);
  }
}

class Reading extends DataClass implements Insertable<Reading> {
  final int id;
  final int userId;
  final String deviceId;
  final DateTime takenAt;
  final String sampleStatus;
  final int? contactDurationMs;
  final String qcStatus;
  final String? invalidReason;
  final String modelVersion;
  final String rawPackageRef;
  const Reading(
      {required this.id,
      required this.userId,
      required this.deviceId,
      required this.takenAt,
      required this.sampleStatus,
      this.contactDurationMs,
      required this.qcStatus,
      this.invalidReason,
      required this.modelVersion,
      required this.rawPackageRef});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['user_id'] = Variable<int>(userId);
    map['device_id'] = Variable<String>(deviceId);
    map['taken_at'] = Variable<DateTime>(takenAt);
    map['sample_status'] = Variable<String>(sampleStatus);
    if (!nullToAbsent || contactDurationMs != null) {
      map['contact_duration_ms'] = Variable<int>(contactDurationMs);
    }
    map['qc_status'] = Variable<String>(qcStatus);
    if (!nullToAbsent || invalidReason != null) {
      map['invalid_reason'] = Variable<String>(invalidReason);
    }
    map['model_version'] = Variable<String>(modelVersion);
    map['raw_package_ref'] = Variable<String>(rawPackageRef);
    return map;
  }

  ReadingsCompanion toCompanion(bool nullToAbsent) {
    return ReadingsCompanion(
      id: Value(id),
      userId: Value(userId),
      deviceId: Value(deviceId),
      takenAt: Value(takenAt),
      sampleStatus: Value(sampleStatus),
      contactDurationMs: contactDurationMs == null && nullToAbsent
          ? const Value.absent()
          : Value(contactDurationMs),
      qcStatus: Value(qcStatus),
      invalidReason: invalidReason == null && nullToAbsent
          ? const Value.absent()
          : Value(invalidReason),
      modelVersion: Value(modelVersion),
      rawPackageRef: Value(rawPackageRef),
    );
  }

  factory Reading.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Reading(
      id: serializer.fromJson<int>(json['id']),
      userId: serializer.fromJson<int>(json['userId']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      takenAt: serializer.fromJson<DateTime>(json['takenAt']),
      sampleStatus: serializer.fromJson<String>(json['sampleStatus']),
      contactDurationMs: serializer.fromJson<int?>(json['contactDurationMs']),
      qcStatus: serializer.fromJson<String>(json['qcStatus']),
      invalidReason: serializer.fromJson<String?>(json['invalidReason']),
      modelVersion: serializer.fromJson<String>(json['modelVersion']),
      rawPackageRef: serializer.fromJson<String>(json['rawPackageRef']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'userId': serializer.toJson<int>(userId),
      'deviceId': serializer.toJson<String>(deviceId),
      'takenAt': serializer.toJson<DateTime>(takenAt),
      'sampleStatus': serializer.toJson<String>(sampleStatus),
      'contactDurationMs': serializer.toJson<int?>(contactDurationMs),
      'qcStatus': serializer.toJson<String>(qcStatus),
      'invalidReason': serializer.toJson<String?>(invalidReason),
      'modelVersion': serializer.toJson<String>(modelVersion),
      'rawPackageRef': serializer.toJson<String>(rawPackageRef),
    };
  }

  Reading copyWith(
          {int? id,
          int? userId,
          String? deviceId,
          DateTime? takenAt,
          String? sampleStatus,
          Value<int?> contactDurationMs = const Value.absent(),
          String? qcStatus,
          Value<String?> invalidReason = const Value.absent(),
          String? modelVersion,
          String? rawPackageRef}) =>
      Reading(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        deviceId: deviceId ?? this.deviceId,
        takenAt: takenAt ?? this.takenAt,
        sampleStatus: sampleStatus ?? this.sampleStatus,
        contactDurationMs: contactDurationMs.present
            ? contactDurationMs.value
            : this.contactDurationMs,
        qcStatus: qcStatus ?? this.qcStatus,
        invalidReason:
            invalidReason.present ? invalidReason.value : this.invalidReason,
        modelVersion: modelVersion ?? this.modelVersion,
        rawPackageRef: rawPackageRef ?? this.rawPackageRef,
      );
  Reading copyWithCompanion(ReadingsCompanion data) {
    return Reading(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      takenAt: data.takenAt.present ? data.takenAt.value : this.takenAt,
      sampleStatus: data.sampleStatus.present
          ? data.sampleStatus.value
          : this.sampleStatus,
      contactDurationMs: data.contactDurationMs.present
          ? data.contactDurationMs.value
          : this.contactDurationMs,
      qcStatus: data.qcStatus.present ? data.qcStatus.value : this.qcStatus,
      invalidReason: data.invalidReason.present
          ? data.invalidReason.value
          : this.invalidReason,
      modelVersion: data.modelVersion.present
          ? data.modelVersion.value
          : this.modelVersion,
      rawPackageRef: data.rawPackageRef.present
          ? data.rawPackageRef.value
          : this.rawPackageRef,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Reading(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('deviceId: $deviceId, ')
          ..write('takenAt: $takenAt, ')
          ..write('sampleStatus: $sampleStatus, ')
          ..write('contactDurationMs: $contactDurationMs, ')
          ..write('qcStatus: $qcStatus, ')
          ..write('invalidReason: $invalidReason, ')
          ..write('modelVersion: $modelVersion, ')
          ..write('rawPackageRef: $rawPackageRef')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, userId, deviceId, takenAt, sampleStatus,
      contactDurationMs, qcStatus, invalidReason, modelVersion, rawPackageRef);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Reading &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.deviceId == this.deviceId &&
          other.takenAt == this.takenAt &&
          other.sampleStatus == this.sampleStatus &&
          other.contactDurationMs == this.contactDurationMs &&
          other.qcStatus == this.qcStatus &&
          other.invalidReason == this.invalidReason &&
          other.modelVersion == this.modelVersion &&
          other.rawPackageRef == this.rawPackageRef);
}

class ReadingsCompanion extends UpdateCompanion<Reading> {
  final Value<int> id;
  final Value<int> userId;
  final Value<String> deviceId;
  final Value<DateTime> takenAt;
  final Value<String> sampleStatus;
  final Value<int?> contactDurationMs;
  final Value<String> qcStatus;
  final Value<String?> invalidReason;
  final Value<String> modelVersion;
  final Value<String> rawPackageRef;
  const ReadingsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.takenAt = const Value.absent(),
    this.sampleStatus = const Value.absent(),
    this.contactDurationMs = const Value.absent(),
    this.qcStatus = const Value.absent(),
    this.invalidReason = const Value.absent(),
    this.modelVersion = const Value.absent(),
    this.rawPackageRef = const Value.absent(),
  });
  ReadingsCompanion.insert({
    this.id = const Value.absent(),
    required int userId,
    required String deviceId,
    required DateTime takenAt,
    required String sampleStatus,
    this.contactDurationMs = const Value.absent(),
    required String qcStatus,
    this.invalidReason = const Value.absent(),
    required String modelVersion,
    required String rawPackageRef,
  })  : userId = Value(userId),
        deviceId = Value(deviceId),
        takenAt = Value(takenAt),
        sampleStatus = Value(sampleStatus),
        qcStatus = Value(qcStatus),
        modelVersion = Value(modelVersion),
        rawPackageRef = Value(rawPackageRef);
  static Insertable<Reading> custom({
    Expression<int>? id,
    Expression<int>? userId,
    Expression<String>? deviceId,
    Expression<DateTime>? takenAt,
    Expression<String>? sampleStatus,
    Expression<int>? contactDurationMs,
    Expression<String>? qcStatus,
    Expression<String>? invalidReason,
    Expression<String>? modelVersion,
    Expression<String>? rawPackageRef,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (deviceId != null) 'device_id': deviceId,
      if (takenAt != null) 'taken_at': takenAt,
      if (sampleStatus != null) 'sample_status': sampleStatus,
      if (contactDurationMs != null) 'contact_duration_ms': contactDurationMs,
      if (qcStatus != null) 'qc_status': qcStatus,
      if (invalidReason != null) 'invalid_reason': invalidReason,
      if (modelVersion != null) 'model_version': modelVersion,
      if (rawPackageRef != null) 'raw_package_ref': rawPackageRef,
    });
  }

  ReadingsCompanion copyWith(
      {Value<int>? id,
      Value<int>? userId,
      Value<String>? deviceId,
      Value<DateTime>? takenAt,
      Value<String>? sampleStatus,
      Value<int?>? contactDurationMs,
      Value<String>? qcStatus,
      Value<String?>? invalidReason,
      Value<String>? modelVersion,
      Value<String>? rawPackageRef}) {
    return ReadingsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      deviceId: deviceId ?? this.deviceId,
      takenAt: takenAt ?? this.takenAt,
      sampleStatus: sampleStatus ?? this.sampleStatus,
      contactDurationMs: contactDurationMs ?? this.contactDurationMs,
      qcStatus: qcStatus ?? this.qcStatus,
      invalidReason: invalidReason ?? this.invalidReason,
      modelVersion: modelVersion ?? this.modelVersion,
      rawPackageRef: rawPackageRef ?? this.rawPackageRef,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<int>(userId.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (takenAt.present) {
      map['taken_at'] = Variable<DateTime>(takenAt.value);
    }
    if (sampleStatus.present) {
      map['sample_status'] = Variable<String>(sampleStatus.value);
    }
    if (contactDurationMs.present) {
      map['contact_duration_ms'] = Variable<int>(contactDurationMs.value);
    }
    if (qcStatus.present) {
      map['qc_status'] = Variable<String>(qcStatus.value);
    }
    if (invalidReason.present) {
      map['invalid_reason'] = Variable<String>(invalidReason.value);
    }
    if (modelVersion.present) {
      map['model_version'] = Variable<String>(modelVersion.value);
    }
    if (rawPackageRef.present) {
      map['raw_package_ref'] = Variable<String>(rawPackageRef.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReadingsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('deviceId: $deviceId, ')
          ..write('takenAt: $takenAt, ')
          ..write('sampleStatus: $sampleStatus, ')
          ..write('contactDurationMs: $contactDurationMs, ')
          ..write('qcStatus: $qcStatus, ')
          ..write('invalidReason: $invalidReason, ')
          ..write('modelVersion: $modelVersion, ')
          ..write('rawPackageRef: $rawPackageRef')
          ..write(')'))
        .toString();
  }
}

class $AnalytesTable extends Analytes with TableInfo<$AnalytesTable, Analyte> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AnalytesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
      'code', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _defaultUnitMeta =
      const VerificationMeta('defaultUnit');
  @override
  late final GeneratedColumn<String> defaultUnit = GeneratedColumn<String>(
      'default_unit', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, code, name, defaultUnit];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'analytes';
  @override
  VerificationContext validateIntegrity(Insertable<Analyte> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('code')) {
      context.handle(
          _codeMeta, code.isAcceptableOrUnknown(data['code']!, _codeMeta));
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('default_unit')) {
      context.handle(
          _defaultUnitMeta,
          defaultUnit.isAcceptableOrUnknown(
              data['default_unit']!, _defaultUnitMeta));
    } else if (isInserting) {
      context.missing(_defaultUnitMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Analyte map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Analyte(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      code: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}code'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      defaultUnit: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}default_unit'])!,
    );
  }

  @override
  $AnalytesTable createAlias(String alias) {
    return $AnalytesTable(attachedDatabase, alias);
  }
}

class Analyte extends DataClass implements Insertable<Analyte> {
  final int id;
  final String code;
  final String name;
  final String defaultUnit;
  const Analyte(
      {required this.id,
      required this.code,
      required this.name,
      required this.defaultUnit});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['code'] = Variable<String>(code);
    map['name'] = Variable<String>(name);
    map['default_unit'] = Variable<String>(defaultUnit);
    return map;
  }

  AnalytesCompanion toCompanion(bool nullToAbsent) {
    return AnalytesCompanion(
      id: Value(id),
      code: Value(code),
      name: Value(name),
      defaultUnit: Value(defaultUnit),
    );
  }

  factory Analyte.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Analyte(
      id: serializer.fromJson<int>(json['id']),
      code: serializer.fromJson<String>(json['code']),
      name: serializer.fromJson<String>(json['name']),
      defaultUnit: serializer.fromJson<String>(json['defaultUnit']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'code': serializer.toJson<String>(code),
      'name': serializer.toJson<String>(name),
      'defaultUnit': serializer.toJson<String>(defaultUnit),
    };
  }

  Analyte copyWith(
          {int? id, String? code, String? name, String? defaultUnit}) =>
      Analyte(
        id: id ?? this.id,
        code: code ?? this.code,
        name: name ?? this.name,
        defaultUnit: defaultUnit ?? this.defaultUnit,
      );
  Analyte copyWithCompanion(AnalytesCompanion data) {
    return Analyte(
      id: data.id.present ? data.id.value : this.id,
      code: data.code.present ? data.code.value : this.code,
      name: data.name.present ? data.name.value : this.name,
      defaultUnit:
          data.defaultUnit.present ? data.defaultUnit.value : this.defaultUnit,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Analyte(')
          ..write('id: $id, ')
          ..write('code: $code, ')
          ..write('name: $name, ')
          ..write('defaultUnit: $defaultUnit')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, code, name, defaultUnit);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Analyte &&
          other.id == this.id &&
          other.code == this.code &&
          other.name == this.name &&
          other.defaultUnit == this.defaultUnit);
}

class AnalytesCompanion extends UpdateCompanion<Analyte> {
  final Value<int> id;
  final Value<String> code;
  final Value<String> name;
  final Value<String> defaultUnit;
  const AnalytesCompanion({
    this.id = const Value.absent(),
    this.code = const Value.absent(),
    this.name = const Value.absent(),
    this.defaultUnit = const Value.absent(),
  });
  AnalytesCompanion.insert({
    this.id = const Value.absent(),
    required String code,
    required String name,
    required String defaultUnit,
  })  : code = Value(code),
        name = Value(name),
        defaultUnit = Value(defaultUnit);
  static Insertable<Analyte> custom({
    Expression<int>? id,
    Expression<String>? code,
    Expression<String>? name,
    Expression<String>? defaultUnit,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (code != null) 'code': code,
      if (name != null) 'name': name,
      if (defaultUnit != null) 'default_unit': defaultUnit,
    });
  }

  AnalytesCompanion copyWith(
      {Value<int>? id,
      Value<String>? code,
      Value<String>? name,
      Value<String>? defaultUnit}) {
    return AnalytesCompanion(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      defaultUnit: defaultUnit ?? this.defaultUnit,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (defaultUnit.present) {
      map['default_unit'] = Variable<String>(defaultUnit.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AnalytesCompanion(')
          ..write('id: $id, ')
          ..write('code: $code, ')
          ..write('name: $name, ')
          ..write('defaultUnit: $defaultUnit')
          ..write(')'))
        .toString();
  }
}

class $ReadingAnalytesTable extends ReadingAnalytes
    with TableInfo<$ReadingAnalytesTable, ReadingAnalyte> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReadingAnalytesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<int> userId = GeneratedColumn<int>(
      'user_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _readingIdMeta =
      const VerificationMeta('readingId');
  @override
  late final GeneratedColumn<int> readingId = GeneratedColumn<int>(
      'reading_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _analyteIdMeta =
      const VerificationMeta('analyteId');
  @override
  late final GeneratedColumn<int> analyteId = GeneratedColumn<int>(
      'analyte_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<double> value = GeneratedColumn<double>(
      'value', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
      'unit', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _estimatedBgMeta =
      const VerificationMeta('estimatedBg');
  @override
  late final GeneratedColumn<double> estimatedBg = GeneratedColumn<double>(
      'estimated_bg', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, userId, readingId, analyteId, value, unit, estimatedBg];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reading_analytes';
  @override
  VerificationContext validateIntegrity(Insertable<ReadingAnalyte> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('reading_id')) {
      context.handle(_readingIdMeta,
          readingId.isAcceptableOrUnknown(data['reading_id']!, _readingIdMeta));
    } else if (isInserting) {
      context.missing(_readingIdMeta);
    }
    if (data.containsKey('analyte_id')) {
      context.handle(_analyteIdMeta,
          analyteId.isAcceptableOrUnknown(data['analyte_id']!, _analyteIdMeta));
    } else if (isInserting) {
      context.missing(_analyteIdMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
          _valueMeta, value.isAcceptableOrUnknown(data['value']!, _valueMeta));
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('unit')) {
      context.handle(
          _unitMeta, unit.isAcceptableOrUnknown(data['unit']!, _unitMeta));
    } else if (isInserting) {
      context.missing(_unitMeta);
    }
    if (data.containsKey('estimated_bg')) {
      context.handle(
          _estimatedBgMeta,
          estimatedBg.isAcceptableOrUnknown(
              data['estimated_bg']!, _estimatedBgMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReadingAnalyte map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReadingAnalyte(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}user_id'])!,
      readingId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}reading_id'])!,
      analyteId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}analyte_id'])!,
      value: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}value'])!,
      unit: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}unit'])!,
      estimatedBg: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}estimated_bg']),
    );
  }

  @override
  $ReadingAnalytesTable createAlias(String alias) {
    return $ReadingAnalytesTable(attachedDatabase, alias);
  }
}

class ReadingAnalyte extends DataClass implements Insertable<ReadingAnalyte> {
  final int id;

  /// Per-user data: required even though it can be inferred via readingId.
  final int userId;
  final int readingId;
  final int analyteId;
  final double value;
  final String unit;
  final double? estimatedBg;
  const ReadingAnalyte(
      {required this.id,
      required this.userId,
      required this.readingId,
      required this.analyteId,
      required this.value,
      required this.unit,
      this.estimatedBg});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['user_id'] = Variable<int>(userId);
    map['reading_id'] = Variable<int>(readingId);
    map['analyte_id'] = Variable<int>(analyteId);
    map['value'] = Variable<double>(value);
    map['unit'] = Variable<String>(unit);
    if (!nullToAbsent || estimatedBg != null) {
      map['estimated_bg'] = Variable<double>(estimatedBg);
    }
    return map;
  }

  ReadingAnalytesCompanion toCompanion(bool nullToAbsent) {
    return ReadingAnalytesCompanion(
      id: Value(id),
      userId: Value(userId),
      readingId: Value(readingId),
      analyteId: Value(analyteId),
      value: Value(value),
      unit: Value(unit),
      estimatedBg: estimatedBg == null && nullToAbsent
          ? const Value.absent()
          : Value(estimatedBg),
    );
  }

  factory ReadingAnalyte.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReadingAnalyte(
      id: serializer.fromJson<int>(json['id']),
      userId: serializer.fromJson<int>(json['userId']),
      readingId: serializer.fromJson<int>(json['readingId']),
      analyteId: serializer.fromJson<int>(json['analyteId']),
      value: serializer.fromJson<double>(json['value']),
      unit: serializer.fromJson<String>(json['unit']),
      estimatedBg: serializer.fromJson<double?>(json['estimatedBg']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'userId': serializer.toJson<int>(userId),
      'readingId': serializer.toJson<int>(readingId),
      'analyteId': serializer.toJson<int>(analyteId),
      'value': serializer.toJson<double>(value),
      'unit': serializer.toJson<String>(unit),
      'estimatedBg': serializer.toJson<double?>(estimatedBg),
    };
  }

  ReadingAnalyte copyWith(
          {int? id,
          int? userId,
          int? readingId,
          int? analyteId,
          double? value,
          String? unit,
          Value<double?> estimatedBg = const Value.absent()}) =>
      ReadingAnalyte(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        readingId: readingId ?? this.readingId,
        analyteId: analyteId ?? this.analyteId,
        value: value ?? this.value,
        unit: unit ?? this.unit,
        estimatedBg: estimatedBg.present ? estimatedBg.value : this.estimatedBg,
      );
  ReadingAnalyte copyWithCompanion(ReadingAnalytesCompanion data) {
    return ReadingAnalyte(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      readingId: data.readingId.present ? data.readingId.value : this.readingId,
      analyteId: data.analyteId.present ? data.analyteId.value : this.analyteId,
      value: data.value.present ? data.value.value : this.value,
      unit: data.unit.present ? data.unit.value : this.unit,
      estimatedBg:
          data.estimatedBg.present ? data.estimatedBg.value : this.estimatedBg,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReadingAnalyte(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('readingId: $readingId, ')
          ..write('analyteId: $analyteId, ')
          ..write('value: $value, ')
          ..write('unit: $unit, ')
          ..write('estimatedBg: $estimatedBg')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, userId, readingId, analyteId, value, unit, estimatedBg);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReadingAnalyte &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.readingId == this.readingId &&
          other.analyteId == this.analyteId &&
          other.value == this.value &&
          other.unit == this.unit &&
          other.estimatedBg == this.estimatedBg);
}

class ReadingAnalytesCompanion extends UpdateCompanion<ReadingAnalyte> {
  final Value<int> id;
  final Value<int> userId;
  final Value<int> readingId;
  final Value<int> analyteId;
  final Value<double> value;
  final Value<String> unit;
  final Value<double?> estimatedBg;
  const ReadingAnalytesCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.readingId = const Value.absent(),
    this.analyteId = const Value.absent(),
    this.value = const Value.absent(),
    this.unit = const Value.absent(),
    this.estimatedBg = const Value.absent(),
  });
  ReadingAnalytesCompanion.insert({
    this.id = const Value.absent(),
    required int userId,
    required int readingId,
    required int analyteId,
    required double value,
    required String unit,
    this.estimatedBg = const Value.absent(),
  })  : userId = Value(userId),
        readingId = Value(readingId),
        analyteId = Value(analyteId),
        value = Value(value),
        unit = Value(unit);
  static Insertable<ReadingAnalyte> custom({
    Expression<int>? id,
    Expression<int>? userId,
    Expression<int>? readingId,
    Expression<int>? analyteId,
    Expression<double>? value,
    Expression<String>? unit,
    Expression<double>? estimatedBg,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (readingId != null) 'reading_id': readingId,
      if (analyteId != null) 'analyte_id': analyteId,
      if (value != null) 'value': value,
      if (unit != null) 'unit': unit,
      if (estimatedBg != null) 'estimated_bg': estimatedBg,
    });
  }

  ReadingAnalytesCompanion copyWith(
      {Value<int>? id,
      Value<int>? userId,
      Value<int>? readingId,
      Value<int>? analyteId,
      Value<double>? value,
      Value<String>? unit,
      Value<double?>? estimatedBg}) {
    return ReadingAnalytesCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      readingId: readingId ?? this.readingId,
      analyteId: analyteId ?? this.analyteId,
      value: value ?? this.value,
      unit: unit ?? this.unit,
      estimatedBg: estimatedBg ?? this.estimatedBg,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<int>(userId.value);
    }
    if (readingId.present) {
      map['reading_id'] = Variable<int>(readingId.value);
    }
    if (analyteId.present) {
      map['analyte_id'] = Variable<int>(analyteId.value);
    }
    if (value.present) {
      map['value'] = Variable<double>(value.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (estimatedBg.present) {
      map['estimated_bg'] = Variable<double>(estimatedBg.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReadingAnalytesCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('readingId: $readingId, ')
          ..write('analyteId: $analyteId, ')
          ..write('value: $value, ')
          ..write('unit: $unit, ')
          ..write('estimatedBg: $estimatedBg')
          ..write(')'))
        .toString();
  }
}

class $NotesTable extends Notes with TableInfo<$NotesTable, Note> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NotesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<int> userId = GeneratedColumn<int>(
      'user_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _readingIdMeta =
      const VerificationMeta('readingId');
  @override
  late final GeneratedColumn<int> readingId = GeneratedColumn<int>(
      'reading_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _contentMeta =
      const VerificationMeta('content');
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
      'content', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, userId, readingId, content, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'notes';
  @override
  VerificationContext validateIntegrity(Insertable<Note> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('reading_id')) {
      context.handle(_readingIdMeta,
          readingId.isAcceptableOrUnknown(data['reading_id']!, _readingIdMeta));
    } else if (isInserting) {
      context.missing(_readingIdMeta);
    }
    if (data.containsKey('content')) {
      context.handle(_contentMeta,
          content.isAcceptableOrUnknown(data['content']!, _contentMeta));
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Note map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Note(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}user_id'])!,
      readingId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}reading_id'])!,
      content: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}content'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $NotesTable createAlias(String alias) {
    return $NotesTable(attachedDatabase, alias);
  }
}

class Note extends DataClass implements Insertable<Note> {
  final int id;

  /// Per-user data: required even though it can be inferred via readingId.
  final int userId;
  final int readingId;
  final String content;
  final DateTime createdAt;
  const Note(
      {required this.id,
      required this.userId,
      required this.readingId,
      required this.content,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['user_id'] = Variable<int>(userId);
    map['reading_id'] = Variable<int>(readingId);
    map['content'] = Variable<String>(content);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  NotesCompanion toCompanion(bool nullToAbsent) {
    return NotesCompanion(
      id: Value(id),
      userId: Value(userId),
      readingId: Value(readingId),
      content: Value(content),
      createdAt: Value(createdAt),
    );
  }

  factory Note.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Note(
      id: serializer.fromJson<int>(json['id']),
      userId: serializer.fromJson<int>(json['userId']),
      readingId: serializer.fromJson<int>(json['readingId']),
      content: serializer.fromJson<String>(json['content']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'userId': serializer.toJson<int>(userId),
      'readingId': serializer.toJson<int>(readingId),
      'content': serializer.toJson<String>(content),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Note copyWith(
          {int? id,
          int? userId,
          int? readingId,
          String? content,
          DateTime? createdAt}) =>
      Note(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        readingId: readingId ?? this.readingId,
        content: content ?? this.content,
        createdAt: createdAt ?? this.createdAt,
      );
  Note copyWithCompanion(NotesCompanion data) {
    return Note(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      readingId: data.readingId.present ? data.readingId.value : this.readingId,
      content: data.content.present ? data.content.value : this.content,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Note(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('readingId: $readingId, ')
          ..write('content: $content, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, userId, readingId, content, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Note &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.readingId == this.readingId &&
          other.content == this.content &&
          other.createdAt == this.createdAt);
}

class NotesCompanion extends UpdateCompanion<Note> {
  final Value<int> id;
  final Value<int> userId;
  final Value<int> readingId;
  final Value<String> content;
  final Value<DateTime> createdAt;
  const NotesCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.readingId = const Value.absent(),
    this.content = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  NotesCompanion.insert({
    this.id = const Value.absent(),
    required int userId,
    required int readingId,
    required String content,
    required DateTime createdAt,
  })  : userId = Value(userId),
        readingId = Value(readingId),
        content = Value(content),
        createdAt = Value(createdAt);
  static Insertable<Note> custom({
    Expression<int>? id,
    Expression<int>? userId,
    Expression<int>? readingId,
    Expression<String>? content,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (readingId != null) 'reading_id': readingId,
      if (content != null) 'content': content,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  NotesCompanion copyWith(
      {Value<int>? id,
      Value<int>? userId,
      Value<int>? readingId,
      Value<String>? content,
      Value<DateTime>? createdAt}) {
    return NotesCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      readingId: readingId ?? this.readingId,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<int>(userId.value);
    }
    if (readingId.present) {
      map['reading_id'] = Variable<int>(readingId.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NotesCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('readingId: $readingId, ')
          ..write('content: $content, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $ExportsTable extends Exports with TableInfo<$ExportsTable, Export> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExportsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<int> userId = GeneratedColumn<int>(
      'user_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _fileUriMeta =
      const VerificationMeta('fileUri');
  @override
  late final GeneratedColumn<String> fileUri = GeneratedColumn<String>(
      'file_uri', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, userId, type, fileUri, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'exports';
  @override
  VerificationContext validateIntegrity(Insertable<Export> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('file_uri')) {
      context.handle(_fileUriMeta,
          fileUri.isAcceptableOrUnknown(data['file_uri']!, _fileUriMeta));
    } else if (isInserting) {
      context.missing(_fileUriMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Export map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Export(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}user_id'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      fileUri: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}file_uri'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $ExportsTable createAlias(String alias) {
    return $ExportsTable(attachedDatabase, alias);
  }
}

class Export extends DataClass implements Insertable<Export> {
  final int id;
  final int userId;
  final String type;
  final String fileUri;
  final DateTime createdAt;
  const Export(
      {required this.id,
      required this.userId,
      required this.type,
      required this.fileUri,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['user_id'] = Variable<int>(userId);
    map['type'] = Variable<String>(type);
    map['file_uri'] = Variable<String>(fileUri);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ExportsCompanion toCompanion(bool nullToAbsent) {
    return ExportsCompanion(
      id: Value(id),
      userId: Value(userId),
      type: Value(type),
      fileUri: Value(fileUri),
      createdAt: Value(createdAt),
    );
  }

  factory Export.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Export(
      id: serializer.fromJson<int>(json['id']),
      userId: serializer.fromJson<int>(json['userId']),
      type: serializer.fromJson<String>(json['type']),
      fileUri: serializer.fromJson<String>(json['fileUri']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'userId': serializer.toJson<int>(userId),
      'type': serializer.toJson<String>(type),
      'fileUri': serializer.toJson<String>(fileUri),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Export copyWith(
          {int? id,
          int? userId,
          String? type,
          String? fileUri,
          DateTime? createdAt}) =>
      Export(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        type: type ?? this.type,
        fileUri: fileUri ?? this.fileUri,
        createdAt: createdAt ?? this.createdAt,
      );
  Export copyWithCompanion(ExportsCompanion data) {
    return Export(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      type: data.type.present ? data.type.value : this.type,
      fileUri: data.fileUri.present ? data.fileUri.value : this.fileUri,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Export(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('type: $type, ')
          ..write('fileUri: $fileUri, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, userId, type, fileUri, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Export &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.type == this.type &&
          other.fileUri == this.fileUri &&
          other.createdAt == this.createdAt);
}

class ExportsCompanion extends UpdateCompanion<Export> {
  final Value<int> id;
  final Value<int> userId;
  final Value<String> type;
  final Value<String> fileUri;
  final Value<DateTime> createdAt;
  const ExportsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.type = const Value.absent(),
    this.fileUri = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  ExportsCompanion.insert({
    this.id = const Value.absent(),
    required int userId,
    required String type,
    required String fileUri,
    required DateTime createdAt,
  })  : userId = Value(userId),
        type = Value(type),
        fileUri = Value(fileUri),
        createdAt = Value(createdAt);
  static Insertable<Export> custom({
    Expression<int>? id,
    Expression<int>? userId,
    Expression<String>? type,
    Expression<String>? fileUri,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (type != null) 'type': type,
      if (fileUri != null) 'file_uri': fileUri,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  ExportsCompanion copyWith(
      {Value<int>? id,
      Value<int>? userId,
      Value<String>? type,
      Value<String>? fileUri,
      Value<DateTime>? createdAt}) {
    return ExportsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      fileUri: fileUri ?? this.fileUri,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<int>(userId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (fileUri.present) {
      map['file_uri'] = Variable<String>(fileUri.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExportsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('type: $type, ')
          ..write('fileUri: $fileUri, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $ChatMessagesTable extends ChatMessages
    with TableInfo<$ChatMessagesTable, ChatMessage> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChatMessagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<int> userId = GeneratedColumn<int>(
      'user_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _readingIdMeta =
      const VerificationMeta('readingId');
  @override
  late final GeneratedColumn<int> readingId = GeneratedColumn<int>(
      'reading_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
      'role', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _textBodyMeta =
      const VerificationMeta('textBody');
  @override
  late final GeneratedColumn<String> textBody = GeneratedColumn<String>(
      'text', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, userId, readingId, role, textBody, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'chat_messages';
  @override
  VerificationContext validateIntegrity(Insertable<ChatMessage> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('reading_id')) {
      context.handle(_readingIdMeta,
          readingId.isAcceptableOrUnknown(data['reading_id']!, _readingIdMeta));
    }
    if (data.containsKey('role')) {
      context.handle(
          _roleMeta, role.isAcceptableOrUnknown(data['role']!, _roleMeta));
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('text')) {
      context.handle(_textBodyMeta,
          textBody.isAcceptableOrUnknown(data['text']!, _textBodyMeta));
    } else if (isInserting) {
      context.missing(_textBodyMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ChatMessage map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChatMessage(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}user_id'])!,
      readingId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}reading_id']),
      role: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}role'])!,
      textBody: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}text'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $ChatMessagesTable createAlias(String alias) {
    return $ChatMessagesTable(attachedDatabase, alias);
  }
}

class ChatMessage extends DataClass implements Insertable<ChatMessage> {
  final int id;
  final int userId;
  final int? readingId;
  final String role;
  final String textBody;
  final DateTime createdAt;
  const ChatMessage(
      {required this.id,
      required this.userId,
      this.readingId,
      required this.role,
      required this.textBody,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['user_id'] = Variable<int>(userId);
    if (!nullToAbsent || readingId != null) {
      map['reading_id'] = Variable<int>(readingId);
    }
    map['role'] = Variable<String>(role);
    map['text'] = Variable<String>(textBody);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ChatMessagesCompanion toCompanion(bool nullToAbsent) {
    return ChatMessagesCompanion(
      id: Value(id),
      userId: Value(userId),
      readingId: readingId == null && nullToAbsent
          ? const Value.absent()
          : Value(readingId),
      role: Value(role),
      textBody: Value(textBody),
      createdAt: Value(createdAt),
    );
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChatMessage(
      id: serializer.fromJson<int>(json['id']),
      userId: serializer.fromJson<int>(json['userId']),
      readingId: serializer.fromJson<int?>(json['readingId']),
      role: serializer.fromJson<String>(json['role']),
      textBody: serializer.fromJson<String>(json['textBody']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'userId': serializer.toJson<int>(userId),
      'readingId': serializer.toJson<int?>(readingId),
      'role': serializer.toJson<String>(role),
      'textBody': serializer.toJson<String>(textBody),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  ChatMessage copyWith(
          {int? id,
          int? userId,
          Value<int?> readingId = const Value.absent(),
          String? role,
          String? textBody,
          DateTime? createdAt}) =>
      ChatMessage(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        readingId: readingId.present ? readingId.value : this.readingId,
        role: role ?? this.role,
        textBody: textBody ?? this.textBody,
        createdAt: createdAt ?? this.createdAt,
      );
  ChatMessage copyWithCompanion(ChatMessagesCompanion data) {
    return ChatMessage(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      readingId: data.readingId.present ? data.readingId.value : this.readingId,
      role: data.role.present ? data.role.value : this.role,
      textBody: data.textBody.present ? data.textBody.value : this.textBody,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChatMessage(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('readingId: $readingId, ')
          ..write('role: $role, ')
          ..write('textBody: $textBody, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, userId, readingId, role, textBody, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChatMessage &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.readingId == this.readingId &&
          other.role == this.role &&
          other.textBody == this.textBody &&
          other.createdAt == this.createdAt);
}

class ChatMessagesCompanion extends UpdateCompanion<ChatMessage> {
  final Value<int> id;
  final Value<int> userId;
  final Value<int?> readingId;
  final Value<String> role;
  final Value<String> textBody;
  final Value<DateTime> createdAt;
  const ChatMessagesCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.readingId = const Value.absent(),
    this.role = const Value.absent(),
    this.textBody = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  ChatMessagesCompanion.insert({
    this.id = const Value.absent(),
    required int userId,
    this.readingId = const Value.absent(),
    required String role,
    required String textBody,
    required DateTime createdAt,
  })  : userId = Value(userId),
        role = Value(role),
        textBody = Value(textBody),
        createdAt = Value(createdAt);
  static Insertable<ChatMessage> custom({
    Expression<int>? id,
    Expression<int>? userId,
    Expression<int>? readingId,
    Expression<String>? role,
    Expression<String>? textBody,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (readingId != null) 'reading_id': readingId,
      if (role != null) 'role': role,
      if (textBody != null) 'text': textBody,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  ChatMessagesCompanion copyWith(
      {Value<int>? id,
      Value<int>? userId,
      Value<int?>? readingId,
      Value<String>? role,
      Value<String>? textBody,
      Value<DateTime>? createdAt}) {
    return ChatMessagesCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      readingId: readingId ?? this.readingId,
      role: role ?? this.role,
      textBody: textBody ?? this.textBody,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<int>(userId.value);
    }
    if (readingId.present) {
      map['reading_id'] = Variable<int>(readingId.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (textBody.present) {
      map['text'] = Variable<String>(textBody.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChatMessagesCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('readingId: $readingId, ')
          ..write('role: $role, ')
          ..write('textBody: $textBody, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $DiagLogsTable extends DiagLogs with TableInfo<$DiagLogsTable, DiagLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DiagLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<int> userId = GeneratedColumn<int>(
      'user_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
      'source', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _levelMeta = const VerificationMeta('level');
  @override
  late final GeneratedColumn<String> level = GeneratedColumn<String>(
      'level', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _messageMeta =
      const VerificationMeta('message');
  @override
  late final GeneratedColumn<String> message = GeneratedColumn<String>(
      'message', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, userId, source, level, message, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'diag_logs';
  @override
  VerificationContext validateIntegrity(Insertable<DiagLog> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    }
    if (data.containsKey('source')) {
      context.handle(_sourceMeta,
          source.isAcceptableOrUnknown(data['source']!, _sourceMeta));
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('level')) {
      context.handle(
          _levelMeta, level.isAcceptableOrUnknown(data['level']!, _levelMeta));
    } else if (isInserting) {
      context.missing(_levelMeta);
    }
    if (data.containsKey('message')) {
      context.handle(_messageMeta,
          message.isAcceptableOrUnknown(data['message']!, _messageMeta));
    } else if (isInserting) {
      context.missing(_messageMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DiagLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DiagLog(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}user_id']),
      source: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source'])!,
      level: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}level'])!,
      message: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}message'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $DiagLogsTable createAlias(String alias) {
    return $DiagLogsTable(attachedDatabase, alias);
  }
}

class DiagLog extends DataClass implements Insertable<DiagLog> {
  final int id;
  final int? userId;
  final String source;
  final String level;

  /// CRITICAL: Must never contain analyte values or raw sensor data.
  /// Store operational messages only (e.g., "Package validation failed").
  final String message;
  final DateTime createdAt;
  const DiagLog(
      {required this.id,
      this.userId,
      required this.source,
      required this.level,
      required this.message,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || userId != null) {
      map['user_id'] = Variable<int>(userId);
    }
    map['source'] = Variable<String>(source);
    map['level'] = Variable<String>(level);
    map['message'] = Variable<String>(message);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  DiagLogsCompanion toCompanion(bool nullToAbsent) {
    return DiagLogsCompanion(
      id: Value(id),
      userId:
          userId == null && nullToAbsent ? const Value.absent() : Value(userId),
      source: Value(source),
      level: Value(level),
      message: Value(message),
      createdAt: Value(createdAt),
    );
  }

  factory DiagLog.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DiagLog(
      id: serializer.fromJson<int>(json['id']),
      userId: serializer.fromJson<int?>(json['userId']),
      source: serializer.fromJson<String>(json['source']),
      level: serializer.fromJson<String>(json['level']),
      message: serializer.fromJson<String>(json['message']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'userId': serializer.toJson<int?>(userId),
      'source': serializer.toJson<String>(source),
      'level': serializer.toJson<String>(level),
      'message': serializer.toJson<String>(message),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  DiagLog copyWith(
          {int? id,
          Value<int?> userId = const Value.absent(),
          String? source,
          String? level,
          String? message,
          DateTime? createdAt}) =>
      DiagLog(
        id: id ?? this.id,
        userId: userId.present ? userId.value : this.userId,
        source: source ?? this.source,
        level: level ?? this.level,
        message: message ?? this.message,
        createdAt: createdAt ?? this.createdAt,
      );
  DiagLog copyWithCompanion(DiagLogsCompanion data) {
    return DiagLog(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      source: data.source.present ? data.source.value : this.source,
      level: data.level.present ? data.level.value : this.level,
      message: data.message.present ? data.message.value : this.message,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DiagLog(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('source: $source, ')
          ..write('level: $level, ')
          ..write('message: $message, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, userId, source, level, message, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DiagLog &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.source == this.source &&
          other.level == this.level &&
          other.message == this.message &&
          other.createdAt == this.createdAt);
}

class DiagLogsCompanion extends UpdateCompanion<DiagLog> {
  final Value<int> id;
  final Value<int?> userId;
  final Value<String> source;
  final Value<String> level;
  final Value<String> message;
  final Value<DateTime> createdAt;
  const DiagLogsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.source = const Value.absent(),
    this.level = const Value.absent(),
    this.message = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  DiagLogsCompanion.insert({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    required String source,
    required String level,
    required String message,
    required DateTime createdAt,
  })  : source = Value(source),
        level = Value(level),
        message = Value(message),
        createdAt = Value(createdAt);
  static Insertable<DiagLog> custom({
    Expression<int>? id,
    Expression<int>? userId,
    Expression<String>? source,
    Expression<String>? level,
    Expression<String>? message,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (source != null) 'source': source,
      if (level != null) 'level': level,
      if (message != null) 'message': message,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  DiagLogsCompanion copyWith(
      {Value<int>? id,
      Value<int?>? userId,
      Value<String>? source,
      Value<String>? level,
      Value<String>? message,
      Value<DateTime>? createdAt}) {
    return DiagLogsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      source: source ?? this.source,
      level: level ?? this.level,
      message: message ?? this.message,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<int>(userId.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (level.present) {
      map['level'] = Variable<String>(level.value);
    }
    if (message.present) {
      map['message'] = Variable<String>(message.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DiagLogsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('source: $source, ')
          ..write('level: $level, ')
          ..write('message: $message, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $UsersTable users = $UsersTable(this);
  late final $DevicesTable devices = $DevicesTable(this);
  late final $DeviceBindingsTable deviceBindings = $DeviceBindingsTable(this);
  late final $ReadingsTable readings = $ReadingsTable(this);
  late final $AnalytesTable analytes = $AnalytesTable(this);
  late final $ReadingAnalytesTable readingAnalytes =
      $ReadingAnalytesTable(this);
  late final $NotesTable notes = $NotesTable(this);
  late final $ExportsTable exports = $ExportsTable(this);
  late final $ChatMessagesTable chatMessages = $ChatMessagesTable(this);
  late final $DiagLogsTable diagLogs = $DiagLogsTable(this);
  late final ReadingDao readingDao = ReadingDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        users,
        devices,
        deviceBindings,
        readings,
        analytes,
        readingAnalytes,
        notes,
        exports,
        chatMessages,
        diagLogs
      ];
}

typedef $$UsersTableCreateCompanionBuilder = UsersCompanion Function({
  Value<int> id,
  required String email,
  required String passwordHash,
  Value<String> units,
  Value<bool> estBgEnabled,
  required DateTime createdAt,
});
typedef $$UsersTableUpdateCompanionBuilder = UsersCompanion Function({
  Value<int> id,
  Value<String> email,
  Value<String> passwordHash,
  Value<String> units,
  Value<bool> estBgEnabled,
  Value<DateTime> createdAt,
});

class $$UsersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $UsersTable,
    User,
    $$UsersTableFilterComposer,
    $$UsersTableOrderingComposer,
    $$UsersTableCreateCompanionBuilder,
    $$UsersTableUpdateCompanionBuilder> {
  $$UsersTableTableManager(_$AppDatabase db, $UsersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$UsersTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$UsersTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> email = const Value.absent(),
            Value<String> passwordHash = const Value.absent(),
            Value<String> units = const Value.absent(),
            Value<bool> estBgEnabled = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              UsersCompanion(
            id: id,
            email: email,
            passwordHash: passwordHash,
            units: units,
            estBgEnabled: estBgEnabled,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String email,
            required String passwordHash,
            Value<String> units = const Value.absent(),
            Value<bool> estBgEnabled = const Value.absent(),
            required DateTime createdAt,
          }) =>
              UsersCompanion.insert(
            id: id,
            email: email,
            passwordHash: passwordHash,
            units: units,
            estBgEnabled: estBgEnabled,
            createdAt: createdAt,
          ),
        ));
}

class $$UsersTableFilterComposer
    extends FilterComposer<_$AppDatabase, $UsersTable> {
  $$UsersTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get email => $state.composableBuilder(
      column: $state.table.email,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get passwordHash => $state.composableBuilder(
      column: $state.table.passwordHash,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get units => $state.composableBuilder(
      column: $state.table.units,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<bool> get estBgEnabled => $state.composableBuilder(
      column: $state.table.estBgEnabled,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$UsersTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $UsersTable> {
  $$UsersTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get email => $state.composableBuilder(
      column: $state.table.email,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get passwordHash => $state.composableBuilder(
      column: $state.table.passwordHash,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get units => $state.composableBuilder(
      column: $state.table.units,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<bool> get estBgEnabled => $state.composableBuilder(
      column: $state.table.estBgEnabled,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$DevicesTableCreateCompanionBuilder = DevicesCompanion Function({
  required String deviceId,
  Value<String?> hwRev,
  Value<String?> fwRev,
  Value<String?> nickname,
  Value<int> rowid,
});
typedef $$DevicesTableUpdateCompanionBuilder = DevicesCompanion Function({
  Value<String> deviceId,
  Value<String?> hwRev,
  Value<String?> fwRev,
  Value<String?> nickname,
  Value<int> rowid,
});

class $$DevicesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DevicesTable,
    Device,
    $$DevicesTableFilterComposer,
    $$DevicesTableOrderingComposer,
    $$DevicesTableCreateCompanionBuilder,
    $$DevicesTableUpdateCompanionBuilder> {
  $$DevicesTableTableManager(_$AppDatabase db, $DevicesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$DevicesTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$DevicesTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> deviceId = const Value.absent(),
            Value<String?> hwRev = const Value.absent(),
            Value<String?> fwRev = const Value.absent(),
            Value<String?> nickname = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DevicesCompanion(
            deviceId: deviceId,
            hwRev: hwRev,
            fwRev: fwRev,
            nickname: nickname,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String deviceId,
            Value<String?> hwRev = const Value.absent(),
            Value<String?> fwRev = const Value.absent(),
            Value<String?> nickname = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DevicesCompanion.insert(
            deviceId: deviceId,
            hwRev: hwRev,
            fwRev: fwRev,
            nickname: nickname,
            rowid: rowid,
          ),
        ));
}

class $$DevicesTableFilterComposer
    extends FilterComposer<_$AppDatabase, $DevicesTable> {
  $$DevicesTableFilterComposer(super.$state);
  ColumnFilters<String> get deviceId => $state.composableBuilder(
      column: $state.table.deviceId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get hwRev => $state.composableBuilder(
      column: $state.table.hwRev,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get fwRev => $state.composableBuilder(
      column: $state.table.fwRev,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get nickname => $state.composableBuilder(
      column: $state.table.nickname,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$DevicesTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $DevicesTable> {
  $$DevicesTableOrderingComposer(super.$state);
  ColumnOrderings<String> get deviceId => $state.composableBuilder(
      column: $state.table.deviceId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get hwRev => $state.composableBuilder(
      column: $state.table.hwRev,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get fwRev => $state.composableBuilder(
      column: $state.table.fwRev,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get nickname => $state.composableBuilder(
      column: $state.table.nickname,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$DeviceBindingsTableCreateCompanionBuilder = DeviceBindingsCompanion
    Function({
  Value<int> id,
  required int userId,
  required String deviceId,
  required DateTime pairedAt,
  Value<DateTime?> lastSeenAt,
  Value<bool> isDefault,
});
typedef $$DeviceBindingsTableUpdateCompanionBuilder = DeviceBindingsCompanion
    Function({
  Value<int> id,
  Value<int> userId,
  Value<String> deviceId,
  Value<DateTime> pairedAt,
  Value<DateTime?> lastSeenAt,
  Value<bool> isDefault,
});

class $$DeviceBindingsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DeviceBindingsTable,
    DeviceBinding,
    $$DeviceBindingsTableFilterComposer,
    $$DeviceBindingsTableOrderingComposer,
    $$DeviceBindingsTableCreateCompanionBuilder,
    $$DeviceBindingsTableUpdateCompanionBuilder> {
  $$DeviceBindingsTableTableManager(
      _$AppDatabase db, $DeviceBindingsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$DeviceBindingsTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$DeviceBindingsTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> userId = const Value.absent(),
            Value<String> deviceId = const Value.absent(),
            Value<DateTime> pairedAt = const Value.absent(),
            Value<DateTime?> lastSeenAt = const Value.absent(),
            Value<bool> isDefault = const Value.absent(),
          }) =>
              DeviceBindingsCompanion(
            id: id,
            userId: userId,
            deviceId: deviceId,
            pairedAt: pairedAt,
            lastSeenAt: lastSeenAt,
            isDefault: isDefault,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int userId,
            required String deviceId,
            required DateTime pairedAt,
            Value<DateTime?> lastSeenAt = const Value.absent(),
            Value<bool> isDefault = const Value.absent(),
          }) =>
              DeviceBindingsCompanion.insert(
            id: id,
            userId: userId,
            deviceId: deviceId,
            pairedAt: pairedAt,
            lastSeenAt: lastSeenAt,
            isDefault: isDefault,
          ),
        ));
}

class $$DeviceBindingsTableFilterComposer
    extends FilterComposer<_$AppDatabase, $DeviceBindingsTable> {
  $$DeviceBindingsTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get userId => $state.composableBuilder(
      column: $state.table.userId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get deviceId => $state.composableBuilder(
      column: $state.table.deviceId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get pairedAt => $state.composableBuilder(
      column: $state.table.pairedAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get lastSeenAt => $state.composableBuilder(
      column: $state.table.lastSeenAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<bool> get isDefault => $state.composableBuilder(
      column: $state.table.isDefault,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$DeviceBindingsTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $DeviceBindingsTable> {
  $$DeviceBindingsTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get userId => $state.composableBuilder(
      column: $state.table.userId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get deviceId => $state.composableBuilder(
      column: $state.table.deviceId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get pairedAt => $state.composableBuilder(
      column: $state.table.pairedAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get lastSeenAt => $state.composableBuilder(
      column: $state.table.lastSeenAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<bool> get isDefault => $state.composableBuilder(
      column: $state.table.isDefault,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$ReadingsTableCreateCompanionBuilder = ReadingsCompanion Function({
  Value<int> id,
  required int userId,
  required String deviceId,
  required DateTime takenAt,
  required String sampleStatus,
  Value<int?> contactDurationMs,
  required String qcStatus,
  Value<String?> invalidReason,
  required String modelVersion,
  required String rawPackageRef,
});
typedef $$ReadingsTableUpdateCompanionBuilder = ReadingsCompanion Function({
  Value<int> id,
  Value<int> userId,
  Value<String> deviceId,
  Value<DateTime> takenAt,
  Value<String> sampleStatus,
  Value<int?> contactDurationMs,
  Value<String> qcStatus,
  Value<String?> invalidReason,
  Value<String> modelVersion,
  Value<String> rawPackageRef,
});

class $$ReadingsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ReadingsTable,
    Reading,
    $$ReadingsTableFilterComposer,
    $$ReadingsTableOrderingComposer,
    $$ReadingsTableCreateCompanionBuilder,
    $$ReadingsTableUpdateCompanionBuilder> {
  $$ReadingsTableTableManager(_$AppDatabase db, $ReadingsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$ReadingsTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$ReadingsTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> userId = const Value.absent(),
            Value<String> deviceId = const Value.absent(),
            Value<DateTime> takenAt = const Value.absent(),
            Value<String> sampleStatus = const Value.absent(),
            Value<int?> contactDurationMs = const Value.absent(),
            Value<String> qcStatus = const Value.absent(),
            Value<String?> invalidReason = const Value.absent(),
            Value<String> modelVersion = const Value.absent(),
            Value<String> rawPackageRef = const Value.absent(),
          }) =>
              ReadingsCompanion(
            id: id,
            userId: userId,
            deviceId: deviceId,
            takenAt: takenAt,
            sampleStatus: sampleStatus,
            contactDurationMs: contactDurationMs,
            qcStatus: qcStatus,
            invalidReason: invalidReason,
            modelVersion: modelVersion,
            rawPackageRef: rawPackageRef,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int userId,
            required String deviceId,
            required DateTime takenAt,
            required String sampleStatus,
            Value<int?> contactDurationMs = const Value.absent(),
            required String qcStatus,
            Value<String?> invalidReason = const Value.absent(),
            required String modelVersion,
            required String rawPackageRef,
          }) =>
              ReadingsCompanion.insert(
            id: id,
            userId: userId,
            deviceId: deviceId,
            takenAt: takenAt,
            sampleStatus: sampleStatus,
            contactDurationMs: contactDurationMs,
            qcStatus: qcStatus,
            invalidReason: invalidReason,
            modelVersion: modelVersion,
            rawPackageRef: rawPackageRef,
          ),
        ));
}

class $$ReadingsTableFilterComposer
    extends FilterComposer<_$AppDatabase, $ReadingsTable> {
  $$ReadingsTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get userId => $state.composableBuilder(
      column: $state.table.userId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get deviceId => $state.composableBuilder(
      column: $state.table.deviceId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get takenAt => $state.composableBuilder(
      column: $state.table.takenAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get sampleStatus => $state.composableBuilder(
      column: $state.table.sampleStatus,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get contactDurationMs => $state.composableBuilder(
      column: $state.table.contactDurationMs,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get qcStatus => $state.composableBuilder(
      column: $state.table.qcStatus,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get invalidReason => $state.composableBuilder(
      column: $state.table.invalidReason,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get modelVersion => $state.composableBuilder(
      column: $state.table.modelVersion,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get rawPackageRef => $state.composableBuilder(
      column: $state.table.rawPackageRef,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$ReadingsTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $ReadingsTable> {
  $$ReadingsTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get userId => $state.composableBuilder(
      column: $state.table.userId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get deviceId => $state.composableBuilder(
      column: $state.table.deviceId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get takenAt => $state.composableBuilder(
      column: $state.table.takenAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get sampleStatus => $state.composableBuilder(
      column: $state.table.sampleStatus,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get contactDurationMs => $state.composableBuilder(
      column: $state.table.contactDurationMs,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get qcStatus => $state.composableBuilder(
      column: $state.table.qcStatus,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get invalidReason => $state.composableBuilder(
      column: $state.table.invalidReason,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get modelVersion => $state.composableBuilder(
      column: $state.table.modelVersion,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get rawPackageRef => $state.composableBuilder(
      column: $state.table.rawPackageRef,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$AnalytesTableCreateCompanionBuilder = AnalytesCompanion Function({
  Value<int> id,
  required String code,
  required String name,
  required String defaultUnit,
});
typedef $$AnalytesTableUpdateCompanionBuilder = AnalytesCompanion Function({
  Value<int> id,
  Value<String> code,
  Value<String> name,
  Value<String> defaultUnit,
});

class $$AnalytesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AnalytesTable,
    Analyte,
    $$AnalytesTableFilterComposer,
    $$AnalytesTableOrderingComposer,
    $$AnalytesTableCreateCompanionBuilder,
    $$AnalytesTableUpdateCompanionBuilder> {
  $$AnalytesTableTableManager(_$AppDatabase db, $AnalytesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$AnalytesTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$AnalytesTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> code = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> defaultUnit = const Value.absent(),
          }) =>
              AnalytesCompanion(
            id: id,
            code: code,
            name: name,
            defaultUnit: defaultUnit,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String code,
            required String name,
            required String defaultUnit,
          }) =>
              AnalytesCompanion.insert(
            id: id,
            code: code,
            name: name,
            defaultUnit: defaultUnit,
          ),
        ));
}

class $$AnalytesTableFilterComposer
    extends FilterComposer<_$AppDatabase, $AnalytesTable> {
  $$AnalytesTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get code => $state.composableBuilder(
      column: $state.table.code,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get defaultUnit => $state.composableBuilder(
      column: $state.table.defaultUnit,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$AnalytesTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $AnalytesTable> {
  $$AnalytesTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get code => $state.composableBuilder(
      column: $state.table.code,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get defaultUnit => $state.composableBuilder(
      column: $state.table.defaultUnit,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$ReadingAnalytesTableCreateCompanionBuilder = ReadingAnalytesCompanion
    Function({
  Value<int> id,
  required int userId,
  required int readingId,
  required int analyteId,
  required double value,
  required String unit,
  Value<double?> estimatedBg,
});
typedef $$ReadingAnalytesTableUpdateCompanionBuilder = ReadingAnalytesCompanion
    Function({
  Value<int> id,
  Value<int> userId,
  Value<int> readingId,
  Value<int> analyteId,
  Value<double> value,
  Value<String> unit,
  Value<double?> estimatedBg,
});

class $$ReadingAnalytesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ReadingAnalytesTable,
    ReadingAnalyte,
    $$ReadingAnalytesTableFilterComposer,
    $$ReadingAnalytesTableOrderingComposer,
    $$ReadingAnalytesTableCreateCompanionBuilder,
    $$ReadingAnalytesTableUpdateCompanionBuilder> {
  $$ReadingAnalytesTableTableManager(
      _$AppDatabase db, $ReadingAnalytesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$ReadingAnalytesTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$ReadingAnalytesTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> userId = const Value.absent(),
            Value<int> readingId = const Value.absent(),
            Value<int> analyteId = const Value.absent(),
            Value<double> value = const Value.absent(),
            Value<String> unit = const Value.absent(),
            Value<double?> estimatedBg = const Value.absent(),
          }) =>
              ReadingAnalytesCompanion(
            id: id,
            userId: userId,
            readingId: readingId,
            analyteId: analyteId,
            value: value,
            unit: unit,
            estimatedBg: estimatedBg,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int userId,
            required int readingId,
            required int analyteId,
            required double value,
            required String unit,
            Value<double?> estimatedBg = const Value.absent(),
          }) =>
              ReadingAnalytesCompanion.insert(
            id: id,
            userId: userId,
            readingId: readingId,
            analyteId: analyteId,
            value: value,
            unit: unit,
            estimatedBg: estimatedBg,
          ),
        ));
}

class $$ReadingAnalytesTableFilterComposer
    extends FilterComposer<_$AppDatabase, $ReadingAnalytesTable> {
  $$ReadingAnalytesTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get userId => $state.composableBuilder(
      column: $state.table.userId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get readingId => $state.composableBuilder(
      column: $state.table.readingId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get analyteId => $state.composableBuilder(
      column: $state.table.analyteId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get value => $state.composableBuilder(
      column: $state.table.value,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get unit => $state.composableBuilder(
      column: $state.table.unit,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get estimatedBg => $state.composableBuilder(
      column: $state.table.estimatedBg,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$ReadingAnalytesTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $ReadingAnalytesTable> {
  $$ReadingAnalytesTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get userId => $state.composableBuilder(
      column: $state.table.userId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get readingId => $state.composableBuilder(
      column: $state.table.readingId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get analyteId => $state.composableBuilder(
      column: $state.table.analyteId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get value => $state.composableBuilder(
      column: $state.table.value,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get unit => $state.composableBuilder(
      column: $state.table.unit,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get estimatedBg => $state.composableBuilder(
      column: $state.table.estimatedBg,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$NotesTableCreateCompanionBuilder = NotesCompanion Function({
  Value<int> id,
  required int userId,
  required int readingId,
  required String content,
  required DateTime createdAt,
});
typedef $$NotesTableUpdateCompanionBuilder = NotesCompanion Function({
  Value<int> id,
  Value<int> userId,
  Value<int> readingId,
  Value<String> content,
  Value<DateTime> createdAt,
});

class $$NotesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $NotesTable,
    Note,
    $$NotesTableFilterComposer,
    $$NotesTableOrderingComposer,
    $$NotesTableCreateCompanionBuilder,
    $$NotesTableUpdateCompanionBuilder> {
  $$NotesTableTableManager(_$AppDatabase db, $NotesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$NotesTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$NotesTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> userId = const Value.absent(),
            Value<int> readingId = const Value.absent(),
            Value<String> content = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              NotesCompanion(
            id: id,
            userId: userId,
            readingId: readingId,
            content: content,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int userId,
            required int readingId,
            required String content,
            required DateTime createdAt,
          }) =>
              NotesCompanion.insert(
            id: id,
            userId: userId,
            readingId: readingId,
            content: content,
            createdAt: createdAt,
          ),
        ));
}

class $$NotesTableFilterComposer
    extends FilterComposer<_$AppDatabase, $NotesTable> {
  $$NotesTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get userId => $state.composableBuilder(
      column: $state.table.userId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get readingId => $state.composableBuilder(
      column: $state.table.readingId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get content => $state.composableBuilder(
      column: $state.table.content,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$NotesTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $NotesTable> {
  $$NotesTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get userId => $state.composableBuilder(
      column: $state.table.userId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get readingId => $state.composableBuilder(
      column: $state.table.readingId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get content => $state.composableBuilder(
      column: $state.table.content,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$ExportsTableCreateCompanionBuilder = ExportsCompanion Function({
  Value<int> id,
  required int userId,
  required String type,
  required String fileUri,
  required DateTime createdAt,
});
typedef $$ExportsTableUpdateCompanionBuilder = ExportsCompanion Function({
  Value<int> id,
  Value<int> userId,
  Value<String> type,
  Value<String> fileUri,
  Value<DateTime> createdAt,
});

class $$ExportsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ExportsTable,
    Export,
    $$ExportsTableFilterComposer,
    $$ExportsTableOrderingComposer,
    $$ExportsTableCreateCompanionBuilder,
    $$ExportsTableUpdateCompanionBuilder> {
  $$ExportsTableTableManager(_$AppDatabase db, $ExportsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$ExportsTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$ExportsTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> userId = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<String> fileUri = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              ExportsCompanion(
            id: id,
            userId: userId,
            type: type,
            fileUri: fileUri,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int userId,
            required String type,
            required String fileUri,
            required DateTime createdAt,
          }) =>
              ExportsCompanion.insert(
            id: id,
            userId: userId,
            type: type,
            fileUri: fileUri,
            createdAt: createdAt,
          ),
        ));
}

class $$ExportsTableFilterComposer
    extends FilterComposer<_$AppDatabase, $ExportsTable> {
  $$ExportsTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get userId => $state.composableBuilder(
      column: $state.table.userId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get type => $state.composableBuilder(
      column: $state.table.type,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get fileUri => $state.composableBuilder(
      column: $state.table.fileUri,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$ExportsTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $ExportsTable> {
  $$ExportsTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get userId => $state.composableBuilder(
      column: $state.table.userId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get type => $state.composableBuilder(
      column: $state.table.type,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get fileUri => $state.composableBuilder(
      column: $state.table.fileUri,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$ChatMessagesTableCreateCompanionBuilder = ChatMessagesCompanion
    Function({
  Value<int> id,
  required int userId,
  Value<int?> readingId,
  required String role,
  required String textBody,
  required DateTime createdAt,
});
typedef $$ChatMessagesTableUpdateCompanionBuilder = ChatMessagesCompanion
    Function({
  Value<int> id,
  Value<int> userId,
  Value<int?> readingId,
  Value<String> role,
  Value<String> textBody,
  Value<DateTime> createdAt,
});

class $$ChatMessagesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ChatMessagesTable,
    ChatMessage,
    $$ChatMessagesTableFilterComposer,
    $$ChatMessagesTableOrderingComposer,
    $$ChatMessagesTableCreateCompanionBuilder,
    $$ChatMessagesTableUpdateCompanionBuilder> {
  $$ChatMessagesTableTableManager(_$AppDatabase db, $ChatMessagesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$ChatMessagesTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$ChatMessagesTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> userId = const Value.absent(),
            Value<int?> readingId = const Value.absent(),
            Value<String> role = const Value.absent(),
            Value<String> textBody = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              ChatMessagesCompanion(
            id: id,
            userId: userId,
            readingId: readingId,
            role: role,
            textBody: textBody,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int userId,
            Value<int?> readingId = const Value.absent(),
            required String role,
            required String textBody,
            required DateTime createdAt,
          }) =>
              ChatMessagesCompanion.insert(
            id: id,
            userId: userId,
            readingId: readingId,
            role: role,
            textBody: textBody,
            createdAt: createdAt,
          ),
        ));
}

class $$ChatMessagesTableFilterComposer
    extends FilterComposer<_$AppDatabase, $ChatMessagesTable> {
  $$ChatMessagesTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get userId => $state.composableBuilder(
      column: $state.table.userId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get readingId => $state.composableBuilder(
      column: $state.table.readingId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get role => $state.composableBuilder(
      column: $state.table.role,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get textBody => $state.composableBuilder(
      column: $state.table.textBody,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$ChatMessagesTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $ChatMessagesTable> {
  $$ChatMessagesTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get userId => $state.composableBuilder(
      column: $state.table.userId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get readingId => $state.composableBuilder(
      column: $state.table.readingId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get role => $state.composableBuilder(
      column: $state.table.role,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get textBody => $state.composableBuilder(
      column: $state.table.textBody,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$DiagLogsTableCreateCompanionBuilder = DiagLogsCompanion Function({
  Value<int> id,
  Value<int?> userId,
  required String source,
  required String level,
  required String message,
  required DateTime createdAt,
});
typedef $$DiagLogsTableUpdateCompanionBuilder = DiagLogsCompanion Function({
  Value<int> id,
  Value<int?> userId,
  Value<String> source,
  Value<String> level,
  Value<String> message,
  Value<DateTime> createdAt,
});

class $$DiagLogsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DiagLogsTable,
    DiagLog,
    $$DiagLogsTableFilterComposer,
    $$DiagLogsTableOrderingComposer,
    $$DiagLogsTableCreateCompanionBuilder,
    $$DiagLogsTableUpdateCompanionBuilder> {
  $$DiagLogsTableTableManager(_$AppDatabase db, $DiagLogsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$DiagLogsTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$DiagLogsTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int?> userId = const Value.absent(),
            Value<String> source = const Value.absent(),
            Value<String> level = const Value.absent(),
            Value<String> message = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              DiagLogsCompanion(
            id: id,
            userId: userId,
            source: source,
            level: level,
            message: message,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int?> userId = const Value.absent(),
            required String source,
            required String level,
            required String message,
            required DateTime createdAt,
          }) =>
              DiagLogsCompanion.insert(
            id: id,
            userId: userId,
            source: source,
            level: level,
            message: message,
            createdAt: createdAt,
          ),
        ));
}

class $$DiagLogsTableFilterComposer
    extends FilterComposer<_$AppDatabase, $DiagLogsTable> {
  $$DiagLogsTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get userId => $state.composableBuilder(
      column: $state.table.userId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get source => $state.composableBuilder(
      column: $state.table.source,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get level => $state.composableBuilder(
      column: $state.table.level,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get message => $state.composableBuilder(
      column: $state.table.message,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$DiagLogsTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $DiagLogsTable> {
  $$DiagLogsTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get userId => $state.composableBuilder(
      column: $state.table.userId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get source => $state.composableBuilder(
      column: $state.table.source,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get level => $state.composableBuilder(
      column: $state.table.level,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get message => $state.composableBuilder(
      column: $state.table.message,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$UsersTableTableManager get users =>
      $$UsersTableTableManager(_db, _db.users);
  $$DevicesTableTableManager get devices =>
      $$DevicesTableTableManager(_db, _db.devices);
  $$DeviceBindingsTableTableManager get deviceBindings =>
      $$DeviceBindingsTableTableManager(_db, _db.deviceBindings);
  $$ReadingsTableTableManager get readings =>
      $$ReadingsTableTableManager(_db, _db.readings);
  $$AnalytesTableTableManager get analytes =>
      $$AnalytesTableTableManager(_db, _db.analytes);
  $$ReadingAnalytesTableTableManager get readingAnalytes =>
      $$ReadingAnalytesTableTableManager(_db, _db.readingAnalytes);
  $$NotesTableTableManager get notes =>
      $$NotesTableTableManager(_db, _db.notes);
  $$ExportsTableTableManager get exports =>
      $$ExportsTableTableManager(_db, _db.exports);
  $$ChatMessagesTableTableManager get chatMessages =>
      $$ChatMessagesTableTableManager(_db, _db.chatMessages);
  $$DiagLogsTableTableManager get diagLogs =>
      $$DiagLogsTableTableManager(_db, _db.diagLogs);
}
