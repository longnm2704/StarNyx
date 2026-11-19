import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';
import 'package:starnyx/app/di/service_locator.dart';
import 'package:starnyx/core/constants/core_constants.dart';
import 'package:starnyx/core/utils/date_utils.dart' as core_date_utils;
import 'package:starnyx/core/widgets/app_empty_state.dart';
import 'package:starnyx/core/widgets/app_error_state.dart';
import 'package:starnyx/core/widgets/app_icon.dart';
import 'package:starnyx/domain/entities/overview_stats.dart';
import 'package:starnyx/features/overview/presentation/bloc/overview_bloc.dart';
import 'package:starnyx/features/overview/presentation/bloc/overview_event.dart';
import 'package:starnyx/features/overview/presentation/bloc/overview_state.dart';
import 'package:starnyx/features/starnyx_form/presentation/pages/starnyx_form_page.dart';

/// Full-screen Overview tab.
///
/// Hosts its own [OverviewBloc] so parent shells do not need to manage
/// per-tab lifecycle. Reloads automatically when the shell's create-sheet
/// completes (via [reloadToken]).
class OverviewPage extends StatefulWidget {
  const OverviewPage({
    this.bloc,
    this.reloadToken = 0,
    this.onProfilePressed,
    super.key,
  });

  final OverviewBloc? bloc;
  final int reloadToken;
  final VoidCallback? onProfilePressed;

  @override
  State<OverviewPage> createState() => _OverviewPageState();
}

class _OverviewPageState extends State<OverviewPage> {
  late final OverviewBloc _bloc;
  late final bool _ownsBloc;
  int _lastReloadToken = 0;

  @override
  void initState() {
    super.initState();
    _ownsBloc = widget.bloc == null;
    _bloc = widget.bloc ?? serviceLocator<OverviewBloc>();
    _lastReloadToken = widget.reloadToken;
    _bloc.add(const OverviewLoadRequested());
  }

  @override
  void didUpdateWidget(covariant OverviewPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.reloadToken != _lastReloadToken) {
      _lastReloadToken = widget.reloadToken;
      _bloc.add(const OverviewReloadRequested());
    }
  }

  @override
  void dispose() {
    if (_ownsBloc) {
      _bloc.close();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<OverviewBloc>.value(
      value: _bloc,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          bottom: false,
          child: _OverviewScreen(onProfilePressed: widget.onProfilePressed),
        ),
      ),
    );
  }
}

class _OverviewScreen extends StatelessWidget {
  const _OverviewScreen({this.onProfilePressed});

  final VoidCallback? onProfilePressed;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OverviewBloc, OverviewState>(
      listener: (BuildContext context, OverviewState state) {
        if (state.status == OverviewStatus.failure) {
          ScaffoldMessenger.maybeOf(context)?.showSnackBar(
            SnackBar(content: Text('overview.error_message'.tr())),
          );
        }
      },
      builder: (BuildContext context, OverviewState state) {
        if (state.status == OverviewStatus.initial ||
            (state.status == OverviewStatus.loading && state.stats == null)) {
          return const _OverviewSkeleton();
        }

        if (state.status == OverviewStatus.failure && state.stats == null) {
          return _OverviewErrorView(
            onRetry: () => context.read<OverviewBloc>().add(
              const OverviewReloadRequested(),
            ),
          );
        }

        if (state.stats == null || state.isEmpty) {
          return _OverviewEmptyView(onProfilePressed: onProfilePressed);
        }

        return _OverviewContent(
          state: state,
          onProfilePressed: onProfilePressed,
        );
      },
    );
  }
}

class _OverviewAppBar extends StatelessWidget {
  const _OverviewAppBar({this.onProfilePressed});

  final VoidCallback? onProfilePressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pageHorizontal,
        AppSpacing.xs,
        AppSpacing.pageHorizontal,
        AppSpacing.xs,
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'app.title'.tr().toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontFamily: AppFonts.mono,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.1,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  'overview.title'.tr(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontFamily: AppFonts.headline,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.4,
                  ),
                ),
              ],
            ),
          ),
          _ProfileButton(onPressed: onProfilePressed),
        ],
      ),
    );
  }
}

