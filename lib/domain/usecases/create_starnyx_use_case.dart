import 'package:uuid/uuid.dart';
import 'package:starnyx/core/utils/date_utils.dart';
import 'package:starnyx/domain/entities/starnyx.dart';
import 'package:starnyx/core/services/app_log_service.dart';
import 'package:starnyx/domain/usecases/use_case_validation.dart';
import 'package:starnyx/domain/repositories/starnyx_repository.dart';

// Creates a new StarNyx entity with generated id and timestamps.
class CreateStarNyxUseCase {
  const CreateStarNyxUseCase(
    this._repository,
    this._uuid, {
    AppLogService logger = const NoOpAppLogService(),
  }) : _logger = logger;

  final StarNyxRepository _repository;
  final Uuid _uuid;
  final AppLogService _logger;

  Future<StarNyx> call({
    required String title,
    required String? description,
    required String color,
    required DateTime startDate,
    required bool reminderEnabled,
    required String? reminderTime,
    DateTime? now,
  }) async {
    final timestamp = now ?? DateTime.now();
    _logger.debug(
      'CreateStarNyxUseCase',
      'validate startDate=$startDate today=$timestamp title="$title" '
          'reminderEnabled=$reminderEnabled reminderTime=$reminderTime',
    );
    UseCaseValidation.validateStartDate(startDate, today: timestamp);
    final normalizedReminderTime = reminderEnabled ? reminderTime : null;
    final starnyx = StarNyx(
      id: _uuid.v4(),
      title: title,
      description: description,
      color: color,
      startDate: DateUtils.dateOnly(startDate),
      reminderEnabled: reminderEnabled,
      reminderTime: normalizedReminderTime,
      createdAt: timestamp,
      updatedAt: timestamp,
    );

    _logger.debug(
      'CreateStarNyxUseCase',
      'saving id=${starnyx.id} title="${starnyx.title}" '
          'startDate=${starnyx.startDate} color=${starnyx.color}',
    );
    await _repository.saveStarnyx(starnyx);
    _logger.debug('CreateStarNyxUseCase', 'saved id=${starnyx.id}');
    return starnyx;
  }
}
