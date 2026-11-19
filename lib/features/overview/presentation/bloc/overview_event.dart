import 'package:starnyx/core/constants/enums.dart';

sealed class OverviewEvent {
  const OverviewEvent();
}

final class OverviewLoadRequested extends OverviewEvent {
  const OverviewLoadRequested();
}

final class OverviewReloadRequested extends OverviewEvent {
  const OverviewReloadRequested();
}

final class OverviewRangeChanged extends OverviewEvent {
  const OverviewRangeChanged(this.range);

  final OverviewRange range;
}
