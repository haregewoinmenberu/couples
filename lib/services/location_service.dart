import 'package:geolocator/geolocator.dart';
import 'consent_service.dart';

class LocationService {
  /// Ask the operating system for location access. Called only after the user
  /// explicitly opts in to the GPS feature from the Privacy screen.
  static Future<bool> requestPermission() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  /// Returns current position only if gpsLocation consent is granted.
  /// Returns null if consent is missing or location is unavailable.
  static Future<Position?> getPosition(ConsentMap consents) async {
    if (!(consents[AppPermission.gpsLocation] ?? false)) return null;

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return null;
    }
    if (permission == LocationPermission.deniedForever) return null;

    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.medium,
        timeLimit: Duration(seconds: 10),
      ),
    );
  }
}
