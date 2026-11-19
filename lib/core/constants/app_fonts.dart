import 'package:flutter/painting.dart';

/// Font families bundled with the app (see `pubspec.yaml` `fonts:` section).
///
/// Obsidian Lumina uses three families:
/// - [headline] Space Grotesk — display/headline styles.
/// - [body] Plus Jakarta Sans — titles, body copy.
/// - [mono] JetBrains Mono — labels, metrics, tabular figures.
abstract final class AppFonts {
  static const headline = 'Space Grotesk';
  static const body = 'Plus Jakarta Sans';
  static const mono = 'JetBrains Mono';

  /// Enables tabular (monospaced) figures so numeric metrics align.
  static const tabularFigures = [FontFeature.tabularFigures()];
}
