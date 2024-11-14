import 'package:permission_handler/permission_handler.dart';

class LocationsService {
  static Future<PermissionStatus> locationPermissionStatus() async {
    var status = await Permission.location.status;

    return status;
  }

  static requestLocationPermission() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.location,
      Permission.locationAlways,
      Permission.locationWhenInUse
    ].request();
    return statuses[Permission.location];
  }
}
