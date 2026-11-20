import 'dart:convert';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';
import 'package:share_plus/share_plus.dart';
import 'package:starnyx/core/constants/core_constants.dart';
import 'package:starnyx/core/utils/backup_file_codec.dart';
import 'package:starnyx/core/widgets/core_widgets.dart';
import 'package:starnyx/domain/entities/storage_stats.dart';
import 'package:starnyx/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:starnyx/features/settings/presentation/bloc/settings_event.dart';
import 'package:starnyx/features/settings/presentation/bloc/settings_state.dart';

const _danger = Color(0xFFDC2626);

/// How the backup screen replaced local data; it pops with one of these.
enum BackupOutcome { imported, deletedAll }

/// Full-screen backup & export screen (`sao_luu_xuat_du_lieu`).
///
/// Uses the [SettingsBloc] provided by the Settings tab. Pops with a
/// [BackupOutcome] after an import or delete-all replaced local data so the
/// caller can reload (onboarding only finishes on an import).
class BackupPage extends StatefulWidget {
  const BackupPage({
    required this.onBack,
    this.showDangerZone = true,
    super.key,
  });

  final VoidCallback onBack;

  /// False when opened from onboarding's "restore": there is nothing to
  /// delete yet, only something to import.
  final bool showDangerZone;

  @override
  State<BackupPage> createState() => _BackupPageState();
}

