import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';
import 'package:starnyx/core/constants/core_constants.dart';
import 'package:starnyx/core/widgets/core_widgets.dart';

const _violet = Color(0xFF9D50FF);

/// Onboarding step 1/3: welcome (`chao_mung`).
class OnboardingWelcomePage extends StatelessWidget {
  const OnboardingWelcomePage({
    required this.onStart,
    required this.onSkip,
    required this.onRestore,
    super.key,
  });

  final VoidCallback onStart;
  final VoidCallback onSkip;
  final VoidCallback onRestore;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
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
                AppSpacing.xs,
                AppSpacing.pageHorizontal,
                AppSpacing.lg,
              ),
              children: <Widget>[
                Row(
                  children: <Widget>[
                    const _PageIndicator(),
                    const Spacer(),
                    TextButton(
                      key: const Key('onboarding-skip'),
                      onPressed: onSkip,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            'onboarding.skip'.tr(),
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.xxs),
                          const AppIcon(
                            icon: HugeIconsStrokeRounded
                                .strokeRoundedArrowRight02,
                            color: AppColors.textSecondary,
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                const _Hero(),
                const SizedBox(height: AppSpacing.md),
                Center(
                  child: _Pill(
                    icon: HugeIconsStrokeRounded.strokeRoundedFire,
                    iconColor: AppColors.tertiary,
                    label: 'onboarding.welcome.days_pill'.tr(),
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Center(
                  child: _Pill(label: 'onboarding.welcome.values_pill'.tr()),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  '• ${'onboarding.welcome.overline'.tr()}',
                  textAlign: TextAlign.center,
                  style: textTheme.labelLarge?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text.rich(
                  TextSpan(
                    children: <InlineSpan>[
                      TextSpan(text: 'onboarding.welcome.title_lead'.tr()),
                      TextSpan(
                        text: 'onboarding.welcome.title_emphasis'.tr(),
                        style: const TextStyle(color: AppColors.primary),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                  style: textTheme.headlineLarge?.copyWith(fontSize: 34),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'onboarding.welcome.subtitle'.tr(),
                  textAlign: TextAlign.center,
                  style: textTheme.bodyLarge,
                ),
                const SizedBox(height: AppSpacing.lg),
                _FeatureRow(
                  icon: HugeIconsStrokeRounded.strokeRoundedDashboardSquare01,
                  color: AppColors.primary,
                  title: 'onboarding.welcome.feature_grid_title'.tr(),
                  subtitle: 'onboarding.welcome.feature_grid_subtitle'.tr(),
                  trailing: const _MiniGrid(),
                ),
                _FeatureRow(
                  icon: HugeIconsStrokeRounded.strokeRoundedShield01,
                  color: _violet,
                  title: 'onboarding.welcome.feature_privacy_title'.tr(),
                  subtitle: 'onboarding.welcome.feature_privacy_subtitle'.tr(),
                  trailing: _Badge(
                    'onboarding.welcome.feature_privacy_badge'.tr(),
                  ),
                ),
                _FeatureRow(
                  icon: HugeIconsStrokeRounded.strokeRoundedNotification03,
                  color: AppColors.tertiary,
                  title: 'onboarding.welcome.feature_reminder_title'.tr(),
                  subtitle: 'onboarding.welcome.feature_reminder_subtitle'.tr(),
                  trailing: const _AccentDot(color: AppColors.tertiary),
                ),
                const SizedBox(height: AppSpacing.xs),
                const _DemoCard(),
                const SizedBox(height: AppSpacing.lg),
                AppPrimaryButton(
                  key: const Key('onboarding-start'),
                  label: '${'onboarding.welcome.cta'.tr()} →',
                  onPressed: onStart,
                ),
                const SizedBox(height: AppSpacing.xs),
                Center(
                  child: TextButton.icon(
                    key: const Key('onboarding-restore'),
                    onPressed: onRestore,
                    icon: const AppIcon(
                      icon: HugeIconsStrokeRounded.strokeRoundedRefresh,
                      color: AppColors.textSecondary,
                      size: 18,
                    ),
                    label: Text(
                      'onboarding.welcome.restore'.tr(),
                      style: textTheme.bodyLarge?.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const AppIcon(
                      icon: HugeIconsStrokeRounded.strokeRoundedShieldCheck,
                      color: AppColors.textTertiary,
                      size: 14,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Flexible(
                      child: Text(
                        'onboarding.welcome.footer'.tr(),
                        textAlign: TextAlign.center,
                        style: textTheme.labelSmall,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Three-step progress: the first dot is an elongated emerald bar.
class _PageIndicator extends StatelessWidget {
  const _PageIndicator();

  @override
  Widget build(BuildContext context) {
    Widget dot({required bool active}) => Container(
      width: active ? 24 : 6,
      height: 6,
      margin: const EdgeInsets.only(right: AppSpacing.xxs),
      decoration: BoxDecoration(
        color: active ? AppColors.primary : AppColors.surfaceLevel3,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
    );
    return ExcludeSemantics(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          dot(active: true),
          dot(active: false),
          dot(active: false),
        ],
      ),
    );
  }
}

/// Concentric circles around a sprout, with a few floating accent dots.
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
              width: 168,
              height: 168,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.surfaceLevel1,
                border: Border.all(color: AppColors.borderSubtle),
              ),
            ),
            Container(
              width: 104,
              height: 104,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.12),
                boxShadow: const <BoxShadow>[
                  BoxShadow(color: Color(0x2610B981), blurRadius: 24),
                ],
              ),
              alignment: Alignment.center,
              child: const AppIcon(
                icon: HugeIconsStrokeRounded.strokeRoundedSprout,
                color: AppColors.primary,
                size: 44,
              ),
            ),
            const Align(
              alignment: Alignment(0.5, -0.9),
              child: _AccentDot(color: AppColors.primary, size: 10),
            ),
            const Align(
              alignment: Alignment(-0.6, -0.05),
              child: _AccentDot(color: AppColors.tertiary, size: 6),
            ),
            const Align(
              alignment: Alignment(-0.45, 0.7),
              child: _AccentDot(color: _violet, size: 8),
            ),
          ],
        ),
      ),
    );
  }
}

class _AccentDot extends StatelessWidget {
  const _AccentDot({required this.color, this.size = 8});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, this.icon, this.iconColor});

  final String label;
  final List<List<dynamic>>? icon;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceLevel2,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (icon != null) ...<Widget>[
            AppIcon(icon: icon!, color: iconColor, size: 16),
            const SizedBox(width: AppSpacing.xs),
          ],
          Flexible(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  final List<List<dynamic>> icon;
  final Color color;
  final String title;
  final String subtitle;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: AppCard(
        child: Row(
          children: <Widget>[
            _IconTile(icon: icon, color: color),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(title, style: textTheme.titleMedium),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            trailing,
          ],
        ),
      ),
    );
  }
}

class _IconTile extends StatelessWidget {
  const _IconTile({required this.icon, required this.color});

  final List<List<dynamic>> icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      alignment: Alignment.center,
      child: AppIcon(icon: icon, color: color, size: 22),
    );
  }
}

