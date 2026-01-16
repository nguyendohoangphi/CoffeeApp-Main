// ignore_for_file: file_names
import 'package:intl/intl.dart';
String getCurrentFormattedDateTime() {
  final now = DateTime.now();
  final formatter = DateFormat('dd/MM/yyyy - HH:mm:ss');
  return formatter.format(now);
}

//use in OrderService to gán value for createDate in OrderItem => provide ngày giờ to store and display
