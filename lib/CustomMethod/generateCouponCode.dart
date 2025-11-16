import 'dart:math';

String generateCouponCode() {
  const letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  const numbers = '0123456789';
  final rand = Random();

  // Pick 5 random letters
  List<String> letterPart = List.generate(
    5,
    (_) => letters[rand.nextInt(letters.length)],
  );

  // Pick 5 random digits
  List<String> numberPart = List.generate(
    5,
    (_) => numbers[rand.nextInt(numbers.length)],
  );

  // Combine and shuffle
  List<String> all = [...letterPart, ...numberPart]..shuffle(rand);

  return all.join();
}
