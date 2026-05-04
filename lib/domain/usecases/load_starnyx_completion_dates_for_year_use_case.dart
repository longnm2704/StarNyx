import 'package:starnyx/core/utils/date_utils.dart';
import 'package:starnyx/core/services/app_log_service.dart';
import 'package:starnyx/domain/repositories/completion_repository.dart';

// Loads completed calendar days for one StarNyx inside a target year.
class LoadStarNyxCompletionDatesForYearUseCase {
  const LoadStarNyxCompletionDatesForYearUseCase(
    this._completionRepository, {
    AppLogService logger = const NoOpAppLogService(),
  }) : _logger = logger;

  final CompletionRepository _completionRepository;
  final AppLogService _logger;

  Future<List<DateTime>> call({
    required String starnyxId,
    required int year,
  }) async {
    _logger.debug(
      'LoadStarNyxCompletionDatesForYearUseCase',
      'load begin starnyxId=$starnyxId year=$year',
    );
    final completions = await _completionRepository.getCompletionsForStarnyx(
      starnyxId,
    );
    final uniqueDates =
        completions
            .where(
              (completion) =>
                  completion.completed && completion.date.year == year,
            )
            .map((completion) => DateUtils.dateOnly(completion.date))
            .toSet()
            .toList(growable: false)
          ..sort((left, right) => left.compareTo(right));

    _logger.debug(
      'LoadStarNyxCompletionDatesForYearUseCase',
      'load success starnyxId=$starnyxId year=$year count=${uniqueDates.length}',
    );
    return uniqueDates;
  }
}
