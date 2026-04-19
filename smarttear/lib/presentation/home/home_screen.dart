import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../application/providers/home_view_model.dart';
import '../../application/providers/simulation_connector_provider.dart';
import '../../domain/entities/reading.dart';
import '../../domain/services/device_connector_port.dart';
import '../../infrastructure/ml/data_ingestor.dart';
import '../auth/auth_ui.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conn = ref.watch(simulationConnectorProvider);
    final vm = ref.watch(homeViewModelProvider).valueOrNull ??
        const HomeState(latestReading: null, isAcquiring: false);
    final acquiring = vm.isAcquiring;

    return Scaffold(
      appBar: AppBar(title: const Text('SmartTear')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _DeviceConnectionCard(state: conn),
          const SizedBox(height: 16),
          FilledButton(
            style: SmartTearAuthUi.filledFullWidthButton().copyWith(
              minimumSize:
                  const WidgetStatePropertyAll<Size>(Size(double.infinity, 64)),
              textStyle: WidgetStatePropertyAll(
                Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            onPressed: (!conn.isConnected || acquiring)
                ? null
                : () async {
                    final result = await ref
                        .read(homeViewModelProvider.notifier)
                        .acquireReading();
                    if (!context.mounted) return;

                    switch (result) {
                      case IngestSuccess(:final reading):
                        context.go('/results/${reading.rawPackageRef}');
                      case IngestFailure(:final reason, :final isRetryable):
                        final snack = SnackBar(
                          content: Text(reason),
                          action: isRetryable
                              ? SnackBarAction(
                                  label: 'Retry',
                                  onPressed: () {
                                    if (conn.isConnected) {
                                      ref
                                          .read(homeViewModelProvider.notifier)
                                          .acquireReading();
                                    }
                                  },
                                )
                              : null,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(snack);
                    }
                  },
            child: acquiring
                ? const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 12),
                      Text('Acquiring...'),
                    ],
                  )
                : const Text('Take Reading'),
          ),
          const SizedBox(height: 16),
          if (vm.latestReading != null) ...[
            _LatestReadingCard(reading: vm.latestReading!),
            const SizedBox(height: 16),
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
    final lastSeen = state.lastSeenAt;
    final lastSeenText = lastSeen == null
        ? 'Last seen: —'
        : 'Last seen: ${DateFormat('h:mm a').format(lastSeen)}';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: switch (state.connectionState) {
          DeviceConnectionState.disconnected => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'No Device Connected',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                FilledButton(
                  style: SmartTearAuthUi.filledFullWidthButton(),
                  onPressed: () =>
                      ref.read(simulationConnectorProvider.notifier).connect(),
                  child: const Text('Connect Device'),
                ),
              ],
            ),
          DeviceConnectionState.connecting => Row(
              children: [
                const SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: 12),
                Text(
                  'Connecting...',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          DeviceConnectionState.connected => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      height: 10,
                      width: 10,
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        state.deviceId,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(lastSeenText),
                const SizedBox(height: 12),
                FilledButton(
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(double.infinity, 52),
                    shape: SmartTearAuthUi.roundedShape(),
                    backgroundColor: Theme.of(context).colorScheme.error,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () => ref
                      .read(simulationConnectorProvider.notifier)
                      .disconnect(),
                  child: const Text('Disconnect'),
                ),
              ],
            ),
          DeviceConnectionState.error => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Connection error',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 6),
                Text(state.lastError ?? 'Something went wrong.'),
                const SizedBox(height: 12),
                FilledButton(
                  style: SmartTearAuthUi.filledFullWidthButton(),
                  onPressed: () =>
                      ref.read(simulationConnectorProvider.notifier).connect(),
                  child: const Text('Retry Connect'),
                ),
              ],
            ),
        },
      ),
    );
  }
}

class _LatestReadingCard extends StatelessWidget {
  const _LatestReadingCard({required this.reading});

  final Reading reading;

  @override
  Widget build(BuildContext context) {
    final takenAt = reading.takenAt;
    final isValid = reading.isValid;
    final glucose = reading.glucose;

    final glucoseText = glucose == null
        ? 'Glucose —'
        : 'Glucose ${glucose.value.toStringAsFixed(1)} ${glucose.unit}';

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => context.push('/history/${reading.rawPackageRef}'),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Text(
                    'Latest Reading',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const Spacer(),
                  Chip(
                    label: Text(isValid ? 'Valid' : 'Invalid'),
                    backgroundColor: isValid
                        ? Colors.green.withOpacity(0.15)
                        : Colors.red.withOpacity(0.15),
                    labelStyle: TextStyle(
                      color: isValid ? Colors.green : Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                    side: BorderSide.none,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                glucoseText,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 6),
              Text('Taken ${DateFormat('MMM d, h:mm a').format(takenAt)}'),
            ],
          ),
        ),
      ),
    );
  }
}