class _BackupPageState extends State<BackupPage> {
  @override
  void initState() {
    super.initState();
    context.read<SettingsBloc>().add(const SettingsStorageRequested());
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: MultiBlocListener(
        listeners: <BlocListener<SettingsBloc, SettingsState>>[
          BlocListener<SettingsBloc, SettingsState>(
            listenWhen: (previous, current) =>
                previous.exportStatus != current.exportStatus,
            listener: _onExportStatus,
          ),
          BlocListener<SettingsBloc, SettingsState>(
            listenWhen: (previous, current) =>
                previous.importStatus != current.importStatus,
            listener: (context, state) {
              if (state.importStatus == AsyncStatus.success) {
                _showSnackBar(context, 'settings.import_success'.tr());
                Navigator.of(context).pop(BackupOutcome.imported);
              } else if (state.hasImportFailure) {
                _showSnackBar(
                  context,
                  'settings.import_error_title'.tr(),
                  isError: true,
                );
              }
            },
          ),
          BlocListener<SettingsBloc, SettingsState>(
            listenWhen: (previous, current) =>
                previous.deleteAllStatus != current.deleteAllStatus,
            listener: (context, state) {
              if (state.deleteAllStatus == AsyncStatus.success) {
                _showSnackBar(context, 'settings.delete_all_success'.tr());
                Navigator.of(context).pop(BackupOutcome.deletedAll);
              } else if (state.deleteAllStatus == AsyncStatus.failure) {
                _showSnackBar(
                  context,
                  'settings.delete_all_error'.tr(),
                  isError: true,
                );
              }
            },
          ),
        ],
        child: BlocBuilder<SettingsBloc, SettingsState>(
          builder: (context, state) => ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.pageHorizontal,
              AppSpacing.md,
              AppSpacing.pageHorizontal,
              AppSpacing.xxl,
            ),
            children: <Widget>[
              _Header(onBack: widget.onBack),
              const SizedBox(height: AppSpacing.lg),
              _SectionLabel('settings.files_section'.tr()),
              _Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    _ActionBlock(
                      icon: HugeIconsStrokeRounded.strokeRoundedDownload04,
                      iconColor: AppColors.primary,
                      title: 'settings.export_label'.tr(),
                      description: 'settings.export_hint'.tr(),
                      button: _PillButton(
                        key: const Key('backup-export-button'),
                        icon: HugeIconsStrokeRounded.strokeRoundedDownload04,
                        label: 'settings.export_button'.tr(),
                        color: AppColors.primary,
                        isLoading: state.isExporting,
                        onTap: state.isExporting
                            ? null
                            : () => _handleExportTap(context),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                      child: Divider(height: 1, color: AppColors.borderSubtle),
                    ),
                    _ActionBlock(
                      icon: HugeIconsStrokeRounded.strokeRoundedUpload04,
                      iconColor: AppColors.secondary,
                      title: 'settings.import_label'.tr(),
                      description: 'settings.import_hint'.tr(),
                      button: _PillButton(
                        key: const Key('backup-import-button'),
                        icon: HugeIconsStrokeRounded.strokeRoundedFolderOpen,
                        label: 'settings.import_button'.tr(),
                        color: AppColors.textPrimary,
                        isLoading: state.importStatus == AsyncStatus.inProgress,
                        onTap: state.importStatus == AsyncStatus.inProgress
                            ? null
                            : () => _handleImportTap(context),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              _SectionLabel('settings.storage_section'.tr()),
              _StorageCard(stats: state.storage),
              if (widget.showDangerZone) ...<Widget>[
                const SizedBox(height: AppSpacing.lg),
                _SectionLabel(
                  'settings.danger_section'.tr(),
                  color: AppColors.errorOnDark,
                  icon: HugeIconsStrokeRounded.strokeRoundedAlert01,
                ),
                _Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Text(
                        'settings.delete_all_title'.tr(),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontFamily: AppFonts.headline,
                          fontWeight: FontWeight.w600,
                          color: AppColors.errorOnDark,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'settings.delete_all_message'.tr(),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _PillButton(
                        key: const Key('backup-delete-all-button'),
                        icon: HugeIconsStrokeRounded.strokeRoundedDelete02,
                        label: 'settings.delete_all_button'.tr(),
                        color: AppColors.white,
                        background: _danger,
                        isLoading:
                            state.deleteAllStatus == AsyncStatus.inProgress,
                        onTap: state.deleteAllStatus == AsyncStatus.inProgress
                            ? null
                            : () => _handleDeleteAllTap(context),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onExportStatus(
    BuildContext context,
    SettingsState state,
  ) async {
    if (state.hasExportFailure) {
      _showSnackBar(context, 'settings.export_error_title'.tr(), isError: true);
      return;
    }
    if (state.exportStatus != AsyncStatus.success ||
        state.exportedFilePath == null) {
      return;
    }
    final path = state.exportedFilePath!;
    final result = await SharePlus.instance.share(
      ShareParams(
        files: <XFile>[XFile(path)],
        subject: 'settings.export_success'.tr(),
      ),
    );
    // ponytail: a dismissed share deletes the temp file right away. After a
    // successful share the receiving app may still be reading it (Android
    // reads the content URI asynchronously), so it is deleted at the next
    // export instead (SettingsBloc), or by the OS temp cleanup.
    if (result.status == ShareResultStatus.dismissed) {
      try {
        await File(path).delete();
      } catch (_) {}
    }
    if (result.status == ShareResultStatus.success && context.mounted) {
      _showSnackBar(context, 'settings.export_success'.tr());
    }
  }

  // Two separate confirmations: the first explains, the second commits.
  Future<void> _handleDeleteAllTap(BuildContext context) async {
    final proceed = await showAppConfirmDialog(
      context: context,
      title: 'settings.delete_all_confirm_title'.tr(),
      message: 'settings.delete_all_confirm_message'.tr(),
      cancelLabel: 'settings.backup_cancel'.tr(),
      confirmLabel: 'settings.backup_export_confirm'.tr(),
      icon: HugeIconsStrokeRounded.strokeRoundedAlert01,
      actionStyle: AppConfirmActionStyle.destructive,
    );
    if (proceed != true || !context.mounted) {
      return;
    }
    final confirmed = await showAppConfirmDialog(
      context: context,
      title: 'settings.delete_all_final_title'.tr(),
      message: 'settings.delete_all_final_message'.tr(),
      cancelLabel: 'settings.backup_cancel'.tr(),
      confirmLabel: 'settings.delete_all_final_confirm'.tr(),
      icon: HugeIconsStrokeRounded.strokeRoundedDelete02,
      actionStyle: AppConfirmActionStyle.destructive,
    );
    if (confirmed == true && context.mounted) {
      context.read<SettingsBloc>().add(const SettingsDeleteAllRequested());
    }
  }

  Future<void> _handleExportTap(BuildContext context) async {
    final passphrase = await _showExportDialog(context);
    if (!context.mounted || passphrase == null) {
      return;
    }

    final confirmed = await _showBackupPrivacyWarningDialog(context);
    if (!context.mounted || !confirmed) {
      return;
    }

    context.read<SettingsBloc>().add(
      SettingsExportRequested(
        passphrase: passphrase.isEmpty ? null : passphrase,
      ),
    );
  }

  Future<void> _handleImportTap(BuildContext context) async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: <String>['json', backupFileExtension],
    );
    if (result == null ||
        result.files.single.path == null ||
        !context.mounted) {
      return;
    }

    try {
      final jsonPayload = await _loadImportPayload(
        context,
        File(result.files.single.path!),
      );
      if (jsonPayload == null || !context.mounted) {
        return;
      }

      final confirmed = await showAppConfirmDialog(
        context: context,
        title: 'settings.import_confirm_title'.tr(),
        message: 'settings.import_confirm_message'.tr(),
        cancelLabel: 'settings.backup_cancel'.tr(),
        confirmLabel: 'settings.import_confirm'.tr(),
        icon: HugeIconsStrokeRounded.strokeRoundedUpload04,
      );
      if (confirmed != true || !context.mounted) {
        return;
      }

      context.read<SettingsBloc>().add(SettingsImportRequested(jsonPayload));
    } catch (_) {
      if (context.mounted) {
        _showSnackBar(
          context,
          'settings.import_error_title'.tr(),
          isError: true,
        );
      }
    }
  }

  Future<Map<String, dynamic>?> _loadImportPayload(
    BuildContext context,
    File file,
  ) async {
    final extension = file.path.split('.').last.toLowerCase();
    if (extension == 'json') {
      return _decodeJsonMap(await file.readAsString());
    }

    if (extension != backupFileExtension) {
      throw const FormatException('Unsupported backup extension');
    }

    final codec = BackupFileCodec();
    final encodedText = await file.readAsString();
    String? errorText;

    while (true) {
      if (!context.mounted) {
        return null;
      }

      try {
        final passphrase = await _showImportPassphraseDialog(
          context,
          errorText: errorText,
        );
        if (passphrase == null) {
          return null;
        }

        return await codec.decodeJsonMap(encodedText, passphrase: passphrase);
      } on BackupFileCodecException catch (error) {
        if (error.code == BackupFileCodecErrorCode.passphraseRequired ||
            error.code == BackupFileCodecErrorCode.invalidPassphrase) {
          errorText = error.code == BackupFileCodecErrorCode.invalidPassphrase
              ? 'settings.backup_import_passphrase_error'.tr()
              : null;
          continue;
        }
        rethrow;
      }
    }
  }

  Future<String?> _showExportDialog(BuildContext context) {
    final passphraseController = TextEditingController();
    final confirmController = TextEditingController();

    return showDialog<String>(
      context: context,
      builder: (dialogContext) {
        var validationMessage = '';

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('settings.backup_export_dialog_title'.tr()),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text('settings.backup_export_dialog_message'.tr()),
                  const SizedBox(height: AppSpacing.md),
                  TextField(
                    controller: passphraseController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'settings.backup_passphrase_label'.tr(),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextField(
                    controller: confirmController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'settings.backup_passphrase_confirm_label'
                          .tr(),
                      errorText: validationMessage.isEmpty
                          ? null
                          : validationMessage,
                    ),
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: Text('settings.backup_cancel'.tr()),
                ),
                FilledButton(
                  onPressed: () {
                    final passphrase = passphraseController.text.trim();
                    final confirmation = confirmController.text.trim();
                    if (passphrase.isNotEmpty && passphrase != confirmation) {
                      setState(() {
                        validationMessage =
                            'settings.backup_passphrase_mismatch'.tr();
                      });
                      return;
                    }

                    Navigator.of(dialogContext).pop(passphrase);
                  },
                  child: Text('settings.backup_export_confirm'.tr()),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<bool> _showBackupPrivacyWarningDialog(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('settings.backup_privacy_warning_title'.tr()),
          content: Text('settings.backup_privacy_warning_message'.tr()),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text('settings.backup_cancel'.tr()),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text('settings.backup_privacy_warning_confirm'.tr()),
            ),
          ],
        );
      },
    );

    return confirmed ?? false;
  }

  Future<String?> _showImportPassphraseDialog(
    BuildContext context, {
    String? errorText,
  }) {
    final controller = TextEditingController();

    return showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('settings.backup_import_passphrase_title'.tr()),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text('settings.backup_import_passphrase_message'.tr()),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: controller,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'settings.backup_passphrase_label'.tr(),
                  errorText: errorText,
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text('settings.backup_cancel'.tr()),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(controller.text.trim());
              },
              child: Text('settings.backup_export_confirm'.tr()),
            ),
          ],
        );
      },
    );
  }

