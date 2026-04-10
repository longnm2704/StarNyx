import 'package:starnyx/core/utils/date_utils.dart';
import 'package:starnyx/domain/entities/completion.dart';
import 'package:starnyx/domain/repositories/completion_repository.dart';

// Toggles one daily completion record on or off for a StarNyx.
class ToggleCompletionUseCase {
  const ToggleCompletionUseCase(this._repository);

  final CompletionRepository _repository;

  Future<bool> call({required String starnyxId, required DateTime date}) async {
    final normalizedDate = DateUtils.dateOnly(date);
    final existing = await _repository.getCompletionByDate(
      starnyxId: starnyxId,
      date: normalizedDate,
    );

    if (existing?.completed ?? false) {
      await _repository.deleteCompletionByDate(
        starnyxId: starnyxId,
        date: normalizedDate,
      );
      return false;
    }

    await _repository.saveCompletion(
      Completion(starnyxId: starnyxId, date: normalizedDate, completed: true),
    );
    return true;
  }
}
