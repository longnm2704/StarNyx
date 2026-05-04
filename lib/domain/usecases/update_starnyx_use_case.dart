import 'package:starnyx/core/utils/date_utils.dart';
import 'package:starnyx/domain/entities/starnyx.dart';
import 'package:starnyx/core/services/app_log_service.dart';
import 'package:starnyx/domain/usecases/use_case_validation.dart';
import 'package:starnyx/domain/repositories/starnyx_repository.dart';

// Updates an existing StarNyx while refreshing its updated timestamp.
class UpdateStarNyxUseCase {
  const UpdateStarNyxUseCase(
    this._repository, {
    AppLogService logger = const NoOpAppLogService(),
  }) : _logger = logger;

  final StarNyxRepository _repository;
  final AppLogService _logger;

  Future<StarNyx> call(StarNyx starnyx, {DateTime? now}) async {
    final timestamp = now ?? DateTime.now();
    _logger.debug(
      'UpdateStarNyxUseCase',
      'validate id=${starnyx.id} startDate=${starnyx.startDate} '
          'today=$timestamp title="${starnyx.title}" '
          'reminderEnabled=${starnyx.reminderEnabled} '
          'reminderTime=${starnyx.reminderTime}',
    );
    UseCaseValidation.validateStartDate(starnyx.startDate, today: timestamp);
    final updated = starnyx.copyWith(
      startDate: DateUtils.dateOnly(starnyx.startDate),
      reminderTime: starnyx.reminderEnabled ? starnyx.reminderTime : null,
      updatedAt: timestamp,
    );

    _logger.debug(
      'UpdateStarNyxUseCase',
      'saving id=${updated.id} title="${updated.title}" '
          'startDate=${updated.startDate} color=${updated.color}',
    );
    await _repository.saveStarnyx(updated);
    _logger.debug('UpdateStarNyxUseCase', 'saved id=${updated.id}');
    return updated;
  }
}
