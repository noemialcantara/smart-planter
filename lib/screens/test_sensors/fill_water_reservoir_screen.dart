import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hortijoy_mobile_app/models/plant_devices.dart';
import 'package:hortijoy_mobile_app/resources/colors.dart';
import 'package:hortijoy_mobile_app/resources/my_button.dart';
import 'package:hortijoy_mobile_app/resources/webview_contactus_screen.dart';
import 'package:hortijoy_mobile_app/screens/planter/success_banner.dart/success.dart';
import 'package:hortijoy_mobile_app/screens/test_sensors/sensor_success_screen.dart';
import 'package:http/http.dart' as http;
import 'package:hortijoy_mobile_app/models/device.dart';
import 'package:hortijoy_mobile_app/screens/add_device_bluetooth/device_list_item.dart';
import 'package:hortijoy_mobile_app/screens/wifi_provisioning/wifi_provisioning.dart';
import 'package:lan_scanner/lan_scanner.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter_gif/flutter_gif.dart';
import 'package:url_launcher/url_launcher.dart';

/// Example app for wifi_scan plugin.
class FillWaterReservoirScreen extends StatefulWidget {
  final bool isFirstSetup;
  final PlantDevices planterDetails;
  bool isFromPlanterSettings;
  bool isFromNotifHomeFertilizer;
  FillWaterReservoirScreen(
      {required this.isFirstSetup,
      required this.planterDetails,
      this.isFromPlanterSettings = false,
      this.isFromNotifHomeFertilizer = false,
      Key? key})
      : super(key: key);

  @override
  State<FillWaterReservoirScreen> createState() =>
      _FillWaterReservoirScreenState();

  static dart() {}
}

class _FillWaterReservoirScreenState extends State<FillWaterReservoirScreen>
    with TickerProviderStateMixin {
  bool isSensorOn = false;
  FlutterGifController? flutterGifController;
  FlutterGifController? flutterGifController2;
  late bool isFromPlanterSettings;
  late bool isFromNotifHomeFertilizer;

  @override
  void initState() {
    super.initState();
    flutterGifController = FlutterGifController(vsync: this);
    flutterGifController2 = FlutterGifController(vsync: this);

    WidgetsBinding.instance?.addPostFrameCallback((_) {
      flutterGifController?.repeat(
        min: 0,
        max: 50,
        period: const Duration(milliseconds: 3000),
        reverse: true,
      );
      flutterGifController2?.repeat(
        min: 0,
        max: 30,
        period: const Duration(milliseconds: 3000),
        reverse: true,
      );
    });
    isFromPlanterSettings = widget.isFromPlanterSettings;
    isFromNotifHomeFertilizer = widget.isFromNotifHomeFertilizer;
  }

  @override
  void dispose() {
    flutterGifController?.dispose();
    flutterGifController2?.dispose();
    super.dispose();
  }

  testSensor() async {
    setState(() {
      isSensorOn = true;
    });

    var emailID = await FirebaseFirestore.instance
        .collection("user_plant_devices")
        .where("planter_device_name",
            isEqualTo: widget.planterDetails.planterDeviceName)
        .where("email",
            isEqualTo: FirebaseAuth.instance.currentUser?.email.toString())
        .get();
    var userUID = emailID.docs.first.id;

    FirebaseFirestore.instance
        .collection("user_plant_devices")
        .doc(userUID)
        .update({"water_scale_warning_level": 1});

    final Map<String, dynamic> waterRefillData = {
      'timestamp': FieldValue.serverTimestamp(),
      'water_reservoir_level': 100
    };

    FirebaseFirestore.instance
        .collection("user_plant_devices")
        .doc(userUID)
        .collection('water_readings')
        .add(waterRefillData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Fill Water Reservoir",
          style: GoogleFonts.openSans(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.black),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: AppColors.primaryColor,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      backgroundColor: AppColors.white,
      body: Container(
          padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 30),
          child: Stack(children: [
            !isSensorOn
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Make sure the planter is plugged in.",
                        style: GoogleFonts.openSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 20),
                      GestureDetector(
                        child: Container(
                          height: 42,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor,
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          child: Center(
                              child: Text(
                            'Next',
                            style: GoogleFonts.openSans(
                              color: AppColors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          )),
                        ),
                        onTap: () {
                          testSensor();
                        },
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "STOP FILLING",
                        style: GoogleFonts.openSans(
                            color: Color.fromRGBO(253, 113, 103, 1),
                            fontSize: 24,
                            fontWeight: FontWeight.w600),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 160),
                      Text(
                        "Pour water into the reservoir until the water level reaches 100%.",
                        style: GoogleFonts.openSans(
                            fontSize: 16, fontWeight: FontWeight.w600),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 20),
                      GestureDetector(
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
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SensorSuccessScreen(
                                    appBarTitle: "Fill Water Reservoir",
                                    successText: "Water Reservoir Filled.",
                                    isFirstSetup: widget.isFirstSetup,
                                    isSetupDone: false,
                                    planterDetails: widget.planterDetails,
                                    isFromNotifHomeFertilizer:
                                        isFromNotifHomeFertilizer,
                                    isFromPlanterSettingsWater:
                                        isFromPlanterSettings),
                              ));
                        },
                      ),
                      SizedBox(height: 10),
                      GestureDetector(
                        child: Text('Troubleshoot reservoir sensor',
                            style: GoogleFonts.openSans(
                              color: AppColors.primaryColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            )),
                        onTap: () async {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => WebviewContactus(),
                              ));
                        },
                      ),
                    ],
                  ),
            !isSensorOn
                ? Positioned(
                    bottom: 350,
                    left: 110,
                    child: Center(
                        child: Container(
                      height: 150,
                      width: 150,
                      child: Image.asset(
                        'assets/icons/fill_water_reservoir.png',
                        scale: 1,
                      ),
                      alignment: Alignment.center,
                    )))
                : Positioned(
                    bottom: 350,
                    left: 110,
                    child: Center(
                        child: Column(
                      children: [
                        Container(
                          height: 150,
                          width: 150,
                          child: Image.asset(
                            'assets/icons/fill_water_reservoir_100.png',
                            scale: 1,
                          ),
                          alignment: Alignment.center,
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          "100%",
                          style: GoogleFonts.openSans(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.w600),
                        )
                      ],
                    )))
          ])),
    );
  }
}
