import 'dart:async';
import 'dart:convert';

import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:hortijoy_mobile_app/custom_widgets/custom_outlined_button.dart';
import 'package:hortijoy_mobile_app/main.dart';
import 'package:hortijoy_mobile_app/resources/colors.dart';
import 'package:hortijoy_mobile_app/resources/custom_button.dart';
import 'package:hortijoy_mobile_app/resources/my_textfield.dart';
import 'package:hortijoy_mobile_app/resources/measurements.dart';
import 'package:hortijoy_mobile_app/models/plants.dart';
import 'package:hortijoy_mobile_app/models/plant_devices.dart';
import 'package:hortijoy_mobile_app/resources/my_button.dart';
import 'package:hortijoy_mobile_app/resources/my_textfield.dart';
import 'package:hortijoy_mobile_app/resources/widget_properties.dart';
import 'package:hortijoy_mobile_app/screens/add_device_options/add_device_options.dart';
import 'package:hortijoy_mobile_app/screens/discover/care_profile.dart';
import 'package:hortijoy_mobile_app/screens/home/components/body.dart';
import 'package:hortijoy_mobile_app/screens/home/components/detail_page.dart';
import 'package:hortijoy_mobile_app/screens/plant_library/components/chips_list.dart';
import 'package:hortijoy_mobile_app/screens/home/components/plant_widget.dart';
import 'package:hortijoy_mobile_app/screens/add_device_bluetooth/add_device_bluetooth.dart';
import 'package:hortijoy_mobile_app/screens/home/home_page_body.dart';
import 'package:hortijoy_mobile_app/screens/menu/main_menu.dart';
import 'package:hortijoy_mobile_app/screens/plant_library/components/plant_filter.dart';
import 'package:hortijoy_mobile_app/screens/plant_library/components/plant_library_card_widget.dart';
import 'package:hortijoy_mobile_app/screens/plant_library/plant_library_main.dart';
import 'package:hortijoy_mobile_app/screens/planter/planter_plant_description.dart';
import 'package:hortijoy_mobile_app/screens/planters/planter_list.dart';
import 'package:hortijoy_mobile_app/screens/shops/shops.dart';
import 'package:page_transition/page_transition.dart';
import 'package:hortijoy_mobile_app/screens/notifications/components/notification_body.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PlantLibraryBody extends StatefulWidget {
  List<String> selectedFilters;
  PlantLibraryBody({super.key, required this.selectedFilters});

  @override
  State<PlantLibraryBody> createState() => _PlantLibraryBodyState();
}

class _PlantLibraryBodyState extends State<PlantLibraryBody> {
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

  late StreamSubscription<QuerySnapshot> _notificationSubscription;
  int _unreadCount = 0;

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

