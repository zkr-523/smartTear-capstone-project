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
            connectTimeout: const Duration(seconds: 5),
            receiveTimeout: const Duration(seconds: 5),
            sendTimeout: const Duration(seconds: 5),
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

  @override
  Future<void> triggerReading() async {
    if (!_isConnected) {
      _connectionStateController.add(DeviceConnectionState.error);
      _connectionStateController.addError(
        'Not connected. Pair a device first.',
        StackTrace.current,
      );
      return;
    }

    // "Acquiring" feel: reuse the connecting state for 1500ms.
    _connectionStateController.add(DeviceConnectionState.connecting);
    await Future<void>.delayed(const Duration(milliseconds: 1500));

    try {
      final resp = await _dio.get<Object>('$_baseUrl/reading');
      final data = resp.data;
      if (data is! Map<String, dynamic>) {
        throw StateError('Unexpected response shape from /reading');
      }

      final pkg = DataPackage.fromJson(data);
      _readingController.add(pkg);
      _connectionStateController.add(DeviceConnectionState.connected);
    } on DioException catch (e, st) {
      _connectionStateController.add(DeviceConnectionState.error);
      _connectionStateController.addError(_toReachabilityMessage(e), st);
    } catch (e, st) {
      _connectionStateController.add(DeviceConnectionState.error);
      _connectionStateController.addError(e, st);
    }
  }

  @override
  Future<void> disconnect() async {
    _isConnected = false;
    _connectionStateController.add(DeviceConnectionState.disconnected);
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

