import 'dart:math';

String generateInvitationCode() {
  const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  final rng = Random.secure();
  final parts = List.generate(3, (_) {
    return List.generate(4, (_) => chars[rng.nextInt(chars.length)]).join();
  });
  return parts.join('-');
}

bool isValidCodeFormat(String code) {
  final clean = code.trim().toUpperCase();
  final parts = clean.split('-');
  if (parts.length != 3) return false;
  return parts.every((p) => p.length == 4);
}
