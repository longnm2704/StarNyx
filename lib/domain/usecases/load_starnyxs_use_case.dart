import 'package:starnyx/core/services/app_log_service.dart';
import 'package:starnyx/core/services/starnyx_order_store.dart';
import 'package:starnyx/domain/entities/starnyx.dart';
import 'package:starnyx/domain/repositories/starnyx_repository.dart';

// Loads all StarNyx entities for list and picker flows.
class LoadStarnyxsUseCase {
  const LoadStarnyxsUseCase(
    this._repository, {
    StarNyxOrderStore? orderStore,
    AppLogService logger = const NoOpAppLogService(),
  }) : _orderStore = orderStore,
       _logger = logger;

  final StarNyxRepository _repository;
  final StarNyxOrderStore? _orderStore;
  final AppLogService _logger;

  Future<List<StarNyx>> call() async {
    _logger.debug('LoadStarnyxsUseCase', 'load begin');
    final starnyxs = await _repository.getAllStarnyxs();
    final ordered = await _applyStoredOrder(starnyxs);
    _logger.debug(
      'LoadStarnyxsUseCase',
      'load success count=${ordered.length}',
    );
    return ordered;
  }

  Future<List<StarNyx>> _applyStoredOrder(List<StarNyx> starnyxs) async {
    final orderStore = _orderStore;
    if (orderStore == null || starnyxs.length < 2) {
      return starnyxs;
    }

    final orderedIds = await orderStore.loadOrder();
    if (orderedIds.isEmpty) {
      return starnyxs;
    }

    final byId = <String, StarNyx>{
      for (final starnyx in starnyxs) starnyx.id: starnyx,
    };
    final ordered = <StarNyx>[];
    final usedIds = <String>{};
    for (final id in orderedIds) {
      final starnyx = byId[id];
      if (starnyx != null && usedIds.add(id)) {
        ordered.add(starnyx);
      }
    }

    for (final starnyx in starnyxs) {
      if (usedIds.add(starnyx.id)) {
        ordered.add(starnyx);
      }
    }

    return ordered;
  }
}
