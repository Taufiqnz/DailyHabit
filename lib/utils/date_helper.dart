String todayDate() {
  final now = DateTime.now();
  return "${now.year}-${now.month}-${now.day}";
}

String formatDate(DateTime date) {
  return "${date.year}-${date.month}-${date.day}";
}

List<String> last7Days() {
  final now = DateTime.now();
  return List.generate(7, (i) {
    final d = now.subtract(Duration(days: i));
    return formatDate(d);
  });
}
