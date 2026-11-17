import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/app_state.dart';
import 'consent_service.dart';
import 'snapshot_service.dart';

/// Keeps the consent-driven background services in sync with app state.
///
/// The screenshot/location collector only runs while the user has granted the
/// relevant permissions, and stops immediately when they are revoked.
class PrivacyBootstrap extends ConsumerStatefulWidget {
  final Widget child;
  const PrivacyBootstrap({super.key, required this.child});

  @override
  ConsumerState<PrivacyBootstrap> createState() => _PrivacyBootstrapState();
}

class _PrivacyBootstrapState extends ConsumerState<PrivacyBootstrap>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _sync());
  }

  @override
  void didUpdateWidget(covariant PrivacyBootstrap oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _sync(force: true);
  }

  void _sync({bool force = false}) {
    // The snapshot collector relies on native path/permission plugins that do
    // not exist on web; the consent UI still works, collection is a no-op.
    if (kIsWeb) return;
    final consents = ref.read(consentProvider);
    final user = ref.read(sessionProvider).currentUser;

    final captureAllowed =
        consents[AppPermission.screenshotCapture] ?? false;
    final storageAllowed = consents[AppPermission.localStorage] ?? false;

    if (!captureAllowed || !storageAllowed || user == null) {
      SnapshotService.stop();
      return;
    }

    SnapshotService.start(consents, user.id);
    if (force || (consents[AppPermission.serverSync] ?? false)) {
      SnapshotService.syncPending(consents, user.id);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    SnapshotService.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch both providers so consent/session changes rebuild and re-sync.
    ref.watch(consentProvider);
    ref.watch(sessionProvider);
    return widget.child;
  }
}