    _listenToNotifications();
  }

  void _listenToNotifications() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _notificationSubscription = FirebaseFirestore.instance
          .collection('notifications')
          .where("email", isEqualTo: user.email)
          .where("is_read", isEqualTo: false)
          .snapshots()
          .listen((snapshot) {
        setState(() {
          _unreadCount = snapshot.docs.length;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String searchKeyword = "";
    int selectedIndex = 1;
    Size size = MediaQuery.of(context).size;

    //List of the pages icons
    List<IconData> iconList = [
      Icons.dashboard_outlined,
      Icons.energy_savings_leaf_outlined,
      Icons.library_books_outlined,
      Icons.person_2_outlined,
    ];

    return SafeArea(
        child: Scaffold(
            backgroundColor: AppColors.white,
            bottomNavigationBar: BottomNavigationBar(
                onTap: (index) {
                  setState(() => selectedIndex = index);

                  if (selectedIndex == 0) {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HomeScreenBody(),
                        ));
                  } else if (selectedIndex == 1) {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PlantLibraryMain(),
                        ));
                  } else if (selectedIndex == 2) {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PlanterList(),
                        ));
                  }
                  // else if (selectedIndex == 3) {
                  //   Navigator.push(
                  //       context,
                  //       MaterialPageRoute(
                  //         builder: (context) => const Shops(),
                  //       ));
                  // }
                  else if (selectedIndex == 3) {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NotificationBody(
                            selectedFilters: [],
                          ),
                        ));
                  }
                },
                items: <BottomNavigationBarItem>[
                  const BottomNavigationBarItem(
                      icon: ImageIcon(
                        AssetImage("assets/icons/home.png"),
                      ),
                      backgroundColor: AppColors.white,
                      label: "Home"),
                  BottomNavigationBarItem(
                      icon: SvgPicture.asset(
                        "assets/icons/discover_outlined.svg",
                      ),
                      backgroundColor: Colors.white,
                      label: "Discover"),
                  BottomNavigationBarItem(
                    icon: SvgPicture.asset(
                      "assets/icons/planter_outlined.svg",
                    ),
                    label: "Planters",
                    backgroundColor: Colors.white,
                  ),
                  // const BottomNavigationBarItem(
                  //     icon: ImageIcon(
                  //       AssetImage("assets/icons/shop.png"),
                  //     ),
                  //     backgroundColor: Colors.white,
                  //     label: "Shop"),
                  BottomNavigationBarItem(
                    icon: Stack(
                      children: [
                        ImageIcon(
                          AssetImage("assets/icons/notification_filled.png"),
                        ),
                        if (_unreadCount >
                            0) // Only show the badge if there are unread notifications
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              padding: const EdgeInsets.all(1),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 12,
                                minHeight: 12,
                              ),
                              child: Text(
                                _unreadCount.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          )
                      ],
                    ),
                    label: "Notifications",
                    backgroundColor: Colors.white,
                  ),
                ],
                type: BottomNavigationBarType.fixed,
                currentIndex: selectedIndex,
                selectedItemColor: AppColors.primaryColor,
                iconSize: 25,
                elevation: 5),
            body: TextDisplayDiscover(
                context, searchController, size, searchKeyword)));
  }

  SingleChildScrollView TextDisplayDiscover(BuildContext context,
      TextEditingController searchController, Size size, String searchKeyword) {
    return SingleChildScrollView(
      child: Padding(
          padding: const EdgeInsets.only(left: 0, right: 0, bottom: 5, top: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                  padding: EdgeInsets.only(left: 20, top: 10, right: 20),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Discover",
                          style: GoogleFonts.openSans(
                              fontSize: 25.0, fontWeight: FontWeight.w600),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AddDeviceOptions(),
                                ));
                          },
                          child: IconButton(
                            icon: SvgPicture.asset(
                              "assets/icons/filter.svg",
                              color: Colors.black,
                            ),
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const PlantFilter(),
                                  ));
                            },
                          ),
                        )
                      ])),
              Container(
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
                                      saveList(context);
                                    },
                                    child: Text(
                                      "Save List",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 16),
                                    )),
                                SizedBox(
                                  width: 10,
                                ),
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
                            // Extract and sort the documents by the first element of the 'botanical_name' array
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

                                if (searchController.text.isEmpty) {
                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              PlantDescriptions(
                                            planterDetails: snapshot.data,
                                          ),
                                        ),
                                      );
                                    },
                                    child: PlantLibraryCardWidget(
                                      index: index,
                                      isOptionsAvailable: false,
                                      plantListDataForBottomSheet: {
                                        "sdfsf": "dsfsdf"
                                      },
                                      planterDetails: snapshot.data,
                                      plantList: sortedDocs
                                          .map((e) => Plant(
                                                botanicalName: jsonDecode(
                                                        e.get("botanical_name"))
                                                    .map((data) =>
                                                        data[0].toUpperCase() +
                                                        data
                                                            .toString()
                                                            .substring(1))
                                                    .toList()
                                                    .join(", "),
                                                commonNames: jsonDecode(
                                                        e.get("common_names"))
                                                    .map((data) =>
                                                        data[0].toUpperCase() +
                                                        data
                                                            .toString()
                                                            .substring(1))
                                                    .toList()
                                                    .join(", "),
                                                fertilizerFrequency: e
                                                    .get("fertilizer_frequency")
                                                    .toString(),
                                                fertilizerSeason: e
                                                    .get("fertilizer_season")
                                                    .toString(),
                                                fertilizerStrength: e
                                                    .get("fertilizer_strength")
                                                    .toString(),
                                                hasAirCleaner: e
                                                    .get("has_air_cleaner")
                                                    .toString(),
                                                lightIntensityDark: e
                                                    .get("light_intensity_dark")
                                                    .toString(),
                                                lightIntensityIdeal: e
                                                    .get(
                                                        "light_intensity_ideal")
                                                    .toString(),
                                                lightIntensitySufficient: e
                                                    .get(
                                                        "light_intensity_sufficient")
                                                    .toString(),
                                                lightIntensityTooSunny: e
                                                    .get(
                                                        "light_intensity_too_sunny")
                                                    .toString(),
                                                plantImageUrl: e
                                                    .get("plant_image_url")
                                                    .toString(),
                                                plantType: jsonDecode(
                                                        e.get("plant_type"))
                                                    .map((data) =>
                                                        data[0].toUpperCase() +
                                                        data
                                                            .toString()
                                                            .substring(1))
                                                    .toList()
                                                    .join(", "),
                                                standardLightIntensity: e
                                                    .get(
                                                        "standard_light_intensity")
                                                    .toString(),
                                                standardWaterProfileStatus: e
                                                    .get(
                                                        "standard_water_profile_status")
                                                    .toString(),
                                                waterStatus: e
                                                    .get("water_status")
                                                    .toString(),
                                                waterStatusPercentage: e
                                                    .get(
                                                        "water_status_percentage")
                                                    .toString(),
                                                wateringCareProfileInformation: e
                                                    .get(
                                                        "watering_care_profile_information")
                                                    .toString(),
                                                sunlightCareProfileInformation: e
                                                    .get(
                                                        "sunlight_care_profile_information")
                                                    .toString(),
                                              ))
                                          .toList(),
                                      isSwitching: false,
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
                                    searchController.text.isNotEmpty) {
                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              PlantDescriptions(
                                            planterDetails: snapshot.data,
                                          ),
                                        ),
                                      );
                                    },
                                    child: PlantLibraryCardWidget(
                                      index: index,
                                      isOptionsAvailable: false,
                                      plantListDataForBottomSheet: {
                                        "sdfsf": "dsfsdf"
                                      },
                                      planterDetails: snapshot.data,
                                      plantList: sortedDocs
                                          .map((e) => Plant(
                                                botanicalName: jsonDecode(
                                                        e.get("botanical_name"))
                                                    .map((data) =>
                                                        data[0].toUpperCase() +
                                                        data
                                                            .toString()
                                                            .substring(1))
                                                    .toList()
                                                    .join(", "),
                                                commonNames: jsonDecode(
                                                        e.get("common_names"))
                                                    .map((data) =>
                                                        data[0].toUpperCase() +
                                                        data
                                                            .toString()
                                                            .substring(1))
                                                    .toList()
                                                    .join(", "),
                                                fertilizerFrequency: e
                                                    .get("fertilizer_frequency")
                                                    .toString(),
                                                fertilizerSeason: e
                                                    .get("fertilizer_season")
                                                    .toString(),
                                                fertilizerStrength: e
                                                    .get("fertilizer_strength")
                                                    .toString(),
                                                hasAirCleaner: e
                                                    .get("has_air_cleaner")
                                                    .toString(),
                                                lightIntensityDark: e
                                                    .get("light_intensity_dark")
                                                    .toString(),
                                                lightIntensityIdeal: e
                                                    .get(
                                                        "light_intensity_ideal")
                                                    .toString(),
                                                lightIntensitySufficient: e
                                                    .get(
                                                        "light_intensity_sufficient")
                                                    .toString(),
                                                lightIntensityTooSunny: e
                                                    .get(
                                                        "light_intensity_too_sunny")
                                                    .toString(),
                                                plantImageUrl: e
                                                    .get("plant_image_url")
                                                    .toString(),
                                                plantType: jsonDecode(
                                                        e.get("plant_type"))
                                                    .map((data) =>
                                                        data[0].toUpperCase() +
                                                        data
                                                            .toString()
                                                            .substring(1))
                                                    .toList()
                                                    .join(", "),
                                                standardLightIntensity: e
                                                    .get(
                                                        "standard_light_intensity")
                                                    .toString(),
                                                standardWaterProfileStatus: e
                                                    .get(
                                                        "standard_water_profile_status")
                                                    .toString(),
                                                waterStatus: e
                                                    .get("water_status")
                                                    .toString(),
                                                waterStatusPercentage: e
                                                    .get(
                                                        "water_status_percentage")
                                                    .toString(),
                                                wateringCareProfileInformation: e
                                                    .get(
                                                        "watering_care_profile_information")
                                                    .toString(),
                                                sunlightCareProfileInformation: e
                                                    .get(
                                                        "sunlight_care_profile_information")
                                                    .toString(),
                                              ))
                                          .toList(),
                                      isSwitching: false,
                                    ),
                                  );
                                } else {
                                  return Container();
                                }
                              },
                            );
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

                            return PlantLibraryCardWidget(
                              index: index,
                              isOptionsAvailable: false,
                              plantListDataForBottomSheet: test,
                              planterDetails: filteredRecords[index],
                              plantList: filteredRecords
                                  .map((e) => Plant(
                                        botanicalName:
                                            jsonDecode(e.get("botanical_name"))
                                                        .length >
                                                    0
                                                ? jsonDecode(
                                                        e.get("botanical_name"))
                                                    .map((data) =>
                                                        data[0].toUpperCase() +
                                                        data
                                                            .toString()
                                                            .substring(1))
                                                    .toList()
                                                    .join(", ")
                                                : "No botanical name",
                                        commonNames: jsonDecode(
                                                        e.get("common_names"))
                                                    .length >
                                                0
                                            ? jsonDecode(e.get("common_names"))
                                                .map((data) =>
                                                    data[0].toUpperCase() +
                                                    data
                                                        .toString()
                                                        .substring(1))
                                                .toList()
                                                .join(", ")
                                            : "No common name",
                                        fertilizerFrequency: e
                                            .get("fertilizer_frequency")
                                            .toString(),
                                        fertilizerSeason: e
                                            .get("fertilizer_season")
                                            .toString(),
                                        fertilizerStrength: e
                                            .get("fertilizer_strength")
                                            .toString(),
                                        hasAirCleaner:
                                            e.get("has_air_cleaner").toString(),
                                        lightIntensityDark: e
                                            .get("light_intensity_dark")
                                            .toString(),
                                        lightIntensityIdeal: e
                                            .get("light_intensity_ideal")
                                            .toString(),
                                        lightIntensitySufficient: e
                                            .get("light_intensity_sufficient")
                                            .toString(),
                                        lightIntensityTooSunny: e
                                            .get("light_intensity_too_sunny")
                                            .toString(),
                                        plantImageUrl:
                                            e.get("plant_image_url").toString(),
                                        plantType: jsonDecode(
                                                        e.get("plant_type"))
                                                    .length >
                                                0
                                            ? jsonDecode(e.get("plant_type"))
                                                .map((data) =>
                                                    data[0].toUpperCase() +
                                                    data
                                                        .toString()
                                                        .substring(1))
                                                .toList()
                                                .join(", ")
                                            : "No plant type",
                                        standardLightIntensity: e
                                            .get("standard_light_intensity")
                                            .toString(),
                                        standardWaterProfileStatus: e
                                            .get(
                                                "standard_water_profile_status")
                                            .toString(),
                                        waterStatus:
                                            e.get("water_status").toString(),
                                        waterStatusPercentage: e
                                            .get("water_status_percentage")
                                            .toString(),
                                        wateringCareProfileInformation: e
                                            .get(
                                                "watering_care_profile_information")
                                            .toString(),
                                        sunlightCareProfileInformation: e
                                            .get(
                                                "sunlight_care_profile_information")
                                            .toString(),
                                      ))
                                  .toList(),
                              isSwitching: false,
                            );
                          })),
            ],
          )),
    );
  }

  void saveList(context) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        builder: (BuildContext context) {
          return Padding(
            // padding: const EdgeInsets.all(8.0),
            padding: MediaQuery.of(context).viewInsets,
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom),
                // padding: const EdgeInsets.all(8.0),
                child: Container(
                  // padding: EdgeInsets.only(
                  //   bottom: MediaQuery.of(context).viewInsets.bottom,
                  // ),
                  margin: const EdgeInsets.only(left: 20.0, right: 5.0),
                  height: 250,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          margin: const EdgeInsets.all(8.0),
                          width: 50,
                          height: 7,
                          decoration: const BoxDecoration(
                              color: Colors.black45,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20.0))),
                        ),
                      ),
                      const SizedBox(
                        height: 20.0,
                      ),
                      Text("Choose a name for this list ",
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xff0b172e))),
                      MyTextField2(
                        hintText: 'List Name',
                        maxLine: 1,
                        obscureText: false,
                        controller: saveListController,
                      ),
                      const SizedBox(
                        height: 30.0,
                      ),
                      Align(
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Container(
                                  width: 187,
                                  height: 40,
                                  child: OutlinedButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    style: OutlinedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                        side: BorderSide(
                                          color: AppColors
                                              .primaryColor, //Color of the border
                                          style: BorderStyle
                                              .solid, //Style of the border
                                          width: 3, //width of the border
                                        ),
                                      ),
                                    ),
                                    child: Text(
                                      'Cancel',
                                      style: TextStyle(
                                        color: AppColors.primaryColor,
                                      ),
                                    ),
                                  )),
                              SizedBox(width: 8.0),
                              Container(
                                width: 187,
                                height: 40,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    if (!saveListController.text.isEmpty) {
                                      saveCategoryDataList();
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    primary: AppColors.primaryColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                  child: Text(
                                    'Save',
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ))
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }

  void saveCategoryDataList() async {
    await FirebaseFirestore.instance.collection("user_filter_saved_lists").add({
      "email": FirebaseAuth.instance.currentUser?.email.toString() ??
          "user@gmail.com",
      "category_list": jsonEncode(allCategory),
      "value_list": jsonEncode(allValue),
      "list_title": saveListController.text.toString(),
      "record_count": snapshotDataLength
    });
    AnimatedSnackBar.material(
      "Added successfully!",
      type: AnimatedSnackBarType.success,
      mobileSnackBarPosition:
          MobileSnackBarPosition.top, // Position of snackbar on mobile devices
      desktopSnackBarPosition: DesktopSnackBarPosition
          .topCenter, // Position of snackbar on desktop devices
    ).show(context);
    Navigator.pop(context);
  }
}
