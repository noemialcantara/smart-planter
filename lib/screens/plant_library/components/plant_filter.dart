import 'dart:collection';

import 'package:async_task/async_task_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:hortijoy_mobile_app/resources/colors.dart';
import 'package:hortijoy_mobile_app/resources/measurements.dart';
import 'package:hortijoy_mobile_app/models/plants.dart';
import 'package:hortijoy_mobile_app/resources/my_button.dart';
import 'package:hortijoy_mobile_app/screens/add_device_options/add_device_options.dart';
import 'package:hortijoy_mobile_app/screens/home/components/body.dart';
import 'package:hortijoy_mobile_app/screens/home/components/detail_page.dart';
import 'package:hortijoy_mobile_app/screens/home/components/plant_widget.dart';
import 'package:hortijoy_mobile_app/screens/add_device_bluetooth/add_device_bluetooth.dart';
import 'package:hortijoy_mobile_app/screens/home/home_page_body.dart';
import 'package:hortijoy_mobile_app/screens/menu/main_menu.dart';
import 'package:hortijoy_mobile_app/screens/plant_library/components/filter_savedlist.dart';
import 'package:hortijoy_mobile_app/screens/plant_library/components/light_sensor_planter_list.dart';
import 'package:hortijoy_mobile_app/screens/plant_library/components/plant_library_body.dart';
import 'package:hortijoy_mobile_app/screens/plant_library/components/plant_library_card_widget.dart';
import 'package:hortijoy_mobile_app/screens/plant_library/plant_library_main.dart';
import 'package:hortijoy_mobile_app/screens/planters/planter_list.dart';
import 'package:hortijoy_mobile_app/screens/shops/shops.dart';
import 'package:page_transition/page_transition.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PlantFilter extends StatefulWidget {
  const PlantFilter({super.key});

  @override
  State<PlantFilter> createState() => _PlantFilterState();
}

String _filterCountText = "Show Results";
List<String> selectedValueList = [];
List<DocumentSnapshot> listOfSearchedData = [];

List<String> filterCategoryList = [];
List<String> waterNeededList = [];
List<String> indoorLightList = [];
List<String> categoryList = [];
List<String> finalList = [];
bool isLightSensorChosen = false;

List<Color> listButtonColor = <Color>[
  Color(0xFFEBEDEB),
  Color(0xFFEBEDEB),
  Color(0xFFEBEDEB),
  Color(0xFFEBEDEB),
  Color(0xFFEBEDEB),
  Color(0xFFEBEDEB),
  Color(0xFFEBEDEB),
  Color(0xFFEBEDEB),
  Color(0xFFEBEDEB),
  Color(0xFFEBEDEB),
  Color(0xFFEBEDEB),
  Color(0xFFEBEDEB),
  Color(0xFFEBEDEB),
  Color(0xFFEBEDEB),
  Color(0xFFEBEDEB),
  Color(0xFFEBEDEB),
]; // Initial color
List<Color> listButtonTextColor = <Color>[
  AppColors.black,
  AppColors.black,
  AppColors.black,
  AppColors.black,
  AppColors.black,
  AppColors.black,
  AppColors.black,
  AppColors.black,
  AppColors.black,
  AppColors.black,
  AppColors.black,
  AppColors.black,
  AppColors.black,
  AppColors.black,
  AppColors.black,
  AppColors.black
];

