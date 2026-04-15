const int homeGridColumnCount = 18;

int homeGridDayCountForYear(int year) {
  return DateTime.utc(
    year + 1,
    1,
    1,
  ).difference(DateTime.utc(year, 1, 1)).inDays;
}

DateTime homeGridDateForIndex(int year, int index) {
  return DateTime.utc(year, 1, 1).add(Duration(days: index));
}