class _MiniGrid extends StatelessWidget {
  const _MiniGrid();

  @override
  Widget build(BuildContext context) {
    Widget cell(Color color) => Container(
      width: 8,
      height: 8,
      margin: const EdgeInsets.only(left: 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
      ),
    );
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        cell(AppColors.primary),
        cell(AppColors.primary.withValues(alpha: 0.6)),
        cell(AppColors.surfaceLevel3),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 96),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xs,
          vertical: AppSpacing.xxs,
        ),
        decoration: BoxDecoration(
          color: _violet.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.labelSmall?.copyWith(color: _violet),
        ),
      ),
    );
  }
}

/// Self-contained "try it" card: tapping lights the check with a haptic and
/// an emerald bloom. Nothing is persisted.
class _DemoCard extends StatefulWidget {
  const _DemoCard();

  @override
  State<_DemoCard> createState() => _DemoCardState();
}

class _DemoCardState extends State<_DemoCard> {
  bool _lit = false;

  void _toggle() {
    HapticFeedback.lightImpact();
    setState(() => _lit = !_lit);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final duration = reduceMotion ? Duration.zero : AppDurations.medium;

    return Semantics(
      button: true,
      checked: _lit,
      child: Material(
        color: AppColors.surfaceLevel2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
          side: const BorderSide(color: AppColors.borderSubtle),
        ),
        child: InkWell(
          key: const Key('onboarding-demo'),
          borderRadius: BorderRadius.circular(AppRadius.card),
          onTap: _toggle,
          child: Padding(
            padding: AppSpacing.cardPadding,
            child: Row(
              children: <Widget>[
                _IconTile(
                  icon: HabitSymbols.iconFor('droplet'),
                  color: AppColors.primary,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'onboarding.templates.water.title'.tr(),
                        style: textTheme.titleMedium,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        (_lit
                                ? 'onboarding.welcome.demo_done'
                                : 'onboarding.welcome.demo_hint')
                            .tr(),
                        style: textTheme.labelMedium?.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                AnimatedContainer(
                  duration: duration,
                  curve: Curves.easeOut,
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _lit ? AppColors.primary : AppColors.surfaceLevel3,
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: AppColors.primary.withValues(
                          alpha: _lit ? 0.45 : 0,
                        ),
                        blurRadius: _lit ? 28 : 0,
                        spreadRadius: _lit ? 2 : 0,
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: AppIcon(
                    icon: HugeIconsStrokeRounded.strokeRoundedTick02,
                    color: _lit ? AppColors.onPrimary : AppColors.textSecondary,
                    size: 22,
                    strokeWidth: 2.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
