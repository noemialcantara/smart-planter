import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hortijoy_mobile_app/resources/colors.dart';
import 'package:hortijoy_mobile_app/resources/measurements.dart';
import 'package:hortijoy_mobile_app/models/plants.dart';
import 'package:hortijoy_mobile_app/models/plant_devices.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:hortijoy_mobile_app/resources/my_button.dart';
import 'package:hortijoy_mobile_app/resources/widget_properties.dart';
import 'package:hortijoy_mobile_app/screens/add_device_options/add_device_options.dart';
import 'package:hortijoy_mobile_app/screens/home/components/detail_page.dart';
import 'package:hortijoy_mobile_app/screens/home/components/plant_widget.dart';
import 'package:hortijoy_mobile_app/screens/add_device_bluetooth/add_device_bluetooth.dart';
import 'package:hortijoy_mobile_app/screens/home/home_page_body.dart';
import 'package:hortijoy_mobile_app/screens/plant_library/components/plant_library_body.dart';
import 'package:hortijoy_mobile_app/screens/plant_library/plant_library_main.dart';
import 'package:hortijoy_mobile_app/screens/menu/main_menu.dart';
import 'package:hortijoy_mobile_app/screens/planters/components/detail_page%20copy.dart';
import 'package:hortijoy_mobile_app/screens/planters/planter_list.dart';
import 'package:hortijoy_mobile_app/screens/shops/shops.dart';
import 'package:page_transition/page_transition.dart';
import 'package:hortijoy_mobile_app/screens/notifications/components/notification_body.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'featured_plants.dart';
import 'header_with_seachbox.dart';
import 'recomend_plants.dart';
import 'title_with_more_bbtn.dart';

class PlantListBody extends StatefulWidget {
  const PlantListBody({super.key});

  @override
  State<PlantListBody> createState() => _PlantListBodyState();
}

class _PlantListBodyState extends State<PlantListBody> {
  String searchPlanter = '';
  List<DocumentSnapshot> listOfSearchedData = [];
  late StreamSubscription<QuerySnapshot> _notificationSubscription;
  int _unreadCount = 0;

