import 'dart:async';
import 'dart:convert';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hortijoy_mobile_app/models/plants.dart';
import 'package:hortijoy_mobile_app/models/plant_devices.dart';
import 'package:hortijoy_mobile_app/resources/colors.dart';
import 'package:hortijoy_mobile_app/resources/shared_pref_service.dart';
import 'package:hortijoy_mobile_app/screens/home/components/detail_page.dart';
import 'package:hortijoy_mobile_app/screens/planter/planter_profile.dart';
import 'package:hortijoy_mobile_app/screens/planter/planter_select_care_profile.dart';
import 'package:hortijoy_mobile_app/screens/planter/planter_settings.dart';
import 'package:page_transition/page_transition.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class PlantWidget extends StatefulWidget {
  final int index;
  final List<PlantDevices> plantList;
  final String documentId;
  final BuildContext cont;
  PlantWidget(
      {Key? key,
      required this.index,
      required this.plantList,
      required this.documentId,
      required this.cont})
      : super(key: key);

  @override
  State<PlantWidget> createState() => _PlantWidgetState();
}

class _PlantWidgetState extends State<PlantWidget> {
  String latestLightValue = "0FC";
  String latestWaterReservoirValue = "0%";
  String latestMoistureValue = "0%";
  String latestFertilizerValue = "0%";

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
      _fertilizerSubscription;

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
      _moistureSubscription;

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
      _reservoirSubscription;

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _lightSubscription;

  double? _lightIntensityDarkMin;
  double? _lightIntensityDarkMax;
  double? _lightIntensitySunnyMin;
  double? _lightIntensitySunnyMax;

  @override
  void initState() {
    super.initState();

    getLatestLightReading();
    getLatestReservoirReading();
    getLatestMoistureReading();
    getLatestFertilizerReading();
    _fetchData();
  }

  @override
  void dispose() {
    _fertilizerSubscription?.cancel();
    _moistureSubscription?.cancel();
    _reservoirSubscription?.cancel();
    _lightSubscription?.cancel();
    super.dispose();
  }

  getLatestLightReading() async {
    QuerySnapshot<Map<String, dynamic>> userDevices = await FirebaseFirestore
        .instance
        .collection('user_plant_devices')
        .where('planter_device_name',
            isEqualTo: widget.plantList[widget.index].planterDeviceName)
        .where('email', isEqualTo: FirebaseAuth.instance.currentUser?.email)
        .limit(1)
        .get();

    if (userDevices.docs.isNotEmpty) {
      var deviceId = userDevices.docs.first.id;

      _lightSubscription = FirebaseFirestore.instance
          .collection('user_plant_devices')
          .doc(deviceId)
          .collection('light_readings')
          .orderBy('timestamp', descending: true)
          .limit(1)
          .snapshots()
          .listen((QuerySnapshot<Map<String, dynamic>> snapshot) {
        if (snapshot.docs.isNotEmpty) {
          setState(() {
            latestLightValue = snapshot.docs[0]
                    .get("foot_candle")
                    .toString()
                    .replaceAll(RegExp(r"\.0$"), "") +
                "FC";
          });
        } else {
          setState(() {
            latestLightValue = "1000FC"; //TODO: REMOVE THIS
          });
        }
      });
    }
  }

