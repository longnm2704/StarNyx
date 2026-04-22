import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:starnyx/app/di/service_locator.dart';
import 'package:starnyx/core/constants/core_constants.dart';
import 'package:starnyx/core/widgets/core_widgets.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:starnyx/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:starnyx/features/settings/presentation/bloc/settings_state.dart';
import 'package:starnyx/features/settings/presentation/pages/about_starnyx_sheet.dart';
import 'package:starnyx/features/settings/presentation/pages/backup_settings_sheet.dart';
import 'package:starnyx/features/settings/presentation/pages/general_settings_sheet.dart';
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
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

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

  Route<dynamic> _onGenerateRoute(RouteSettings settings) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) {
        Widget page;
        switch (settings.name) {
          case '/':
            page = SettingsMainView(
              onGeneralTap: () =>
                  _navigatorKey.currentState?.pushNamed('/general'),
              onBackupTap: () =>
                  _navigatorKey.currentState?.pushNamed('/backup'),
              onAboutTap: () => _navigatorKey.currentState?.pushNamed('/about'),
              onClose: () => Navigator.of(context, rootNavigator: true).pop(),
            );
          case '/general':
            page = GeneralSettingsSheet(
              onBack: () => _navigatorKey.currentState?.pop(),
            );
          case '/backup':
            page = BackupSettingsSheet(
              onBack: () => _navigatorKey.currentState?.pop(),
            );
          case '/about':
            page = AboutStarnyxSheet(
              onBack: () => _navigatorKey.currentState?.pop(),
            );
          default:
            page = const SizedBox.shrink();
        }

        return Container(
          clipBehavior: Clip.antiAlias,
          decoration: const BoxDecoration(
            gradient: _sheetTopDownGradient,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppRadius.xl * 1.5),
            ),
          ),
          child: CosmicBackground(child: page),
        );
      },
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeOutCubic;
        var tween = Tween(
          begin: begin,
          end: end,
        ).chain(CurveTween(curve: curve));

        return SlideTransition(position: animation.drive(tween), child: child);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SettingsBloc>.value(
      value: _settingsBloc,
      child: FractionallySizedBox(
        heightFactor: 1.0,
        child: Navigator(
          key: _navigatorKey,
          initialRoute: '/',
          onGenerateRoute: _onGenerateRoute,
        ),
      ),
    );
  }
}

class SettingsMainView extends StatefulWidget {
  const SettingsMainView({
    required this.onGeneralTap,
    required this.onBackupTap,
    required this.onAboutTap,
    required this.onClose,
    super.key,
  });

  final VoidCallback onGeneralTap;
  final VoidCallback onBackupTap;
  final VoidCallback onAboutTap;
  final VoidCallback onClose;

  @override
  State<SettingsMainView> createState() => _SettingsMainViewState();
}

class _SettingsMainViewState extends State<SettingsMainView> {
  String _appVersion = '';

  @override
  void initState() {
    super.initState();
    _loadPackageInfo();
  }

  Future<void> _loadPackageInfo() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (mounted) {
        setState(() {
          _appVersion = '${info.version} (${info.buildNumber})';
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _appVersion = '1.0.0';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final topInset = mediaQuery.viewPadding.top > 0
        ? mediaQuery.viewPadding.top
        : mediaQuery.padding.top;
    final headerTopPadding = (topInset < 24 ? 24.0 : topInset) + AppSpacing.lg;

    return BlocListener<SettingsBloc, SettingsState>(
      listener: (context, state) {
        if (state.exportStatus == AsyncStatus.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('settings.export_success'.tr())),
          );
        }
        if (state.importStatus == AsyncStatus.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('settings.import_success'.tr())),
          );
        }
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
        }
      },
      child: Column(
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
              onClosePressed: widget.onClose,
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
                      iconPath: 'assets/icons/ic_general.svg',
                      title: 'settings.general_label'.tr(),
                      onTap: widget.onGeneralTap,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),
                _SettingsSection(
                  title: 'settings.backup_section'.tr(),
                  children: [
                    _SettingsTile(
                      iconPath: 'assets/icons/ic_book.svg',
                      title: 'settings.backup_label'.tr(),
                      onTap: widget.onBackupTap,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),
                _SettingsSection(
                  title: 'settings.about_section'.tr(),
                  children: [
                    _SettingsTile(
                      iconPath: 'assets/icons/ic_about.svg',
                      title: 'settings.about_label'.tr(),
                      onTap: widget.onAboutTap,
                    ),
                    _SettingsTile(
                      iconPath: 'assets/icons/ic_version.svg',
                      title: 'settings.version_label'.tr(
                        args: <String>[_appVersion],
                      ),
                      onTap: null,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
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
          padding: const EdgeInsets.only(
            left: AppSpacing.xs,
            bottom: AppSpacing.sm,
          ),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[
                AppColors.surfaceGlass.withValues(alpha: 0.84),
                AppColors.surface.withValues(alpha: 0.74),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppColors.outlineSoft.withValues(alpha: 0.18),
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: AppColors.black.withValues(alpha: 0.18),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
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
                      color: AppColors.white.withValues(alpha: 0.06),
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
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.outlineSoft.withValues(alpha: 0.12),
                  ),
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
                    fontWeight: FontWeight.w700,
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
