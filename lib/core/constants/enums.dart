enum AppConfirmActionStyle { neutral, destructive }

enum UseCaseValidationCode {
  startDateInFuture,
  startDateTooFarInPast,
  dateInFuture,
  dateBeforeStartDate,
  completionEditWindowExpired,
}

enum StarnyxFormMode { create, edit }

enum AsyncStatus { idle, inProgress, success, failure }

enum StarnyxFormTitleError { empty, tooLong }

enum StarnyxFormDescriptionError { tooLong }

enum StarnyxFormStartDateError { inFuture, tooFarInPast }

enum StarnyxFormReminderTimeError { missing, invalid }

enum HomeStatus { initial, loading, success, failure }

enum OverviewStatus { initial, loading, success, failure }

enum OverviewRange { week, month, year }

enum JournalStatus { initial, loading, success, failure }

enum HomeGridStarDayState { beforeStart, completed, missed, future }
