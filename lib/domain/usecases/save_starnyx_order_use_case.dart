import 'package:starnyx/core/services/app_log_service.dart';
import 'package:starnyx/domain/repositories/starnyx_repository.dart';

class SaveStarNyxOrderUseCase {
  const SaveStarNyxOrderUseCase(
    this._repository, {
    AppLogService logger = const NoOpAppLogService(),
  }) : _logger = logger;

  final StarNyxRepository _repository;
  final AppLogService _logger;

  Future<void> call(List<String> orderedIds) async {
    _logger.debug(
      'SaveStarNyxOrderUseCase',
      'save begin count=${orderedIds.length}',
    );
    await _repository.reorderStarnyxs(orderedIds);
    _logger.debug(
      'SaveStarNyxOrderUseCase',
      'save success count=${orderedIds.length}',
    );
  }
}
