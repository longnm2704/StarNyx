import 'package:starnyx/core/utils/date_utils.dart';
import 'package:starnyx/domain/repositories/completion_repository.dart';

// Loads completed calendar days for one StarNyx inside a target year.
class LoadStarNyxCompletionDatesForYearUseCase {
  const LoadStarNyxCompletionDatesForYearUseCase(this._completionRepository);

  final CompletionRepository _completionRepository;

  Future<List<DateTime>> call({
    required String starnyxId,
    required int year,
  }) async {
    final completions = await _completionRepository.getCompletionsForStarnyx(
      starnyxId,
    );
    final uniqueDates = completions
        .where((completion) => completion.completed && completion.date.year == year)
        .map((completion) => DateUtils.dateOnly(completion.date))
        .toSet()
        .toList(growable: false)
      ..sort((left, right) => left.compareTo(right));

    return uniqueDates;
  }
}