  Map<String, dynamic> _decodeJsonMap(String jsonString) {
    final decoded = jsonDecode(jsonString);
    if (decoded is Map) {
      return decoded.cast<String, dynamic>();
    }
    throw const FormatException('Root is not an object');
  }
}

void _showSnackBar(
  BuildContext context,
  String message, {
  bool isError = false,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: isError ? Theme.of(context).colorScheme.error : null,
    ),
  );
}

/// Human-readable size, e.g. `48 KB` or `1.4 MB`.
String formatBytes(int bytes) {
  if (bytes < 1024) return '$bytes B';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(0)} KB';
  return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
}

class _Header extends StatelessWidget {
  const _Header({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        IconButton(
          key: const Key('backup-back-button'),
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          onPressed: onBack,
          icon: const AppIcon(
            icon: HugeIconsStrokeRounded.strokeRoundedArrowLeft01,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Text(
            'settings.backup_title'.tr(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontFamily: AppFonts.headline,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text, {this.color, this.icon});

  final String text;
  final Color? color;
  final List<List<dynamic>>? icon;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? AppColors.textSecondary;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xxs,
        0,
        AppSpacing.xxs,
        AppSpacing.xs,
      ),
      child: Row(
        children: <Widget>[
          if (icon != null) ...<Widget>[
            AppIcon(icon: icon!, size: 16, color: effectiveColor),
            const SizedBox(width: AppSpacing.xxs),
          ],
          Text(
            text.toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontFamily: AppFonts.mono,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.1,
              color: effectiveColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceLevel1,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: child,
    );
  }
}

class _IconBox extends StatelessWidget {
  const _IconBox({required this.icon, required this.color});

  final List<List<dynamic>> icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.surfaceLevel2,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Center(
        child: AppIcon(icon: icon, size: 20, color: color),
      ),
    );
  }
}

class _ActionBlock extends StatelessWidget {
  const _ActionBlock({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
    required this.button,
  });

  final List<List<dynamic>> icon;
  final Color iconColor;
  final String title;
  final String description;
  final Widget button;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _IconBox(icon: icon, color: iconColor),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        button,
      ],
    );
  }
}

