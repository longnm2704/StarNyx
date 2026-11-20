import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';
import 'package:starnyx/core/constants/core_constants.dart';
import 'package:starnyx/core/widgets/core_widgets.dart';
import 'package:starnyx/domain/entities/starnyx.dart';
import 'package:starnyx/features/onboarding/presentation/widgets/onboarding_widgets.dart';
import 'package:starnyx/features/starnyx_form/presentation/widgets/starnyx_form_color_utils.dart';

/// Onboarding completion (`hoan_tat_onboarding`): recaps the habits that
/// STX-U022 just created. [onDone] lands on the Habits tab without lighting
/// anything — the first check-in stays the user's own tap.
///
/// The mockup's "1 / 365 days" progress row is dropped: nothing is lit yet,
/// so the number would be made up.
class OnboardingCompletePage extends StatelessWidget {
  const OnboardingCompletePage({
    required this.habits,
    required this.onDone,
    super.key,
  });

  final List<StarNyx> habits;

  /// Enters the app. Back / system back do the same: the habits are already
  /// saved, so there is nothing to undo here.
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return PopScope<Object?>(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) onDone();
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppLayout.contentMaxWidth,
              ),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.pageHorizontal,
                  AppSpacing.xxs,
                  AppSpacing.pageHorizontal,
                  AppSpacing.lg,
                ),
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.xxs,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceLevel1,
                            borderRadius: BorderRadius.circular(AppRadius.pill),
                            border: Border.all(color: AppColors.borderSubtle),
                          ),
                          child: OnboardingDotLabel(
                            child: Text(
                              'onboarding.complete.overline'.tr(),
                              style: textTheme.labelMedium?.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const _Hero(),
                  const SizedBox(height: AppSpacing.lg),
                  Text.rich(
                    TextSpan(
                      children: <InlineSpan>[
                        TextSpan(text: 'onboarding.complete.title_lead'.tr()),
                        TextSpan(
                          text: 'onboarding.complete.title_emphasis'.tr(),
                          style: const TextStyle(color: AppColors.primary),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                    style: textTheme.headlineLarge?.copyWith(fontSize: 34),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'onboarding.complete.subtitle'.tr(),
                    textAlign: TextAlign.center,
                    style: textTheme.bodyLarge,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _CommitmentCard(habits: habits),
                  const SizedBox(height: AppSpacing.md),
                  const _Quote(),
                  const SizedBox(height: AppSpacing.lg),
                  AppPrimaryButton(
                    key: const Key('onboarding-complete-done'),
                    label: '${'onboarding.complete.cta'.tr()} →',
                    onPressed: onDone,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'onboarding.complete.footer'.tr(),
                    textAlign: TextAlign.center,
                    style: textTheme.labelSmall,
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

/// Concentric circles around a leaf, ringed by an emerald→amber sweep.
class _Hero extends StatelessWidget {
  const _Hero();

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: SizedBox(
        height: 180,
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Container(
              width: 176,
              height: 176,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.surfaceLevel1,
                border: Border.all(color: AppColors.borderSubtle),
              ),
            ),
            Container(
              width: 112,
              height: 112,
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: SweepGradient(
                  colors: <Color>[
                    AppColors.primary,
                    AppColors.tertiary,
                    AppColors.primary,
                  ],
                ),
                boxShadow: <BoxShadow>[
                  BoxShadow(color: Color(0x4010B981), blurRadius: 32),
                ],
              ),
              child: Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.background,
                ),
                alignment: Alignment.center,
                child: const AppIcon(
                  icon: HugeIconsStrokeRounded.strokeRoundedLeaf01,
                  color: AppColors.primary,
                  size: 44,
                ),
              ),
            ),
            Align(
              alignment: const Alignment(-0.45, 0.85),
              child: Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.surfaceLevel3,
                ),
                alignment: Alignment.center,
                child: const AppIcon(
                  icon: HugeIconsStrokeRounded.strokeRoundedCheckmarkBadge01,
                  color: AppColors.primary,
                  size: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CommitmentCard extends StatelessWidget {
  const _CommitmentCard({required this.habits});

  final List<StarNyx> habits;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: AppColors.surfaceLevel1,
        borderRadius: BorderRadius.circular(AppRadius.sheet),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              const AppIcon(
                icon: HugeIconsStrokeRounded.strokeRoundedShieldCheck,
                color: AppColors.primary,
                size: 18,
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  'onboarding.complete.commitment'.tr(),
                  style: textTheme.labelMedium?.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xs,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: Text(
                  'onboarding.complete.ready'.tr(),
                  style: textTheme.labelMedium?.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          for (final habit in habits) ...<Widget>[
            const SizedBox(height: AppSpacing.sm),
            _HabitRow(habit: habit),
          ],
        ],
      ),
    );
  }
}

class _HabitRow extends StatelessWidget {
  const _HabitRow({required this.habit});

  final StarNyx habit;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final details = <String>[
      ?habit.reminderTime,
      'onboarding.reminder.daily'.tr(),
      ?habit.description,
    ].join(' · ');

    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surfaceLevel2,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        children: <Widget>[
          OnboardingSymbolTile(
            symbol: habit.icon,
            color: starnyxColorFromHex(habit.color),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(habit.title, style: textTheme.titleMedium),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  details,
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontFeatures: AppFonts.tabularFigures,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          const AppIcon(
            icon: HugeIconsStrokeRounded.strokeRoundedCheckmarkCircle02,
            color: AppColors.primary,
          ),
        ],
      ),
    );
  }
}

class _Quote extends StatelessWidget {
  const _Quote();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: AppColors.surfaceLevel1,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const AppIcon(
            icon: HugeIconsStrokeRounded.strokeRoundedQuoteDown,
            color: AppColors.tertiary,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'onboarding.complete.quote'.tr(),
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}
