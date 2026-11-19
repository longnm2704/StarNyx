// Starter habits offered by the onboarding template picker (STX-U021).

/// Filter chips on the template picker; localized as
/// `onboarding.picker.category_<name>`.
enum OnboardingCategory { health, mind, discipline, energy }

/// A starter habit. Copy lives under `onboarding.templates.<id>.*`
/// (`title`, `description`, `tag`, `duration`). The reminder setup step
/// (STX-U022) lets the user adjust [reminderTime] and then creates the habit
/// with `CreateStarNyxUseCase` using the localized title/description.
class OnboardingTemplate {
  const OnboardingTemplate({
    required this.id,
    required this.symbol,
    required this.colorHex,
    required this.reminderTime,
    required this.category,
  });

  final String id;

  /// A `HabitSymbols.icons` key.
  final String symbol;

  /// One of `AppColors.starnyxPresetColorHexes`.
  final String colorHex;

  /// Default reminder, `HH:mm`.
  final String reminderTime;
  final OnboardingCategory category;

  String get titleKey => 'onboarding.templates.$id.title';
  String get descriptionKey => 'onboarding.templates.$id.description';
  String get tagKey => 'onboarding.templates.$id.tag';
  String get durationKey => 'onboarding.templates.$id.duration';
}

const int onboardingMaxTemplates = 3;

const List<OnboardingTemplate> onboardingTemplates = <OnboardingTemplate>[
  OnboardingTemplate(
    id: 'water',
    symbol: 'droplet',
    colorHex: '#10B981',
    reminderTime: '06:30',
    category: OnboardingCategory.health,
  ),
  OnboardingTemplate(
    id: 'sleep',
    symbol: 'moon',
    colorHex: '#FFB95F',
    reminderTime: '22:15',
    category: OnboardingCategory.discipline,
  ),
  OnboardingTemplate(
    id: 'reading',
    symbol: 'book',
    colorHex: '#9D50FF',
    reminderTime: '21:00',
    category: OnboardingCategory.mind,
  ),
  OnboardingTemplate(
    id: 'move',
    symbol: 'run',
    colorHex: '#10B981',
    reminderTime: '07:00',
    category: OnboardingCategory.energy,
  ),
  OnboardingTemplate(
    id: 'gratitude',
    symbol: 'pencil',
    colorHex: '#FFB95F',
    reminderTime: '21:30',
    category: OnboardingCategory.mind,
  ),
];
