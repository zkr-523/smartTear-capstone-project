import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'estimated_bg_resolver.dart';
import 'tg_bg_ml_model.dart';

final tgBgMlModelProvider = Provider<TgBgMlModel>((ref) {
  final model = TgBgMlModel();
  ref.onDispose(model.dispose);
  return model;
});

final tgBgMlModelReadyProvider = FutureProvider<bool>((ref) async {
  final model = ref.watch(tgBgMlModelProvider);
  await model.initialize();
  return model.isReady;
});

final estimatedBgResolverProvider = Provider<EstimatedBgResolver>((ref) {
  return EstimatedBgResolver(ref.watch(tgBgMlModelProvider));
});
