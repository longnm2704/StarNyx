import 'package:flutter_test/flutter_test.dart';
import 'package:starnyx/domain/entities/completion.dart';

// Locks the immutable contract of daily completion records.
void main() {
  test('copyWith updates completion fields by value', () {
    final completion = Completion(
      starnyxId: 'habit-1',
      date: DateTime(2026, 4, 10),
      completed: true,
    );

    final copied = completion.copyWith(completed: false);

    expect(copied.starnyxId, 'habit-1');
    expect(copied.date, DateTime(2026, 4, 10));
    expect(copied.completed, isFalse);
  });
}
