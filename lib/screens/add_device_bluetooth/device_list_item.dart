import 'package:flutter/material.dart';
import 'package:hortijoy_mobile_app/models/device.dart';

class DeviceListItem extends StatelessWidget {
  final Device _device;
  DeviceListItem(this._device);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        _device.ipAddress,
      ),
      subtitle: Text(
        "Hortijoy",
      ),
    );
  }
}
