import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:starnyx/core/widgets/core_widgets.dart';
import 'package:starnyx/core/utils/backup_file_codec.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:starnyx/core/constants/core_constants.dart';
import 'package:starnyx/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:starnyx/features/settings/presentation/bloc/settings_event.dart';
import 'package:starnyx/features/settings/presentation/bloc/settings_state.dart';
import 'package:starnyx/features/starnyx_form/presentation/widgets/starnyx_form_header.dart';

class BackupSettingsSheet extends StatelessWidget {
  const BackupSettingsSheet({required this.onBack, super.key});

  final VoidCallback onBack;

  Future<void> _handleExportTap(BuildContext context) async {
    final passphrase = await _showExportDialog(context);
    if (!context.mounted || passphrase == null) {
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

      context.read<SettingsBloc>().add(SettingsImportRequested(jsonPayload));
    } catch (_) {
      if (context.mounted) {
        _showImportErrorSnackBar(context);
      }
    }
  }

  Future<Map<String, dynamic>?> _loadImportPayload(
    BuildContext context,
    File file,
  ) async {
    final extension = file.path.split('.').last.toLowerCase();
    if (extension == 'json') {
      final jsonString = await file.readAsString();
      return _decodeJsonMap(jsonString);
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
                children: [
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
              actions: [
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
            children: [
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
          actions: [
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
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
    if (decoded is Map) {
      return decoded.cast<String, dynamic>();
    }
    throw const FormatException('Root is not an object');
  }

  void _showImportErrorSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('settings.import_error_title'.tr()),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final topInset = mediaQuery.viewPadding.top > 0
        ? mediaQuery.viewPadding.top
        : mediaQuery.padding.top;
    final bottomSafeInset = mediaQuery.viewPadding.bottom > 0
        ? mediaQuery.viewPadding.bottom
        : mediaQuery.padding.bottom;
    final headerTopPadding = (topInset < 24 ? 24.0 : topInset) + AppSpacing.lg;

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.pageHorizontal,
            headerTopPadding,
            AppSpacing.pageHorizontal,
            AppSpacing.md,
          ),
          child: StarnyxFormHeader(
            title: 'settings.backup_title'.tr(),
            onClosePressed: onBack,
          ),
        ),
        Expanded(
          child: MultiBlocListener(
            listeners: [
              BlocListener<SettingsBloc, SettingsState>(
                listenWhen: (previous, current) =>
                    previous.exportStatus != current.exportStatus,
                listener: (context, state) async {
                  debugPrint('Export status changed to: ${state.exportStatus}');
                  if (state.exportStatus == AsyncStatus.success &&
                      state.exportedFilePath != null) {
                    final result = await SharePlus.instance.share(
                      ShareParams(
                        files: [XFile(state.exportedFilePath!)],
                        subject: 'settings.export_success'.tr(),
                      ),
                    );
                    if (result.status == ShareResultStatus.success) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('settings.export_success'.tr()),
                          ),
                        );
                      }
                    }
                  }
                },
              ),
              BlocListener<SettingsBloc, SettingsState>(
                listenWhen: (previous, current) =>
                    previous.importStatus != current.importStatus,
                listener: (context, state) async {
                  debugPrint('Import status changed to: ${state.importStatus}');
                  if (state.importStatus == AsyncStatus.success) {
                    if (context.mounted) {
                      Navigator.of(
                        context,
                        rootNavigator: true,
                      ).popUntil((route) => route.isFirst);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('settings.import_success'.tr())),
                      );
                    }
                  }
                  if (state.hasImportFailure) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            state.errorMessage ??
                                'settings.import_error_title'.tr(),
                          ),
                          backgroundColor: Theme.of(context).colorScheme.error,
                        ),
                      );
                    }
                  }
                },
              ),
            ],
            child: BlocBuilder<SettingsBloc, SettingsState>(
              builder: (BuildContext context, SettingsState state) {
                return ListView(
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.pageHorizontal,
                    AppSpacing.md,
                    AppSpacing.pageHorizontal,
                    AppSpacing.xl + bottomSafeInset,
                  ),
                  children: [
                    AnimatedSwitcher(
                      duration: AppDurations.fast,
                      child: state.isExporting
                          ? _BackupStatusCard(
                              key: const ValueKey<String>('export-loading'),
                              child: AppLoadingIndicator(
                                label: 'settings.export_loading_message'.tr(),
                              ),
                            )
                          : state.hasExportFailure
                          ? _BackupStatusCard(
                              key: const ValueKey<String>('export-error'),
                              child: AppErrorState(
                                title: 'settings.export_error_title'.tr(),
                                message:
                                    state.errorMessage ??
                                    'settings.export_loading_message'.tr(),
                                retryLabel: 'home.retry'.tr(),
                                onRetry: () {
                                  context.read<SettingsBloc>().add(
                                    const SettingsExportRequested(),
                                  );
                                },
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                    if (state.isExporting || state.hasExportFailure)
                      const SizedBox(height: AppSpacing.md),
                    _BackupTile(
                      iconPath: 'assets/icons/ic_export.svg',
                      title: 'settings.export_label'.tr(),
                      subtitle: 'settings.export_hint'.tr(),
                      isLoading: state.isExporting,
                      onTap: state.isExporting
                          ? null
                          : () => _handleExportTap(context),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _BackupTile(
                      iconPath: 'assets/icons/ic_import.svg',
                      title: 'settings.import_label'.tr(),
                      subtitle: 'settings.import_hint'.tr(),
                      isLoading: state.importStatus == AsyncStatus.inProgress,
                      onTap: state.importStatus == AsyncStatus.inProgress
                          ? null
                          : () => _handleImportTap(context),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _BackupTile extends StatelessWidget {
  const _BackupTile({
    required this.iconPath,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isLoading = false,
  });

  final String iconPath;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
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
              color: AppColors.outlineSoft.withValues(alpha: 0.16),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.outlineSoft.withValues(alpha: 0.12),
                  ),
                ),
                child: Center(
                  child: AppSvgIcon(
                    assetPath: iconPath,
                    size: 18,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              if (isLoading)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textMuted,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BackupStatusCard extends StatelessWidget {
  const _BackupStatusCard({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surfaceGlass.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: AppColors.outlineSoft.withValues(alpha: 0.16),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: child,
      ),
    );
  }
}
