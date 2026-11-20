import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:starnyx/app/di/service_locator.dart';
import 'package:starnyx/app/reminder_permission.dart';
import 'package:starnyx/core/constants/core_constants.dart';
import 'package:starnyx/core/widgets/app_icon.dart';
import 'package:starnyx/core/widgets/app_sheet.dart';
import 'package:starnyx/domain/usecases/sync_notifications_use_case.dart';
import 'package:starnyx/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:starnyx/features/settings/presentation/bloc/settings_event.dart';
import 'package:starnyx/features/settings/presentation/bloc/settings_state.dart';
import 'package:starnyx/features/settings/presentation/pages/about_starnyx_sheet.dart';
import 'package:starnyx/features/settings/presentation/pages/backup_page.dart';

/// Full-screen Settings tab (Obsidian Lumina `cai_dat`).
///
/// Owns its [SettingsBloc] unless one is injected. [reloadToken] bumps when the
/// shell re-selects the tab so the streak and reminder summary stay fresh.
/// [onDataReplaced] fires after an import or delete-all on the backup screen.
class SettingsPage extends StatefulWidget {
  const SettingsPage({
    this.bloc,
    this.reloadToken = 0,
    this.onDataReplaced,
    super.key,
  });

  final SettingsBloc? bloc;
  final int reloadToken;
  final VoidCallback? onDataReplaced;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late final SettingsBloc _bloc;
  late final bool _ownsBloc;
  String _version = '';

  @override
  void initState() {
    super.initState();
    _ownsBloc = widget.bloc == null;
    _bloc = widget.bloc ?? serviceLocator<SettingsBloc>();
    _bloc.add(const SettingsSummaryRequested());
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() => _version = '${info.version} (${info.buildNumber})');
    }
  }

  @override
  void didUpdateWidget(covariant SettingsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.reloadToken != oldWidget.reloadToken) {
      _bloc.add(const SettingsSummaryRequested());
    }
  }

  @override
  void dispose() {
    if (_ownsBloc) {
      _bloc.close();
    }
    super.dispose();
  }

  // Backup and about are full-screen routes sharing this page's bloc.
  // The backup screen pops a [BackupOutcome] when local data was replaced.
  Future<void> _push(Widget Function(VoidCallback onBack) builder) async {
    final outcome = await Navigator.of(context).push<BackupOutcome>(
      MaterialPageRoute<BackupOutcome>(
        builder: (routeContext) => BlocProvider<SettingsBloc>.value(
          value: _bloc,
          child: Scaffold(
            backgroundColor: AppColors.background,
            body: builder(() => Navigator.of(routeContext).pop()),
          ),
        ),
      ),
    );
    if (!mounted) return;
    _bloc.add(const SettingsSummaryRequested());
    if (outcome != null) widget.onDataReplaced?.call();
  }

  Future<void> _onRemindersChanged(bool enabled) async {
    // Permission is asked when reminders are turned on, never at launch.
    if (enabled) await requestReminderPermission(context);
    _bloc.add(SettingsRemindersToggled(enabled));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SettingsBloc>.value(
      value: _bloc,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          bottom: false,
          child: BlocConsumer<SettingsBloc, SettingsState>(
            listenWhen: (previous, current) =>
                previous.remindersToggleFailureCount !=
                current.remindersToggleFailureCount,
            listener: (context, state) =>
                ScaffoldMessenger.maybeOf(context)?.showSnackBar(
                  SnackBar(
                    content: Text('settings.reminders_toggle_error'.tr()),
                  ),
                ),
            builder: (context, state) => _SettingsContent(
              state: state,
              version: _version,
              onLanguageTap: () => _showLanguagePicker(context),
              onRemindersChanged: _onRemindersChanged,
              onBackupTap: () => _push((onBack) => BackupPage(onBack: onBack)),
              onAboutTap: () =>
                  _push((onBack) => AboutStarnyxSheet(onBack: onBack)),
            ),
          ),
        ),
      ),
    );
  }
}

// Language names stay in their own language so users can always find theirs.
const _languages = <String, ({String name, String flag})>{
  'en': (name: 'English', flag: 'assets/icons/us.png'),
  'vi': (name: 'Tiếng Việt', flag: 'assets/icons/vn.png'),
  'ja': (name: '日本語', flag: 'assets/icons/jp.png'),
};

