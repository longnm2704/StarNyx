import 'package:equatable/equatable.dart';

/// On-disk size of the local database plus row counts per user table.
class StorageStats extends Equatable {
  const StorageStats({
    required this.bytes,
    required this.habitCount,
    required this.completionCount,
    required this.journalCount,
  });

  final int bytes;
  final int habitCount;
  final int completionCount;
  final int journalCount;

  @override
  List<Object?> get props => [bytes, habitCount, completionCount, journalCount];
}
