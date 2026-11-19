import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';
import 'package:starnyx/core/constants/core_constants.dart';
import 'package:starnyx/core/widgets/app_icon.dart';
import 'package:starnyx/features/home/presentation/pages/home_page.dart';
import 'package:starnyx/features/journal/presentation/pages/journal_page.dart';
import 'package:starnyx/features/overview/presentation/pages/overview_page.dart';
import 'package:starnyx/features/settings/presentation/pages/settings_page.dart';
import 'package:starnyx/features/starnyx_form/presentation/pages/create_starnyx_bottom_sheet.dart';

/// Stable ids for the four primary destinations hosted by [AppShell].
enum AppShellTab { habits, overview, journal, settings }

extension AppShellTabX on AppShellTab {
  String get labelKey {
    return switch (this) {
      AppShellTab.habits => 'nav.habits',
      AppShellTab.overview => 'nav.overview',
      AppShellTab.journal => 'nav.journal',
      AppShellTab.settings => 'nav.settings',
    };
  }

  List<List<dynamic>> get icon {
    return switch (this) {
      AppShellTab.habits =>
        HugeIconsStrokeRounded.strokeRoundedCheckmarkCircle02,
      AppShellTab.overview => HugeIconsStrokeRounded.strokeRoundedChartBarLine,
      AppShellTab.journal => HugeIconsStrokeRounded.strokeRoundedNote01,
      AppShellTab.settings => HugeIconsStrokeRounded.strokeRoundedSettings01,
    };
  }
}

/// Root navigation shell.
///
/// Every top-level tab is kept alive in an [IndexedStack] so scroll offsets,
/// in-progress check-ins, and search state survive tab switches. Tab taps
/// update local state instead of pushing routes; deep links choose the initial
/// tab via [initialTab]. System back on any tab other than Habits returns to
/// Habits, matching the platform habit of backing out of a secondary section
/// before leaving the app.
class AppShell extends StatefulWidget {
  const AppShell({
    this.initialTab = AppShellTab.habits,
    this.initialAccentColor,
    this.tabs,
    super.key,
  });

  final AppShellTab initialTab;
  final Color? initialAccentColor;

  /// Optional injected tab children (indexed by [AppShellTab]). Used by tests
  /// and by future feature modules that want to compose the shell themselves.
  final List<Widget>? tabs;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  late int _index = widget.initialTab.index;
  int _homeReloadToken = 0;
  int _overviewReloadToken = 0;
  int _journalReloadToken = 0;
  int _settingsReloadToken = 0;

  void _selectIndex(int index) {
    if (index == _index) {
      return;
    }
    setState(() {
      _index = index;
      // Habits, check-ins, or the active habit may have changed on another tab.
      if (index == AppShellTab.overview.index) _overviewReloadToken++;
      if (index == AppShellTab.journal.index) _journalReloadToken++;
      if (index == AppShellTab.settings.index) _settingsReloadToken++;
    });
  }

  Future<void> _openCreateHabit() async {
    final result = await showCreateStarnyxBottomSheet(context);
    if (!mounted || result == null || !result.hasChanges) {
      return;
    }
    setState(() {
      _homeReloadToken++;
    });
  }

  List<Widget> _buildTabs() {
    final injected = widget.tabs;
    if (injected != null) {
      assert(injected.length == AppShellTab.values.length);
      return injected;
    }

    return <Widget>[
      HomePage(
        initialAccentColor: widget.initialAccentColor,
        reloadToken: _homeReloadToken,
        onCreatePressed: _openCreateHabit,
        onSettingsPressed: () => _selectIndex(AppShellTab.settings.index),
        onJournalPressed: () => _selectIndex(AppShellTab.journal.index),
      ),
      OverviewPage(
        key: const ValueKey<String>('overview-tab'),
        reloadToken: _overviewReloadToken,
        onProfilePressed: () => _selectIndex(AppShellTab.settings.index),
      ),
      JournalPage(
        key: const ValueKey<String>('journal-tab'),
        reloadToken: _journalReloadToken,
      ),
      SettingsPage(
        key: const ValueKey<String>('settings-tab'),
        reloadToken: _settingsReloadToken,
        // Import or delete-all replaced everything: show the fresh Habits tab.
        onDataReplaced: () => setState(() {
          _homeReloadToken++;
          _index = AppShellTab.habits.index;
        }),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _index == AppShellTab.habits.index,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (!didPop && _index != AppShellTab.habits.index) {
          _selectIndex(AppShellTab.habits.index);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: IndexedStack(index: _index, children: _buildTabs()),
        bottomNavigationBar: AppShellBottomNavBar(
          currentIndex: _index,
          onDestinationSelected: _selectIndex,
        ),
      ),
    );
  }
}

/// Translucent bottom navigation bar from the Obsidian Lumina mockup.
class AppShellBottomNavBar extends StatelessWidget {
  const AppShellBottomNavBar({
    required this.currentIndex,
    required this.onDestinationSelected,
    super.key,
  });

  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;

  static const double height = 64;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.black.withValues(alpha: 0.85),
            border: const Border(
              top: BorderSide(color: AppColors.borderSubtle),
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: AppColors.black.withValues(alpha: 0.6),
                blurRadius: 16,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: height,
              child: Row(
                children: <Widget>[
                  for (final tab in AppShellTab.values)
                    Expanded(
                      child: _AppShellNavDestination(
                        tab: tab,
                        selected: tab.index == currentIndex,
                        onTap: () => onDestinationSelected(tab.index),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AppShellNavDestination extends StatelessWidget {
  const _AppShellNavDestination({
    required this.tab,
    required this.selected,
    required this.onTap,
  });

  final AppShellTab tab;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = selected ? AppColors.primary : AppColors.textTertiary;
    final label = tab.labelKey.tr();

    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: InkResponse(
        key: Key('bottom-nav-${tab.name}'),
        onTap: onTap,
        radius: 32,
        containedInkWell: true,
        highlightShape: BoxShape.rectangle,
        child: SizedBox(
          height: AppShellBottomNavBar.height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              AppIcon(icon: tab.icon, color: color, size: 22),
              const SizedBox(height: 2),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              AnimatedContainer(
                duration: AppDurations.fast,
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected ? AppColors.primary : Colors.transparent,
                  boxShadow: selected
                      ? <BoxShadow>[
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.8),
                            blurRadius: 8,
                          ),
                        ]
                      : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
