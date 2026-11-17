import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/couple.dart';
import '../data/models/user.dart';
import '../state/app_state.dart';
import 'api_service.dart';
import 'device_phone_service.dart';

/// Connects two people purely by phone number.
///
/// * The invitee's device reports its number; if a pending invitation was
///   addressed to that number, the couple is created automatically.
/// * The inviter's device notices an accepted invitation and picks up the
///   couple the next time the app is opened/resumed.
class PhoneMatchBootstrap extends ConsumerStatefulWidget {
  final Widget child;
  const PhoneMatchBootstrap({super.key, required this.child});

  @override
  ConsumerState<PhoneMatchBootstrap> createState() => _PhoneMatchBootstrapState();
}

class _PhoneMatchBootstrapState extends ConsumerState<PhoneMatchBootstrap>
    with WidgetsBindingObserver {
  String? _checkedForUser;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _check());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _check(force: true);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _check({bool force = false}) async {
    final session = ref.read(sessionProvider);
    final me = session.currentUser;
    if (!session.isAuthenticated || me == null) return;
    if (session.isConnected) return;
    if (!force && _checkedForUser == me.id) return;
    _checkedForUser = me.id;

    await _checkAsInvitee(me.id);
    if (!session.isConnected) await _checkAsInviter(me.id);
  }

  Future<void> _checkAsInvitee(String myId) async {
    final phone = await DevicePhoneService.detect();
    if (phone == null || phone.isEmpty) return;
    final normalized = DevicePhoneService.normalize(phone);

    Map<String, dynamic>? invitation;
    try {
      invitation = await ApiService.getInvitationForPhone(normalized);
    } catch (_) {}

    String? localInviterId;
    if (invitation == null) {
      // Offline / same-device fallback: an invitation created locally.
      for (final inv in ref.read(invitationRegistryProvider)) {
        if (inv.isUsable &&
            inv.inviteePhone != null &&
            DevicePhoneService.normalize(inv.inviteePhone!) == normalized) {
          localInviterId = inv.inviterId;
          break;
        }
      }
      if (localInviterId == null) return;
    }

    final inviterId = invitation?['inviterId'] as String? ?? localInviterId;
    if (inviterId == null || inviterId.isEmpty) return;

    try {
      final coupleData = await ApiService.createCouple(
        userAId: inviterId,
        userBId: myId,
        anniversaryDate: DateTime.now(),
      );
      final couple = Couple.fromJson(coupleData);
      Map<String, dynamic>? inviterRaw =
          invitation?['inviter'] as Map<String, dynamic>?;
      if (inviterRaw == null) {
        try {
          inviterRaw = await ApiService.getUser(inviterId);
        } catch (_) {}
      }
      inviterRaw ??= {};
      final partner = AppUser.fromJson({
        'id': inviterId,
        'fullName': inviterRaw['fullName'] ?? 'Your Partner',
        'username': inviterRaw['username'] ?? 'partner',
        'email': '',
        'phoneNumber': inviterRaw['phoneNumber'] ?? '',
        'countryCode': '+1',
        'avatarSeed': inviterRaw['avatarSeed'] ?? inviterId,
      });
      await ref.read(sessionProvider.notifier).connectPartner(partner, couple);
      if (invitation != null) {
        try {
          await ApiService.acceptInvitation(invitation['id'] as String);
        } catch (_) {}
      }
    } catch (_) {
      // Server unreachable — stay unconnected; will retry on resume.
      _checkedForUser = null;
    }
  }

  Future<void> _checkAsInviter(String myId) async {
    try {
      final rows = await ApiService.getInvitationsByInviter(myId);
      final accepted = rows.where((r) => r is Map && r['status'] == 'accepted');
      for (final _ in accepted) {
        final coupleData = await ApiService.getCoupleForUser(myId);
        if (coupleData == null) continue;
        final couple = Couple.fromJson(coupleData);
        final partnerRaw = couple.userAId == myId
            ? coupleData['userB'] as Map<String, dynamic>?
            : coupleData['userA'] as Map<String, dynamic>?;
        if (partnerRaw == null) continue;
        final partner = AppUser.fromJson({
          ...partnerRaw,
          'email': '',
          'phoneNumber': partnerRaw['phoneNumber'] ?? '',
          'countryCode': '+1',
        });
        await ref.read(sessionProvider.notifier).connectPartner(partner, couple);
        return;
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(sessionProvider);
    return widget.child;
  }
}