class _ProfileButton extends StatelessWidget {
  const _ProfileButton({this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'home.profile_semantics'.tr(),
      child: Material(
        color: AppColors.primary,
        shape: const CircleBorder(),
        child: InkWell(
          key: const Key('overview-profile-button'),
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: const SizedBox.square(
            dimension: 36,
            child: Center(
              child: AppIcon(
                icon: HugeIconsStrokeRounded.strokeRoundedUser,
                size: 20,
                color: AppColors.onPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RangeSelector extends StatelessWidget {
  const _RangeSelector({
    required this.currentRange,
    required this.year,
    required this.onChanged,
  });

  final OverviewRange currentRange;
  final int year;
  final ValueChanged<OverviewRange> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: _RangePill(
            label: 'overview.weekly'.tr(),
            isActive: currentRange == OverviewRange.week,
            onTap: () => onChanged(OverviewRange.week),
          ),
        ),
        Expanded(
          child: _RangePill(
            label: 'overview.monthly'.tr(),
            isActive: currentRange == OverviewRange.month,
            onTap: () => onChanged(OverviewRange.month),
          ),
        ),
        Expanded(
          child: _RangePill(
            label: 'overview.yearly'.tr(namedArgs: {'year': '$year'}),
            isActive: currentRange == OverviewRange.year,
            onTap: () => onChanged(OverviewRange.year),
          ),
        ),
      ],
    );
  }
}

class _RangePill extends StatelessWidget {
  const _RangePill({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      button: true,
      selected: isActive,
      child: Material(
        color: isActive
            ? AppColors.primary.withValues(alpha: 0.12)
            : Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          side: BorderSide(
            color: isActive ? AppColors.primary : Colors.transparent,
            width: 1.2,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xs,
              vertical: AppSpacing.xs,
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                maxLines: 1,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: isActive ? AppColors.primary : AppColors.textSecondary,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.completionRate,
    required this.litDays,
    required this.totalValidDays,
  });

  final double completionRate;
  final int litDays;
  final int totalValidDays;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pct = (completionRate * 100).round();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceLevel1,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'overview.completion_rate'.tr().toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(
              fontFamily: AppFonts.mono,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        '$pct%',
                        maxLines: 1,
                        style: theme.textTheme.displaySmall?.copyWith(
                          fontFamily: AppFonts.headline,
                          fontWeight: FontWeight.w700,
                          fontSize: 40,
                          height: 1.0,
                          color: AppColors.primary,
                          fontFeatures: <FontFeature>[
                            const FontFeature.tabularFigures(),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'overview.completion_sub'.tr(
                        namedArgs: <String, String>{
                          'lit': '$litDays',
                          'total': '$totalValidDays',
                        },
                      ),
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontFamily: AppFonts.mono,
                        color: AppColors.textSecondary,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              CustomPaint(
                size: const Size(88, 88),
                painter: _CircularProgressPainter(
                  progress: completionRate,
                  strokeWidth: 8,
                  color: AppColors.primary,
                  glowColor: AppColors.primary.withValues(alpha: 0.3),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CircularProgressPainter extends CustomPainter {
  const _CircularProgressPainter({
    required this.progress,
    required this.strokeWidth,
    required this.color,
    required this.glowColor,
  });

  final double progress;
  final double strokeWidth;
  final Color color;
  final Color glowColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final backgroundPaint = Paint()
      ..color = AppColors.borderSubtle.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final glowPaint = Paint()
      ..color = glowColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth + 4
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    final foregroundPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    if (progress > 0) {
      final sweepAngle = 2 * 3.1415926535 * progress;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -3.1415926535 / 2,
        sweepAngle,
        false,
        glowPaint,
      );
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -3.1415926535 / 2,
        sweepAngle,
        false,
        foregroundPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.glowColor != glowColor;
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.subtitle,
    this.accentColor = AppColors.primary,
  });

  final List<List<dynamic>> icon;
  final String title;
  final String value;
  final String subtitle;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceLevel1,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Text(
                  title.toUpperCase(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontFamily: AppFonts.mono,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.1,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.xxs),
              AppIcon(icon: icon, size: 18, color: accentColor),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontFamily: AppFonts.headline,
              fontWeight: FontWeight.w700,
              color: accentColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeatmapCard extends StatelessWidget {
  const _HeatmapCard({
    required this.dailyLitCounts,
    required this.dailyValidCounts,
    required this.rangeStart,
    required this.rangeEnd,
    required this.year,
  });

  final Map<DateTime, int> dailyLitCounts;
  final Map<DateTime, int> dailyValidCounts;
  final DateTime? rangeStart;
  final DateTime? rangeEnd;
  final int year;

  @override
  Widget build(BuildContext context) {
    if (rangeStart == null || rangeEnd == null) {
      return const SizedBox.shrink();
    }

    final days = <DateTime>[];
    for (
      var day = rangeStart!;
      !day.isAfter(rangeEnd!);
      day = day.add(const Duration(days: 1))
    ) {
      days.add(day);
    }

    final maxLit = dailyLitCounts.values.isEmpty
        ? 1
        : dailyLitCounts.values.reduce((a, b) => a > b ? a : b);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceLevel1,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'overview.discipline_matrix'.tr(),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontFamily: AppFonts.headline,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'overview.discipline_sub'.tr(namedArgs: {'year': '$year'}),
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.md),
          const _HeatmapLegend(),
          const SizedBox(height: AppSpacing.sm),
          _HeatmapGrid(
            days: days,
            dailyLitCounts: dailyLitCounts,
            dailyValidCounts: dailyValidCounts,
            maxLit: maxLit,
          ),
        ],
      ),
    );
  }
}

class _HeatmapLegend extends StatelessWidget {
  const _HeatmapLegend();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: <Widget>[
        Text(
          'overview.legend_low'.tr(),
          style: theme.textTheme.labelSmall?.copyWith(
            fontFamily: AppFonts.mono,
            color: AppColors.textSecondary,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        ..._legendColors.map(
          (color) => Padding(
            padding: const EdgeInsets.only(right: 2),
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          'overview.legend_high'.tr(),
          style: theme.textTheme.labelSmall?.copyWith(
            fontFamily: AppFonts.mono,
            color: AppColors.textSecondary,
            letterSpacing: 1.1,
          ),
        ),
      ],
    );
  }

  static const List<Color> _legendColors = <Color>[
    Color(0xFF0A0A0C),
    Color(0xFF1E4D2E),
    Color(0xFF34A853),
    Color(0xFF10B981),
    Color(0xFF6CE79A),
  ];
}

class _HeatmapGrid extends StatelessWidget {
  const _HeatmapGrid({
    required this.days,
    required this.dailyLitCounts,
    required this.dailyValidCounts,
    required this.maxLit,
  });

  final List<DateTime> days;
  final Map<DateTime, int> dailyLitCounts;
  final Map<DateTime, int> dailyValidCounts;
  final int maxLit;

  @override
  Widget build(BuildContext context) {
    final crossAxisCount = 7;
    final cellWidth = _HeatmapLegend._legendColors.length * 12.0;

    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: days.length * cellWidth / crossAxisCount,
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 3,
          mainAxisSpacing: 3,
          childAspectRatio: 1.0,
        ),
        itemCount: days.length,
        itemBuilder: (BuildContext context, int index) {
          final day = days[index];
          final lit = dailyLitCounts[day] ?? 0;
          final valid = dailyValidCounts[day] ?? 0;

          Color cellColor;
          if (valid == 0) {
            cellColor = AppColors.surfaceLevel2;
          } else if (lit == 0) {
            cellColor = _HeatmapLegend._legendColors[0];
          } else {
            final ratio = lit / maxLit;
            if (ratio >= 0.8) {
              cellColor = _HeatmapLegend._legendColors[4];
            } else if (ratio >= 0.6) {
              cellColor = _HeatmapLegend._legendColors[3];
            } else if (ratio >= 0.4) {
              cellColor = _HeatmapLegend._legendColors[2];
            } else if (ratio >= 0.2) {
              cellColor = _HeatmapLegend._legendColors[1];
            } else {
              cellColor = _HeatmapLegend._legendColors[0].withValues(
                alpha: 0.6,
              );
            }
          }

          return Semantics(
            label: 'overview.heatmap_cell'.tr(
              namedArgs: <String, String>{
                'day': '${day.day}',
                'month': '${day.month}',
                'lit': '$lit',
                'total': '$valid',
              },
            ),
            child: Container(
              decoration: BoxDecoration(
                color: cellColor,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _HabitListSection extends StatelessWidget {
  const _HabitListSection({required this.habits});

  final List<OverviewHabitStats> habits;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceLevel1,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'overview.per_habit'.tr(),
            style: theme.textTheme.titleMedium?.copyWith(
              fontFamily: AppFonts.headline,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: habits.length,
            separatorBuilder: (_, int index) =>
                const SizedBox(height: AppSpacing.sm),
            itemBuilder: (BuildContext context, int index) {
              return _HabitRow(habit: habits[index]);
            },
          ),
        ],
      ),
    );
  }
}

class _HabitRow extends StatelessWidget {
  const _HabitRow({required this.habit});

  final OverviewHabitStats habit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = _accentColor(habit.color);
    final pct = (habit.completionRateForYear * 100).round();

    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: accent.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Center(
              child: AppIcon(
                icon: HabitSymbols.iconFor(habit.icon),
                size: 20,
                color: accent,
                strokeWidth: 2,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  habit.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: accent,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'overview.current_streak'.tr(
                    namedArgs: {'days': '${habit.currentStreak}'},
                  ),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Text(
                '$pct%',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontFamily: AppFonts.mono,
                  fontWeight: FontWeight.w700,
                  color: accent,
                ),
              ),
              const SizedBox(height: 4),
              SizedBox(
                width: 60,
                child: LinearProgressIndicator(
                  value: habit.completionRateForYear,
                  minHeight: 3,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  backgroundColor: AppColors.borderSubtle,
                  valueColor: AlwaysStoppedAnimation<Color>(accent),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _accentColor(String hex) {
    try {
      final cleaned = hex.replaceFirst('#', '');
      final value = int.parse(cleaned, radix: 16);
      return Color(0xFF000000 | value);
    } catch (_) {
      return AppColors.primary;
    }
  }
}

class _OverviewContent extends StatelessWidget {
  const _OverviewContent({required this.state, this.onProfilePressed});

  final OverviewState state;
  final VoidCallback? onProfilePressed;

  @override
  Widget build(BuildContext context) {
    final stats = state.stats!;
    final bloc = context.read<OverviewBloc>();
    final daysInYear = core_date_utils.DateUtils.daysInYear(state.year);
    final litPct = daysInYear > 0
        ? ((stats.totalLitDays / daysInYear) * 100).round()
        : 0;

    return CustomScrollView(
      slivers: <Widget>[
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _OverviewAppBar(onProfilePressed: onProfilePressed),
              const SizedBox(height: AppSpacing.md),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.pageHorizontal,
                ),
                child: Container(
                  padding: const EdgeInsets.all(1),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLevel1,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  child: _RangeSelector(
                    currentRange: state.range,
                    year: state.year,
                    onChanged: (range) => bloc.add(OverviewRangeChanged(range)),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.pageHorizontal,
                ),
                child: _HeroCard(
                  completionRate: stats.overallCompletionRate,
                  litDays: stats.totalLitDays,
                  totalValidDays: stats.totalValidDays,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.pageHorizontal,
                ),
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Expanded(
                        child: _StatTile(
                          icon: HugeIconsStrokeRounded.strokeRoundedFire,
                          title: 'overview.lit_days'.tr(),
                          value: '${stats.totalLitDays} / $daysInYear',
                          subtitle: 'overview.lit_sub'.tr(
                            namedArgs: <String, String>{'pct': '$litPct'},
                          ),
                          accentColor: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: _StatTile(
                          icon: HugeIconsStrokeRounded.strokeRoundedAward02,
                          title: 'overview.longest_streak'.tr(),
                          value: 'overview.longest_streak_sub'.tr(
                            namedArgs: {'days': '${stats.bestLongestStreak}'},
                          ),
                          subtitle: 'overview.longest_streak_note'.tr(),
                          accentColor: AppColors.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.pageHorizontal,
                ),
                child: _HeatmapCard(
                  dailyLitCounts: stats.dailyLitCounts,
                  dailyValidCounts: stats.dailyValidCounts,
                  rangeStart: stats.rangeStart,
                  rangeEnd: stats.rangeEnd,
                  year: state.year,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.pageHorizontal,
                ),
                child: _HabitListSection(habits: stats.habits),
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ],
    );
  }
}

class _OverviewSkeleton extends StatelessWidget {
  const _OverviewSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pageHorizontal,
        AppSpacing.xs,
        AppSpacing.pageHorizontal,
        AppSpacing.xl,
      ),
      children: <Widget>[
        const _SkeletonBlock(height: 48, width: 120),
        const SizedBox(height: AppSpacing.md),
        const _SkeletonBlock(height: 36, width: 200),
        const SizedBox(height: AppSpacing.lg),
        const _SkeletonBlock(height: 160, width: double.infinity),
        const SizedBox(height: AppSpacing.lg),
        Row(
          children: <Widget>[
            const Expanded(
              child: _SkeletonBlock(height: 100, width: double.infinity),
            ),
            const SizedBox(width: AppSpacing.sm),
            const Expanded(
              child: _SkeletonBlock(height: 100, width: double.infinity),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        const _SkeletonBlock(height: 180, width: double.infinity),
        const SizedBox(height: AppSpacing.lg),
        const _SkeletonBlock(height: 200, width: double.infinity),
      ],
    );
  }
}

class _SkeletonBlock extends StatelessWidget {
  const _SkeletonBlock({required this.height, required this.width});

  final double height;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: AppColors.surfaceLevel2,
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
    );
  }
}

class _OverviewEmptyView extends StatelessWidget {
  const _OverviewEmptyView({this.onProfilePressed});

  final VoidCallback? onProfilePressed;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pageHorizontal,
        AppSpacing.lg,
        AppSpacing.pageHorizontal,
        AppSpacing.xl,
      ),
      child: Column(
        children: <Widget>[
          _OverviewAppBar(onProfilePressed: onProfilePressed),
          const SizedBox(height: AppSpacing.lg),
          AppEmptyState(
            icon: HugeIconsStrokeRounded.strokeRoundedChartBarLine,
            title: 'overview.empty_title'.tr(),
            message: 'overview.empty_message'.tr(),
            actionLabel: 'overview.empty_action'.tr(),
            onActionPressed: () async {
              final result = await StarnyxFormPage.open(context);
              if (result != null && result.hasChanges && context.mounted) {
                context.read<OverviewBloc>().add(
                  const OverviewReloadRequested(),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

class _OverviewErrorView extends StatelessWidget {
  const _OverviewErrorView({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pageHorizontal,
        AppSpacing.lg,
        AppSpacing.pageHorizontal,
        AppSpacing.xl,
      ),
      child: Column(
        children: <Widget>[
          AppErrorState(
            title: 'overview.error_title'.tr(),
            message: 'overview.error_message'.tr(),
            retryLabel: 'overview.retry'.tr(),
            onRetry: onRetry,
          ),
        ],
      ),
    );
  }
}