Future<void> _showLanguagePicker(BuildContext context) {
  return showAppSheet<void>(
    context: context,
    key: const Key('settings-language-picker'),
    useRootNavigator: true,
    title: 'settings.language_label'.tr(),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        for (final locale in context.supportedLocales) ...<Widget>[
          _LanguageOption(
            label: _languages[locale.languageCode]?.name ?? locale.languageCode,
            flagAsset: _languages[locale.languageCode]?.flag,
            selected: locale == context.locale,
            onTap: () async {
              Navigator.of(context, rootNavigator: true).pop();
              await context.setLocale(locale);
              // Scheduled reminder copy must follow the new language
              // (the translator set at app start reads the new locale).
              await serviceLocator<SyncNotificationsUseCase>()
                  .rebuildAllFromLocalData();
            },
          ),
          const SizedBox(height: AppSpacing.xs),
        ],
      ],
    ),
  );
}

class _SettingsContent extends StatelessWidget {
  const _SettingsContent({
    required this.state,
    required this.version,
    required this.onLanguageTap,
    required this.onRemindersChanged,
    required this.onBackupTap,
    required this.onAboutTap,
  });

  final SettingsState state;
  final String version;
  final VoidCallback onLanguageTap;
  final ValueChanged<bool> onRemindersChanged;
  final VoidCallback onBackupTap;
  final VoidCallback onAboutTap;

