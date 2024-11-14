import 'dart:convert';

import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:async_task/async_task_extension.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:hortijoy_mobile_app/models/plant_devices.dart';
import 'package:hortijoy_mobile_app/models/plants.dart';
import 'package:hortijoy_mobile_app/resources/colors.dart';
import 'package:hortijoy_mobile_app/resources/firebase_firestore.dart';
import 'package:hortijoy_mobile_app/resources/shared_pref_service.dart';
import 'package:hortijoy_mobile_app/resources/widget_properties.dart';
import 'package:hortijoy_mobile_app/screens/add_device_options/add_device_options.dart';
import 'package:hortijoy_mobile_app/screens/home/home_page_body.dart';
import 'package:hortijoy_mobile_app/screens/plant_library/components/chips_list.dart';
import 'package:hortijoy_mobile_app/screens/plant_library/components/filter_savedlist.dart';
import 'package:hortijoy_mobile_app/screens/plant_library/components/plant_filter.dart';
import 'package:hortijoy_mobile_app/screens/plant_library/components/plant_library_card_widget.dart';
import 'package:hortijoy_mobile_app/screens/planter/plant_care_profile_screen.dart';
import 'package:hortijoy_mobile_app/screens/planter/planter_plant_description.dart';
import 'package:hortijoy_mobile_app/screens/planter/planter_profile.dart';
import 'package:hortijoy_mobile_app/resources/my_textfield.dart';
import 'package:hortijoy_mobile_app/screens/planter/sensor_instruction_screen.dart';

class PlanterSelectCareProfile extends StatefulWidget {
  final planterDetails;
  final bool isSwitching;
  List<dynamic> selectedFilters;
  PlanterSelectCareProfile(
      {required this.planterDetails,
      required this.isSwitching,
      required this.selectedFilters,
      super.key});

  @override
  State<PlanterSelectCareProfile> createState() =>
      _PlanterSelectCareProfileState();
}

class _PlanterSelectCareProfileState extends State<PlanterSelectCareProfile> {
  String uid = "";
  bool _isLoading = false;
  final searchController = TextEditingController();

  List<QueryDocumentSnapshot<Object?>> filteredRecords = [];
  final saveListController = TextEditingController();
  Query contents =
      FirebaseFirestore.instance.collection('plant_library_test_first');
  List<String> category1 = [];
  List<String> category2 = [];
  List<String> category3 = [];
  List<String> allCategory = [];
  List<String> allValue = [];
  int snapshotDataLength = 0;

  int waterCount = 0;
  List<String> waterFilters = [];
  int lightCount = 0;
  List<String> lightFilters = [];
  int categoryCount = 0;
  List<String> categoryFilters = [];
  bool hasAirCleaner = false;
  bool hasLightSensorValue = false;
  int lightSensorValue = 0;
  int filterDiffCount = 0;

