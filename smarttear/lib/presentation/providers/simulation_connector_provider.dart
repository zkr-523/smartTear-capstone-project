import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/data_package.dart';
import '../../domain/services/device_connector_port.dart';
import '../../infrastructure/simulation/simulation_connector.dart';

class SimulationConnectorState {
  const SimulationConnectorState({
    required this.status,
    this.deviceId,
    this.lastSeen,
    this.errorMessage,
  });

  final DeviceConnectionState status;
  final String? deviceId;
  final DateTime? lastSeen;
  final String? errorMessage;

  bool get isConnected => status == DeviceConnectionState.connected;

  SimulationConnectorState copyWith({
    DeviceConnectionState? status,
    String? deviceId,
    DateTime? lastSeen,
    String? errorMessage,
  }) {
    return SimulationConnectorState(
      status: status ?? this.status,
      deviceId: deviceId ?? this.deviceId,
      lastSeen: lastSeen ?? this.lastSeen,
      errorMessage: errorMessage,
    );
  }
}

class SimulationConnectorNotifier extends StateNotifier<SimulationConnectorState> {
  SimulationConnectorNotifier({SimulationConnector? connector})
      : _connector = connector ?? SimulationConnector(),
        super(
          const SimulationConnectorState(status: DeviceConnectionState.disconnected),
        ) {
    _connSub = _connector.connectionStateStream.listen(
      (s) {
        state = state.copyWith(status: s, errorMessage: null);
      },
      onError: (Object e) {
        state = state.copyWith(
          status: DeviceConnectionState.error,
          errorMessage: e.toString(),
        );
      },
    );

    _readingSub = _connector.readingStream.listen((_) {
      state = state.copyWith(lastSeen: DateTime.now(), errorMessage: null);
    });
  }

  final SimulationConnector _connector;
  late final StreamSubscription<DeviceConnectionState> _connSub;
  late final StreamSubscription<DataPackage> _readingSub;

  SimulationConnector get connector => _connector;

  static const String defaultDeviceId = 'SIM-001';

  Future<void> connect({String deviceId = defaultDeviceId}) async {
    state = state.copyWith(deviceId: deviceId);
    await _connector.pair(deviceId);
    if (_connector.isConnected) {
      state = state.copyWith(lastSeen: DateTime.now());
    }
  }

  Future<void> disconnect() async {
    await _connector.disconnect();
  }

  /// Awaits the HTTP `/reading` round-trip and parsed [DataPackage] directly.
  /// (Do not rely on [readingStream.first] — failures never emit on the stream.)
  Future<DataPackage> triggerReadingAndWait({Duration timeout = const Duration(seconds: 60)}) {
    return _connector.triggerReadingWithResult().timeout(timeout);
  }

  @override
  void dispose() {
    _connSub.cancel();
    _readingSub.cancel();
    _connector.dispose();
    super.dispose();
  }
}

final simulationConnectorProvider = StateNotifierProvider<SimulationConnectorNotifier, SimulationConnectorState>(
  (ref) => SimulationConnectorNotifier(),
);

