import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'package:hortijoy_mobile_app/resources/colors.dart';
import 'package:hortijoy_mobile_app/resources/text_style.dart';
import 'package:hortijoy_mobile_app/resources/my_button.dart';
import 'package:hortijoy_mobile_app/screens/home/home_screen.dart';
import 'package:hortijoy_mobile_app/screens/planter/planter_profile.dart';
import 'package:hortijoy_mobile_app/screens/planter/planter_settings.dart';
import 'package:hortijoy_mobile_app/screens/planter/planter_setup.dart';
import 'package:hortijoy_mobile_app/screens/planter/planter_wifi_connection.dart';
import 'package:hortijoy_mobile_app/screens/planters/planter_list.dart';

import 'package:flutter_blue/flutter_blue.dart';
import 'package:hortijoy_mobile_app/screens/test_sensors/moisture_sensor_test_screen.dart';

class SensorSuccessScreen extends StatefulWidget {
  final String successText;
  final String appBarTitle;
  final bool isFirstSetup;
  final bool isSetupDone;
  bool isFromNotifHomeFertilizer;
  bool isFromPlanterSettingsWater;
  final planterDetails;
  SensorSuccessScreen(
      {required this.successText,
      required this.appBarTitle,
      required this.isFirstSetup,
      required this.isSetupDone,
      required this.planterDetails,
      this.isFromNotifHomeFertilizer = false,
      this.isFromPlanterSettingsWater = false,
      super.key});

  @override
  State<SensorSuccessScreen> createState() => _SensorSuccessScreenState();
}

class _SensorSuccessScreenState extends State<SensorSuccessScreen> {
  late bool isFromNotifHomeFertilizer;
  late bool isFromPlanterSettingsWater;

  _updatePlanterReminder(String reminderName, bool isOn) async {
    var dataObject = {
      reminderName: isOn,
      "is_reservoir_sensor_turned_on": true
    };

    var emailID = await FirebaseFirestore.instance
        .collection("user_plant_devices")
        .where("planter_device_name",
            isEqualTo: widget.planterDetails.planterDeviceName)
        .limit(1)
        .get();
    var userUID = emailID.docs.first.id;

    FirebaseFirestore.instance
        .collection("user_plant_devices")
        .doc(userUID)
        .update(dataObject);
  }

  @override
  void initState() {
    super.initState();
    // Initialize the value here
    isFromNotifHomeFertilizer = widget.isFromNotifHomeFertilizer;
    isFromPlanterSettingsWater = widget.isFromPlanterSettingsWater;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
          backgroundColor: AppColors.white,
          elevation: 0,
          centerTitle: true,
          title: Text(
            widget.appBarTitle,
            style: GoogleFonts.openSans(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.black),
          )),
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
            height: 175,
            width: 175,
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
          const SizedBox(height: 20),
          Text(
            "Great!",
            style: CustomTextStyle.headLine2,
          ),
          const SizedBox(height: 10),
          Text(
            widget.successText,
            style: CustomTextStyle.headLine2,
          ),
          const SizedBox(
            height: 15,
          ),
          MyButton(
            onPressed: () async {
              var emailID = await FirebaseFirestore.instance
                  .collection("user_plant_devices")
                  .where("planter_device_name",
                      isEqualTo: widget.planterDetails.planterDeviceName)
                  .limit(1)
                  .get();
              var userUID = emailID.docs.first.id;

              if (isFromNotifHomeFertilizer) {
                widget.planterDetails.isReservoirSensorTurnedOn = true;
                // widget.planterDetails.isWaterSensorTurnedOn = true;
                widget.planterDetails.waterScaleWarningLevel = "1";
                print("THIS IS THE PRINT LEVEL 3 " +
                    widget.planterDetails.planterDeviceURL);

                _updatePlanterReminder("reservoir_refill", true);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        PlanterProfile(widget.planterDetails, false),
                  ),
                );
              } else if (isFromPlanterSettingsWater) {
                _updatePlanterReminder("reservoir_refill", true);
                widget.planterDetails.isReservoirSensorTurnedOn = true;
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PlanterSettings(
                        plantId: userUID,
                        planterDetails: widget.planterDetails,
                      ),
                    ));
              } else {
                widget.isSetupDone && widget.isFirstSetup
                    ? Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => WifiConnectionList(
                            planterId: "",
                          ),
                        ))
                    : widget.isFirstSetup
                        ? Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HomeScreen(),
                            ))
                        : Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PlanterSettings(
                                plantId: userUID,
                                planterDetails: widget.planterDetails,
                              ),
                            ));
              }
            },
            buttonText: "Continue",
          )
        ],
      )),
    );
  }
}
