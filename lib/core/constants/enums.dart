enum AppConfirmActionStyle { neutral, destructive }

enum UseCaseValidationCode {
  startDateInFuture,
  startDateTooFarInPast,
  dateInFuture,
  dateBeforeStartDate,
  completionEditWindowExpired,
  journalEntryAlreadyExists,
}

enum StarnyxFormMode { create, edit }

enum AsyncStatus { idle, inProgress, success, failure }

enum StarnyxFormTitleError { empty }

enum StarnyxFormStartDateError { inFuture, tooFarInPast }

enum StarnyxFormReminderTimeError { missing, invalid }

enum HomeStatus { initial, loading, success, failure }

enum ConstellationSwitcherSheetActionType { createRequested, editRequested }

enum HomeGridStarDayState { beforeStart, completed, missed, future }
