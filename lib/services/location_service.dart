import 'package:geolocator/geolocator.dart';
import 'consent_service.dart';

class LocationService {
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