  @override
  Widget build(BuildContext context) {
    final nextReminder = state.nextReminderTime(DateTime.now());
    final reminderSubtitle = nextReminder != null && !state.notificationsAllowed
        ? 'settings.reminders_permission_off'.tr()
        : nextReminder != null
        ? 'settings.reminders_next'.tr(args: <String>[nextReminder])
        : state.canToggleReminders
        ? 'settings.reminders_off'.tr()
        : 'settings.reminders_none'.tr();

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pageHorizontal,
        AppSpacing.md,
        AppSpacing.pageHorizontal,
        AppSpacing.xxl,
      ),
      children: <Widget>[
        const _Header(),
        const SizedBox(height: AppSpacing.lg),
        _ProfileCard(state: state),
        const SizedBox(height: AppSpacing.lg),
        _Section(
          title: 'settings.general_section'.tr(),
          children: <Widget>[
            _SettingsRow(
              key: const Key('settings-language-row'),
              icon: HugeIconsStrokeRounded.strokeRoundedGlobe02,
              iconColor: AppColors.secondary,
              title: 'settings.language_label'.tr(),
              subtitle: 'settings.language_subtitle'.tr(),
              value:
                  _languages[context.locale.languageCode]?.name ??
                  context.locale.languageCode,
              onTap: onLanguageTap,
            ),
            _SettingsRow(
              icon: HugeIconsStrokeRounded.strokeRoundedNotification03,
              iconColor: AppColors.tertiary,
              title: 'settings.reminders_label'.tr(),
              subtitle: reminderSubtitle,
              // No switch until some habit has a reminder time to restore.
              trailing: state.canToggleReminders
                  ? Switch(
                      key: const Key('settings-reminders-switch'),
                      value: state.remindersOn,
                      onChanged: onRemindersChanged,
                    )
                  : null,
            ),
            _SettingsRow(
              icon: HugeIconsStrokeRounded.strokeRoundedMoon02,
              iconColor: AppColors.primary,
              title: 'settings.appearance_label'.tr(),
              value: 'Obsidian Lumina',
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        _Section(
          title: 'settings.data_section'.tr(),
          trailing: 'settings.data_location'.tr(),
          children: <Widget>[
            _SettingsRow(
              key: const Key('settings-backup-row'),
              icon: HugeIconsStrokeRounded.strokeRoundedArchive,
              iconColor: AppColors.secondary,
              title: 'settings.backup_label'.tr(),
              subtitle: 'settings.backup_subtitle'.tr(),
              onTap: onBackupTap,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        _Section(
          title: 'settings.about_section'.tr(),
          children: <Widget>[
            _SettingsRow(
              key: const Key('settings-about-row'),
              icon: HugeIconsStrokeRounded.strokeRoundedIdCard,
              iconColor: AppColors.textSecondary,
              title: 'settings.about_label'.tr(),
              subtitle: 'settings.about_subtitle'.tr(),
              onTap: onAboutTap,
            ),
            _SettingsRow(
              icon: HugeIconsStrokeRounded.strokeRoundedInformationCircle,
              iconColor: AppColors.textSecondary,
              title: 'settings.version_label'.tr(),
              trailing: version.isEmpty ? null : _MonoPill(label: version),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xxl),
        const _Footer(),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'settings.title'.tr(),
          style: theme.textTheme.headlineSmall?.copyWith(
            fontFamily: AppFonts.headline,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'settings.subtitle'.tr().toUpperCase(),
          style: theme.textTheme.labelSmall?.copyWith(
            fontFamily: AppFonts.mono,
            letterSpacing: 1.1,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.state});

  final SettingsState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = state.activeHabitTitle;
    return _Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: <Widget>[
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.surfaceLevel2,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: const Center(
                child: AppIcon(
                  icon: HugeIconsStrokeRounded.strokeRoundedSparkles,
                  color: AppColors.primary,
                  size: 26,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title ?? 'app.title'.tr(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontFamily: AppFonts.headline,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    title == null
                        ? 'settings.profile_empty'.tr()
                        : 'settings.profile_streak'.plural(state.currentStreak),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children, this.trailing});

  final String title;
  final String? trailing;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final overline = Theme.of(context).textTheme.labelSmall?.copyWith(
      fontFamily: AppFonts.mono,
      fontWeight: FontWeight.w600,
      letterSpacing: 1.1,
      color: AppColors.textSecondary,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xxs,
            0,
            AppSpacing.xxs,
            AppSpacing.xs,
          ),
          child: Row(
            children: <Widget>[
              Expanded(child: Text(title.toUpperCase(), style: overline)),
              if (trailing != null)
                Flexible(
                  child: Text(
                    trailing!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: overline?.copyWith(color: AppColors.primary),
                  ),
                ),
            ],
          ),
        ),
        _Card(
          child: Column(
            children: <Widget>[
              for (var i = 0; i < children.length; i++) ...<Widget>[
                if (i > 0)
                  const Divider(
                    height: 1,
                    indent: 64,
                    color: AppColors.borderSubtle,
                  ),
                children[i],
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceLevel1,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
        side: const BorderSide(color: AppColors.borderSubtle),
      ),
      child: child,
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    this.value,
    this.trailing,
    this.onTap,
    super.key,
  });

  final List<List<dynamic>> icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final String? value;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 64),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.surfaceLevel2,
                  borderRadius: BorderRadius.circular(AppRadius.sm - 4),
                ),
                child: Center(
                  child: AppIcon(icon: icon, size: 20, color: iconColor),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // Wraps instead of ellipsizing so large text stays
                    // readable on narrow screens.
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (subtitle != null) ...<Widget>[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (value != null) ...<Widget>[
                const SizedBox(width: AppSpacing.xs),
                Flexible(
                  child: Text(
                    value!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontFamily: AppFonts.mono,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
              if (trailing != null) ...<Widget>[
                const SizedBox(width: AppSpacing.xs),
                Flexible(
                  child: FittedBox(fit: BoxFit.scaleDown, child: trailing),
                ),
              ],
              if (onTap != null) ...<Widget>[
                const SizedBox(width: AppSpacing.xxs),
                const AppIcon(
                  icon: HugeIconsStrokeRounded.strokeRoundedChevronRight,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _MonoPill extends StatelessWidget {
  const _MonoPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceLevel2,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          fontFamily: AppFonts.mono,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: <Widget>[
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary.withValues(alpha: 0.12),
          ),
          child: const Center(
            child: AppIcon(
              icon: HugeIconsStrokeRounded.strokeRoundedSparkles,
              size: 20,
              color: AppColors.primary,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'app.title'.tr(),
          style: theme.textTheme.titleLarge?.copyWith(
            fontFamily: AppFonts.headline,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          'settings.footer_tagline'.tr(),
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'settings.footer_made_with'.tr(),
          textAlign: TextAlign.center,
          style: theme.textTheme.labelSmall?.copyWith(
            fontFamily: AppFonts.mono,
            color: AppColors.textTertiary,
          ),
        ),
      ],
    );
  }
}

class _LanguageOption extends StatelessWidget {
  const _LanguageOption({
    required this.label,
    required this.flagAsset,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String? flagAsset;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.surfaceLevel2 : AppColors.surfaceLevel1,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
        side: BorderSide(
          color: selected ? AppColors.primary : AppColors.borderSubtle,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Row(
            children: <Widget>[
              SizedBox.square(
                dimension: 32,
                child: flagAsset == null
                    ? const AppIcon(
                        icon: HugeIconsStrokeRounded.strokeRoundedLanguages,
                        color: AppColors.textSecondary,
                      )
                    : Image.asset(flagAsset!, fit: BoxFit.cover),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
              if (selected)
                const AppIcon(
                  icon: HugeIconsStrokeRounded.strokeRoundedCircleCheck,
                  color: AppColors.primary,
                  size: 22,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
