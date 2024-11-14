void calculateDDay(DateTime startDate, Function(int) callback) {
  final DateTime currentDate = DateTime.now();
  final int difference = currentDate.difference(startDate).inDays + 1;
  callback(difference);
}