  getLatestReservoirReading() async {
    QuerySnapshot<Map<String, dynamic>> userDevices = await FirebaseFirestore
        .instance
        .collection('user_plant_devices')
        .where('planter_device_name',
            isEqualTo: widget.plantList[widget.index].planterDeviceName)
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
            latestWaterReservoirValue = snapshot.docs[0]
                    .get("water_reservoir_level")
                    .toString()
                    .replaceAll(RegExp(r"\.0$"), "") +
                "%";
          });
        } else {
          setState(() {
            latestWaterReservoirValue = "100%"; //TODO: REMOVE THIS
          });
        }
      });
    }
  }

  getLatestMoistureReading() async {
    QuerySnapshot<Map<String, dynamic>> userDevices = await FirebaseFirestore
        .instance
        .collection('user_plant_devices')
        .where('planter_device_name',
            isEqualTo: widget.plantList[widget.index].planterDeviceName)
        .where('email', isEqualTo: FirebaseAuth.instance.currentUser?.email)
        .limit(1)
        .get();

    if (userDevices.docs.isNotEmpty) {
      var deviceId = userDevices.docs.first.id;

      _moistureSubscription = FirebaseFirestore.instance
          .collection('user_plant_devices')
          .doc(deviceId)
          .collection('soil_moisture_readings')
          .orderBy('timestamp', descending: true)
          .limit(1)
          .snapshots()
          .listen((QuerySnapshot<Map<String, dynamic>> snapshot) {
        if (snapshot.docs.isNotEmpty) {
          setState(() {
            latestMoistureValue = snapshot.docs[0]
                    .get("soil_moisture_level")
                    .toString()
                    .replaceAll(RegExp(r"\.0$"), "") +
                "%";
          });
        } else {
          setState(() {
            latestMoistureValue = "100%"; //TODO: remove this
          });
        }
      });
    }
  }

  getLatestFertilizerReading() async {
    QuerySnapshot<Map<String, dynamic>> userDevices = await FirebaseFirestore
        .instance
        .collection('user_plant_devices')
        .where('planter_device_name',
            isEqualTo: widget.plantList[widget.index].planterDeviceName)
        .where('email', isEqualTo: FirebaseAuth.instance.currentUser?.email)
        .limit(1)
        .get();

    if (userDevices.docs.isNotEmpty) {
      var deviceId = userDevices.docs.first.id;

      _fertilizerSubscription = FirebaseFirestore.instance
          .collection('user_plant_devices')
          .doc(deviceId)
          .collection('fertilizer_readings')
          .orderBy('timestamp', descending: true)
          .limit(1)
          .snapshots()
          .listen((QuerySnapshot<Map<String, dynamic>> snapshot) {
        if (snapshot.docs.isNotEmpty) {
          setState(() {
            latestFertilizerValue = ((double.parse(snapshot.docs[0]
                                .get("fertilizer_volume")
                                .toString()) /
                            236.00) *
                        100)
                    .toStringAsFixed(2)
                    .replaceAll(RegExp(r"\.0$"), "") +
                "%";
          });
        } else {
          setState(() {
            latestFertilizerValue = "100%"; //TODO: remove this
          });
        }
      });
    }
  }

  Future<void> _fetchData() async {
    var fileDocument = await FirebaseFirestore.instance
        .collection("plant_library_test_first")
        .where("common_names",
            isEqualTo: widget.plantList[widget.index].plantName)
        .limit(1)
        .get();

    if (fileDocument.docs.isNotEmpty) {
      _parseLightIntensity(fileDocument.docs.first.data());
    } else {
      _parseLightIntensity({
        "light_intensity_dark": "<201",
        "light_intensity_too_sunny": ">1000"
      });
    }
  }

  void _parseLightIntensity(Map<String, dynamic> data) {
    String darkIntensity = data["light_intensity_dark"];
    String sunnyIntensity = data["light_intensity_too_sunny"];

    _lightIntensityDarkMin = _parseIntensityValue(darkIntensity, isMin: true);
    _lightIntensityDarkMax = _parseIntensityValue(darkIntensity, isMin: false);
    _lightIntensitySunnyMin =
        _parseIntensityValue(sunnyIntensity, isMin: true) ?? 1000;
    _lightIntensitySunnyMax =
        _parseIntensityValue(sunnyIntensity, isMin: false) ?? 1100;
  }

  double? _parseIntensityValue(String intensity, {required bool isMin}) {
    if (intensity.startsWith('>')) {
      return isMin ? double.parse(intensity.substring(1)) : 1100;
    } else if (intensity.startsWith('<')) {
      return isMin ? 0 : double.parse(intensity.substring(1));
    } else if (intensity.contains('-')) {
      var parts = intensity.split('-');
      return isMin ? double.parse(parts[0]) : double.parse(parts[1]);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: () {
        SharedPreferenceService.setAddedPlanterUID(widget.documentId);
        SharedPreferenceService.setIsAlreadyProfiled(
            widget.plantList[widget.index].isAlreadyProfiled);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                PlanterProfile(widget.plantList[widget.index], false),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.all(10),
        margin: const EdgeInsets.only(bottom: 30, right: 10, top: 30),
        width: size.width,
        child: 
        
        Slidable(
          endActionPane: ActionPane(
            motion: const StretchMotion(),
            children: [
              SlidableAction(
                backgroundColor: Colors.green,
                label: 'Settings',
                onPressed: (context) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PlanterSettings(
                        plantId: widget.documentId,
                        planterDetails: widget.plantList[widget.index],
                      ),
                    ),
                  );
                },
              ),
              SlidableAction(
                backgroundColor: Colors.red,
                label: 'Delete',
                onPressed: (context) {
                  AwesomeDialog(
                    context: widget.cont,
                    dialogType: DialogType.warning,
                    animType: AnimType.topSlide,
                    showCloseIcon: true,
                    title: "Warning",
                    desc: "Are you sure you want to delete this plant?",
                    btnCancelOnPress: () {},
                    btnOkOnPress: () async {
                      await deletePlant(widget.documentId, widget.cont);
                    },
                  ).show();
                },
              ),
            ],
          ),
          child: 
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: AppColors.primaryColor,
                radius: 40,
                backgroundImage:
                    widget.plantList[widget.index].planterDeviceURL.isEmpty
                        ? NetworkImage(widget.plantList[widget.index].imageURL)
                        : NetworkImage(
                            widget.plantList[widget.index].planterDeviceURL),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.plantList[widget.index].planterDeviceName,
                      style: GoogleFonts.openSans(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: AppColors.black,
                      ),
                    ),
                    widget.plantList[widget.index].isAlreadyProfiled == "false"
                        ? const Text(
                            "No care profile selected yet",
                            style: TextStyle(
                              fontStyle: FontStyle.italic,
                              color: AppColors.subtitleColor,
                            ),
                          )
                        : Text(
                            widget.plantList[widget.index].description,
                            style: GoogleFonts.openSans(),
                            overflow: TextOverflow.visible,
                          ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        LightSensorIcon(
                          assetPath: "assets/icons/light_outlined.svg",
                          value: double.parse(
                              latestLightValue.replaceAll("FC", "")),
                          isActive: widget
                              .plantList[widget.index].isLightSensorTurnedOn,
                          lightDarkIntensityValues: [
                            _lightIntensityDarkMin ?? 0,
                            _lightIntensityDarkMax ?? 200
                          ],
                          lightBrightIntensityValues: [
                            _lightIntensitySunnyMin ?? 1000,
                            _lightIntensitySunnyMax ?? 2000,
                          ],
                        ),
                        const SizedBox(width: 10),
                        MoistureSensorIcon(
                          assetPath: "assets/icons/moisture_outlined.svg",
                          value: double.parse(
                              latestMoistureValue.replaceAll("%", "")),
                          isActive: widget
                              .plantList[widget.index].isWaterSensorTurnedOn,
                        ),
                        const SizedBox(width: 10),
                        WaterSensorIcon(
                          assetPath: "assets/icons/water_outlined.svg",
                          value: double.parse(
                              latestWaterReservoirValue.replaceAll("%", "")),
                          isActive: widget.plantList[widget.index]
                              .isReservoirSensorTurnedOn,
                        ),
                        const SizedBox(width: 10),
                        FertilizerSensorIcon(
                          assetPath: "assets/icons/nutrient.svg",
                          value: double.parse(
                              latestFertilizerValue.replaceAll("%", "")),
                          isActive: widget
                              .plantList[widget.index].isFertilizerTurnedOn,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> deletePlant(String docuName, BuildContext context) async {
    await FirebaseFirestore.instance
        .collection('user_plant_devices')
        .doc(docuName)
        .delete()
        .then((value) => {
              AwesomeDialog(
                      context: context,
                      dialogType: DialogType.success,
                      animType: AnimType.rightSlide,
                      title: 'Success!',
                      desc:
                          'This planter device has been successfully added to your list',
                      btnOkOnPress: () async {},
                      btnOkColor: AppColors.primaryColor)
                  .show()
            });
  }
}

class SensorIcon extends StatelessWidget {
  final String assetPath;
  final bool isActive;
  final double? value;

  const SensorIcon({
    required this.assetPath,
    required this.isActive,
    this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SvgPicture.asset(
          assetPath,
          width: 16,
          height: 16,
        ),
        CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(
            isActive ? AppColors.sensorIconColor : AppColors.sensorNotYetAdded,
          ),
          value: value,
          strokeWidth: 3,
        ),
      ],
    );
  }
}