  @override
  void initState() {
    super.initState();

    widget.selectedFilters.forEach((element) {
      allCategory.add(element.split("-")[0]);
      if ("light_sensor" == element.split("-")[0]) {
        allValue.add(element.split("-")[1]);
      } else {
        allValue.add(element.split("-")[1]);
      }
    });

    widget.selectedFilters.forEach((element) async {
      if (element.contains("standard_water_profile_status")) {
        if (waterCount == 0) filterDiffCount++;
        waterCount++;
        waterFilters.add(element.split("-")[1]);
      }

      if (element.contains("standard_light_intensity")) {
        if (lightCount == 0) filterDiffCount++;
        lightCount++;
        lightFilters.add(element.split("-")[1]);
      }

      if (element.contains("category")) {
        if (categoryCount == 0) filterDiffCount++;
        categoryCount++;
        categoryFilters.add(element.split("-")[1]);

        if (element.split("-")[1] == "air cleaner") {
          setState(() {
            hasAirCleaner = true;
          });
        }
      }

      if (element.contains("light_sensor")) {
        setState(() {
          hasLightSensorValue = true;
          lightSensorValue = int.parse(element.split("-")[1].split("&&&&&")[0]);
        });
      }
    });

    Filter filterCategory = Filter.or(
        Filter("category", arrayContains: "perennial"),
        Filter("category", arrayContains: "evergreen"),
        Filter("category", arrayContains: "vine"),
        Filter("category", arrayContains: "palm"),
        Filter("category", arrayContains: "succulent"),
        Filter("category", arrayContains: "cactus"),
        Filter("category", arrayContains: "tree"),
        Filter("category", arrayContains: "fern"));

    if (categoryCount == 1) {
      if (categoryFilters[0] != "air cleaner") {
        filterCategory = Filter.or(
            Filter("category", arrayContains: categoryFilters[0]),
            Filter("category", arrayContains: categoryFilters[0]));
      }
    } else if (categoryCount == 2) {
      filterCategory = Filter.or(
          Filter("category", arrayContains: categoryFilters[0]),
          Filter("category", arrayContains: categoryFilters[1]));
    } else if (categoryCount == 3) {
      filterCategory = Filter.or(
          Filter("category", arrayContains: categoryFilters[0]),
          Filter("category", arrayContains: categoryFilters[1]),
          Filter("category", arrayContains: categoryFilters[2]));
    } else if (categoryCount == 4) {
      filterCategory = Filter.or(
          Filter("category", arrayContains: categoryFilters[0]),
          Filter("category", arrayContains: categoryFilters[1]),
          Filter("category", arrayContains: categoryFilters[2]),
          Filter("category", arrayContains: categoryFilters[3]));
    } else if (categoryCount == 5) {
      filterCategory = Filter.or(
          Filter("category", arrayContains: categoryFilters[0]),
          Filter("category", arrayContains: categoryFilters[1]),
          Filter("category", arrayContains: categoryFilters[2]),
          Filter("category", arrayContains: categoryFilters[3]),
          Filter("category", arrayContains: categoryFilters[4]));
    } else if (categoryCount == 6) {
      filterCategory = Filter.or(
          Filter("category", arrayContains: categoryFilters[0]),
          Filter("category", arrayContains: categoryFilters[1]),
          Filter("category", arrayContains: categoryFilters[2]),
          Filter("category", arrayContains: categoryFilters[3]),
          Filter("category", arrayContains: categoryFilters[4]),
          Filter("category", arrayContains: categoryFilters[5]));
    } else if (categoryCount == 7) {
      filterCategory = Filter.or(
          Filter("category", arrayContains: categoryFilters[0]),
          Filter("category", arrayContains: categoryFilters[1]),
          Filter("category", arrayContains: categoryFilters[2]),
          Filter("category", arrayContains: categoryFilters[3]),
          Filter("category", arrayContains: categoryFilters[4]),
          Filter("category", arrayContains: categoryFilters[5]),
          Filter("category", arrayContains: categoryFilters[6]));
    } else if (categoryCount == 8 || categoryCount == 0) {
      filterCategory = Filter.or(
          Filter("category", arrayContains: "perennial"),
          Filter("category", arrayContains: "evergreen"),
          Filter("category", arrayContains: "vine"),
          Filter("category", arrayContains: "palm"),
          Filter("category", arrayContains: "succulent"),
          Filter("category", arrayContains: "cactus"),
          Filter("category", arrayContains: "tree"),
          Filter("category", arrayContains: "fern"));
    }

    Filter filterHasAirCleaner = Filter.or(
        Filter("has_air_cleaner", isEqualTo: "false"),
        Filter("has_air_cleaner", isEqualTo: "true"));

    if (hasAirCleaner) {
      filterHasAirCleaner = filterHasAirCleaner = Filter.or(
          Filter("has_air_cleaner", isEqualTo: "true"),
          Filter("has_air_cleaner", isEqualTo: "true"));
    }

    contents
        .where(Filter.and(filterCategory, filterHasAirCleaner))
        .snapshots()
        .forEach((element) async {
      int recordsLength = 0;

      element.docs.every(
        (element) {
          int filterMatchCounter = 0;

          for (int i = 0; i < waterCount; i++) {
            if (waterFilters[i] ==
                element.get("standard_water_profile_status").toString()) {
              filterMatchCounter++;
              break;
            }
          }

          for (int j = 0; j < lightCount; j++) {
            if (lightFilters[j] ==
                element.get("standard_light_intensity").toString()) {
              filterMatchCounter++;
              break;
            }
          }

          if (categoryCount > 0) {
            filterMatchCounter++;
          }

          if (filterDiffCount == filterMatchCounter && !hasLightSensorValue) {
            setState(() {
              recordsLength++;
              filteredRecords.add(element);
            });
          } else if (filterDiffCount == filterMatchCounter &&
              hasLightSensorValue) {
            if (element.get("light_intensity_ideal_ending") >=
                    lightSensorValue &&
                element.get("light_intensity_ideal_starting") <=
                    lightSensorValue) {
              setState(() {
                recordsLength++;
                filteredRecords.add(element);
              });
            }
          }

          print("THE LIGHT SENSOR VALUE IS $lightSensorValue");

          return true;
        },
      );

      setState(() {
        snapshotDataLength = filteredRecords.length;
      });
    });
  }

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
                            SharedPreferenceService.setIsAlreadyProfiled(
                                "true");
                            var extraDetails = {
                              "plant_name": commonNames,
                              "species_name": botanical_name,
                              "type": plantType,
                              "planter_image_url": plantImageUrl,
                              "image_url": plantImageUrl,
                              "is_already_profiled": true,
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
    String searchKeyword = "";
    int selectedIndex = 1;
    Size size = MediaQuery.of(context).size;

    return Scaffold(
        backgroundColor: AppColors.white,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: AppColors.white,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: AppColors.primaryColor,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: Text('Select Care Profile',
              style: GoogleFonts.openSans(color: Colors.black)),
          actions: [
            IconButton(
                icon: const Icon(Icons.bookmark_outline, color: Colors.black),
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SavedList(
                          cameFromSelectCareProfile: true,
                          isSwitching: widget.isSwitching,
                          planterDetails: widget.planterDetails),
                    ))),
          ],
        ),
        body: TextDisplayDiscover(
            context, searchController, size, searchKeyword));
  }

  SingleChildScrollView TextDisplayDiscover(BuildContext context,
      TextEditingController searchController, Size size, String searchKeyword) {
    return SingleChildScrollView(
      child: Padding(
          padding: const EdgeInsets.only(left: 0, right: 0, bottom: 5, top: 1),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                //
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Expanded(
                        child: Container(
                            width: double.infinity,
                            height: 55,
                            child: TextField(
                              onChanged: (value) {
                                setState(() {});
                              },
                              onSubmitted: (value) {},
                              controller: searchController,
                              decoration: InputDecoration(
                                prefixIcon: Icon(Icons.search_outlined),
                                prefixIconConstraints: const BoxConstraints(
                                  minWidth: 60,
                                  minHeight: 60,
                                ),
                                hintText: "Find a plant",
                                contentPadding:
                                    const EdgeInsets.fromLTRB(0, 15, 0, 0),
                                hintStyle: GoogleFonts.openSans(
                                  fontSize: 15,
                                  color: HexColor("#8d8d8d"),
                                ),
                              ),
                            ))),
                  ],
                ),
              ),
              widget.selectedFilters.length > 0
                  ? Container(
                      padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Filters",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            ),
                            Row(
                              children: [
                                GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        widget.selectedFilters = [];
                                      });
                                    },
                                    child: Icon(Icons.close_rounded))
                              ],
                            )
                          ]),
                    )
                  : Container(),
              if (widget.selectedFilters.length > 0)
                ChipsList(categoryList: allCategory, valueList: allValue),
              widget.selectedFilters.length == 0
                  ? Container(
                      padding: const EdgeInsets.only(
                        left: 20,
                        right: 20,
                        top: 20,
                      ),
                      height: size.height - (size.height * 0.26),
                      child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                        stream: FirebaseFirestore.instance
                            .collection('plant_library_test_first')
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData && snapshot.data != null) {
                            List<QueryDocumentSnapshot<Map<String, dynamic>>>
                                sortedDocs = snapshot.data!.docs.toList();

                            // Sorting the documents based on the botanical_name after decoding the JSON string
                            sortedDocs.sort((a, b) {
                              List<dynamic> botanicalNameA =
                                  jsonDecode(a.get("botanical_name"));
                              List<dynamic> botanicalNameB =
                                  jsonDecode(b.get("botanical_name"));

                              String firstNameA = botanicalNameA.isNotEmpty
                                  ? botanicalNameA[0].toString().toLowerCase()
                                  : '';
                              String firstNameB = botanicalNameB.isNotEmpty
                                  ? botanicalNameB[0].toString().toLowerCase()
                                  : '';

                              return firstNameA.compareTo(firstNameB);
                            });

                            return ListView.builder(
                                itemCount: sortedDocs.length,
                                scrollDirection: Axis.vertical,
                                physics: const BouncingScrollPhysics(),
                                itemBuilder: (BuildContext context, int index) {
                                  snapshotDataLength = sortedDocs.length;
                                  Map<String, dynamic> test = {
                                    "sdfsf": "dsfsdf"
                                  };

                                  if (searchController.text == "" ||
                                      searchController.text == null) {
                                    return GestureDetector(
                                      onTap: () {
                                        _showModalBottomSheet(
                                            context,
                                            sortedDocs[index],
                                            widget.planterDetails);
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: AppColors.white,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        height: 105.0,
                                        padding: const EdgeInsets.all(10),
                                        margin: const EdgeInsets.only(
                                            bottom: 10, top: 10),
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
                                                        sortedDocs[index].get(
                                                            "plant_image_url")),
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
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    jsonDecode(sortedDocs[index]
                                                            .get(
                                                                "botanical_name"))
                                                        .map((data) =>
                                                            data[0]
                                                                .toUpperCase() +
                                                            data
                                                                .toString()
                                                                .substring(1))
                                                        .toList()
                                                        .join(", "),
                                                    style: GoogleFonts.openSans(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 18,
                                                      color: AppColors.black,
                                                    ),
                                                  ),
                                                  Text(
                                                    jsonDecode(sortedDocs[index]
                                                            .get(
                                                                "common_names"))
                                                        .map((data) =>
                                                            data[0]
                                                                .toUpperCase() +
                                                            data
                                                                .toString()
                                                                .substring(1))
                                                        .toList()
                                                        .join(", "),
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
                                      ),
                                    );
                                  } else if ((sortedDocs[index]
                                              .data()["botanical_name"]
                                              .toLowerCase()
                                              .contains(searchController
                                                  .value.text
                                                  .toLowerCase()) ||
                                          sortedDocs[index]
                                              .data()["common_names"]
                                              .toLowerCase()
                                              .contains(searchController
                                                  .value.text
                                                  .toLowerCase()) ||
                                          sortedDocs[index]
                                              .data()["plant_type"]
                                              .toLowerCase()
                                              .contains(searchController
                                                  .value.text
                                                  .toLowerCase())) &&
                                      searchController.text != "") {
                                    Map<String, dynamic> test = {
                                      "sdfsf": "dsfsdf"
                                    };
                                    return GestureDetector(
                                      onTap: () {
                                        _showModalBottomSheet(
                                            context,
                                            sortedDocs[index],
                                            widget.planterDetails);
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: AppColors.white,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        height: 105.0,
                                        padding: const EdgeInsets.all(10),
                                        margin: const EdgeInsets.only(
                                            bottom: 10, top: 10),
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
                                                        sortedDocs[index].get(
                                                            "plant_image_url")),
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
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    jsonDecode(sortedDocs[index]
                                                            .get(
                                                                "botanical_name"))
                                                        .map((data) =>
                                                            data[0]
                                                                .toUpperCase() +
                                                            data
                                                                .toString()
                                                                .substring(1))
                                                        .toList()
                                                        .join(", "),
                                                    style: GoogleFonts.openSans(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 18,
                                                      color: AppColors.black,
                                                    ),
                                                  ),
                                                  Text(
                                                    jsonDecode(sortedDocs[index]
                                                            .get(
                                                                "common_names"))
                                                        .map((data) =>
                                                            data[0]
                                                                .toUpperCase() +
                                                            data
                                                                .toString()
                                                                .substring(1))
                                                        .toList()
                                                        .join(", "),
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
                                      ),
                                    );
                                  } else {
                                    return Container();
                                  }
                                });
                          } else {
                            return CustomLoadingScreen();
                          }
                        },
                      ))
                  : Container(
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      height: size.height - (size.height * 0.37),
                      child: ListView.builder(
                          itemCount: filteredRecords.length,
                          scrollDirection: Axis.vertical,
                          physics: const BouncingScrollPhysics(),
                          itemBuilder: (BuildContext context, int index) {
                            Map<String, dynamic> test = {"sdfsf": "dsfsdf"};

                            return GestureDetector(
                                onTap: () {
                                  _showModalBottomSheet(
                                      context,
                                      filteredRecords[index],
                                      widget.planterDetails);
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.white,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  height: 105.0,
                                  padding: const EdgeInsets.all(10),
                                  margin: const EdgeInsets.only(
                                      bottom: 10, top: 10),
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
                                                  filteredRecords[index]
                                                      .get("plant_image_url")),
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
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              jsonDecode(filteredRecords[index]
                                                      .get("botanical_name"))
                                                  .map((data) =>
                                                      data[0].toUpperCase() +
                                                      data
                                                          .toString()
                                                          .substring(1))
                                                  .toList()
                                                  .join(", "),
                                              style: GoogleFonts.openSans(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                                color: AppColors.black,
                                              ),
                                            ),
                                            Text(
                                              jsonDecode(filteredRecords[index]
                                                      .get("common_names"))
                                                  .map((data) =>
                                                      data[0].toUpperCase() +
                                                      data
                                                          .toString()
                                                          .substring(1))
                                                  .toList()
                                                  .join(", "),
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
                          })),
            ],
          )),
    );
  }
}
