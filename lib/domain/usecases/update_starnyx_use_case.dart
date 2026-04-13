import 'package:starnyx/core/utils/date_utils.dart';
import 'package:starnyx/domain/entities/starnyx.dart';
import 'package:starnyx/domain/usecases/use_case_validation.dart';
import 'package:starnyx/domain/repositories/starnyx_repository.dart';

// Updates an existing StarNyx while refreshing its updated timestamp.
class UpdateStarNyxUseCase {
  const UpdateStarNyxUseCase(this._repository);

  final StarNyxRepository _repository;

  Future<StarNyx> call(StarNyx starnyx, {DateTime? now}) async {
    final timestamp = now ?? DateTime.now();
    UseCaseValidation.validateStartDate(starnyx.startDate, today: timestamp);
    final updated = starnyx.copyWith(
      startDate: DateUtils.dateOnly(starnyx.startDate),
      reminderTime: starnyx.reminderEnabled ? starnyx.reminderTime : null,
      updatedAt: timestamp,
    );

    await _repository.saveStarnyx(updated);
    return updated;
  }
}
