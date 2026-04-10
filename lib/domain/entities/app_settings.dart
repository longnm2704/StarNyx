import 'package:equatable/equatable.dart';

const Object _unset = Object();

// Domain object for app-wide settings that are not tied to one screen.
class AppSettings extends Equatable {
  const AppSettings({
    required this.lastSelectedStarnyxId,
    required this.updatedAt,
  });

  final String? lastSelectedStarnyxId;
  final DateTime updatedAt;

  // This keeps selection restore logic easy to read in use cases.
  bool get hasSelectedStarnyx => lastSelectedStarnyxId != null;

  // Copy helpers keep settings updates immutable.
  AppSettings copyWith({
    Object? lastSelectedStarnyxId = _unset,
    DateTime? updatedAt,
  }) {
    return AppSettings(
      lastSelectedStarnyxId: identical(lastSelectedStarnyxId, _unset)
          ? this.lastSelectedStarnyxId
          : lastSelectedStarnyxId as String?,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => <Object?>[lastSelectedStarnyxId, updatedAt];
}
