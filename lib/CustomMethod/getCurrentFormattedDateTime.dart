import 'package:intl/intl.dart';

String getCurrentFormattedDateTime() {
  final now = DateTime.now();
  final formatter = DateFormat('dd/MM/yyyy - HH:mm:ss');
  return formatter.format(now);
}
