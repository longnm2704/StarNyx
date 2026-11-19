import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';
import 'package:starnyx/core/constants/core_constants.dart';
import 'package:starnyx/core/widgets/core_widgets.dart';
import 'package:starnyx/features/onboarding/domain/onboarding_template.dart';
import 'package:starnyx/features/onboarding/presentation/widgets/onboarding_widgets.dart';
import 'package:starnyx/features/starnyx_form/presentation/widgets/starnyx_form_color_utils.dart';

/// Onboarding step 2/3: pick 1–3 starter habits (`chon_thoi_quen_mau`).
///
/// Selection is local state; [onContinue] hands the picked templates (in tap
/// order) to the reminder setup step.
class OnboardingTemplatePickerPage extends StatefulWidget {
  const OnboardingTemplatePickerPage({
    required this.onBack,
    required this.onSkip,
    required this.onCreateCustom,
    required this.onContinue,
    super.key,
  });

  final VoidCallback onBack;
  final VoidCallback onSkip;
  final VoidCallback onCreateCustom;
  final ValueChanged<List<OnboardingTemplate>> onContinue;

  @override
  State<OnboardingTemplatePickerPage> createState() =>
      _OnboardingTemplatePickerPageState();
}

class _OnboardingTemplatePickerPageState
    extends State<OnboardingTemplatePickerPage> {
  final List<OnboardingTemplate> _selected = <OnboardingTemplate>[];
  OnboardingCategory? _category;

  void _toggle(OnboardingTemplate template) {
    if (_selected.contains(template)) {
      setState(() => _selected.remove(template));
      return;
    }
    if (_selected.length >= onboardingMaxTemplates) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              'onboarding.picker.max_reached'.tr(
                args: <String>['$onboardingMaxTemplates'],
              ),
            ),
          ),
        );
      return;
    }
    setState(() => _selected.add(template));
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final visible = onboardingTemplates.where(
      (template) => _category == null || template.category == _category,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            OnboardingHeader(
              step: 'onboarding.picker.step'.tr(),
              onBack: widget.onBack,
              onSkip: widget.onSkip,
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.pageHorizontal,
                  AppSpacing.xs,
                  AppSpacing.pageHorizontal,
                  AppSpacing.lg,
                ),
                children: <Widget>[
                  OnboardingDotLabel(
                    child: Text.rich(
                      TextSpan(
                        children: <InlineSpan>[
                          TextSpan(
                            text: 'onboarding.picker.overline_step'.tr(),
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          TextSpan(
                            text:
                                ' · ${'onboarding.picker.overline_label'.tr()}',
                          ),
                        ],
                      ),
                      style: textTheme.labelMedium,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'onboarding.picker.title'.tr(),
                    style: textTheme.headlineLarge,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'onboarding.picker.subtitle'.tr(),
                    style: textTheme.bodyLarge,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: <Widget>[
                        _CategoryChip(
                          key: const Key('onboarding-category-all'),
                          label: 'onboarding.picker.category_all'.tr(),
                          selected: _category == null,
                          onTap: () => setState(() => _category = null),
                        ),
                        for (final category in OnboardingCategory.values)
                          _CategoryChip(
                            key: Key('onboarding-category-${category.name}'),
                            label: 'onboarding.picker.category_${category.name}'
                                .tr(),
                            selected: _category == category,
                            onTap: () => setState(() => _category = category),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  for (final template in visible) ...<Widget>[
                    _TemplateCard(
                      template: template,
                      selected: _selected.contains(template),
                      onTap: () => _toggle(template),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                  ],
                  const SizedBox(height: AppSpacing.xs),
                  _CreateCustomRow(onTap: widget.onCreateCustom),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'onboarding.picker.helper'.tr(),
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            _Footer(
              count: _selected.length,
              onContinue: _selected.isEmpty
                  ? null
                  : () => widget.onContinue(
                      List<OnboardingTemplate>.unmodifiable(_selected),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.xs),
      child: Semantics(
        selected: selected,
        button: true,
        child: Material(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.12)
              : AppColors.surfaceLevel2,
          shape: StadiumBorder(
            side: BorderSide(
              color: selected
                  ? AppColors.primary.withValues(alpha: 0.4)
                  : AppColors.borderSubtle,
            ),
          ),
          child: InkWell(
            customBorder: const StadiumBorder(),
            onTap: onTap,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: AppSize.iconButton),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                child: Center(
                  widthFactor: 1,
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: selected
                          ? AppColors.primary
                          : AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TemplateCard extends StatelessWidget {
  const _TemplateCard({
    required this.template,
    required this.selected,
    required this.onTap,
  });

  final OnboardingTemplate template;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final accent = starnyxColorFromHex(template.colorHex);

    return Semantics(
      selected: selected,
      button: true,
      child: AnimatedContainer(
        key: Key('onboarding-template-${template.id}'),
        duration: AppDurations.fast,
        decoration: BoxDecoration(
          color: AppColors.surfaceLevel2,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: selected
                ? AppColors.primary.withValues(alpha: 0.4)
                : AppColors.borderSubtle,
          ),
          boxShadow: selected
              ? const <BoxShadow>[
                  BoxShadow(color: Color(0x2610B981), blurRadius: 24),
                ]
              : null,
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            onTap: onTap,
            child: Padding(
              padding: AppSpacing.cardPadding,
              child: Row(
                children: <Widget>[
                  OnboardingSymbolTile(symbol: template.symbol, color: accent),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          template.titleKey.tr(),
                          style: textTheme.titleMedium,
                        ),
                        const SizedBox(height: AppSpacing.xxs),
                        Text(
                          template.descriptionKey.tr(),
                          style: textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Wrap(
                          spacing: AppSpacing.xs,
                          runSpacing: AppSpacing.xxs,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: <Widget>[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.xs,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: accent.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(
                                  AppRadius.pill,
                                ),
                              ),
                              child: Text(
                                template.tagKey.tr(),
                                style: textTheme.labelMedium?.copyWith(
                                  color: accent,
                                ),
                              ),
                            ),
                            Text(
                              '· ${template.durationKey.tr()}',
                              style: textTheme.labelMedium,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  _CheckCircle(selected: selected),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CheckCircle extends StatelessWidget {
  const _CheckCircle({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: AppDurations.fast,
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected ? AppColors.primary : AppColors.surfaceLevel3,
        border: selected ? null : Border.all(color: AppColors.borderSubtle),
      ),
      alignment: Alignment.center,
      child: selected
          ? const AppIcon(
              icon: HugeIconsStrokeRounded.strokeRoundedTick02,
              color: AppColors.onPrimary,
              size: 16,
              strokeWidth: 2.5,
            )
          : null,
    );
  }
}

class _CreateCustomRow extends StatelessWidget {
  const _CreateCustomRow({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      key: const Key('onboarding-create-custom'),
      borderRadius: BorderRadius.circular(AppRadius.pill),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: AppColors.surfaceLevel3,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const AppIcon(
                icon: HugeIconsStrokeRounded.strokeRoundedPlusSign,
                color: AppColors.textPrimary,
                size: 18,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Flexible(
              child: Text(
                'onboarding.picker.create_custom'.tr(),
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: AppColors.textPrimary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({required this.count, required this.onContinue});

  final int count;
  final VoidCallback? onContinue;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.surfaceLevel1,
        border: Border(top: BorderSide(color: AppColors.borderSubtle)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.pageHorizontal,
          AppSpacing.sm,
          AppSpacing.pageHorizontal,
          AppSpacing.sm,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: AppSpacing.xs,
              children: <Widget>[
                OnboardingDotLabel(
                  child: Text(
                    'onboarding.picker.selected_count'.tr(
                      args: <String>['$count', '$onboardingMaxTemplates'],
                    ),
                    style: textTheme.labelMedium?.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Text(
                  'onboarding.picker.recommended'.tr(),
                  style: textTheme.labelMedium?.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            AppPrimaryButton(
              key: const Key('onboarding-continue'),
              label:
                  '${'onboarding.picker.continue'.tr(args: <String>['$count'])} →',
              onPressed: onContinue,
            ),
          ],
        ),
      ),
    );
  }
}
