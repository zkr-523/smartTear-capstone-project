import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/reading.dart';
import '../../domain/entities/qc_status.dart';
import '../../domain/services/device_connector_port.dart';
import '../providers/simulation_connector_provider.dart';
import 'home_view_model.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(homeViewModelProvider, (prev, next) {
      next.whenOrNull(
        data: (readingId) {
          if (readingId != null) {
            context.push('/results/$readingId');
          }
        },
        error: (err, _) {
          final message = err is HomeAcquireException
              ? err.message
              : err.toString();
          final retryable = err is! HomeAcquireException || err.isRetryable;

          final snackBar = SnackBar(
            content: Text(message),
            action: retryable
                ? SnackBarAction(
                    label: 'Retry',
                    onPressed: () => ref.read(homeViewModelProvider.notifier).acquireReading(),
                  )
                : null,
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        },
      );
    });

    final connectorState = ref.watch(simulationConnectorProvider);
    final isConnected = connectorState.isConnected;
    final acquiring = ref.watch(homeViewModelProvider).isLoading;
    final readings = ref.watch(readingsStoreProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _DeviceConnectionCard(state: connectorState),
          const SizedBox(height: 16),
          _TakeReadingButton(
            enabled: isConnected && !acquiring,
            acquiring: acquiring,
            onPressed: () => ref.read(homeViewModelProvider.notifier).acquireReading(),
          ),
          const SizedBox(height: 16),
          if (readings.isNotEmpty) ...[
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Recent readings',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 8),
            ...readings.take(8).map((r) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _LatestReadingCard(reading: r),
                )),
          ],
        ],
      ),
    );
  }
}

class _DeviceConnectionCard extends ConsumerWidget {
  const _DeviceConnectionCard({required this.state});

  final SimulationConnectorState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = state.status;

    Widget content;
    if (status == DeviceConnectionState.disconnected) {
      content = Row(
        children: [
          const Expanded(
            child: _DeviceText(
              title: 'No Device Connected',
              subtitle: 'Pair your SmartTear device to start.',
            ),
          ),
          ElevatedButton(
            onPressed: () => ref.read(simulationConnectorProvider.notifier).connect(),
            child: const Text('Connect Device'),
          ),
        ],
      );
    } else if (status == DeviceConnectionState.connecting) {
      content = const Row(
        children: [
          SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
          SizedBox(width: 12),
          Expanded(child: _DeviceText(title: 'Connecting...', subtitle: 'Please wait')),
        ],
      );
    } else if (status == DeviceConnectionState.connected) {
      final deviceId = state.deviceId ?? SimulationConnectorNotifier.defaultDeviceId;
      final lastSeen = state.lastSeen;
      final lastSeenText = lastSeen == null ? '—' : DateFormat('h:mm a').format(lastSeen);

      content = Row(
        children: [
          const _StatusDot(color: Colors.green),
          const SizedBox(width: 12),
          Expanded(
            child: _DeviceText(
              title: deviceId,
              subtitle: 'Last seen: $lastSeenText',
            ),
          ),
          OutlinedButton(
            onPressed: () => ref.read(simulationConnectorProvider.notifier).disconnect(),
            child: const Text('Disconnect'),
          ),
        ],
      );
    } else {
      content = Row(
        children: [
          const _StatusDot(color: Colors.red),
          const SizedBox(width: 12),
          Expanded(
            child: _DeviceText(
              title: 'Connection error',
              subtitle: state.errorMessage ?? 'Something went wrong.',
            ),
          ),
          ElevatedButton(
            onPressed: () => ref.read(simulationConnectorProvider.notifier).connect(),
            child: const Text('Retry'),
          ),
        ],
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: content,
      ),
    );
  }
}

class _TakeReadingButton extends StatelessWidget {
  const _TakeReadingButton({
    required this.enabled,
    required this.acquiring,
    required this.onPressed,
  });

  final bool enabled;
  final bool acquiring;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: FilledButton(
        onPressed: enabled ? onPressed : null,
        style: FilledButton.styleFrom(
          backgroundColor: Colors.blue,
          disabledBackgroundColor: Colors.blue.withAlpha(90),
        ),
        child: acquiring
            ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
                  SizedBox(width: 12),
                  Text('Acquiring...'),
                ],
              )
            : const Text(
                'Take Reading',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
      ),
    );
  }
}

class _LatestReadingCard extends StatelessWidget {
  const _LatestReadingCard({required this.reading});

  final Reading reading;

  @override
  Widget build(BuildContext context) {
    final id = reading.id;
    final ts = DateFormat('MMM d, h:mm a').format(reading.takenAt);

    final glucose = reading.glucose;
    final glucoseText = glucose == null ? '—' : '${glucose.value.toStringAsFixed(0)} ${glucose.unit}';

    final (chipColor, chipText) = reading.qcStatus == QCStatus.valid
        ? (Colors.green, 'Valid')
        : (Colors.red, 'Invalid');

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: id == null ? null : () => context.go('/history/$id'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Chip(
                    label: Text(chipText, style: const TextStyle(color: Colors.white)),
                    backgroundColor: chipColor,
                    side: BorderSide.none,
                  ),
                  const Spacer(),
                  Text(ts, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Glucose',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              Text(
                glucoseText,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              if (reading.qcStatus == QCStatus.invalid && reading.invalidReason != null) ...[
                const SizedBox(height: 8),
                Text(
                  reading.invalidReason!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.red.shade700),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusDot extends StatelessWidget {
  const _StatusDot({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class _DeviceText extends StatelessWidget {
  const _DeviceText({required this.title, required this.subtitle});
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

