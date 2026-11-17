import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/user.dart';
import '../data/models/couple.dart';
import '../data/models/invitation.dart';
import '../services/api_service.dart';
import '../services/auth_storage.dart';
import '../services/local_store.dart';

// ─── Auth / Session ──────────────────────────────────────────────────────────

class SessionState {
  final AppUser? currentUser;
  final AppUser? partner;
  final Couple? couple;
  final bool isAuthenticated;
  final bool isLoading;

  const SessionState({
    this.currentUser,
    this.partner,
    this.couple,
    this.isAuthenticated = false,
    this.isLoading = true,
  });

  bool get isConnected =>
      currentUser?.hasPartner == true && couple != null && partner != null;

  SessionState copyWith({
    AppUser? currentUser,
    AppUser? partner,
    Couple? couple,
    bool? isAuthenticated,
    bool? isLoading,
  }) =>
      SessionState(
        currentUser: currentUser ?? this.currentUser,
        partner: partner ?? this.partner,
        couple: couple ?? this.couple,
        isAuthenticated: isAuthenticated ?? this.isAuthenticated,
        isLoading: isLoading ?? this.isLoading,
      );
}

class SessionNotifier extends StateNotifier<SessionState> {
  SessionNotifier() : super(const SessionState()) {
    _boot();
  }

  /// Load persisted session on app start.
  Future<void> _boot() async {
    final stored = await AuthStorage.load();
    if (stored == null) {
      state = const SessionState(isLoading: false, isAuthenticated: false);
      return;
    }
    final user = AppUser.fromJson(stored.user);
    final couple =
        stored.couple != null ? Couple.fromJson(stored.couple!) : null;
    final partner =
        stored.partner != null ? AppUser.fromJson(stored.partner!) : null;

    // Re-fetch couple from server in case it was created after initial login.
    Couple? freshCouple = couple;
    AppUser? freshPartner = partner;
    if (couple == null) {
      try {
        final data = await ApiService.getCoupleForUser(user.id);
        if (data != null) {
          freshCouple = Couple.fromJson(data);
          final partnerData = data['userA']['id'] == user.id
              ? data['userB'] as Map<String, dynamic>
              : data['userA'] as Map<String, dynamic>;
          freshPartner = AppUser.fromJson({
            ...partnerData,
            'email': '',
            'phoneNumber': partnerData['phoneNumber'] ?? '',
            'countryCode': '+1',
          });
          await AuthStorage.save(
              user: stored.user,
              couple: freshCouple.toJson(),
              partner: freshPartner.toJson());
        }
      } catch (_) {}
    }

    state = SessionState(
      currentUser: user,
      partner: freshPartner,
      couple: freshCouple,
      isAuthenticated: true,
      isLoading: false,
    );
  }

  /// Register a new user and persist the session.
  Future<AppUser> register({
    required String fullName,
    required String username,
    required String email,
    required String phoneNumber,
    String countryCode = '+1',
  }) async {
    final data = await ApiService.createUser(
      fullName: fullName,
      username: username,
      email: email,
      phoneNumber: phoneNumber,
      countryCode: countryCode,
    );
    final user = AppUser.fromJson(data);
    await AuthStorage.save(user: data);
    state = SessionState(
      currentUser: user,
      isAuthenticated: true,
      isLoading: false,
    );
    return user;
  }

  /// Login by looking up the user by email or username.
  Future<bool> login(String emailOrUsername) async {
    Map<String, dynamic>? data;
    if (emailOrUsername.contains('@')) {
      data = await ApiService.getUserByEmail(emailOrUsername);
    } else {
      data = await ApiService.getUserByUsername(emailOrUsername);
    }
    if (data == null) return false;

    final user = AppUser.fromJson(data);

    // Try to load couple.
    Couple? couple;
    AppUser? partner;
    try {
      final coupleData = await ApiService.getCoupleForUser(user.id);
      if (coupleData != null) {
        couple = Couple.fromJson(coupleData);
        final partnerRaw = coupleData['userA']['id'] == user.id
            ? coupleData['userB'] as Map<String, dynamic>
            : coupleData['userA'] as Map<String, dynamic>;
        partner = AppUser.fromJson({
          ...partnerRaw,
          'email': '',
          'phoneNumber': partnerRaw['phoneNumber'] ?? '',
          'countryCode': '+1',
        });
      }
    } catch (_) {}

    await AuthStorage.save(
      user: data,
      couple: couple?.toJson(),
      partner: partner?.toJson(),
    );

    state = SessionState(
      currentUser: user,
      partner: partner,
      couple: couple,
      isAuthenticated: true,
      isLoading: false,
    );
    return true;
  }

  Future<void> logout() async {
    await AuthStorage.clear();
    state = const SessionState(isLoading: false, isAuthenticated: false);
  }

  Future<void> connectPartner(AppUser partner, Couple couple) async {
    final updated = state.currentUser!.copyWith(
      partnerId: partner.id,
      coupleId: couple.id,
    );
    await AuthStorage.save(
      user: updated.toJson(),
      couple: couple.toJson(),
      partner: partner.toJson(),
    );
    state = state.copyWith(
      currentUser: updated,
      partner: partner,
      couple: couple,
    );
  }

  Future<void> disconnectPartner() async {
    final updated = state.currentUser!.copyWith(clearPartner: true);
    await AuthStorage.save(user: updated.toJson());
    state = SessionState(
      currentUser: updated,
      isAuthenticated: true,
      isLoading: false,
    );
  }

  void updateProfile(AppUser updated) {
    state = state.copyWith(currentUser: updated);
    AuthStorage.save(
      user: updated.toJson(),
      couple: state.couple?.toJson(),
      partner: state.partner?.toJson(),
    );
  }

  /// Update the shared anniversary date and persist the whole session.
  Future<void> updateAnniversary(DateTime date) async {
    final couple = state.couple;
    if (couple == null) return;
    final updated = Couple(
      id: couple.id,
      userAId: couple.userAId,
      userBId: couple.userBId,
      anniversaryDate: date,
      connectedAt: couple.connectedAt,
    );
    final user = state.currentUser!;
    await AuthStorage.save(
      user: user.toJson(),
      couple: updated.toJson(),
      partner: state.partner?.toJson(),
    );
    state = state.copyWith(couple: updated);
  }
}

final sessionProvider =
    StateNotifierProvider<SessionNotifier, SessionState>((ref) {
  return SessionNotifier();
});

// ─── Invitation registry ──────────────────────────────────────────────────────

class InvitationRegistry extends StateNotifier<List<Invitation>> {
  InvitationRegistry() : super([]) {
    _load();
  }

  Future<void> _load() async {
    final rows = await LocalStore.readList('invitations');
    state = rows.map(Invitation.fromJson).toList();
  }

  void _persist() =>
      LocalStore.writeList('invitations', state.map((i) => i.toJson()).toList());

  void add(Invitation invitation) {
    state = [...state, invitation];
    _persist();
  }

  void cancel(String invitationId, String userId) {
    state = state.map((inv) {
      if (inv.id == invitationId && inv.inviterId == userId) {
        inv.status = InvitationStatus.cancelled;
      }
      return inv;
    }).toList();
    _persist();
  }

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
    _persist();
    return updated[idx];
  }
}

final invitationRegistryProvider =
    StateNotifierProvider<InvitationRegistry, List<Invitation>>((ref) {
  return InvitationRegistry();
});
