import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/user.dart';
import '../data/models/couple.dart';
import '../data/models/invitation.dart';
import '../data/mock/mock_people.dart';

// ─── Auth / Session ──────────────────────────────────────────────────────────

class SessionState {
  final AppUser? currentUser;
  final AppUser? partner;
  final Couple? couple;
  final bool isAuthenticated;

  const SessionState({
    this.currentUser,
    this.partner,
    this.couple,
    this.isAuthenticated = false,
  });

  bool get isConnected =>
      currentUser?.hasPartner == true && couple != null && partner != null;

  SessionState copyWith({
    AppUser? currentUser,
    AppUser? partner,
    Couple? couple,
    bool? isAuthenticated,
  }) =>
      SessionState(
        currentUser: currentUser ?? this.currentUser,
        partner: partner ?? this.partner,
        couple: couple ?? this.couple,
        isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      );
}

class SessionNotifier extends StateNotifier<SessionState> {
  SessionNotifier() : super(const SessionState()) {
    // Boot with Alex as the logged-in user (demo mode).
    state = SessionState(
      currentUser: mockAlex,
      partner: mockSophia,
      couple: mockCouple,
      isAuthenticated: true,
    );
  }

  void login(AppUser user, AppUser? partner, Couple? couple) {
    state = SessionState(
      currentUser: user,
      partner: partner,
      couple: couple,
      isAuthenticated: true,
    );
  }

  void logout() => state = const SessionState();

  void connectPartner(AppUser partner, Couple couple) {
    final updated = state.currentUser!.copyWith(
      partnerId: partner.id,
      coupleId: couple.id,
    );
    state = state.copyWith(
      currentUser: updated,
      partner: partner,
      couple: couple,
    );
  }

  void disconnectPartner() {
    final updated = state.currentUser!.copyWith(clearPartner: true);
    state = SessionState(
      currentUser: updated,
      isAuthenticated: true,
    );
  }

  void updateProfile(AppUser updated) =>
      state = state.copyWith(currentUser: updated);
}

final sessionProvider =
    StateNotifierProvider<SessionNotifier, SessionState>((ref) {
  return SessionNotifier();
});

// ─── Invitation registry (single-use, enforced client-side) ──────────────────

class InvitationRegistry extends StateNotifier<List<Invitation>> {
  InvitationRegistry() : super([]);

  /// Add a new invitation. Caller ensures inviter isn't already connected.
  void add(Invitation invitation) => state = [...state, invitation];

  /// Cancel an invitation created by [userId].
  void cancel(String invitationId, String userId) {
    state = state.map((inv) {
      if (inv.id == invitationId && inv.inviterId == userId) {
        inv.status = InvitationStatus.cancelled;
      }
      return inv;
    }).toList();
  }

  /// Redeem an invitation code. Returns the invitation or null.
  /// Enforces: code exists, is usable, inviter != redeemer, neither is already connected.
  Invitation? redeem({
    required String code,
    required String redeemingUserId,
    required bool redeemerAlreadyConnected,
  }) {
    final idx = state.indexWhere((inv) => inv.code == code);
    if (idx == -1) return null;

    final inv = state[idx];
    if (!inv.isUsable) return null;
    if (inv.inviterId == redeemingUserId) return null;
    if (redeemerAlreadyConnected) return null;

    final updated = List<Invitation>.from(state);
    updated[idx].status = InvitationStatus.accepted;
    updated[idx].redeemedByUserId = redeemingUserId;
    state = updated;
    return updated[idx];
  }
}

final invitationRegistryProvider =
    StateNotifierProvider<InvitationRegistry, List<Invitation>>((ref) {
  return InvitationRegistry();
});
