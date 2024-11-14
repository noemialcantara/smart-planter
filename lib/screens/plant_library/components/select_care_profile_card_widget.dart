import 'dart:convert';
import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hortijoy_mobile_app/models/plants.dart';
import 'package:hortijoy_mobile_app/models/plant_devices.dart';
import 'package:hortijoy_mobile_app/resources/colors.dart';
import 'package:hortijoy_mobile_app/resources/shared_pref_service.dart';
import 'package:hortijoy_mobile_app/screens/discover/care_profile.dart';
import 'package:hortijoy_mobile_app/screens/home/components/detail_page.dart';
import 'package:hortijoy_mobile_app/screens/home/home_page_body.dart';
import 'package:hortijoy_mobile_app/screens/plant_library/components/detail_page.dart';
import 'package:hortijoy_mobile_app/screens/planter/plant_care_profile_screen.dart';
import 'package:hortijoy_mobile_app/screens/planter/planter_plant_description.dart';
import 'package:hortijoy_mobile_app/screens/planter/planter_profile.dart';
import 'package:hortijoy_mobile_app/screens/planter/planter_select_care_profile.dart';
import 'package:hortijoy_mobile_app/screens/planter/sensor_instruction_screen.dart';
import 'package:page_transition/page_transition.dart';

class SelectCareProfileCardWidget extends StatefulWidget {
  final int index;
  final planterMainData;
  final List<Plant> plantList;
  final planterDetails;
  final bool isSwitching;
  final Map<String, dynamic> plantListDataForBottomSheet;

  const SelectCareProfileCardWidget(
      {super.key,
      required this.index,
      required this.plantList,
      required this.planterDetails,
      required this.planterMainData,
      required this.plantListDataForBottomSheet,
      required this.isSwitching});

  @override
  State<SelectCareProfileCardWidget> createState() =>
      _SelectCareProfileCardWidgetState();
}

