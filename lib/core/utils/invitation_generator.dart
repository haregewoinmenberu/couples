import 'dart:math';

String generateInvitationCode() {
  const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  final rng = Random.secure();
  final parts = List.generate(3, (_) {
    return List.generate(4, (_) => chars[rng.nextInt(chars.length)]).join();
  });
  return 'OS-${parts.join('-')}';
}

bool isValidCodeFormat(String code) {
  final clean = code.trim().toUpperCase();
  final parts = clean.split('-');
  // Accept both the canonical OS-XXXX-XXXX-XXXX form and a bare
  // XXXX-XXXX-XXXX code someone might type from a QR payload.
  if (parts.length == 4 && parts.first == 'OS') {
    return parts.skip(1).every((p) => p.length == 4);
  }
  if (parts.length == 3) return parts.every((p) => p.length == 4);
  return false;
}