class LightSensorIcon extends StatelessWidget {
  final String assetPath;
  final double value;
  final bool isActive;
  final lightDarkIntensityValues;
  final lightBrightIntensityValues;

  const LightSensorIcon(
      {required this.assetPath,
      required this.value,
      required this.isActive,
      required this.lightDarkIntensityValues,
      required this.lightBrightIntensityValues});

  @override
  Widget build(BuildContext context) {
    Color getColor() {
      if (!isActive) {
        return AppColors.sensorNotYetAdded;
      } else if (value > lightDarkIntensityValues[1] &&
          value < lightBrightIntensityValues[0]) {
        return AppColors.sensorIconColor;
      } else if (value >= 0 && value <= lightDarkIntensityValues[0]) {
        return Color(0xfff707D6D);
      } else {
        return Color.fromARGB(255, 255, 252, 80);
      }
    }

    double normalizedValue = (value / 1100).clamp(0.0, 1.0);

    return Stack(
      alignment: Alignment.center,
      children: [
        SvgPicture.asset(
          assetPath,
          width: 16,
          height: 16,
        ),
        CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(getColor()),
          value: normalizedValue,
          strokeWidth: 3,
        ),
      ],
    );
  }
}

class FertilizerSensorIcon extends StatelessWidget {
  final String assetPath;
  final double value;
  final bool isActive;

