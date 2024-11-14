import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_onboarding_slider/flutter_onboarding_slider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hortijoy_mobile_app/resources/colors.dart';

import 'package:hortijoy_mobile_app/screens/login/login_body.dart';
import 'package:hortijoy_mobile_app/screens/login/login_screen.dart';
import 'package:hortijoy_mobile_app/screens/onboarding/onboarding3.dart';
import 'package:hortijoy_mobile_app/screens/plant_library/components/plant_library_body.dart';
import 'package:hortijoy_mobile_app/screens/planter/fill_water_reservoir_initial_screen.dart';
import 'package:hortijoy_mobile_app/screens/registration/registration_screen.dart';
import 'package:hortijoy_mobile_app/screens/test_sensors/fill_water_reservoir_screen.dart';

class FilterSensorInstructionScreen extends StatefulWidget {
  List<String> selectedFilters;
  int lightValue;
  String planterDeviceName;
  FilterSensorInstructionScreen(
      {required this.selectedFilters,
      required this.lightValue,
      required this.planterDeviceName,
      super.key});

  @override
  State<FilterSensorInstructionScreen> createState() =>
      _FilterSensorInstructionScreenState();
}

class _FilterSensorInstructionScreenState
    extends State<FilterSensorInstructionScreen> {
  final Color primaryColor = AppColors.primaryColor;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.white,
        body: Container(
            color: AppColors.white,
            child: SingleChildScrollView(
                child: Column(children: [
              Image.asset(
                'assets/images/filter_main_image.png',
                height: 500,
              ),
              SizedBox(height: 10),
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
                            padding:
                                EdgeInsets.only(left: 25, right: 25, top: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Image.asset(
                                    'assets/icons/filter_light_one.png'),
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
                                          'Make sure the planter is plugged in at the desired planting location.',
                                          textAlign: TextAlign.start,
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
                            padding:
                                EdgeInsets.only(left: 25, right: 25, top: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Image.asset(
                                    'assets/icons/filter_light_two.png'),
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
                                          "The light sensor should point straight up.",
                                          textAlign: TextAlign.start,
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
                            padding:
                                EdgeInsets.only(left: 25, right: 25, top: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Image.asset(
                                    'assets/icons/filter_light_three.png'),
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
                                          'Measure in peak daylight during periods of indirect and direct sun.',
                                          textAlign: TextAlign.start,
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
                padding: EdgeInsets.only(left: 60, right: 60, bottom: 30),
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
                    var adjustedSelectedFilters = widget.selectedFilters;
                    adjustedSelectedFilters.removeWhere(
                        (element) => element.contains("light_sensor"));

                    adjustedSelectedFilters.add("light_sensor-" +
                        widget.lightValue.toString() +
                        "&&&&&" +
                        widget.planterDeviceName);

                    print("LIGHT VALUE: " + widget.lightValue.toString());
                    adjustedSelectedFilters
                        .remove("standard_light_intensity-light sensor");
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PlantLibraryBody(
                            selectedFilters: adjustedSelectedFilters,
                          ),
                        ));
                  },
                ),
              ),
            ]))));
  }
}
