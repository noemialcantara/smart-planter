import 'package:permission_handler/permission_handler.dart';

class PermissionManager {
  PermissionStatus _permissionStatus = PermissionStatus.denied;

  // Location
  PermissionStatus checkLocationStatus() {
    Permission.location.status.then((PermissionStatus status) {
      _permissionStatus = status;
    });

    return _permissionStatus;
  }

  Future<void> requestCameraPermission() async {
    var cameraStatus = await Permission.camera.status;
    if (cameraStatus.isDenied) {
      Permission.camera.request();
    } else if (cameraStatus.isPermanentlyDenied) {
      openAppSettings();
    }
  }

  Future<void> requestBluetoothPermission() async {
    if (await Permission.bluetoothScan.request().isGranted &&
        await Permission.bluetoothConnect.request().isGranted &&
        await Permission.location.request().isGranted) {
    } else {
      openAppSettings();
    }
  }

  Future<void> requestSMSPermissions() async {
    var smsStatus = await Permission.sms.status;
    if (smsStatus.isDenied) {
      Permission.sms.request();
    } else if (smsStatus.isPermanentlyDenied) {
      openAppSettings();
    }
  }

  Future<void> requestExternalStoragePermission() async {
    var permissionStatus = await Permission.storage.status;

    if (permissionStatus.isDenied) {
      await Permission.storage.request();
    } else if (permissionStatus.isPermanentlyDenied) {
      openAppSettings();
    }
  }

  Future<void> requestVouchPermissions() async {
    var statuses = await [Permission.storage, Permission.camera].request();
    if (statuses[Permission.storage]!.isPermanentlyDenied ||
        statuses[Permission.camera]!.isPermanentlyDenied) {
      openAppSettings();
    }
  }
}