class _PillButton extends StatelessWidget {
  const _PillButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.background = AppColors.black,
    this.isLoading = false,
    super.key,
  });

  final List<List<dynamic>> icon;
  final String label;
  final Color color;
  final Color background;
  final VoidCallback? onTap;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.pill),
        side: background == AppColors.black
            ? const BorderSide(color: AppColors.borderSubtle)
            : BorderSide.none,
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 48,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (isLoading)
                SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: color,
                  ),
                )
              else
                AppIcon(icon: icon, size: 18, color: color),
              const SizedBox(width: AppSpacing.xs),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StorageCard extends StatelessWidget {
  const _StorageCard({required this.stats});

  final StorageStats? stats;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final stats = this.stats;
    final segments = <(int, Color)>[
      (stats?.habitCount ?? 0, AppColors.primary),
      (stats?.completionCount ?? 0, AppColors.secondary),
      (stats?.journalCount ?? 0, AppColors.tertiary),
    ];
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              const _IconBox(
                icon: HugeIconsStrokeRounded.strokeRoundedPieChart,
                color: AppColors.tertiary,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'settings.storage_local'.tr(),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'settings.storage_private'.tr(),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              if (stats != null)
                Text(
                  formatBytes(stats.bytes),
                  key: const Key('backup-storage-size'),
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontFamily: AppFonts.mono,
                    fontWeight: FontWeight.w600,
                    fontFeatures: AppFonts.tabularFigures,
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          // ponytail: segments are proportional to row counts, not bytes;
          // per-table byte sizes would need SQLite's dbstat extension.
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            child: Container(
              height: 8,
              color: AppColors.surfaceLevel2,
              child: Row(
                children: <Widget>[
                  for (final (count, color) in segments)
                    if (count > 0)
                      Expanded(
                        flex: count,
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 1),
                          color: color,
                        ),
                      ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _StatTile(
                  color: AppColors.primary,
                  label: 'settings.storage_habits'.tr(),
                  count: stats?.habitCount,
                  caption: 'settings.storage_habits_caption'.tr(),
                ),
                const SizedBox(width: AppSpacing.xs),
                _StatTile(
                  color: AppColors.secondary,
                  label: 'settings.storage_checkins'.tr(),
                  count: stats?.completionCount,
                  caption: 'settings.storage_checkins_caption'.tr(),
                ),
                const SizedBox(width: AppSpacing.xs),
                _StatTile(
                  color: AppColors.tertiary,
                  label: 'settings.storage_journal'.tr(),
                  count: stats?.journalCount,
                  caption: 'settings.storage_journal_caption'.tr(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.color,
    required this.label,
    required this.count,
    required this.caption,
  });

  final Color color;
  final String label;
  final int? count;
  final String caption;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.sm - 2),
        decoration: BoxDecoration(
          color: AppColors.black,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(color: AppColors.borderSubtle),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              count?.toString() ?? '–',
              style: theme.textTheme.titleLarge?.copyWith(
                fontFamily: AppFonts.mono,
                fontWeight: FontWeight.w600,
                fontFeatures: AppFonts.tabularFigures,
              ),
            ),
            Text(
              caption,
              maxLines: 2,
              style: theme.textTheme.labelSmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