class _SelectCareProfileCardWidgetState
    extends State<SelectCareProfileCardWidget> {
  String searchProfile = '';

  String uid = "";
  bool _isLoading = false;

  _showModalBottomSheet(BuildContext context, data, planterDetails) {
    SharedPreferenceService.getAddedPlanterUID().then((value) {
      setState(() {
        uid = value.toString();
      });
    });
    String botanical_name = data['botanical_name'];
    String commonNames = data['common_names'];
    String fertilizerFrequency = data['fertilizer_frequency'];
    String fertilizerSeason = data['fertilizer_season'];
    String fertilizerStrength = data['fertilizer_strength'];
    String hasAirCleaner = data['has_air_cleaner'];
    String lightIntensityDark = data['light_intensity_dark'];
    String lightIntensityIdeal = data['light_intensity_ideal'];
    String lightIntensitySufficient = data['light_intensity_sufficient'];
    String lightIntensityTooSunny = data['light_intensity_too_sunny'];

    String plantImageUrl = data['plant_image_url'];
    String plantType = data['plant_type'];
    String standardLightIntensity = data['standard_light_intensity'];
    String standardWaterProfileStatus = data['standard_water_profile_status'];
    String waterStatus = data['water_status'];
    String waterStatusPercentage = data['water_status_percentage'];
    String sunlightCareProfileInformation =
        data["sunlight_care_profile_information"];
    String wateringCareProfileInformation =
        data["watering_care_profile_information"];

    return showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        builder: (BuildContext context) {
          return Container(
            height: 150,
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.all(8.0),
                  width: 50,
                  height: 7,
                  decoration: const BoxDecoration(
                      color: Colors.black45,
                      borderRadius: BorderRadius.all(Radius.circular(20.0))),
                ),
                Flexible(
                    child: ListView(
                  children: [
                    ListTile(
                      leading: Icon(Icons.check_circle_outline),
                      title: GestureDetector(
                          child: Text("Use care profile",
                              style: GoogleFonts.openSans(color: Colors.black)),
                          onTap: () {
                            // setState(() {
                            //   _isLoading = true;
                            // });
                            // try {
                            //   FirebaseFirestore.instance
                            //       .collection("user_plant_devices")
                            //       .doc(uid)
                            //       .update({
                            //     "plant_name": commonNames,
                            //     "species_name": botanical_name,
                            //     "type": plantType,
                            //     "is_already_profiled": true,
                            //     "sunlight_care_profile_information":
                            //         sunlightCareProfileInformation,
                            //     "watering_care_profile_information":
                            //         wateringCareProfileInformation,
                            //   }).then((value) {
                            //     setState(() {
                            //       _isLoading = false;
                            //     });
                            //     // AnimatedSnackBar.material(
                            //     //   "Added successfully!",
                            //     //   type: AnimatedSnackBarType.success,
                            //     //   mobileSnackBarPosition: MobileSnackBarPosition
                            //     //       .bottom, // Position of snackbar on mobile devices
                            //     //   desktopSnackBarPosition: DesktopSnackBarPosition
                            //     //       .bottomCenter, // Position of snackbar on desktop devices
                            //     // ).show(context);
                            //   });
                            // } on FirebaseAuthException catch (e) {
                            //   setState(() {
                            //     _isLoading = false;
                            //   });
                            //   AnimatedSnackBar.material(
                            //     e.message.toString(),
                            //     type: AnimatedSnackBarType.error,
                            //     mobileSnackBarPosition: MobileSnackBarPosition
                            //         .bottom, // Position of snackbar on mobile devices
                            //     desktopSnackBarPosition: DesktopSnackBarPosition
                            //         .bottomCenter, // Position of snackbar on desktop devices
                            //   ).show(context);
                            // }

                            // SharedPreferenceService.setIsAlreadyProfiled(
                            //     "true");
                            var extraDetails = {
                              "plant_name": commonNames,
                              "species_name": botanical_name,
                              "type": plantType,
                              "is_already_profiled": true,
                              "planter_image_url": plantImageUrl,
                              "image_url": plantImageUrl,
                              "sunlight_care_profile_information":
                                  sunlightCareProfileInformation,
                              "watering_care_profile_information":
                                  wateringCareProfileInformation,
                            };

                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        SensorInstructionScreen(
                                          isSwitching: widget.isSwitching,
                                          planterDetails: widget.planterDetails,
                                          extraDetails: extraDetails,
                                          uid: uid,
                                          isPlanterUpdateRequired: true,
                                        )));

                            //  Navigator.pushReplacement(
                            //       context,
                            //       MaterialPageRoute(
                            //           builder: (context) =>
                            //                SensorInstructionScreen(planterDetails: widget.planterDetails,)));
                            // Future.delayed(const Duration(seconds: 2), () {
                            //   Navigator.pushReplacement(
                            //       context,
                            //       MaterialPageRoute(
                            //           builder: (context) =>
                            //               const HomeScreenBody()));
                            // });
                          }),
                    ),
                    ListTile(
                      leading: const Icon(
                        Icons.arrow_upward_rounded,
                      ),
                      title: GestureDetector(
                          child: Text("View care profile",
                              style: GoogleFonts.openSans(color: Colors.black)),
                          onTap: () async {
                            Plant data;
                            await FirebaseFirestore.instance
                                .collection("plant_library_test_first")
                                .where("common_names", isEqualTo: commonNames)
                                .where("plant_type", isEqualTo: plantType)
                                .get()
                                .then((event) async {
                              if (event.docs.isNotEmpty) {
                                setState(() {
                                  //${event.docs.first.get("standard_light_intensity")}
                                  data = Plant(
                                    botanicalName: jsonDecode(event.docs.first
                                                    .get("botanical_name"))
                                                .length >
                                            0
                                        ? jsonDecode(event.docs.first
                                                .get("botanical_name"))
                                            .map((data) =>
                                                data[0].toUpperCase() +
                                                data.toString().substring(1))
                                            .toList()
                                            .join(", ")
                                        : "No botanical name",
                                    commonNames: jsonDecode(event.docs.first
                                                    .get("common_names"))
                                                .length >
                                            0
                                        ? jsonDecode(event.docs.first
                                                .get("common_names"))
                                            .map((data) =>
                                                data[0].toUpperCase() +
                                                data.toString().substring(1))
                                            .toList()
                                            .join(", ")
                                        : "No common name",
                                    fertilizerFrequency: event.docs.first
                                        .get("fertilizer_frequency")
                                        .toString(),
                                    fertilizerSeason: event.docs.first
                                        .get("fertilizer_season")
                                        .toString(),
                                    fertilizerStrength: event.docs.first
                                        .get("fertilizer_strength")
                                        .toString(),
                                    hasAirCleaner: event.docs.first
                                        .get("has_air_cleaner")
                                        .toString(),
                                    lightIntensityDark: event.docs.first
                                        .get("light_intensity_dark")
                                        .toString(),
                                    lightIntensityIdeal: event.docs.first
                                        .get("light_intensity_ideal")
                                        .toString(),
                                    lightIntensitySufficient: event.docs.first
                                        .get("light_intensity_sufficient")
                                        .toString(),
                                    lightIntensityTooSunny: event.docs.first
                                        .get("light_intensity_too_sunny")
                                        .toString(),
                                    plantImageUrl: event.docs.first
                                        .get("plant_image_url")
                                        .toString(),
                                    plantType: jsonDecode(event.docs.first
                                                    .get("plant_type")
                                                    .toString())
                                                .length >
                                            0
                                        ? jsonDecode(event.docs.first
                                                .get("plant_type")
                                                .toString())
                                            .map((data) =>
                                                data[0].toUpperCase() +
                                                data.toString().substring(1))
                                            .toList()
                                            .join(", ")
                                        : "No plant type",
                                    standardLightIntensity: event.docs.first
                                        .get("standard_light_intensity")
                                        .toString(),
                                    standardWaterProfileStatus: event.docs.first
                                        .get("standard_water_profile_status")
                                        .toString(),
                                    waterStatus: event.docs.first
                                        .get("water_status")
                                        .toString(),
                                    waterStatusPercentage: event.docs.first
                                        .get("water_status_percentage")
                                        .toString(),
                                    wateringCareProfileInformation: event
                                        .docs.first
                                        .get(
                                            "watering_care_profile_information")
                                        .toString(),
                                    sunlightCareProfileInformation: event
                                        .docs.first
                                        .get(
                                            "sunlight_care_profile_information")
                                        .toString(),
                                  );

                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            PlantCareProfileScreen(
                                                plantDetails: data),
                                      ));
                                });
                              }
                            });

                            // Navigator.push(
                            //     context,
                            //     MaterialPageRoute(
                            //       builder: (context) => PlantDescriptions(
                            //           planterDetails: widget.planterDetails),
                            //     ));
                          }),
                    ),
                  ],
                )),
              ],
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return GestureDetector(
        onTap: () {
          _showModalBottomSheet(
              context, widget.planterMainData, widget.planterDetails);
        },
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          height: 105.0,
          padding: const EdgeInsets.all(10),
          margin: const EdgeInsets.only(bottom: 10, top: 10),
          width: size.width,
          child: Stack(
            children: [
              Positioned(
                top: 0,
                left: 0,
                child: Container(
                  width: 80.0,
                  height: 80.0,
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor,
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: NetworkImage(
                          widget.plantList[widget.index].plantImageUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 0,
                left: 100,
                right: 0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.plantList[widget.index].botanicalName,
                      style: GoogleFonts.openSans(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: AppColors.black,
                      ),
                    ),
                    Text(
                      widget.plantList[widget.index].commonNames.toString(),
                      style: GoogleFonts.openSans(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ));
  }
}
