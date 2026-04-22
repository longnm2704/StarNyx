import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:starnyx/app/di/service_locator.dart';
import 'package:starnyx/domain/entities/domain_entities.dart';
import 'package:starnyx/domain/repositories/domain_repositories.dart';
import 'package:starnyx/domain/usecases/domain_usecases.dart';
import 'package:starnyx/features/journal/presentation/bloc/journal_bloc.dart';
import 'package:starnyx/features/journal/presentation/pages/journal_bottom_sheet.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await EasyLocalization.ensureInitialized();
  });

  tearDown(() async {
    await resetDependencies();
  });

  testWidgets('journal bottom sheet saves draft and renders new entry', (
    tester,
  ) async {
    final repository = _InMemoryJournalEntryRepository();
    final saveUseCase = SaveJournalEntryUseCase(repository);
    final watchUseCase = WatchJournalEntriesForStarnyxUseCase(repository);
    final deleteUseCase = DeleteJournalEntryUseCase(repository);

    serviceLocator.registerFactory<JournalBloc>(
      () => JournalBloc(
        saveJournalEntryUseCase: saveUseCase,
        watchJournalEntriesForStarnyxUseCase: watchUseCase,
        deleteJournalEntryUseCase: deleteUseCase,
        nowBuilder: () => DateTime(2026, 4, 13, 10, 20),
      ),
    );

    await tester.pumpWidget(
      _buildLocalizedApp(
        JournalBottomSheet(
          starnyxId: 'habit-1',
          accentColor: const Color(0xFF2360E9),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Journal'), findsOneWidget);
    expect(find.text('Write a quick note about today...'), findsOneWidget);

    await tester.enterText(
      find.byType(EditableText).first,
      'Checked in and felt great.',
    );
    await tester.pump();
    await tester.tap(find.byIcon(Icons.send_rounded));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Checked in and felt great.'), findsWidgets);
    expect(
      await repository.getJournalEntriesForStarnyx('habit-1'),
      hasLength(1),
    );
  });
}

Widget _buildLocalizedApp(Widget child) {
  return EasyLocalization(
    supportedLocales: const <Locale>[Locale('en')],
    fallbackLocale: const Locale('en'),
    path: 'assets/translations',
    useOnlyLangCode: true,
    child: Builder(
      builder: (context) {
        return MaterialApp(
          locale: context.locale,
          supportedLocales: context.supportedLocales,
          localizationsDelegates: context.localizationDelegates,
          home: Scaffold(body: child),
        );
      },
    ),
  );
}

class _InMemoryJournalEntryRepository implements JournalEntryRepository {
  final List<JournalEntry> _entries = <JournalEntry>[];
  final StreamController<List<JournalEntry>> _controller =
      StreamController<List<JournalEntry>>.broadcast();
  int _nextId = 1;

  @override
  Future<void> deleteJournalEntriesForStarnyx(String starnyxId) async {
    _entries.removeWhere((entry) => entry.starnyxId == starnyxId);
    _emit(starnyxId);
  }

  @override
  Future<void> deleteJournalEntryById(int id) async {
    JournalEntry? entry;
    for (final item in _entries) {
      if (item.id == id) {
        entry = item;
        break;
      }
    }
    _entries.removeWhere((item) => item.id == id);
    if (entry != null) {
      _emit(entry.starnyxId);
    }
  }

  @override
  Future<List<JournalEntry>> getJournalEntriesForDate({
    required String starnyxId,
    required DateTime date,
  }) async {
    return _entries
        .where(
          (entry) =>
              entry.starnyxId == starnyxId &&
              entry.date.year == date.year &&
              entry.date.month == date.month &&
              entry.date.day == date.day,
        )
        .toList(growable: false);
  }

  @override
  Future<List<JournalEntry>> getJournalEntriesForStarnyx(
    String starnyxId,
  ) async {
    final entries = _entries
        .where((entry) => entry.starnyxId == starnyxId)
        .toList(growable: false);
    entries.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return entries;
  }

  @override
  Future<void> saveJournalEntry(JournalEntry entry) async {
    _entries.add(
      entry.copyWith(id: _nextId++, createdAt: DateTime(2026, 4, 13, 10, 20)),
    );
    _emit(entry.starnyxId);
  }

  @override
  Stream<List<JournalEntry>> watchJournalEntriesForStarnyx(String starnyxId) {
    Future<void>.microtask(() => _emit(starnyxId));
    return _controller.stream.map(
      (entries) => entries
          .where((entry) => entry.starnyxId == starnyxId)
          .toList(growable: false),
    );
  }

  void _emit(String starnyxId) async {
    _controller.add(await getJournalEntriesForStarnyx(starnyxId));
  }
}
