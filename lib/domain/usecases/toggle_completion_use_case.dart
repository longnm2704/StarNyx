import 'package:starnyx/core/utils/date_utils.dart';
import 'package:starnyx/core/services/app_log_service.dart';
import 'package:starnyx/domain/entities/completion.dart';
import 'package:starnyx/domain/usecases/use_case_validation.dart';
import 'package:starnyx/domain/repositories/starnyx_repository.dart';
import 'package:starnyx/domain/repositories/completion_repository.dart';

// Toggles one daily completion record on or off for a StarNyx.
class ToggleCompletionUseCase {
  const ToggleCompletionUseCase(
    this._starnyxRepository,
    this._repository, {
    AppLogService logger = const NoOpAppLogService(),
  }) : _logger = logger;

  final StarNyxRepository _starnyxRepository;
  final CompletionRepository _repository;
  final AppLogService _logger;

  Future<bool> call({
    required String starnyxId,
    required DateTime date,
    DateTime? today,
  }) async {
    final normalizedDate = DateUtils.dateOnly(date);
    _logger.debug(
      'ToggleCompletionUseCase',
      'toggle begin starnyxId=$starnyxId date=$normalizedDate today=$today',
    );
    final starnyx = await _starnyxRepository.getStarnyxById(starnyxId);
    if (starnyx == null) {
      throw StateError('StarNyx with id $starnyxId was not found.');
    }
    UseCaseValidation.validateCompletionActionDate(
      date: normalizedDate,
      startDate: starnyx.startDate,
      today: today,
    );
    final existing = await _repository.getCompletionByDate(
      starnyxId: starnyxId,
      date: normalizedDate,
    );

    if (existing?.completed ?? false) {
      await _repository.deleteCompletionByDate(
        starnyxId: starnyxId,
        date: normalizedDate,
      );
      _logger.debug(
        'ToggleCompletionUseCase',
        'toggle success completed=false starnyxId=$starnyxId date=$normalizedDate',
      );
      return false;
    }

    await _repository.saveCompletion(
      Completion(starnyxId: starnyxId, date: normalizedDate, completed: true),
    );
    _logger.debug(
      'ToggleCompletionUseCase',
      'toggle success completed=true starnyxId=$starnyxId date=$normalizedDate',
    );
    return true;
  }
}
