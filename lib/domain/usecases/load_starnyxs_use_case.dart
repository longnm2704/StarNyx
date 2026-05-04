import 'package:starnyx/core/services/app_log_service.dart';
import 'package:starnyx/domain/entities/starnyx.dart';
import 'package:starnyx/domain/repositories/starnyx_repository.dart';

// Loads all StarNyx entities for list and picker flows.
class LoadStarnyxsUseCase {
  const LoadStarnyxsUseCase(
    this._repository, {
    AppLogService logger = const NoOpAppLogService(),
  }) : _logger = logger;

  final StarNyxRepository _repository;
  final AppLogService _logger;

  Future<List<StarNyx>> call() async {
    _logger.debug('LoadStarnyxsUseCase', 'load begin');
    final starnyxs = await _repository.getAllStarnyxs();
    _logger.debug(
      'LoadStarnyxsUseCase',
      'load success count=${starnyxs.length}',
    );
    return starnyxs;
  }
}