class _PlantFilterState extends State<PlantFilter> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Scaffold(
        backgroundColor: AppColors.white,
        appBar: AppBar(
          backgroundColor: AppColors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          elevation: 0,
          title: Text(
            'Filters',
            textAlign: TextAlign.center,
            style: GoogleFonts.openSans(
                fontSize: 20.0,
                fontWeight: FontWeight.w600,
                color: AppColors.black),
          ),
          actions: [],
          centerTitle: true,
        ),
        body: SafeArea(
          child: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(),
            child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                            padding:
                                EdgeInsetsDirectional.fromSTEB(15, 0, 20, 0),
                            child: Row(children: [
                              Icon(Icons.bookmark_outline, color: Colors.black),
                              SizedBox(width: 10),
                              Text(
                                'Saved Lists',
                                style: GoogleFonts.openSans(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              )
                            ])),
                        IconButton(
                          icon: const Icon(
                            Icons.keyboard_arrow_right,
                            size: 30,
                          ),
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SavedList(
                                    cameFromSelectCareProfile: false,
                                    planterDetails: null,
                                    isSwitching: false,
                                  ),
                                ));
                          },
                        ),
                      ],
                    ),
                    const Divider(
                      thickness: 2,
                      color: Colors.black12,
                    ),
                    Container(
                      padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                      width: double.infinity,
                      height: 200,
                      decoration: const BoxDecoration(),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Care Profile',
                            style: GoogleFonts.openSans(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Water Needed',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          SizedBox(height: 10),
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              GestureDetector(
                                  onTap: () {
                                    changeColor(0, "Water Needed", "high");
                                  },
                                  child: Align(
                                    alignment: const AlignmentDirectional(0, 0),
                                    child: Container(
                                      width: 60,
                                      height: 30,
                                      decoration: BoxDecoration(
                                        color: listButtonColor[0],
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      alignment:
                                          const AlignmentDirectional(0, 0),
                                      child: Text(
                                        'High',
                                        textAlign: TextAlign.center,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                                color: listButtonTextColor[0]),
                                      ),
                                    ),
                                  )),
                              SizedBox(width: 10),
                              GestureDetector(
                                  onTap: () {
                                    changeColor(1, "Water Needed", "medium");
                                  },
                                  child: Align(
                                    alignment: const AlignmentDirectional(0, 0),
                                    child: Container(
                                      width: 80,
                                      height: 30,
                                      decoration: BoxDecoration(
                                        color: listButtonColor[1],
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      alignment:
                                          const AlignmentDirectional(0, 0),
                                      child: Align(
                                        alignment:
                                            const AlignmentDirectional(0, 0),
                                        child: Text(
                                          'Medium',
                                          textAlign: TextAlign.center,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                  color:
                                                      listButtonTextColor[1]),
                                        ),
                                      ),
                                    ),
                                  )),
                              SizedBox(width: 10),
                              GestureDetector(
                                  onTap: () {
                                    changeColor(2, "Water Needed", "low");
                                  },
                                  child: Align(
                                    alignment: const AlignmentDirectional(0, 0),
                                    child: Container(
                                      width: 50,
                                      height: 30,
                                      decoration: BoxDecoration(
                                        color: listButtonColor[2],
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      alignment:
                                          const AlignmentDirectional(0, 0),
                                      child: Text(
                                        'Low',
                                        textAlign: TextAlign.center,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                                color: listButtonTextColor[2]),
                                      ),
                                    ),
                                  )),
                            ],
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Indoor Light',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          SizedBox(height: 10),
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              GestureDetector(
                                  onTap: () {
                                    changeColor(3, "Indoor Light", "bright");
                                  },
                                  child: Align(
                                    alignment: const AlignmentDirectional(0, 0),
                                    child: Container(
                                      width: 60,
                                      height: 30,
                                      decoration: BoxDecoration(
                                        color: listButtonColor[3],
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      alignment:
                                          const AlignmentDirectional(0, 0),
                                      child: Text(
                                        'Bright',
                                        textAlign: TextAlign.center,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                                color: listButtonTextColor[3]),
                                      ),
                                    ),
                                  )),
                              SizedBox(width: 10),
                              GestureDetector(
                                  onTap: () {
                                    changeColor(4, "Indoor Light", "medium");
                                  },
                                  child: Align(
                                    alignment: const AlignmentDirectional(0, 0),
                                    child: Container(
                                      width: 80,
                                      height: 30,
                                      decoration: BoxDecoration(
                                        color: listButtonColor[4],
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      alignment:
                                          const AlignmentDirectional(0, 0),
                                      child: Align(
                                        alignment:
                                            const AlignmentDirectional(0, 0),
                                        child: Text(
                                          'Medium',
                                          textAlign: TextAlign.center,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                  color:
                                                      listButtonTextColor[4]),
                                        ),
                                      ),
                                    ),
                                  )),
                              SizedBox(width: 10),
                              GestureDetector(
                                  onTap: () {
                                    changeColor(5, "Indoor Light", "low");
                                  },
                                  child: Align(
                                    alignment: const AlignmentDirectional(0, 0),
                                    child: Container(
                                      width: 50,
                                      height: 30,
                                      decoration: BoxDecoration(
                                        color: listButtonColor[5],
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      alignment:
                                          const AlignmentDirectional(0, 0),
                                      child: Text(
                                        'Low',
                                        textAlign: TextAlign.center,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                                color: listButtonTextColor[5]),
                                      ),
                                    ),
                                  )),
                              SizedBox(width: 10),
                              GestureDetector(
                                  onTap: () {
                                    changeColor(
                                        6, "Indoor Light", "light sensor");
                                  },
                                  child: Align(
                                    alignment: const AlignmentDirectional(0, 0),
                                    child: Container(
                                      width: 110,
                                      height: 30,
                                      decoration: BoxDecoration(
                                        color: listButtonColor[6],
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      alignment:
                                          const AlignmentDirectional(0, 0),
                                      child: Text(
                                        'Light Sensor',
                                        textAlign: TextAlign.center,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                                color: listButtonTextColor[6]),
                                      ),
                                    ),
                                  )),
                              SizedBox(width: 10),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Divider(thickness: 2, color: Colors.black12),
                    Container(
                      padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
                      width: double.infinity,
                      height: 180,
                      decoration: const BoxDecoration(),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Category',
                            style: GoogleFonts.openSans(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          Expanded(
                            child: Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    0, 12, 0, 12),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    GestureDetector(
                                        onTap: () {
                                          changeColor(
                                              7, "Category", "air cleaner");
                                        },
                                        child: Align(
                                          alignment:
                                              const AlignmentDirectional(0, 0),
                                          child: Container(
                                            width: 100,
                                            height: 30,
                                            decoration: BoxDecoration(
                                              color: listButtonColor[7],
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                            ),
                                            alignment:
                                                const AlignmentDirectional(
                                                    0, 0),
                                            child: Text(
                                              'Air Cleaner',
                                              textAlign: TextAlign.center,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium
                                                  ?.copyWith(
                                                      color:
                                                          listButtonTextColor[
                                                              7]),
                                            ),
                                          ),
                                        )),
                                    SizedBox(width: 10),
                                    GestureDetector(
                                        onTap: () {
                                          changeColor(
                                              8, "Category", "perennial");
                                        },
                                        child: Align(
                                          alignment:
                                              const AlignmentDirectional(0, 0),
                                          child: Container(
                                            width: 100,
                                            height: 30,
                                            decoration: BoxDecoration(
                                              color: listButtonColor[8],
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                            ),
                                            alignment:
                                                const AlignmentDirectional(
                                                    0, 0),
                                            child: Align(
                                              alignment:
                                                  const AlignmentDirectional(
                                                      0, 0),
                                              child: Text(
                                                'Perennials',
                                                textAlign: TextAlign.center,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium
                                                    ?.copyWith(
                                                        color:
                                                            listButtonTextColor[
                                                                8]),
                                              ),
                                            ),
                                          ),
                                        )),
                                    SizedBox(width: 10),
                                    GestureDetector(
                                        onTap: () {
                                          changeColor(
                                              9, "Category", "evergreen");
                                        },
                                        child: Align(
                                          alignment:
                                              const AlignmentDirectional(0, 0),
                                          child: Container(
                                            width: 100,
                                            height: 30,
                                            decoration: BoxDecoration(
                                              color: listButtonColor[9],
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                            ),
                                            alignment:
                                                const AlignmentDirectional(
                                                    0, 0),
                                            child: Text(
                                              'Evergreen',
                                              textAlign: TextAlign.center,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium
                                                  ?.copyWith(
                                                      color:
                                                          listButtonTextColor[
                                                              9]),
                                            ),
                                          ),
                                        )),
                                    // SizedBox(width: 10),
                                  ],
                                )),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(width: 10),
                              GestureDetector(
                                  onTap: () {
                                    changeColor(10, "Category", "vine");
                                  },
                                  child: Align(
                                    alignment: const AlignmentDirectional(0, 0),
                                    child: Container(
                                      width: 50,
                                      height: 30,
                                      decoration: BoxDecoration(
                                        color: listButtonColor[10],
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      alignment:
                                          const AlignmentDirectional(0, 0),
                                      child: Text(
                                        'Vine',
                                        textAlign: TextAlign.center,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                                color: listButtonTextColor[10]),
                                      ),
                                    ),
                                  )),
                              SizedBox(width: 10),
                              GestureDetector(
                                  onTap: () {
                                    changeColor(11, "Category", "palm");
                                  },
                                  child: Align(
                                    alignment: const AlignmentDirectional(0, 0),
                                    child: Container(
                                      width: 50,
                                      height: 30,
                                      decoration: BoxDecoration(
                                        color: listButtonColor[11],
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      alignment:
                                          const AlignmentDirectional(0, 0),
                                      child: Align(
                                        alignment:
                                            const AlignmentDirectional(0, 0),
                                        child: Text(
                                          'Palm',
                                          textAlign: TextAlign.center,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                  color:
                                                      listButtonTextColor[11]),
                                        ),
                                      ),
                                    ),
                                  )),
                              SizedBox(width: 10),
                              GestureDetector(
                                  onTap: () {
                                    changeColor(12, "Category", "succulent");
                                  },
                                  child: Align(
                                    alignment: const AlignmentDirectional(0, 0),
                                    child: Container(
                                      width: 90,
                                      height: 30,
                                      decoration: BoxDecoration(
                                        color: listButtonColor[12],
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      alignment:
                                          const AlignmentDirectional(0, 0),
                                      child: Text(
                                        'Succulent',
                                        textAlign: TextAlign.center,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                                color: listButtonTextColor[12]),
                                      ),
                                    ),
                                  )),
                              SizedBox(width: 10),
                              GestureDetector(
                                  onTap: () {
                                    changeColor(13, "Category", "cactus");
                                  },
                                  child: Align(
                                    alignment: const AlignmentDirectional(0, 0),
                                    child: Container(
                                      width: 70,
                                      height: 30,
                                      decoration: BoxDecoration(
                                        color: listButtonColor[13],
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      alignment:
                                          const AlignmentDirectional(0, 0),
                                      child: Text(
                                        'Cactus',
                                        textAlign: TextAlign.center,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                                color: listButtonTextColor[13]),
                                      ),
                                    ),
                                  )),
                              // SizedBox(width: 10),
                            ],
                          ),
                          SizedBox(height: 10),
                          Row(
                              mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(width: 10),
                                GestureDetector(
                                    onTap: () {
                                      changeColor(14, "Category", "tree");
                                    },
                                    child: Align(
                                      alignment:
                                          const AlignmentDirectional(0, 0),
                                      child: Container(
                                        width: 70,
                                        height: 30,
                                        decoration: BoxDecoration(
                                          color: listButtonColor[14],
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ),
                                        alignment:
                                            const AlignmentDirectional(0, 0),
                                        child: Text(
                                          'Tree',
                                          textAlign: TextAlign.center,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                  color:
                                                      listButtonTextColor[14]),
                                        ),
                                      ),
                                    )),
                                SizedBox(width: 10),
                                GestureDetector(
                                    onTap: () {
                                      changeColor(15, "Category", "fern");
                                    },
                                    child: Align(
                                      alignment:
                                          const AlignmentDirectional(0, 0),
                                      child: Container(
                                        width: 50,
                                        height: 30,
                                        decoration: BoxDecoration(
                                          color: listButtonColor[15],
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ),
                                        alignment:
                                            const AlignmentDirectional(0, 0),
                                        child: Text(
                                          'Fern',
                                          textAlign: TextAlign.center,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                  color:
                                                      listButtonTextColor[15]),
                                        ),
                                      ),
                                    )),
                              ]),
                          SizedBox(height: 10),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(top: 30),
                      child: CustomOutlinedButton(
                        customColor: AppColors.white,
                        backgroundColor: AppColors.primaryColor,
                        onPressed: () {
                          if (isLightSensorChosen) {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => LightSensorPlanterList(
                                    selectedFilters: selectedValueList,
                                  ),
                                ));
                          } else {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PlantLibraryBody(
                                    selectedFilters: selectedValueList,
                                  ),
                                ));
                          }
                        },
                        buttonText: _filterCountText,
                      ),
                      margin: EdgeInsets.only(left: 20, right: 20),
                    ),
                    SizedBox(height: 15),
                    Container(
                      child: CustomOutlinedButton(
                        customColor: AppColors.primaryColor,
                        onPressed: () {
                          setState(() {
                            listOfSearchedData.clear();
                            listOfSearchedData = [];
                            selectedValueList = [];
                            isLightSensorChosen = false;
                            _filterCountText = "Show 0 Results";
                            listButtonColor = [
                              Color(0xFFEBEDEB),
                              Color(0xFFEBEDEB),
                              Color(0xFFEBEDEB),
                              Color(0xFFEBEDEB),
                              Color(0xFFEBEDEB),
                              Color(0xFFEBEDEB),
                              Color(0xFFEBEDEB),
                              Color(0xFFEBEDEB),
                              Color(0xFFEBEDEB),
                              Color(0xFFEBEDEB),
                              Color(0xFFEBEDEB),
                              Color(0xFFEBEDEB),
                              Color(0xFFEBEDEB),
                              Color(0xFFEBEDEB),
                              Color(0xFFEBEDEB),
                              Color(0xFFEBEDEB)
                            ];

                            listButtonTextColor = <Color>[
                              AppColors.black,
                              AppColors.black,
                              AppColors.black,
                              AppColors.black,
                              AppColors.black,
                              AppColors.black,
                              AppColors.black,
                              AppColors.black,
                              AppColors.black,
                              AppColors.black,
                              AppColors.black,
                              AppColors.black,
                              AppColors.black,
                              AppColors.black,
                              AppColors.black,
                              AppColors.black
                            ];
                          });
                        },
                        buttonText: 'Reset All',
                      ),
                      margin: EdgeInsets.only(left: 20, right: 20),
                    ),
                  ],
                )),
          ),
        ),
      ),
    );
  }

  void filterList() async {
    //bool hasLightSensor = false;
    Query contents =
        FirebaseFirestore.instance.collection('plant_library_test_first');

    int waterCount = 0;
    List<String> waterFilters = [];
    int lightCount = 0;
    List<String> lightFilters = [];
    int categoryCount = 0;
    List<String> categoryFilters = [];
    bool hasAirCleaner = false;
    int filterDiffCount = 0;

    selectedValueList.forEach((element) async {
      if (element.contains("standard_water_profile_status")) {
        if (waterCount == 0) filterDiffCount++;
        waterCount++;
        waterFilters.add(element.split("-")[1]);
      }

      if (element.contains("standard_light_intensity")) {
        if (lightCount == 0) filterDiffCount++;
        lightCount++;
        lightFilters.add(element.split("-")[1]);

        if (element.split("-")[1] == "light sensor") {
          setState(() {
            isLightSensorChosen = true;
          });
        }
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

    await contents
        .where(Filter.and(filterCategory, filterHasAirCleaner))
        .snapshots()
        .forEach((element) async {
      int recordsLength = 0;
      List<String> filteredRecords = [];

      element.docs.every(
        (element) {
          var recordId = element.id;
          int filterMatchCounter = 0;

          for (int i = 0; i < waterCount; i++) {
            if (waterFilters[i] ==
                element.get("standard_water_profile_status").toString()) {
              filterMatchCounter++;
              break;
            }
          }

          for (int j = 0; j < lightCount; j++) {
            if (lightFilters[j] == "light sensor" && lightCount == 1) {
              filterMatchCounter++;
            } else if (lightFilters[j] ==
                element.get("standard_light_intensity").toString()) {
              filterMatchCounter++;
              break;
            }
          }

          if (categoryCount > 0) {
            filterMatchCounter++;
          }

          if (filterDiffCount == filterMatchCounter) {
            setState(() {
              recordsLength++;
              filteredRecords.add(recordId);
            });
          }

          return true;
        },
      );

      setState(() {
        _filterCountText = "Show $recordsLength Results";
      });
    });
  }

  changeColor(int index, String filterCategory, String filterData) {
    finalList = [];
    waterNeededList = [];
    indoorLightList = [];
    setState(() {
      print("FILTER CATEGORY: $filterCategory AND FILTER DATA: $filterData");

      if (filterCategory == "Water Needed") {
        filterCategory = "standard_water_profile_status";
      } else if (filterCategory == "Indoor Light") {
        filterCategory = "standard_light_intensity";
      } else if (filterCategory == "Category") {
        filterCategory = "category";
      }

      if (listButtonColor[index] == Color(0xFFEBEDEB)) {
        listButtonColor[index] = AppColors.primaryColor;
        listButtonTextColor[index] = AppColors.white;
        selectedValueList.add(filterCategory + "-" + filterData);

        if (!filterCategoryList.contains(filterCategory))
          filterCategoryList.add(filterCategory);
      } else {
        listButtonColor[index] = Color(0xFFEBEDEB);
        listButtonTextColor[index] = AppColors.black;

        if (filterData == "light sensor")
          selectedValueList.removeWhere((element) {
            bool isMatch = false;
            print("ELEMENT IS ${element}");
            if (element == "standard_light_intensity-light sensor" ||
                element.contains("light_sensor-")) {
              setState(() {
                isMatch = true;
                isLightSensorChosen = false;
              });
            }

            return isMatch;
          });

        selectedValueList.remove(filterCategory + "-" + filterData);
        filterCategoryList.remove(filterCategory);

        // if (filterCategory.contains("light_sensor") ||
        //     filterData.contains("light")) {
        //   selectedValueList.removeWhere((element) => element.contains("light"));
        //   setState(() {
        //     isLightSensorChosen = false;
        //   });
        // }
      }
    });

    print("SELECTED CATEGORY LIST: ${selectedValueList.toString()}");
    listOfSearchedData.clear();

    filterList();

    if (selectedValueList.isEmpty) {
      _filterCountText = "Show 0 Results";
    }
  }
}