  const FertilizerSensorIcon(
      {required this.assetPath, required this.value, required this.isActive});

  @override
  Widget build(BuildContext context) {
    Color getColor() {
      if (!isActive) {
        return AppColors.sensorNotYetAdded;
      } else if (value >= 75 && value <= 100) {
        return AppColors.sensorIconColor;
      } else if (value >= 10 && value <= 74) {
        return Color.fromARGB(255, 255, 252, 80);
      } else {
        return Color.fromARGB(255, 233, 26, 26);
      }
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        SvgPicture.asset(
          assetPath,
          width: 16,
          height: 16,
        ),
        CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(getColor()),
          value: value * .01,
          strokeWidth: 3,
        ),
      ],
    );
  }
}

class MoistureSensorIcon extends StatelessWidget {
  final String assetPath;
  final double value;
  final bool isActive;

  const MoistureSensorIcon(
      {required this.assetPath, required this.value, required this.isActive});

  @override
  Widget build(BuildContext context) {
    Color getColor() {
      if (!isActive) {
        return AppColors.sensorNotYetAdded;
      } else if (value >= 75 && value <= 100) {
        return AppColors.sensorIconColor;
      } else if (value >= 25 && value <= 74) {
        return Color.fromARGB(255, 255, 252, 80);
      } else {
        return Color.fromARGB(255, 233, 26, 26);
      }
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        SvgPicture.asset(
          assetPath,
          width: 16,
          height: 16,
        ),
        CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(getColor()),
          value: value * .01,
          strokeWidth: 3,
        ),
      ],
    );
  }
}

class WaterSensorIcon extends StatelessWidget {
  final String assetPath;
  final double value;
  final bool isActive;

  const WaterSensorIcon(
      {required this.assetPath, required this.value, required this.isActive});

  @override
  Widget build(BuildContext context) {
    Color getColor() {
      if (!isActive) {
        return AppColors.sensorNotYetAdded;
      } else if (value >= 75 && value <= 100) {
        return AppColors.sensorIconColor;
      } else if (value >= 25 && value <= 74) {
        return Color.fromARGB(255, 255, 252, 80);
      } else {
        return Color.fromARGB(255, 233, 26, 26);
      }
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        SvgPicture.asset(
          assetPath,
          width: 16,
          height: 16,
        ),
        CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(getColor()),
          value: value * .01,
          strokeWidth: 3,
        ),
      ],
    );
  }
}

class CustomCircularProgressBar extends StatelessWidget {
  final double progress; // Progress value from 0.0 to 1.0

  const CustomCircularProgressBar({Key? key, required this.progress})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Circular progress background
        CircularProgressIndicator(
          value: 1.0,
          backgroundColor: Colors.grey[200],
          strokeWidth: 10.0,
        ),
        // Circular progress indicator with segmented color
        CircularProgressIndicator(
          value: progress,
          strokeWidth: 10.0,
          valueColor: AlwaysStoppedAnimation<Color>(
            progress > 0.75
                ? Colors.green
                : progress > 0.25
                    ? Colors.yellow
                    : Colors.red,
          ),
        ),
        // Icon inside the circular progress bar
        Icon(
          Icons.image, // Replace with your icon
          size: 24.0,
          color: Colors.black,
        ),
      ],
    );
  }
}
