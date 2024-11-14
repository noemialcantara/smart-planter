import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'package:hortijoy_mobile_app/resources/colors.dart';
import 'package:hortijoy_mobile_app/resources/text_style.dart';
import 'package:hortijoy_mobile_app/resources/my_button.dart';
import 'package:hortijoy_mobile_app/screens/home/home_page_body.dart';
import 'package:hortijoy_mobile_app/screens/planter/allsetcareprofilescreen.dart';
import 'package:hortijoy_mobile_app/screens/planter/fill_fertilizer_reservoir_initial_screen.dart';
import 'package:hortijoy_mobile_app/screens/planter/planter_profile.dart';
import 'package:hortijoy_mobile_app/screens/planter/planter_settings.dart';
import 'package:hortijoy_mobile_app/screens/planter/planter_setup.dart';
import 'package:hortijoy_mobile_app/screens/planter/planter_wifi_connection.dart';
import 'package:hortijoy_mobile_app/screens/planters/planter_list.dart';
import 'package:hortijoy_mobile_app/screens/test_sensors/moisture_sensor_test_screen.dart';

class SensorSuccessInitialScreen extends StatefulWidget {
  final String successText;
  final String appBarTitle;
  final bool isSetupDone;
  final planterDetails;
  final bool isSwitching;
  const SensorSuccessInitialScreen(
      {required this.successText,
      required this.appBarTitle,
      required this.isSetupDone,
      required this.planterDetails,
      required this.isSwitching,
      super.key});

  @override
  State<SensorSuccessInitialScreen> createState() =>
      _SensorSuccessInitialScreenState();
}

class _SensorSuccessInitialScreenState
    extends State<SensorSuccessInitialScreen> {
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
          if (widget.isSetupDone)
            MyButton(
              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AllSetCareProfileScreen(
                        planterDetails: widget.planterDetails,
                        isWater: true,
                        isFertilizer: true),
                  )),
              buttonText: "Continue",
            ),
          if (!widget.isSetupDone && !widget.isSwitching)
            MyButton(
              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FillFertilizerReservoirInitialScreen(
                      planterDetails: widget.planterDetails,
                      isSwitching: widget.isSwitching,
                    ),
                  )),
              buttonText: "Fill Fertilizer Reservoir",
            ),
          if (!widget.isSetupDone) SizedBox(height: 5),
          if (!widget.isSetupDone && widget.isSwitching)
            MyButton(
              onPressed: () => Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (context) => AllSetCareProfileScreen(
                      planterDetails: widget.planterDetails,
                      isWater: true,
                      isFertilizer: false),
                ),
              ),
              buttonText: "Next",
            ),
          if (!widget.isSetupDone && !widget.isSwitching)
            MyButton(
              onPressed: () => Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (context) => AllSetCareProfileScreen(
                      planterDetails: widget.planterDetails,
                      isWater: true,
                      isFertilizer: false),
                ),
              ),
              buttonText: "Continue to Care Profile",
            ),
        ],
      )),
    );
  }
}
