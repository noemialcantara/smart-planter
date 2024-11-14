import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_onboarding_slider/flutter_onboarding_slider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hortijoy_mobile_app/resources/colors.dart';
import 'package:hortijoy_mobile_app/resources/shared_pref_service.dart';

import 'package:hortijoy_mobile_app/screens/login/login_body.dart';
import 'package:hortijoy_mobile_app/screens/login/login_screen.dart';
import 'package:hortijoy_mobile_app/screens/onboarding/onboarding3.dart';
import 'package:hortijoy_mobile_app/screens/planter/allsetcareprofilescreen.dart';
import 'package:hortijoy_mobile_app/screens/planter/fill_water_reservoir_initial_screen.dart';
import 'package:hortijoy_mobile_app/screens/planter/sensor_success_initial_screen.dart';
import 'package:hortijoy_mobile_app/screens/registration/registration_screen.dart';
import 'package:hortijoy_mobile_app/screens/test_sensors/fill_water_reservoir_screen.dart';

class SensorInstructionScreen extends StatefulWidget {
  final planterDetails;
  final bool isSwitching;
  Map<Object, Object?> extraDetails;
  String uid;
  bool isPlanterUpdateRequired;
  SensorInstructionScreen(
      {required this.planterDetails,
      required this.isSwitching,
      required this.extraDetails,
      this.uid = "",
      this.isPlanterUpdateRequired = false,
      super.key});

  @override
  State<SensorInstructionScreen> createState() =>
      _SensorInstructionScreenState();
}

class _SensorInstructionScreenState extends State<SensorInstructionScreen> {
  final Color primaryColor = AppColors.primaryColor;
  var currentWaterReservoirValue = 0;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
      _reservoirSubscription;

  _updatePlanterDevice() {
    try {
      FirebaseFirestore.instance
          .collection("user_plant_devices")
          .doc(widget.uid)
          .update(widget.extraDetails)
          .then((value) {});
    } on FirebaseAuthException catch (e) {}

    SharedPreferenceService.setIsAlreadyProfiled("true");
  }

  @override
  void initState() {
    super.initState();
    getLatestReservoirReading();
  }

  @override
  void dispose() {
    _reservoirSubscription?.cancel();
    super.dispose();
  }