  AppBar buildAppBar() {
    return AppBar(
        elevation: 0,
        title: Padding(
            padding: EdgeInsets.only(left: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Planters",
                  style: GoogleFonts.openSans(
                      color: AppColors.primaryColor,
                      fontSize: 23,
                      fontWeight: FontWeight.w600),
                ),
                GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddDeviceOptions(),
                          ));
                    },
                    child: Icon(
                      Icons.add,
                      color: AppColors.black,
                      size: 30.0,
                    ))
              ],
            )));
  }

  @override
  void initState() {
    super.initState();

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
    final searchController = TextEditingController().obs;
    int selectedIndex = 2;
    Size size = MediaQuery.of(context).size;

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
                  const BottomNavigationBarItem(
                      icon: ImageIcon(
                        AssetImage("assets/icons/discover.png"),
                      ),
                      backgroundColor: Colors.white,
                      label: "Discover"),
                  BottomNavigationBarItem(
                    icon: SvgPicture.asset(
                      "assets/icons/planter_filled.svg",
                      // color: Colors.black,
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
            body: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                    padding: EdgeInsets.only(left: 20, top: 20, right: 20),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Planters",
                            style: GoogleFonts.openSans(
                                fontSize: 24.0, fontWeight: FontWeight.w600),
                          ),
                          GestureDetector(
                              onTap: () {
                                _showAddDeviceOptions(context);
                              },
                              child: const Icon(
                                Icons.add,
                                color: AppColors.black,
                                size: 30.0,
                              ))
                        ])),
                const SizedBox(
                  height: 12,
                ),
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(
                          child: Container(
                              width: double.infinity,
                              height: 55,
                              child: TextField(
                                onChanged: onTextChanged,
                                onSubmitted: (value) {},
                                // controller: searchController.value,
                                decoration: InputDecoration(
                                  prefixIcon: Icon(Icons.search_outlined),
                                  prefixIconConstraints: const BoxConstraints(
                                    minWidth: 60,
                                    minHeight: 60,
                                  ),
                                  hintText: "Find your planter",
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
                searchPlanter == ''
                    ? _buildPlanterListDisplay(context, size)
                    : _buildSearchedPlanterListDisplay(context, size)
              ],
            )));
  }

  void _showAddDeviceOptions(BuildContext context) {
    showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.0), topRight: Radius.circular(20.0)),
        ),
        builder: (BuildContext bc) {
          return Wrap(
            children: <Widget>[
              Container(
                  child: Padding(
                padding: EdgeInsets.fromLTRB(25, 0, 25, 0),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    SizedBox(height: 10),
                    Image.asset("assets/icons/handle.png"),
                    SizedBox(height: 20),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddDeviceBluetooth(),
                            ));
                      },
                      child: SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            children: const [
                              Icon(Icons.bluetooth),
                              SizedBox(width: 10),
                              Text("Scan via Bluetooth")
                            ],
                          )),
                    ),
                    // GestureDetector(
                    //   onTap: () {
                    //     scanQR();
                    //   },
                    //   child: SizedBox(
                    //       width: double.infinity,
                    //       height: 50,
                    //       child: Row(
                    //         mainAxisSize: MainAxisSize.max,
                    //         children: const [
                    //           Icon(Icons.qr_code),
                    //           SizedBox(width: 10),
                    //           Text("Scan via QR Code")
                    //         ],
                    //       )),
                    // ),
                    SizedBox(height: 30)
                  ],
                ),
              ))
            ],
          );
        });
  }

  Future<void> scanQR() async {
    String barcodeScanRes;
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', false, ScanMode.QR);

      // await FirebaseFirestore.instance
      //     .collection("plant_devices")
      //     .where("uid", isEqualTo: barcodeScanRes)
      //     .get()
      //     .then((event) async {
      //   if (event.docs.isNotEmpty) {
      //     String imageURL = "${event.docs.first.get("image_url")}";
      //     String plantName = "${event.docs.first.get("plant_name")}";
      //     String description = "${event.docs.first.get("description")}";
      //     String maxMoistureLevel =
      //         "${event.docs.first.get("max_moisture_level")}";
      //     String minMoistureLevel =
      //         "${event.docs.first.get("min_moisture_level")}";
      //     String minSunlightHour =
      //         "${event.docs.first.get("min_sunlight_hour")}";
      //     String maxSunlightHour =
      //         "${event.docs.first.get("max_sunlight_hour")}";
      //     String speciesName = "${event.docs.first.get("species_name")}";
      //     String type = "${event.docs.first.get("type")}";
      //     String waterScaleWarningLevel =
      //         "${event.docs.first.get("water_scale_warning_level")}";
      //     await FirebaseFirestore.instance
      //         .collection("user_plant_devices")
      //         .add({
      //       "email": FirebaseAuth.instance.currentUser?.email.toString() ??
      //           "user@gmail.com",
      //       "description": description,
      //       "max_moisture_level": maxMoistureLevel,
      //       "max_sunlight_hour": maxSunlightHour,
      //       "min_moisture_level": minMoistureLevel,
      //       "min_sunlight_hour": minSunlightHour,
      //       "plant_name": plantName,
      //       "species_name": speciesName,
      //       "type": type,
      //       "uid": barcodeScanRes,
      //       "water_scale_warning_level": waterScaleWarningLevel,
      //       "image_url": imageURL
      //     });
      AwesomeDialog(
          context: context,
          dialogType: DialogType.success,
          animType: AnimType.rightSlide,
          title: 'Success!',
          desc: 'This planter device has been successfully added to your list',
          btnOkOnPress: () async {},
          btnOkColor: AppColors.primaryColor)
        ..show();
      // }
      // }).catchError((e) => print("error fetching data: $e"));
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }
    if (!mounted) return;
  }

  void onTextChanged(String value) {
    setState(() {
      searchPlanter = value.toString().toLowerCase();
    });

    getSearchedResults();
  }

  void getSearchedResults() {
    FirebaseFirestore.instance
        .collection('user_plant_devices')
        .where('email', isEqualTo: FirebaseAuth.instance.currentUser?.email)
        .get()
        .then((QuerySnapshot snapshot) {
      listOfSearchedData = snapshot.docs;
      setState(() {
        listOfSearchedData = listOfSearchedData.where((element) {
          String searchText = searchPlanter.toLowerCase();
          String planterName =
              element.data().toString().contains('planter_name')
                  ? element['planter_name'].toString().toLowerCase()
                  : '';
          String planterDeviceName =
              element.data().toString().contains('planter_device_name')
                  ? element['planter_device_name'].toString().toLowerCase()
                  : '';
          String plantName = element.data().toString().contains('plant_name')
              ? element['plant_name'].toString().toLowerCase()
              : '';
          String speciesName =
              element.data().toString().contains('species_name')
                  ? element['species_name'].toString().toLowerCase()
                  : '';
          String plantType = element.data().toString().contains('type')
              ? element['type'].toString().toLowerCase()
              : '';
          String description = element.data().toString().contains('description')
              ? element['description'].toString().toLowerCase()
              : '';

          return planterName.contains(searchText) ||
              planterDeviceName.contains(searchText) ||
              plantName.contains(searchText) ||
              speciesName.contains(searchText) ||
              plantType.contains(searchText) ||
              description.contains(searchText);
        }).toList();
      });
    }).catchError((error) {});
  }

  _buildSearchedPlanterListDisplay(BuildContext context, size) {
    if (listOfSearchedData.isEmpty) {
      return Container(
        child: const Center(
          child: Text(
            'Item not found',
            textAlign: TextAlign.center,
          ),
        ),
      );
    } else {
      return Container(
          padding: const EdgeInsets.only(left: 20, right: 20),
          height: size.height * 0.72,
          child: ListView.builder(
            itemCount: listOfSearchedData.length,
            scrollDirection: Axis.vertical,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (BuildContext context, int index) {
              var documentData =
                  listOfSearchedData[index].data()! as Map<String, dynamic>;

              if (documentData != null) {
                return GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          PageTransition(
                              child: DetailPage(
                                plantId: documentData['uid'],
                                plantName: documentData['plant_name'],
                                imageURL: documentData['image_url'],
                              ),
                              type: PageTransitionType.bottomToTop));
                    },
                    child: PlantWidget(
                        cont: context,
                        index: index,
                        documentId: listOfSearchedData[index].id,
                        plantList: listOfSearchedData
                            .map(
                              (e) => PlantDevices(
                                  uid: e.get("uid").toString(),
                                  description: e.get("description").toString(),
                                  maxMoistureLevel:
                                      e.get("max_moisture_level").toString(),
                                  minMoistureLevel:
                                      e.get("min_moisture_level").toString(),
                                  minSunlightHour:
                                      e.get("min_sunlight_hour").toString(),
                                  maxSunlightHour:
                                      e.get("max_sunlight_hour").toString(),
                                  type: e.get("type").toString(),
                                  plantName: e.get("plant_name").toString(),
                                  speciesName: e.get("species_name").toString(),
                                  waterScaleWarningLevel: e
                                      .get("water_scale_warning_level")
                                      .toString(),
                                  imageURL: e.get("image_url").toString(),
                                  isAlreadyProfiled:
                                      e.get("is_already_profiled").toString(),
                                  planterDeviceName:
                                      e.get("planter_device_name").toString(),
                                  planterDeviceURL: e
                                          .data()
                                          .toString()
                                          .contains('planter_image_url')
                                      ? e.get("planter_image_url").toString()
                                      : "",
                                  wateringCareProfileInformation:
                                      e.get("watering_care_profile_information") ??
                                          "".toString(),
                                  sunlightCareProfileInformation: e
                                      .get("sunlight_care_profile_information")
                                      .toString(),
                                  isFertilizerTurnedOn:
                                      e.get("is_fertilizer_turned_on").toString() == "true"
                                          ? true
                                          : false,
                                  isLightSensorTurnedOn:
                                      e.get("is_light_sensor_turned_on").toString() == "true"
                                          ? true
                                          : false,
                                  isReservoirSensorTurnedOn:
                                      e.get("is_reservoir_sensor_turned_on").toString() == "true"
                                          ? true
                                          : false,
                                  isWaterSensorTurnedOn:
                                      e.get("is_water_sensor_turned_on").toString() == "true"
                                          ? true
                                          : false),
                            )
                            .toList()));
              }
            },
          ));
    }
  }

  _buildPlanterListDisplay(BuildContext context, size) {
    final CollectionReference collection =
        FirebaseFirestore.instance.collection("user_plant_devices");
    return Container(
      padding: const EdgeInsets.only(left: 20, right: 20),
      height: size.height * 0.72,
      child: StreamBuilder<QuerySnapshot>(
          stream: collection
              .where("email",
                  isEqualTo:
                      FirebaseAuth.instance.currentUser?.email.toString())
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }
            if (snapshot.data?.docs.length == 0) {
              return Column(
                children: [
                  SizedBox(height: 40),
                  Image.asset(
                    'assets/images/no_planter.png',
                    scale: 1.1,
                    // width: double.infinity,
                  ),
                  SizedBox(height: 20),
                  Text("You haven't added any planters yet",
                      style: GoogleFonts.openSans(
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.w500,
                          fontSize: 15)),
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 15.0, right: 15.0),
                    child: MyCustomInfiniteButton(
                      onPressed: () => _showAddDeviceOptions(context),
                      buttonText: 'Add Planter',
                    ),
                  ),
                ],
              );
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CustomLoadingScreen();
            }

            return ListView.builder(
              itemCount: snapshot.data?.docs.length,
              scrollDirection: Axis.vertical,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (BuildContext context, int index) {
                var document = snapshot.data!.docs[index];
                var data = document.data() as Map<String, dynamic>;

                return GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          PageTransition(
                              child: DetailPage(
                                  plantId:
                                      snapshot.data?.docs[index].get('uid'),
                                  plantName: snapshot.data?.docs[index]
                                      .get('plant_name'),
                                  imageURL: snapshot.data?.docs[index]
                                      .get('image_url')),
                              type: PageTransitionType.bottomToTop));
                    },
                    child: PlantWidget(
                        cont: context,
                        index: index,
                        documentId: snapshot.data!.docs[index].id,
                        plantList: snapshot.data!.docs
                            .map(
                              (e) => PlantDevices(
                                uid: e.get("uid").toString(),
                                description: e.get("description").toString(),
                                maxMoistureLevel:
                                    e.get("max_moisture_level").toString(),
                                minMoistureLevel:
                                    e.get("min_moisture_level").toString(),
                                minSunlightHour:
                                    e.get("min_sunlight_hour").toString(),
                                maxSunlightHour:
                                    e.get("max_sunlight_hour").toString(),
                                type: e.get("type").toString(),
                                plantName: e.get("plant_name").toString(),
                                speciesName: e.get("species_name").toString(),
                                waterScaleWarningLevel: e
                                    .get("water_scale_warning_level")
                                    .toString(),
                                imageURL: e.get("image_url").toString(),
                                isAlreadyProfiled:
                                    e.get("is_already_profiled").toString(),
                                planterDeviceName:
                                    e.get("planter_device_name").toString(),
                                planterDeviceURL: e
                                        .data()
                                        .toString()
                                        .contains('planter_image_url')
                                    ? e.get("planter_image_url").toString()
                                    : "",
                                wateringCareProfileInformation: e
                                        .data()
                                        .toString()
                                        .contains(
                                            'watering_care_profile_information')
                                    ? e
                                        .get(
                                            "watering_care_profile_information")
                                        .toString()
                                    : "",
                                sunlightCareProfileInformation: e
                                        .data()
                                        .toString()
                                        .contains(
                                            'sunlight_care_profile_information')
                                    ? e
                                        .get(
                                            "sunlight_care_profile_information")
                                        .toString()
                                    : "",
                                isFertilizerTurnedOn: e
                                        .data()
                                        .toString()
                                        .contains('is_fertilizer_turned_on')
                                    ? e
                                                .get("is_fertilizer_turned_on")
                                                .toString() ==
                                            "true"
                                        ? true
                                        : false
                                    : false,
                                isLightSensorTurnedOn: e
                                        .data()
                                        .toString()
                                        .contains('is_light_sensor_turned_on')
                                    ? e
                                                .get(
                                                    "is_light_sensor_turned_on")
                                                .toString() ==
                                            "true"
                                        ? true
                                        : false
                                    : false,
                                isReservoirSensorTurnedOn: e
                                        .data()
                                        .toString()
                                        .contains(
                                            'is_reservoir_sensor_turned_on')
                                    ? e
                                                .get(
                                                    "is_reservoir_sensor_turned_on")
                                                .toString() ==
                                            "true"
                                        ? true
                                        : false
                                    : false,
                                isWaterSensorTurnedOn: e
                                        .data()
                                        .toString()
                                        .contains('is_water_sensor_turned_on')
                                    ? e
                                                .get(
                                                    "is_water_sensor_turned_on")
                                                .toString() ==
                                            "true"
                                        ? true
                                        : false
                                    : false,
                              ),
                            )
                            .toList()));
              },
            );
          }),
    );
  }
}
