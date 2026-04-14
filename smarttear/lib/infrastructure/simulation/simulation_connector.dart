import 'dart:async';

import 'package:dio/dio.dart';

import '../../domain/entities/data_package.dart';
import '../../domain/services/device_connector_port.dart';

const String kSimulationServerUrl =
    'https://smart-tear-simulation--zkrST.replit.app';

class SimulationConnector implements DeviceConnectorPort {
  SimulationConnector({String baseUrl = kSimulationServerUrl})
      : _baseUrl = baseUrl,
        _dio = Dio(
          BaseOptions(
            // Replit cold starts can exceed short timeouts; keep reads patient.
            connectTimeout: const Duration(seconds: 30),
            receiveTimeout: const Duration(seconds: 45),
            sendTimeout: const Duration(seconds: 30),
          ),
        );

  final String _baseUrl;
  final Dio _dio;

  final StreamController<DeviceConnectionState> _connectionStateController =
      StreamController<DeviceConnectionState>.broadcast();
  final StreamController<DataPackage> _readingController =
      StreamController<DataPackage>.broadcast();

  bool _isConnected = false;

  @override
  Stream<DeviceConnectionState> get connectionStateStream =>
      _connectionStateController.stream;

  @override
  Stream<DataPackage> get readingStream => _readingController.stream;

  @override
  bool get isConnected => _isConnected;

  @override
  Future<void> pair(String deviceId) async {
    _connectionStateController.add(DeviceConnectionState.connecting);

    try {
      await _dio.post<Map<String, dynamic>>(
        '$_baseUrl/pair',
        data: <String, dynamic>{'device_id': deviceId},
      );

      _isConnected = true;
      _connectionStateController.add(DeviceConnectionState.connected);
    } on DioException catch (e, st) {
      _isConnected = false;
      _connectionStateController.add(DeviceConnectionState.error);
      _connectionStateController.addError(_toReachabilityMessage(e), st);
    } catch (e, st) {
      _isConnected = false;
      _connectionStateController.add(DeviceConnectionState.error);
      _connectionStateController.addError(e, st);
    }
  }

  /// Fetches one reading from `/reading`, normalizes JSON, and returns [DataPackage].
  /// Also pushes to [readingStream] for listeners. On failure: sets error state and
  /// **throws** (so callers can await a single future instead of a broadcast stream).
  Future<DataPackage> triggerReadingWithResult() async {
    if (!_isConnected) {
      _connectionStateController.add(DeviceConnectionState.error);
      const msg = 'Not connected. Pair a device first.';
      _connectionStateController.addError(msg, StackTrace.current);
      throw StateError(msg);
    }

    _connectionStateController.add(DeviceConnectionState.connecting);
    await Future<void>.delayed(const Duration(milliseconds: 1500));

    try {
      final resp = await _dio.get<Object>('$_baseUrl/reading');
      final data = resp.data;
      if (data is! Map) {
        throw StateError(
          'Unexpected response shape from /reading (expected JSON object, got ${data.runtimeType})',
        );
      }

      final normalized = _normalizeReadingJson(
        Map<String, dynamic>.from(data),
      );
      final pkg = DataPackage.fromJson(normalized);
      if (!_readingController.isClosed) {
        _readingController.add(pkg);
      }
      _connectionStateController.add(DeviceConnectionState.connected);
      return pkg;
    } on DioException catch (e, st) {
      final msg = _toReachabilityMessage(e);
      _connectionStateController.add(DeviceConnectionState.error);
      _connectionStateController.addError(msg, st);
      throw Exception(msg);
    } catch (e, st) {
      _connectionStateController.add(DeviceConnectionState.error);
      _connectionStateController.addError(e, st);
      rethrow;
    }
  }

  @override
  Future<void> triggerReading() async {
    try {
      await triggerReadingWithResult();
    } catch (_) {
      // Errors are already surfaced via [connectionStateStream] / addError.
    }
  }

  @override
  Future<void> disconnect() async {
    _isConnected = false;
    _connectionStateController.add(DeviceConnectionState.disconnected);
  }

  /// Maps simulation `/reading` JSON (often snake_case and/or wrapped) to the
  /// camelCase shape expected by [DataPackage.fromJson].
  static Map<String, dynamic> _normalizeReadingJson(Map<String, dynamic> raw) {
    Map<String, dynamic> asMap(Object? v) {
      if (v is Map<String, dynamic>) return v;
      if (v is Map) {
        return Map<String, dynamic>.from(
          v.map((k, val) => MapEntry(k.toString(), val)),
        );
      }
      return <String, dynamic>{};
    }

    // Common API shapes: { ...fields }, { "reading": {...} }, { "data": {...} }
    var src = raw;
    final wrapped = raw['reading'] ?? raw['data'] ?? raw['payload'];
    if (wrapped != null) {
      final inner = asMap(wrapped);
      if (inner.isNotEmpty) src = inner;
    }

    String pickString(String camel, String snake, [String fallback = '']) {
      final v = src[camel] ?? src[snake];
      if (v == null) return fallback;
      return v.toString();
    }

    final id = pickString('id', 'reading_id');
    final deviceId = pickString('deviceId', 'device_id');

    final ts = src['timestamp'] ?? src['taken_at'] ?? src['created_at'];
    late final String timestampIso;
    if (ts is num) {
      timestampIso = DateTime.fromMillisecondsSinceEpoch(ts.toInt()).toUtc().toIso8601String();
    } else if (ts is String && ts.isNotEmpty) {
      timestampIso = DateTime.tryParse(ts)?.toUtc().toIso8601String() ??
          DateTime.now().toUtc().toIso8601String();
    } else {
      timestampIso = DateTime.now().toUtc().toIso8601String();
    }

    final schemaRaw = src['schemaVersion'] ?? src['schema_version'];
    final schemaVersion = schemaRaw is num
        ? schemaRaw.toInt()
        : int.tryParse(schemaRaw?.toString() ?? '') ?? 1;

    final sampleStatus =
        pickString('sampleStatus', 'sample_status', 'complete').toLowerCase();

    final contactRaw = src['contactDurationMs'] ?? src['contact_duration_ms'];
    final contactDurationMs = contactRaw == null
        ? null
        : (contactRaw is num
            ? contactRaw.toInt()
            : int.tryParse(contactRaw.toString()));

    final channelsRaw = src['rawChannels'] ?? src['raw_channels'];
    final rawChannels = channelsRaw is List
        ? channelsRaw
        : (channelsRaw == null ? <dynamic>[] : <dynamic>[channelsRaw]);

    return <String, dynamic>{
      'id': id.isEmpty ? 'reading-${DateTime.now().microsecondsSinceEpoch}' : id,
      'deviceId': deviceId.isEmpty ? 'SIM-001' : deviceId,
      'timestamp': timestampIso,
      'schemaVersion': schemaVersion,
      'sampleStatus': sampleStatus,
      if (contactDurationMs != null) 'contactDurationMs': contactDurationMs,
      'rawChannels': rawChannels,
    };
  }

  String _toReachabilityMessage(DioException e) {
    final isUnreachable = e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout;

    if (isUnreachable) {
      return 'Cannot reach simulation server. Is Replit running?';
    }

    // Fall back to something readable.
    if (e.response != null) {
      return 'Simulation server error: HTTP ${e.response?.statusCode}';
    }
    return 'Simulation server error: ${e.message ?? e.type.name}';
  }

  Future<void> dispose() async {
    await _readingController.close();
    await _connectionStateController.close();
  }
}

