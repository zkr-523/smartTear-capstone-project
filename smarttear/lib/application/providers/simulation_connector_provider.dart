import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/services/device_connector_port.dart';
import '../../infrastructure/simulation/simulation_connector.dart';

class SimulationConnectorState {
  const SimulationConnectorState({
    required this.connectionState,
    required this.deviceId,
    required this.lastSeenAt,
    this.lastError,
  });

  final DeviceConnectionState connectionState;
  final String deviceId;
  final DateTime? lastSeenAt;
  final String? lastError;

  bool get isConnected => connectionState == DeviceConnectionState.connected;
  bool get isConnecting => connectionState == DeviceConnectionState.connecting;
  bool get isDisconnected => connectionState == DeviceConnectionState.disconnected;
}

class SimulationConnectorController
    extends StateNotifier<SimulationConnectorState> {
  SimulationConnectorController(this._connector)
      : super(
          const SimulationConnectorState(
            connectionState: DeviceConnectionState.disconnected,
            deviceId: 'SIM-001',
            lastSeenAt: null,
          ),
        ) {
    _sub = _connector.connectionStateStream.listen(
      (s) {
        state = SimulationConnectorState(
          connectionState: s,
          deviceId: state.deviceId,
          lastSeenAt: s == DeviceConnectionState.connected
              ? (state.lastSeenAt ?? DateTime.now())
              : state.lastSeenAt,
          lastError: null,
        );
      },
      onError: (Object e) {
        state = SimulationConnectorState(
          connectionState: DeviceConnectionState.error,
          deviceId: state.deviceId,
          lastSeenAt: state.lastSeenAt,
          lastError: e.toString(),
        );
      },
    );

    _readingSub = _connector.readingStream.listen((_) {
      state = SimulationConnectorState(
        connectionState: state.connectionState,
        deviceId: state.deviceId,
        lastSeenAt: DateTime.now(),
        lastError: state.lastError,
      );
    });
  }

  final SimulationConnector _connector;
  late final StreamSubscription<DeviceConnectionState> _sub;
  late final StreamSubscription<dynamic> _readingSub;

  SimulationConnector get connector => _connector;

  Future<void> connect() async {
    state = SimulationConnectorState(
      connectionState: DeviceConnectionState.connecting,
      deviceId: state.deviceId,
      lastSeenAt: state.lastSeenAt,
      lastError: null,
    );
    await _connector.pair(state.deviceId);
  }

  Future<void> disconnect() async {
    await _connector.disconnect();
  }

  @override
  void dispose() {
    _sub.cancel();
    _readingSub.cancel();
    _connector.dispose();
    super.dispose();
  }
}

final simulationConnectorProvider = StateNotifierProvider<
    SimulationConnectorController, SimulationConnectorState>((ref) {
  final connector = SimulationConnector();
  return SimulationConnectorController(connector);
});

