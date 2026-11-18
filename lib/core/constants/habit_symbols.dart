import 'package:hugeicons/styles/stroke_rounded.dart';

// Habit symbol catalog. Keys are a persisted data contract (DB + backups):
// never rename or reuse a key. `star` is the default and the fallback for
// unknown keys.
abstract final class HabitSymbols {
  static const String defaultKey = 'star';

  static const Map<String, List<List<dynamic>>> icons =
      <String, List<List<dynamic>>>{
        'star': HugeIconsStrokeRounded.strokeRoundedStar,
        'clover': HugeIconsStrokeRounded.strokeRoundedClover,
        'sprout': HugeIconsStrokeRounded.strokeRoundedSprout,
        'leaf': HugeIconsStrokeRounded.strokeRoundedLeaf01,
        'flower': HugeIconsStrokeRounded.strokeRoundedFlower01,
        'tree': HugeIconsStrokeRounded.strokeRoundedTree01,
        'heart': HugeIconsStrokeRounded.strokeRoundedHeart,
        'brain': HugeIconsStrokeRounded.strokeRoundedBrain,
        'music': HugeIconsStrokeRounded.strokeRoundedMusic,
        'pencil': HugeIconsStrokeRounded.strokeRoundedPencil,
        'flame': HugeIconsStrokeRounded.strokeRoundedFlame,
        'zap': HugeIconsStrokeRounded.strokeRoundedZap,
        'dumbbell': HugeIconsStrokeRounded.strokeRoundedDumbbell01,
        'bike': HugeIconsStrokeRounded.strokeRoundedBike,
        'moon': HugeIconsStrokeRounded.strokeRoundedMoon01,
        'sun': HugeIconsStrokeRounded.strokeRoundedSun01,
        'cloud': HugeIconsStrokeRounded.strokeRoundedCloud,
        'coffee': HugeIconsStrokeRounded.strokeRoundedCoffee01,
        'book': HugeIconsStrokeRounded.strokeRoundedBookOpen01,
        'home': HugeIconsStrokeRounded.strokeRoundedHome01,
      };

  static const List<HabitSymbolGroup> groups = <HabitSymbolGroup>[
    HabitSymbolGroup('Nature', <String>[
      'clover',
      'sprout',
      'leaf',
      'flower',
      'tree',
    ]),
    HabitSymbolGroup('Feelings', <String>[
      'heart',
      'brain',
      'music',
      'pencil',
    ]),
    HabitSymbolGroup('Energy', <String>[
      'flame',
      'zap',
      'dumbbell',
      'bike',
    ]),
    HabitSymbolGroup('Sky', <String>['star', 'moon', 'sun', 'cloud']),
    HabitSymbolGroup('Daily life', <String>['coffee', 'book', 'home']),
  ];

  // Unknown keys fall back to `star` so a bad backup or a stale DB row never
  // crashes the UI.
  static List<List<dynamic>> iconFor(String? key) {
    return icons[key] ?? icons[defaultKey]!;
  }
}

class HabitSymbolGroup {
  const HabitSymbolGroup(this.label, this.keys);

  final String label;
  final List<String> keys;
}
