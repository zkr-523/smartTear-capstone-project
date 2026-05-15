import '../entities/data_package.dart';

abstract class DeviceConnectorPort {
  Stream<DeviceConnectionState> get connectionStateStream;
  Future<void> pair(String deviceId);
  Future<void> disconnect();
  Future<void> triggerReading();
  Stream<DataPackage> get readingStream;
  bool get isConnected;
}

enum DeviceConnectionState { disconnected, connecting, connected, error }

