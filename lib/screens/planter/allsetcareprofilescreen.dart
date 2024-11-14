import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_onboarding_slider/flutter_onboarding_slider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hortijoy_mobile_app/resources/colors.dart';
import 'package:hortijoy_mobile_app/resources/shared_pref_service.dart';
import 'package:hortijoy_mobile_app/screens/home/home_screen.dart';

import 'package:hortijoy_mobile_app/screens/login/login_body.dart';
import 'package:hortijoy_mobile_app/screens/login/login_screen.dart';
import 'package:hortijoy_mobile_app/screens/planter/planter_profile.dart';
import 'package:hortijoy_mobile_app/screens/planters/planter_list.dart';
import 'package:hortijoy_mobile_app/screens/registration/registration_screen.dart';

class AllSetCareProfileScreen extends StatefulWidget {
  final planterDetails;
  final isWater;
  final isFertilizer;
  const AllSetCareProfileScreen(
      {required this.planterDetails,
      required this.isWater,
      required this.isFertilizer,
      Key? key})
      : super(key: key);

  @override
  State<AllSetCareProfileScreen> createState() => _AllSetCareProfileScreen();
}

class _AllSetCareProfileScreen extends State<AllSetCareProfileScreen> {
  final Color primaryColor = AppColors.primaryColor;

  _updatePlanterReminder(String reminderName, bool isOn) async {
    var dataObject = {reminderName: isOn};

    var emailID = await FirebaseFirestore.instance
        .collection("user_plant_devices")
        .where("planter_device_name",
            isEqualTo: widget.planterDetails.planterDeviceName)
        .where("email", isEqualTo: FirebaseAuth.instance.currentUser?.email)
        .limit(1)
        .get();
    var userUID = emailID.docs.first.id;

    FirebaseFirestore.instance
        .collection("user_plant_devices")
        .doc(userUID)
        .update(dataObject);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.white,
        body: Container(
            color: AppColors.white,
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 30),
                  Padding(
                    child: Text(
                      'All Set!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.primaryColor,
                        fontSize: 35.0,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    padding: EdgeInsets.only(left: 10, right: 10),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
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
                                    Image.asset('assets/images/light_icon.png'),
                                    SizedBox(
                                      width: 25,
                                    ),
                                    Expanded(
                                      child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Light will be monitored',
                                              textAlign: TextAlign.center,
                                              style: GoogleFonts.openSans(
                                                color: AppColors.primaryColor,
                                                fontSize: 15.0,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                            Text(
                                              'every 30 minutes.',
                                              textAlign: TextAlign.center,
                                              style: GoogleFonts.openSans(
                                                color: AppColors.primaryColor,
                                                fontSize: 15.0,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ]),
                                    ),
                                  ],
                                )),
                          ])),
                  const SizedBox(
                    height: 30,
                  ),
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
                                        'assets/images/moisture_sensor_icon.png'),
                                    SizedBox(
                                      width: 25,
                                    ),
                                    Expanded(
                                      child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Soil moisture will be monitored ',
                                              textAlign: TextAlign.center,
                                              style: GoogleFonts.openSans(
                                                color: AppColors.primaryColor,
                                                fontSize: 15.0,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                            Text(
                                              'every 4 hours.',
                                              textAlign: TextAlign.center,
                                              style: GoogleFonts.openSans(
                                                color: AppColors.primaryColor,
                                                fontSize: 15.0,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            )
                                          ]),
                                    ),
                                  ],
                                )),
                          ])),
                  SizedBox(height: 20),
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
                          "Continue to Planter Profile",
                          style: GoogleFonts.openSans(
                            color: AppColors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        )),
                      ),
                      onTap: () async {
                        var planterId =
                            await SharedPreferenceService.getAddedPlanterUID();
                        if (widget.isWater && widget.isFertilizer) {
                          await FirebaseFirestore.instance
                              .collection("user_plant_devices")
                              .doc(planterId)
                              .update({
                            "is_fertilizer_turned_on": true,
                            "is_reservoir_sensor_turned_on": true,
                            "is_water_sensor_turned_on": true
                          });

                          widget.planterDetails.isFertilizerTurnedOn = true;
                          widget.planterDetails.isReservoirSensorTurnedOn =
                              true;
                          widget.planterDetails.isWaterSensorTurnedOn = true;

                          _updatePlanterReminder("fertilizer_refill", true);
                          _updatePlanterReminder("reservoir_refill", true);
                        } else {
                          await FirebaseFirestore.instance
                              .collection("user_plant_devices")
                              .doc(planterId)
                              .update({
                            // "is_fertilizer_turned_on": false,
                            "is_reservoir_sensor_turned_on": true,
                            "is_water_sensor_turned_on": true
                          });

                          widget.planterDetails.isReservoirSensorTurnedOn =
                              true;
                          widget.planterDetails.isWaterSensorTurnedOn = true;

                          _updatePlanterReminder("reservoir_refill", true);
                        }

                        // Navigator.push(
                        //   context,
                        //   CupertinoPageRoute(
                        //     builder: (context) => HomeScreen(),
                        //   ),
                        // );

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                PlanterProfile(widget.planterDetails, false),
                          ),
                        );
                      },
                    ),
                    padding: EdgeInsets.only(left: 60, right: 60),
                  ),
                ])));
  }
}
