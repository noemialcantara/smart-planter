import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hortijoy_mobile_app/resources/colors.dart';
import 'package:hortijoy_mobile_app/resources/my_button.dart';
import 'package:hortijoy_mobile_app/screens/planter/sensor_success_initial_screen.dart';
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

/// Example app for wifi_scan plugin.
class FillFertilizerReservoirInitialScreen extends StatefulWidget {
  final planterDetails;
  final isSwitching;
  const FillFertilizerReservoirInitialScreen(
      {required this.planterDetails, required this.isSwitching, Key? key})
      : super(key: key);

  @override
  State<FillFertilizerReservoirInitialScreen> createState() =>
      _FillFertilizerReservoirInitialScreenState();
}

class _FillFertilizerReservoirInitialScreenState
    extends State<FillFertilizerReservoirInitialScreen>
    with TickerProviderStateMixin {
  bool isSensorOn = false;
  FlutterGifController? flutterGifController;
  FlutterGifController? flutterGifController2;
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
  }

  @override
  void dispose() {
    flutterGifController?.dispose();
    flutterGifController2?.dispose();
    super.dispose();
  }

  fillFertilizer() async {
    setState(() {
      // isSensorOn = true;
    });
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => SensorSuccessInitialScreen(
            appBarTitle: "Fill Fertilizer Reservoir",
            isSwitching: widget.isSwitching,
            successText: "Fertilizer Reservoir Filled.",
            isSetupDone: true,
            planterDetails: widget.planterDetails,
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Fill Fertilizer Reservoir",
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
                        "Pour 1 bottle (8 oz) of Hortijoy fertilizer into the reservoir.",
                        style: GoogleFonts.openSans(
                          fontSize: 15,
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
                            'Complete',
                            style: GoogleFonts.openSans(
                              color: AppColors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          )),
                        ),
                        onTap: () {
                          fillFertilizer();
                        },
                      ),
                      SizedBox(height: 20),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Pour 1 bottle (8 oz) of Hortijoy fertilizer into the reservoir.",
                        style: GoogleFonts.openSans(
                            fontSize: 15, fontWeight: FontWeight.w600),
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
                            'Confirm',
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
                                builder: (context) =>
                                    SensorSuccessInitialScreen(
                                  appBarTitle: "Fertilizer Tracker Test",
                                  isSwitching: widget.isSwitching,
                                  successText: "Fill Fertilizer complete.",
                                  isSetupDone: true,
                                  planterDetails: widget.planterDetails,
                                ),
                              ));
                        },
                      ),
                      SizedBox(height: 10),
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
                        'assets/images/fill_fertilizer_sensor_gauge.png',
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
                            'assets/icons/Moisture_Mini_Planter_Status4%.png',
                            scale: 1,
                          ),
                          alignment: Alignment.center,
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          "4%",
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
