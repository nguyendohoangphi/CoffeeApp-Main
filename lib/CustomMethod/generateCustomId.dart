import 'dart:math';

String generateCustomId() {
  const letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  const numbers = '0123456789';
  final random = Random();

  // Get 2 letters
  String letterPart = List.generate(
    3,
    (_) => letters[random.nextInt(letters.length)],
  ).join();

  // Get 4 digits
  String numberPart = List.generate(
    3,
    (_) => numbers[random.nextInt(numbers.length)],
  ).join();

  // Combine with #
  return '#$letterPart$numberPart';
}
