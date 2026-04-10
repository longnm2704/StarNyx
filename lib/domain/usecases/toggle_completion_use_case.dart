import 'package:starnyx/core/utils/date_utils.dart';
import 'package:starnyx/domain/entities/completion.dart';
import 'package:starnyx/domain/usecases/use_case_validation.dart';
import 'package:starnyx/domain/repositories/starnyx_repository.dart';
import 'package:starnyx/domain/repositories/completion_repository.dart';

// Toggles one daily completion record on or off for a StarNyx.
class ToggleCompletionUseCase {
  const ToggleCompletionUseCase(this._starnyxRepository, this._repository);

  final StarNyxRepository _starnyxRepository;
  final CompletionRepository _repository;

  Future<bool> call({
    required String starnyxId,
    required DateTime date,
    DateTime? today,
  }) async {
    final normalizedDate = DateUtils.dateOnly(date);
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
      return false;
    }

    await _repository.saveCompletion(
      Completion(starnyxId: starnyxId, date: normalizedDate, completed: true),
    );
    return true;
  }
}
