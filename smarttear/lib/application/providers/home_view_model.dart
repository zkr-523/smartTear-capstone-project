import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/data_package.dart';
import '../../domain/entities/reading.dart';
import '../../infrastructure/ml/data_ingestor.dart';
import 'auth_provider.dart';
import 'data_ingestor_provider.dart';
import 'history_notifier.dart';
import 'simulation_connector_provider.dart';
import 'trends_notifier.dart';

class HomeState {
  const HomeState({
    required this.latestReading,
    required this.isAcquiring,
    this.lastIngestFailure,
  });

  final Reading? latestReading;
  final bool isAcquiring;
  final IngestFailure? lastIngestFailure;
}

final homeViewModelProvider =
    AsyncNotifierProvider<HomeViewModel, HomeState>(HomeViewModel.new);

class HomeViewModel extends AsyncNotifier<HomeState> {
  @override
  Future<HomeState> build() async {
    return const HomeState(latestReading: null, isAcquiring: false);
  }

  Future<IngestResult> acquireReading() async {
    final prev = state.valueOrNull ??
        const HomeState(latestReading: null, isAcquiring: false);

    state = AsyncData(
      HomeState(
        latestReading: prev.latestReading,
        isAcquiring: true,
      ),
    );

    try {
      final authUser = ref.read(authServiceProvider).currentUser;
      if (authUser == null) {
        const failure =
            IngestFailure('You are signed out. Please sign in.', false);
        state = AsyncData(
          HomeState(
            latestReading: prev.latestReading,
            isAcquiring: false,
            lastIngestFailure: failure,
          ),
        );
        return failure;
      }

      final connector = ref.read(simulationConnectorProvider.notifier).connector;

      // `readingStream` is broadcast: events are dropped if no listener yet.
      // Subscribe for the next packet *before* `triggerReading()` emits it.
      final Future<DataPackage> nextPacket = connector.readingStream.first;
      try {
        await connector.triggerReading();
      } catch (_) {}

      final pkg = await nextPacket.timeout(
        const Duration(seconds: 20),
        onTimeout: () => throw TimeoutException('No reading received from device'),
      );

      final ingestor = await ref.read(dataIngestorProvider.future);
      final result = await ingestor.ingest(pkg, authUser.uid);

      final HomeState next;
      switch (result) {
        case IngestSuccess(:final reading):
          ref.invalidate(historyNotifierProvider);
          ref.invalidate(trendsNotifierProvider);
          next = HomeState(
            latestReading: reading,
            isAcquiring: false,
          );
        case final IngestFailure failure:
          next = HomeState(
            latestReading: prev.latestReading,
            isAcquiring: false,
            lastIngestFailure: failure,
          );
        default:
          next = HomeState(latestReading: prev.latestReading, isAcquiring: false);
      }

      state = AsyncData(next);
      return result;
    } on TimeoutException catch (e) {
      final failure = IngestFailure(e.message ?? 'Timed out', true);
      state = AsyncData(
        HomeState(
          latestReading: prev.latestReading,
          isAcquiring: false,
          lastIngestFailure: failure,
        ),
      );
      return failure;
    } catch (e) {
      final failure = IngestFailure('$e', true);
      state = AsyncData(
        HomeState(
          latestReading: prev.latestReading,
          isAcquiring: false,
          lastIngestFailure: failure,
        ),
      );
      return failure;
    }
  }
}
