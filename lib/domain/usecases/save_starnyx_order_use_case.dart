import 'package:starnyx/core/services/app_log_service.dart';
import 'package:starnyx/core/services/starnyx_order_store.dart';

class SaveStarNyxOrderUseCase {
  const SaveStarNyxOrderUseCase(
    this._orderStore, {
    AppLogService logger = const NoOpAppLogService(),
  }) : _logger = logger;

  final StarNyxOrderStore _orderStore;
  final AppLogService _logger;

  Future<void> call(List<String> orderedIds) async {
    _logger.debug(
      'SaveStarNyxOrderUseCase',
      'save begin count=${orderedIds.length}',
    );
    await _orderStore.saveOrder(orderedIds);
    _logger.debug(
      'SaveStarNyxOrderUseCase',
      'save success count=${orderedIds.length}',
    );
  }
}
