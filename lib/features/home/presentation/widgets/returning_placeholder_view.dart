import 'dart:async';

import 'package:flutter/material.dart';
import 'package:starnyx/domain/entities/starnyx.dart';
import 'package:starnyx/core/widgets/core_widgets.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:starnyx/core/constants/core_constants.dart';

import 'home_swipe_up_hint.dart';
import 'active_starnyx_spotlight.dart';
import 'constellation_switcher_sheet.dart';

class ReturningPlaceholderView extends StatefulWidget {
  const ReturningPlaceholderView({
    required this.starnyxs,
    required this.activeStarnyxId,
    required this.onCreatePressed,
    required this.onEditPressed,
    required this.onSelectPressed,
    super.key,
  });

  final List<StarNyx> starnyxs;
  final String? activeStarnyxId;
  final FutureOr<void> Function() onCreatePressed;
  final FutureOr<void> Function(StarNyx) onEditPressed;
  final ValueChanged<StarNyx> onSelectPressed;

  @override
  State<ReturningPlaceholderView> createState() =>
      _ReturningPlaceholderViewState();
}

class _ReturningPlaceholderViewState extends State<ReturningPlaceholderView> {
  bool _isOpeningSheet = false;

  Future<void> _waitForSheetTransition() {
    return Future<void>.delayed(AppDurations.fast);
  }

  Future<ConstellationSwitcherSheetAction?> _showConstellationSheet() {
    return showModalBottomSheet<ConstellationSwitcherSheetAction>(
      context: context,
      isScrollControlled: true,
      useSafeArea: false,
      backgroundColor: Colors.transparent,
      barrierColor: AppColors.black.withValues(alpha: 0.72),
      builder: (_) {
        return ConstellationSwitcherSheet(
          starnyxs: widget.starnyxs,
          activeStarnyxId: widget.activeStarnyxId,
          onSelectPressed: widget.onSelectPressed,
        );
      },
    );
  }

  Future<void> _openConstellationSheet() async {
    if (_isOpeningSheet) {
      return;
    }

    setState(() {
      _isOpeningSheet = true;
    });

    while (mounted) {
      final action = await _showConstellationSheet();

      if (!mounted || action == null) {
        break;
      }

      await _waitForSheetTransition();
      if (!mounted) {
        break;
      }

      switch (action.type) {
        case ConstellationSwitcherSheetActionType.createRequested:
          await Future.sync(widget.onCreatePressed);
        case ConstellationSwitcherSheetActionType.editRequested:
          final starnyx = action.starnyx;
          if (starnyx == null) {
            break;
          }
          await Future.sync(() => widget.onEditPressed(starnyx));
      }
      if (!mounted) {
        break;
      }

      await _waitForSheetTransition();
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _isOpeningSheet = false;
    });
  }

  void _handleVerticalDragEnd(DragEndDetails details) {
    if ((details.primaryVelocity ?? 0) < -240) {
      _openConstellationSheet();
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeStarnyx = widget.starnyxs.firstWhere(
      (StarNyx item) => item.id == widget.activeStarnyxId,
      orElse: () => widget.starnyxs.first,
    );

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onVerticalDragEnd: _handleVerticalDragEnd,
      child: CosmicBackground(
        bottomGlowColor: AppColors.accentOrange,
        child: SafeArea(
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              return Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.pageHorizontal,
                    AppSpacing.pageVertical,
                    AppSpacing.pageHorizontal,
                    0,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight:
                          constraints.maxHeight - AppSpacing.pageVertical,
                      maxWidth: AppLayout.contentMaxWidth,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        AppSectionTitle(
                          title: 'home.returning_title'.tr(),
                          subtitle: 'home.returning_subtitle'.tr(
                            args: <String>[widget.starnyxs.length.toString()],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xxl),
                        ActiveStarnyxSpotlight(activeStarnyx: activeStarnyx),
                        const Spacer(),
                        Center(
                          child: HomeSwipeUpHint(
                            onTap: _openConstellationSheet,
                            isBusy: _isOpeningSheet,
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
