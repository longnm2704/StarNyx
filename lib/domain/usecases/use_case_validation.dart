import 'package:starnyx/core/constants/enums.dart';
export 'package:starnyx/core/constants/enums.dart';
import 'package:starnyx/core/utils/date_utils.dart';

// Domain use cases throw this when business rules reject an action.
class UseCaseValidationException implements Exception {
  const UseCaseValidationException({required this.code, required this.message});

  final UseCaseValidationCode code;
  final String message;

  @override
  String toString() => 'UseCaseValidationException($code, $message)';
}

// Shared validation helpers keep business rule checks consistent across use cases.
abstract final class UseCaseValidation {
  static void validateStartDate(
    DateTime startDate, {
    DateTime? today,
    bool allowPastStartDate = false,
  }) {
    final normalizedToday = DateUtils.nowDate(today);
    final normalizedStartDate = DateUtils.dateOnly(startDate);

    if (!allowPastStartDate &&
        normalizedStartDate.isBefore(
          normalizedToday.subtract(const Duration(days: 7)),
        )) {
      throw const UseCaseValidationException(
        code: UseCaseValidationCode.startDateTooFarInPast,
        message: 'Start date cannot be earlier than 7 days before today.',
      );
    }

    if (!DateUtils.isFutureDate(startDate, today: today)) {
      return;
    }

    throw const UseCaseValidationException(
      code: UseCaseValidationCode.startDateInFuture,
      message: 'Start date cannot be in the future.',
    );
  }

  static void validateCompletionActionDate({
    required DateTime date,
    required DateTime startDate,
    DateTime? today,
    int editableDays = 7,
  }) {
    if (DateUtils.isFutureDate(date, today: today)) {
      throw const UseCaseValidationException(
        code: UseCaseValidationCode.dateInFuture,
        message: 'Completion date cannot be in the future.',
      );
    }

    if (DateUtils.isBeforeStartDate(date, startDate: startDate)) {
      throw const UseCaseValidationException(
        code: UseCaseValidationCode.dateBeforeStartDate,
        message:
            'Completion date cannot be earlier than the StarNyx start date.',
      );
    }

    if (!DateUtils.isEditableWithinDays(
      date,
      days: editableDays,
      today: today,
    )) {
      throw const UseCaseValidationException(
        code: UseCaseValidationCode.completionEditWindowExpired,
        message: 'Completion can only be edited within the last 7 days.',
      );
    }
  }
}
