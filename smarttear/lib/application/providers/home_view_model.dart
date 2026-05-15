import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/data_package.dart';
import '../../domain/entities/reading.dart';
import '../../infrastructure/ml/data_ingestor.dart';
import 'auth_provider.dart';
import 'data_ingestor_provider.dart';
import 'est_bg_settings_notifier.dart';
import 'history_notifier.dart';
import 'simulation_connector_provider.dart';
import 'trends_notifier.dart';

class HomeState {
  const HomeState({
    required this.latestReading,
    required this.isAcquiring,
    this.lastIngestFailure,
    this.totalReadings = 0,
    this.validReadings = 0,
    this.avgTearGlucose,
  });

  final Reading? latestReading;
  final bool isAcquiring;
  final IngestFailure? lastIngestFailure;
  final int totalReadings;
  final int validReadings;
  final double? avgTearGlucose;
}

final homeViewModelProvider =
    AsyncNotifierProvider<HomeViewModel, HomeState>(HomeViewModel.new);

class HomeViewModel extends AsyncNotifier<HomeState> {
  @override
  Future<HomeState> build() async {
    ref.watch(authStateProvider);
    return _loadDashboard();
  }

  Future<HomeState> _loadDashboard() async {
    final uid = ref.read(authServiceProvider).currentUser?.uid;
    if (uid == null) {
      return const HomeState(
        latestReading: null,
        isAcquiring: false,
        totalReadings: 0,
        validReadings: 0,
        avgTearGlucose: null,
      );
    }

    final repo = ref.read(readingRepositoryProvider);
    final all = await repo.listReadingsForUser(uid);
    final valid = all.where((r) => r.isValid).toList()
      ..sort((a, b) => b.takenAt.compareTo(a.takenAt));
    final latestValid = valid.firstOrNull;
    final tgs = valid
        .map((r) => r.glucose?.value)
        .whereType<double>()
        .toList();
    final avg = tgs.isEmpty
        ? null
        : tgs.reduce((double a, double b) => a + b) / tgs.length;

    return HomeState(
      latestReading: latestValid,
      isAcquiring: false,
      totalReadings: all.length,
      validReadings: valid.length,
      avgTearGlucose: avg,
    );
  }

  Future<IngestResult> acquireReading() async {
    final prev = state.valueOrNull ??
        const HomeState(
          latestReading: null,
          isAcquiring: false,
        );

    state = AsyncData(
      HomeState(
        latestReading: prev.latestReading,
        isAcquiring: true,
        lastIngestFailure: null,
        totalReadings: prev.totalReadings,
        validReadings: prev.validReadings,
        avgTearGlucose: prev.avgTearGlucose,
      ),
    );

    try {
      final authUser = ref.read(authServiceProvider).currentUser;
      if (authUser == null) {
        const failure =
            IngestFailure('You are signed out. Please sign in.', false);
        final d = await _loadDashboard();
        state = AsyncData(
          HomeState(
            latestReading: d.latestReading,
            isAcquiring: false,
            lastIngestFailure: failure,
            totalReadings: d.totalReadings,
            validReadings: d.validReadings,
            avgTearGlucose: d.avgTearGlucose,
          ),
        );
        return failure;
      }

      final connector = ref.read(simulationConnectorProvider.notifier).connector;

      final Future<DataPackage> nextPacket = connector.readingStream.first;
      try {
        await connector.triggerReading();
      } catch (_) {}

      final pkg = await nextPacket.timeout(
        const Duration(seconds: 20),
        onTimeout: () => throw TimeoutException('No reading received from device'),
      );

      final ingestor = await ref.read(dataIngestorProvider.future);
      final estBgEnabled =
          ref.read(estBgSettingsNotifierProvider).valueOrNull ?? false;
      final result = await ingestor.ingest(
        pkg,
        authUser.uid,
        estBgEnabled: estBgEnabled,
      );

      ref.invalidate(historyNotifierProvider);
      ref.invalidate(trendsNotifierProvider);

      switch (result) {
        case IngestSuccess():
          state = AsyncData(await _loadDashboard());
        case final IngestFailure failure:
          final d = await _loadDashboard();
          state = AsyncData(
            HomeState(
              latestReading: d.latestReading,
              isAcquiring: false,
              lastIngestFailure: failure,
              totalReadings: d.totalReadings,
              validReadings: d.validReadings,
              avgTearGlucose: d.avgTearGlucose,
            ),
          );
      }
      return result;
    } on TimeoutException catch (e) {
      final failure = IngestFailure(e.message ?? 'Timed out', true);
      final d = await _loadDashboard();
      state = AsyncData(
        HomeState(
          latestReading: d.latestReading,
          isAcquiring: false,
          lastIngestFailure: failure,
          totalReadings: d.totalReadings,
          validReadings: d.validReadings,
          avgTearGlucose: d.avgTearGlucose,
        ),
      );
      return failure;
    } catch (e) {
      final failure = IngestFailure('$e', true);
      final d = await _loadDashboard();
      state = AsyncData(
        HomeState(
          latestReading: d.latestReading,
          isAcquiring: false,
          lastIngestFailure: failure,
          totalReadings: d.totalReadings,
          validReadings: d.validReadings,
          avgTearGlucose: d.avgTearGlucose,
        ),
      );
      return failure;
    }
  }
}
