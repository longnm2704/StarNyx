import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:starnyx/domain/entities/domain_entities.dart';
import 'package:starnyx/domain/repositories/domain_repositories.dart';
import 'package:starnyx/domain/usecases/domain_usecases.dart';
import 'package:starnyx/features/journal/presentation/bloc/journal_bloc.dart';
import 'package:starnyx/features/journal/presentation/pages/journal_editor_page.dart';
import 'package:starnyx/features/journal/presentation/pages/journal_page.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    rootBundle.clear();
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await EasyLocalization.ensureInitialized();
  });

  final habit = StarNyx(
    id: 'habit-1',
    title: 'Đọc sách',
    description: null,
    color: '#10B981',
    startDate: DateTime(2026, 11, 1),
    reminderEnabled: false,
    reminderTime: null,
    createdAt: DateTime(2026, 11, 1, 8),
    updatedAt: DateTime(2026, 11, 1, 8),
  );

  JournalEntry entry(int id, String content, DateTime at) => JournalEntry(
    id: id,
    starnyxId: 'habit-1',
    date: DateTime(at.year, at.month, at.day),
    content: content,
    createdAt: at,
  );

  testWidgets('renders entries with title, timestamp and habit subtitle', (
    tester,
  ) async {
    final repository = _InMemoryJournalEntryRepository([
      entry(1, 'Buổi sáng yên tĩnh', DateTime(2026, 11, 19, 13, 44)),
      entry(2, 'Tập gym\nGiải tỏa căng thẳng', DateTime(2026, 11, 19, 13, 45)),
    ]);
    await _render(tester, repository, habit);

    expect(find.text('Nhật ký'), findsOneWidget);
    expect(find.text('Đọc sách'), findsOneWidget);
    expect(find.text('Nhật ký ngày 19'), findsOneWidget);
    expect(find.text('Buổi sáng yên tĩnh'), findsOneWidget);
    expect(find.text('Tập gym'), findsOneWidget);
    expect(find.text('Giải tỏa căng thẳng'), findsOneWidget);
    expect(find.text('19/11/2026 13:44'), findsOneWidget);
    expect(find.byType(JournalEntryCard), findsNWidgets(2));
  });

  testWidgets('search filters entries by content', (tester) async {
    final repository = _InMemoryJournalEntryRepository([
      entry(1, 'Uống trà xanh', DateTime(2026, 11, 18, 9)),
      entry(2, 'Chạy bộ buổi tối', DateTime(2026, 11, 19, 20)),
    ]);
    await _render(tester, repository, habit);

    await tester.tap(find.byKey(const Key('journal-search-button')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('journal-search-field')),
      'chạy',
    );
    await tester.pump();

    expect(find.text('Chạy bộ buổi tối'), findsOneWidget);
    expect(find.text('Uống trà xanh'), findsNothing);

    await tester.enterText(
      find.byKey(const Key('journal-search-field')),
      'không có',
    );
    await tester.pump();
    expect(find.text('Không có ghi chú nào khớp.'), findsOneWidget);
  });

  testWidgets('send is disabled when empty and saves the draft', (
    tester,
  ) async {
    final repository = _InMemoryJournalEntryRepository([]);
    await _render(tester, repository, habit);

    final sendButton = find.byKey(const Key('journal-send-button'));
    expect(tester.widget<InkWell>(sendButton).onTap, isNull);

    await tester.enterText(
      find.byKey(const Key('journal-input')),
      'Một ngày nhẹ nhàng',
    );
    await tester.pump();
    expect(tester.widget<InkWell>(sendButton).onTap, isNotNull);

    await tester.tap(sendButton);
    await tester.pumpAndSettle();

    final saved = await repository.getJournalEntriesForStarnyx('habit-1');
    expect(saved.single.content, 'Một ngày nhẹ nhàng');
    expect(find.text('Một ngày nhẹ nhàng'), findsOneWidget);
    expect(tester.widget<InkWell>(sendButton).onTap, isNull);
  });

  testWidgets('editor edits an entry in place keeping id and createdAt', (
    tester,
  ) async {
    final original = entry(1, 'Buổi sáng yên tĩnh', DateTime(2026, 11, 19, 7));
    final repository = _InMemoryJournalEntryRepository([original]);
    await _render(tester, repository, habit);

    final context = tester.element(find.byType(JournalEntryCard));
    unawaited(
      JournalEditorPage.open(
        context,
        bloc: context.read<JournalBloc>(),
        entry: original,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Chỉnh sửa ghi chép'), findsOneWidget);
    expect(find.text('19/11/2026 07:00'), findsOneWidget);
    final save = find.byKey(const Key('journal-editor-save'));
    await tester.enterText(find.byKey(const Key('journal-editor-input')), ' ');
    await tester.pump();
    expect(tester.widget<TextButton>(save).onPressed, isNull);

    await tester.enterText(
      find.byKey(const Key('journal-editor-input')),
      'Buổi sáng yên tĩnh và trong lành',
    );
    await tester.pump();
    await tester.tap(save);
    await tester.pumpAndSettle();

    expect(find.byType(JournalEditorPage), findsNothing);
    expect(find.text('Buổi sáng yên tĩnh và trong lành'), findsOneWidget);
    final saved = await repository.getJournalEntriesForStarnyx('habit-1');
    expect(saved, [
      original.copyWith(content: 'Buổi sáng yên tĩnh và trong lành'),
    ]);
  });

  testWidgets('expand opens the editor in create mode with the draft', (
    tester,
  ) async {
    final repository = _InMemoryJournalEntryRepository([]);
    await _render(tester, repository, habit);

    await tester.enterText(find.byKey(const Key('journal-input')), 'Bắt đầu');
    await tester.tap(find.byKey(const Key('journal-expand-button')));
    await tester.pumpAndSettle();

    expect(find.text('Ghi chép mới'), findsOneWidget);
    await tester.enterText(
      find.byKey(const Key('journal-editor-input')),
      'Bắt đầu\nMột ngày dài',
    );
    await tester.tap(find.byKey(const Key('journal-editor-save')));
    await tester.pumpAndSettle();

    expect(find.byType(JournalEditorPage), findsNothing);
    final saved = await repository.getJournalEntriesForStarnyx('habit-1');
    expect(saved.single.content, 'Bắt đầu\nMột ngày dài');
    expect(
      tester
          .widget<TextField>(find.byKey(const Key('journal-input')))
          .controller!
          .text,
      isEmpty,
    );
  });

  testWidgets('editor saves mood, energy, sleep and tags; card shows chips', (
    tester,
  ) async {
    final repository = _InMemoryJournalEntryRepository([]);
    await _render(tester, repository, habit);

    await tester.tap(find.byKey(const Key('journal-expand-button')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('journal-editor-input')),
      'Ngủ sớm',
    );
    await tester.tap(find.byKey(const Key('journal-mood-energized')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('journal-mood-calm')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('journal-energy-4')));
    await tester.pump();

    await tester.ensureVisible(find.byKey(const Key('journal-sleep-button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('journal-sleep-button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('journal-sleep-done')));
    await tester.pumpAndSettle();
    expect(find.text('7h 00m'), findsOneWidget);

    await tester.ensureVisible(find.byKey(const Key('journal-tag-input')));
    await tester.enterText(
      find.byKey(const Key('journal-tag-input')),
      '#NguSom',
    );
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    expect(find.text('#NguSom'), findsOneWidget);
    // A tag left in the field is saved too.
    await tester.enterText(find.byKey(const Key('journal-tag-input')), 'Detox');

    await tester.tap(find.byKey(const Key('journal-editor-save')));
    await tester.pumpAndSettle();

    final saved = (await repository.getJournalEntriesForStarnyx(
      'habit-1',
    )).single;
    expect(saved.mood, JournalMood.calm);
    expect(saved.energy, 4);
    expect(saved.sleepMinutes, 420);
    expect(saved.tags, <String>['NguSom', 'Detox']);

    final card = find.byType(JournalEntryCard);
    expect(
      find.descendant(of: card, matching: find.text('Bình an')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: card, matching: find.text('#NguSom')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: card, matching: find.text('#Detox')),
      findsOneWidget,
    );
  });

  testWidgets('editor edit mode can clear metadata', (tester) async {
    final original = JournalEntry(
      id: 1,
      starnyxId: 'habit-1',
      date: DateTime(2026, 11, 19),
      content: 'Mệt',
      createdAt: DateTime(2026, 11, 19, 22),
      mood: JournalMood.tired,
      energy: 2,
      tags: const <String>['HoiPhuc'],
    );
    final repository = _InMemoryJournalEntryRepository([original]);
    await _render(tester, repository, habit);
    expect(find.text('Mỏi mệt'), findsOneWidget);

    final context = tester.element(find.byType(JournalEntryCard));
    unawaited(
      JournalEditorPage.open(
        context,
        bloc: context.read<JournalBloc>(),
        entry: original,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('journal-mood-tired')));
    await tester.tap(find.byKey(const Key('journal-energy-2')));
    await tester.pump();
    await tester.ensureVisible(find.text('#HoiPhuc'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.widgetWithText(InputChip, '#HoiPhuc'),
        matching: find.byTooltip('Xóa từ khóa HoiPhuc'),
      ),
    );
    await tester.pump();
    await tester.tap(find.byKey(const Key('journal-editor-save')));
    await tester.pumpAndSettle();

    final saved = (await repository.getJournalEntriesForStarnyx(
      'habit-1',
    )).single;
    expect(saved, entry(1, 'Mệt', DateTime(2026, 11, 19, 22)));
  });

  testWidgets('shows empty state when there are no entries', (tester) async {
    await _render(tester, _InMemoryJournalEntryRepository([]), habit);

    expect(find.text('Chưa có gì được ghi lại'), findsOneWidget);
    expect(find.byType(JournalEntryCard), findsNothing);
  });
}

Future<void> _render(
  WidgetTester tester,
  _InMemoryJournalEntryRepository repository,
  StarNyx habit,
) async {
  final bloc = JournalBloc(
    saveJournalEntryUseCase: SaveJournalEntryUseCase(repository),
    watchJournalEntriesForStarnyxUseCase: WatchJournalEntriesForStarnyxUseCase(
      repository,
    ),
    deleteJournalEntryUseCase: DeleteJournalEntryUseCase(repository),
    nowBuilder: () => DateTime(2026, 11, 19, 21),
  );
  addTearDown(bloc.close);
  await tester.pumpWidget(
    EasyLocalization(
      supportedLocales: const <Locale>[Locale('vi')],
      fallbackLocale: const Locale('vi'),
      path: 'assets/translations',
      useOnlyLangCode: true,
      child: Builder(
        builder: (context) => MaterialApp(
          locale: const Locale('vi'),
          supportedLocales: const <Locale>[Locale('vi')],
          localizationsDelegates: context.localizationDelegates,
          home: JournalPage(
            bloc: bloc,
            loadActiveStarNyxUseCase: _FakeLoadActiveStarNyxUseCase(habit),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

class _FakeLoadActiveStarNyxUseCase implements LoadActiveStarNyxUseCase {
  _FakeLoadActiveStarNyxUseCase(this.habit);

  final StarNyx? habit;

  @override
  Future<StarNyx?> call({DateTime? now}) async => habit;
}

class _InMemoryJournalEntryRepository implements JournalEntryRepository {
  _InMemoryJournalEntryRepository(List<JournalEntry> initial)
    : _items = List<JournalEntry>.of(initial);

  final List<JournalEntry> _items;
  final StreamController<void> _changes = StreamController<void>.broadcast();

  List<JournalEntry> _sorted(String starnyxId) =>
      _items.where((e) => e.starnyxId == starnyxId).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  @override
  Future<List<JournalEntry>> getJournalEntriesForStarnyx(
    String starnyxId,
  ) async => _sorted(starnyxId);

  @override
  Stream<List<JournalEntry>> watchJournalEntriesForStarnyx(String starnyxId) {
    return Stream<List<JournalEntry>>.multi((controller) {
      controller.add(_sorted(starnyxId));
      final sub = _changes.stream.listen(
        (_) => controller.add(_sorted(starnyxId)),
      );
      controller.onCancel = sub.cancel;
    });
  }

  @override
  Future<List<JournalEntry>> getJournalEntriesForDate({
    required String starnyxId,
    required DateTime date,
  }) async => _sorted(starnyxId).where((e) => e.date == date).toList();

  @override
  Future<void> saveJournalEntry(JournalEntry entry) async {
    _items.add(entry.id == 0 ? entry.copyWith(id: _items.length + 1) : entry);
    _changes.add(null);
  }

  @override
  Future<void> updateJournalEntry(JournalEntry entry) async {
    final index = _items.indexWhere((e) => e.id == entry.id);
    if (index >= 0) _items[index] = entry;
    _changes.add(null);
  }

  @override
  Future<void> deleteJournalEntryById(int id) async {
    _items.removeWhere((e) => e.id == id);
    _changes.add(null);
  }

  @override
  Future<void> deleteJournalEntriesForStarnyx(String starnyxId) async {
    _items.removeWhere((e) => e.starnyxId == starnyxId);
    _changes.add(null);
  }
}
