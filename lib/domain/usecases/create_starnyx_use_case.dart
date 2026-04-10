import 'package:uuid/uuid.dart';
import 'package:starnyx/core/utils/date_utils.dart';
import 'package:starnyx/domain/entities/starnyx.dart';
import 'package:starnyx/domain/repositories/starnyx_repository.dart';

// Creates a new StarNyx entity with generated id and timestamps.
class CreateStarNyxUseCase {
  const CreateStarNyxUseCase(this._repository, this._uuid);

  final StarNyxRepository _repository;
  final Uuid _uuid;

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
    final starnyx = StarNyx(
      id: _uuid.v4(),
      title: title,
      description: description,
      color: color,
      startDate: DateUtils.dateOnly(startDate),
      reminderEnabled: reminderEnabled,
      reminderTime: reminderTime,
      createdAt: timestamp,
      updatedAt: timestamp,
    );

    await _repository.saveStarnyx(starnyx);
    return starnyx;
  }
}
