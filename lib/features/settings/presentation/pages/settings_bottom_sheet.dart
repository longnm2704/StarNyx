import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:starnyx/app/di/service_locator.dart';
import 'package:starnyx/core/constants/core_constants.dart';
import 'package:starnyx/core/widgets/core_widgets.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:starnyx/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:starnyx/features/settings/presentation/bloc/settings_event.dart';
import 'package:starnyx/features/settings/presentation/bloc/settings_state.dart';
import 'package:starnyx/features/starnyx_form/presentation/widgets/starnyx_form_header.dart';

const LinearGradient _sheetTopDownGradient = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: <Color>[AppColors.sheetTop, AppColors.sheetMid, AppColors.background],
  stops: <double>[0.0, 0.48, 1.0],
);

Future<void> showSettingsBottomSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: false,
    backgroundColor: Colors.transparent,
    barrierColor: AppColors.black.withValues(alpha: 0.72),
    builder: (BuildContext context) {
      return const SettingsBottomSheet();
    },
  );
}

class SettingsBottomSheet extends StatefulWidget {
  const SettingsBottomSheet({super.key});

  @override
  State<SettingsBottomSheet> createState() => _SettingsBottomSheetState();
}

class _SettingsBottomSheetState extends State<SettingsBottomSheet> {
  late final SettingsBloc _settingsBloc;

  @override
  void initState() {
    super.initState();
    _settingsBloc = serviceLocator<SettingsBloc>();
  }

  @override
  void dispose() {
    _settingsBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final topInset = mediaQuery.viewPadding.top > 0 ? mediaQuery.viewPadding.top : mediaQuery.padding.top;
    final headerTopPadding = (topInset < 24 ? 24.0 : topInset) + AppSpacing.lg;

    return BlocProvider<SettingsBloc>.value(
      value: _settingsBloc,
      child: BlocListener<SettingsBloc, SettingsState>(
        listener: (context, state) {
          if (state.exportStatus == AsyncStatus.success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Data exported successfully')),
            );
          }
          if (state.importStatus == AsyncStatus.success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Data imported successfully. App will restart.')),
            );
          }
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage!)),
            );
          }
        },
        child: FractionallySizedBox(
          heightFactor: 1.0,
          child: DecoratedBox(
            decoration: const BoxDecoration(
              gradient: _sheetTopDownGradient,
              borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl * 1.5)),
            ),
            child: SafeArea(
              top: false,
              bottom: false,
              child: Stack(
                children: [
                  const Positioned.fill(child: CosmicBackground(child: SizedBox.expand())),
                  Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          AppSpacing.pageHorizontal,
                          headerTopPadding,
                          AppSpacing.pageHorizontal,
                          AppSpacing.md,
                        ),
                        child: StarnyxFormHeader(
                          title: 'settings.title'.tr(),
                          onClosePressed: () => Navigator.of(context).pop(),
                        ),
                      ),
                      Expanded(
                        child: ListView(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.pageHorizontal,
                            AppSpacing.md,
                            AppSpacing.pageHorizontal,
                            AppSpacing.xl,
                          ),
                          children: [
                            _SettingsSection(
                              title: 'settings.general_section'.tr(),
                              children: [
                                _SettingsTile(
                                  iconPath: 'assets/icons/ic_settings.svg',
                                  title: 'settings.general_label'.tr(),
                                  onTap: () {
                                    // Navigate to general settings (STX-040)
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.xl),
                            _SettingsSection(
                              title: 'settings.data_section'.tr(),
                              children: [
                                _SettingsTile(
                                  iconPath: 'assets/icons/ic_sparkles.svg', // Use export icon if available
                                  title: 'settings.export_label'.tr(),
                                  onTap: () => _settingsBloc.add(const SettingsExportRequested()),
                                ),
                                _SettingsTile(
                                  iconPath: 'assets/icons/ic_plus.svg', // Use import icon if available
                                  title: 'settings.import_label'.tr(),
                                  onTap: () {
                                    // Handle file picker and dispatch SettingsImportRequested
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.xl),
                            _SettingsSection(
                              title: 'settings.about_section'.tr(),
                              children: [
                                _SettingsTile(
                                  iconPath: 'assets/icons/ic_heart.svg',
                                  title: 'settings.about_label'.tr(),
                                  onTap: () {},
                                ),
                                _SettingsTile(
                                  iconPath: 'assets/icons/ic_cursor.svg',
                                  title: 'Version 1.0.0',
                                  onTap: null,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
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

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: AppSpacing.md, bottom: AppSpacing.sm),
          child: Text(
            title.toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.white.withValues(alpha: 0.05)),
          ),
          child: Column(
            children: List.generate(children.length, (index) {
              return Column(
                children: [
                  children[index],
                  if (index < children.length - 1)
                    Divider(
                      height: 1,
                      indent: 56,
                      endIndent: 16,
                      color: AppColors.white.withValues(alpha: 0.05),
                    ),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.iconPath,
    required this.title,
    this.onTap,
  });

  final String iconPath;
  final String title;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: AppSvgIcon(
                    assetPath: iconPath,
                    size: 18,
                    color: AppColors.accentLavender,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              if (onTap != null)
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textMuted,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
