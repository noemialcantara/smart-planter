import 'package:flutter/material.dart';
import 'dart:async';
import 'package:hortijoy_mobile_app/resources/colors.dart';
import 'package:hortijoy_mobile_app/resources/text_style.dart';
import 'package:hortijoy_mobile_app/resources/my_button.dart';
import 'package:hortijoy_mobile_app/screens/planter/planter_setup.dart';
import 'package:hortijoy_mobile_app/screens/planter/planter_wifi_connection.dart';
import 'package:hortijoy_mobile_app/screens/planters/planter_list.dart';
import 'package:hortijoy_mobile_app/screens/test_sensors/light_sensor_test_screen.dart';

class SuccessBanner extends StatefulWidget {
  final targetCharacteristic;
  String planterId;
  SuccessBanner(
      {required this.targetCharacteristic, required this.planterId, super.key});

  @override
  State<SuccessBanner> createState() => _SuccessBannerSetup();
}

class _SuccessBannerSetup extends State<SuccessBanner> {
  String planterId = "";
  var targetCharacteristic;
  @override
  void initState() {
    planterId = widget.planterId;
    targetCharacteristic = widget.targetCharacteristic;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _displayCreated(context),
    );
  }

  _displayCreated(BuildContext context) {
    return Container(
      child: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
              child: Container(
            height: 150,
            width: 150,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryColor,
            ),
            child: Image.asset(
              'assets/icons/check_successfully.png',
              scale: 1,
            ),
            alignment: Alignment.center,
          )),
          const SizedBox(height: 35),
          const Text(
            "Your planter has been created!",
            style: CustomTextStyle.headLine2,
          ),
          const SizedBox(
            height: 20,
          ),
          MyButton(
            onPressed: () {
              print("PLANTER ID IN SUCCESS BANNER NO DATA??? :$planterId");
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => WifiConnectionList(
                      targetCharacteristic: targetCharacteristic,
                      planterId: planterId),
                ),
              );
            },
            buttonText: 'Connect to Wifi',
          ),
        ],
      )),
    );
  }
}

class SuccessNavigateToWifi extends StatelessWidget {
  const SuccessNavigateToWifi({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _displayCreated(context),
    );
  }

  _displayCreated(BuildContext context) {
    return Container(
      child: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
              child: Container(
            height: 150,
            width: 150,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
            ),
            child: Image.asset(
              'assets/images/success_icon.png',
              scale: 1,
            ),
            alignment: Alignment.center,
          )),
          const SizedBox(height: 20),
          const Text(
            "Your planter is now connected.",
            style: CustomTextStyle.headLine2,
          ),
          const SizedBox(
            height: 20,
          ),
          MyButton(
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const PlanterList(),
              ),
            ),
            buttonText: 'Go back to Planters',
          ),
        ],
      )),
    );
  }
}

class SuccessBluetoothConnected extends StatelessWidget {
  final targetCharacteristic;
  const SuccessBluetoothConnected(
      {required this.targetCharacteristic, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _displayCreated(context),
    );
  }

  _displayCreated(BuildContext context) {
    return Container(
      child: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
              child: Container(
            height: 160,
            width: 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
            ),
            child: Image.asset(
              'assets/images/success_icon.png',
              scale: 1,
            ),
            alignment: Alignment.center,
          )),
          const SizedBox(height: 25),
          const Text(
            "Great!",
            style: CustomTextStyle.headLine2,
          ),
          const Text(
            "Your device is now connected.",
            style: CustomTextStyle.headLine3,
          ),
          const SizedBox(
            height: 15,
          ),
          MyButton(
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    PlanterSetup(targetCharacteristic: targetCharacteristic),
              ),
            ),
            buttonText: 'Next',
          ),
        ],
      )),
    );
  }
}

class BluetoothPairDevice extends StatefulWidget {
  final targetCharacteristic;
  const BluetoothPairDevice({required this.targetCharacteristic, super.key});

  @override
  State<BluetoothPairDevice> createState() => _BluetoothPairDeviceState();
}

class _BluetoothPairDeviceState extends State<BluetoothPairDevice> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 3), () {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => SuccessBluetoothConnected(
                  targetCharacteristic: widget.targetCharacteristic)));
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _displayCreated(context),
    );
  }

  _displayCreated(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            flex: 6,
            child: Container(
              // alignment: Alignment.bottomCenter,
              padding: const EdgeInsets.all(15.0),
              child: Image.asset(
                'assets/icons/bluetooth_loading.png',
                height: 200,
                width: 200,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              margin: EdgeInsets.only(bottom: 15.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Text(
                    "Pairing with this device ..",
                    style: CustomTextStyle.subtitle.copyWith(
                        color: AppColors.black, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  CustomOutlinedButton(
                    customColor: AppColors.black,
                    onPressed: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PlanterList(),
                      ),
                    ),
                    buttonText: 'Cancel',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
