/// Named route table shared by the router, shell, and feature pages.
abstract final class AppRoutes {
  static const habits = '/habits';
  static const overview = '/overview';
  static const journal = '/journal';
  static const settings = '/settings';
  static const habitList = '/habits/list';

  /// Legacy alias kept for existing call sites; the shell always opens Habits.
  static const home = habits;
}
