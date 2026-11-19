import 'package:starnyx/core/services/app_log_service.dart';
import 'package:starnyx/domain/repositories/completion_repository.dart';

/// Counts how many of the given habits have a completion on [date].
///
/// The habit list footer needs one aggregate number without loading full
/// history for every habit, so this use case fans out to the targeted
/// completion lookup already exposed by the repository.
class CountHabitsCompletedOnDateUseCase {
  const CountHabitsCompletedOnDateUseCase(
    this._repository, {
    AppLogService logger = const NoOpAppLogService(),
  }) : _logger = logger;

  final CompletionRepository _repository;
  final AppLogService _logger;

  Future<int> call({
    required List<String> starnyxIds,
    required DateTime date,
  }) async {
    if (starnyxIds.isEmpty) {
      return 0;
    }

    _logger.debug(
      'CountHabitsCompletedOnDateUseCase',
      'count begin date=$date habits=${starnyxIds.length}',
    );
    final completions = await Future.wait(
      starnyxIds.map(
        (String id) =>
            _repository.getCompletionByDate(starnyxId: id, date: date),
      ),
    );
    final count = completions
        .where((completion) => completion?.completed ?? false)
        .length;
    _logger.debug(
      'CountHabitsCompletedOnDateUseCase',
      'count success date=$date count=$count',
    );
    return count;
  }
}