  getLatestReservoirReading() async {
    QuerySnapshot<Map<String, dynamic>> userDevices = await FirebaseFirestore
        .instance
        .collection('user_plant_devices')
        .where('planter_device_name',
            isEqualTo: widget.planterDetails.planterDeviceName)
        .where('email', isEqualTo: FirebaseAuth.instance.currentUser?.email)
        .limit(1)
        .get();

    if (userDevices.docs.isNotEmpty) {
      var deviceId = userDevices.docs.first.id;

      _reservoirSubscription = FirebaseFirestore.instance
          .collection('user_plant_devices')
          .doc(deviceId)
          .collection('water_readings')
          .orderBy('timestamp', descending: true)
          .limit(1)
          .snapshots()
          .listen((QuerySnapshot<Map<String, dynamic>> snapshot) {
        if (snapshot.docs.isNotEmpty) {
          setState(() {
            currentWaterReservoirValue = int.parse(snapshot.docs[0]
                .get("water_reservoir_level")
                .toString()
                .replaceAll(RegExp(r"\.0$"), ""));
          });
        } else {
          setState(() {
            currentWaterReservoirValue = 100;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.white,
        body: SingleChildScrollView(
            child: Container(
                color: AppColors.white,
                child: Column(children: [
                  Image.asset(
                    'assets/images/planter_setup_care_profile.png',
                    height: 400,
                  ),
                  SizedBox(height: 30),
                  Container(
                      margin: EdgeInsets.only(left: 25, right: 25),
                      width: double.infinity,
                      height: 80,
                      decoration: BoxDecoration(
                          color: Color(0xffEBEDEB),
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Padding(
                                padding: EdgeInsets.only(
                                    left: 25, right: 25, top: 20),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Image.asset('assets/images/tube-icon.png'),
                                    SizedBox(
                                      width: 15,
                                    ),
                                    Expanded(
                                      child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Place water tube on top of the soil.',
                                              textAlign: TextAlign.center,
                                              style: GoogleFonts.openSans(
                                                color: AppColors.primaryColor,
                                                fontSize: 15.0,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          ]),
                                    ),
                                  ],
                                )),
                          ])),
                  SizedBox(height: 20),
                  Container(
                      margin: EdgeInsets.only(left: 25, right: 25),
                      width: double.infinity,
                      height: 80,
                      decoration: BoxDecoration(
                          color: Color(0xffEBEDEB),
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Padding(
                                padding: EdgeInsets.only(
                                    left: 25, right: 25, top: 20),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Image.asset(
                                        'assets/images/light-sensor-icon.png'),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Expanded(
                                      child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Insert moisture sensor into the soil.",
                                              textAlign: TextAlign.center,
                                              style: GoogleFonts.openSans(
                                                color: AppColors.primaryColor,
                                                fontSize: 15.0,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          ]),
                                    ),
                                  ],
                                )),
                          ])),
                  SizedBox(height: 20),
                  Container(
                      margin: EdgeInsets.only(left: 25, right: 25),
                      width: double.infinity,
                      height: 80,
                      decoration: BoxDecoration(
                          color: Color(0xffEBEDEB),
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Padding(
                                padding: EdgeInsets.only(
                                    left: 25, right: 25, top: 20),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Image.asset(
                                        'assets/images/light-heat-sensor-icon.png'),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Expanded(
                                      child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Ensure light sensor is exposed to light source.',
                                              textAlign: TextAlign.center,
                                              style: GoogleFonts.openSans(
                                                color: AppColors.primaryColor,
                                                fontSize: 15.0,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          ]),
                                    ),
                                  ],
                                )),
                          ])),
                  const SizedBox(
                    height: 35,
                  ),
                  Padding(
                    child: GestureDetector(
                      child: Container(
                        height: 42,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor,
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        child: Center(
                            child: Text(
                          'Continue',
                          style: GoogleFonts.openSans(
                            color: AppColors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        )),
                      ),
                      onTap: () {
                        if (widget.isPlanterUpdateRequired)
                          _updatePlanterDevice();

                        var planterDetails = widget.planterDetails;

                        planterDetails.plantName =
                            widget.extraDetails["plant_name"];
                        planterDetails.speciesName =
                            widget.extraDetails["species_name"];
                        planterDetails.type = widget.extraDetails["type"];
                        planterDetails.isAlreadyProfiled = widget
                            .extraDetails["is_already_profiled"]
                            .toString();
                        planterDetails.sunlightCareProfileInformation = widget
                            .extraDetails["sunlight_care_profile_information"];
                        planterDetails.wateringCareProfileInformation = widget
                            .extraDetails["watering_care_profile_information"];
                        planterDetails.planterDeviceURL =
                            widget.extraDetails["planter_image_url"];

                        if (currentWaterReservoirValue >= 75) {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AllSetCareProfileScreen(
                                    planterDetails: widget.planterDetails,
                                    isWater: true,
                                    isFertilizer: true),
                              ));
                        } else {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (builder) =>
                                      FillWaterReservoirInitialScreen(
                                        planterDetails: widget.planterDetails,
                                        isSwitching: widget.isSwitching,
                                      )));
                        }
                      },
                    ),
                    padding: EdgeInsets.only(left: 60, right: 60, bottom: 20),
                  ),
                  Padding(
                    child: GestureDetector(
                      child: Container(
                        height: 42,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor,
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        child: Center(
                            child: Text(
                          'Back',
                          style: GoogleFonts.openSans(
                            color: AppColors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        )),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                    padding: EdgeInsets.only(left: 60, right: 60, bottom: 50),
                  ),
                ]))));
  }
}
