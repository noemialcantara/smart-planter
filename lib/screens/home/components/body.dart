import 'dart:convert';
import 'dart:io';
import 'package:async_task/async_task_extension.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:hortijoy_mobile_app/main.dart';
import 'package:hortijoy_mobile_app/models/plant_devices.dart';
import 'package:hortijoy_mobile_app/resources/colors.dart';
import 'package:hortijoy_mobile_app/resources/firebase_firestore.dart';
import 'package:hortijoy_mobile_app/resources/shared_pref_service.dart';
import 'package:hortijoy_mobile_app/resources/measurements.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hortijoy_mobile_app/models/plants.dart';
import 'package:hortijoy_mobile_app/resources/my_button.dart';
import 'package:hortijoy_mobile_app/resources/widget_properties.dart';
import 'package:hortijoy_mobile_app/screens/add_device_options/add_device_options.dart';
import 'package:hortijoy_mobile_app/screens/home/components/detail_page.dart';
import 'package:hortijoy_mobile_app/screens/home/components/plant_widget.dart';
import 'package:hortijoy_mobile_app/screens/add_device_bluetooth/add_device_bluetooth.dart';
import 'package:hortijoy_mobile_app/screens/home/home_page_body.dart';
import 'package:hortijoy_mobile_app/screens/menu/components/main_menu_body.dart';
import 'package:hortijoy_mobile_app/screens/plant_library/components/plant_library_body.dart';
import 'package:hortijoy_mobile_app/screens/planter/planter_profile.dart';
import 'package:hortijoy_mobile_app/screens/planter/planter_select_care_profile.dart';
import 'package:hortijoy_mobile_app/screens/plant_library/plant_library_main.dart';
import 'package:hortijoy_mobile_app/screens/menu/main_menu.dart';
import 'package:hortijoy_mobile_app/screens/planter/planter_settings.dart';
import 'package:hortijoy_mobile_app/screens/planters/planter_list.dart';
import 'package:hortijoy_mobile_app/screens/shops/shops.dart';
import 'package:hortijoy_mobile_app/screens/test_sensors/fill_fertilizer_screen.dart';
import 'package:hortijoy_mobile_app/screens/test_sensors/fill_water_reservoir_screen.dart';
import 'package:page_transition/page_transition.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:hortijoy_mobile_app/screens/notifications/components/notification_body.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'featured_plants.dart';
import 'header_with_seachbox.dart';
import 'recomend_plants.dart';
import 'title_with_more_bbtn.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';

class Body extends StatefulWidget {
  const Body({super.key});

  @override
  State<Body> createState() => _BodyState();
}

String getUserEmail = "";
String getusername = "";

class _BodyState extends State<Body> {
  bool isNotificationClosed = true;
  bool isWelcome = false;
  bool arePlantsHealthy = false;
  bool isWaterReservoirNeedsRefill = false;
  bool isFertilizerReservoirNeedsRefill = false;
  bool isMilestoneAchieved = false;
  double planterDeviceListHeight = 0;
  String homeNotificationId = "";

  String statusTitle = "";
  String statusDescription = "";
  String statusIcon = "";
  String buttonText = "";
  dynamic onTapAction;

  int _notificationCount = 0;
  late StreamSubscription<QuerySnapshot> _notificationSubscription;
  int _unreadCount = 0;

  AppBar buildAppBar() {
    return AppBar(
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: SvgPicture.asset(
            "assets/icons/menu.svg",
            color: Colors.black,
          ),
          onPressed: () {
            // ZoomDrawer.of(context)!.toggle();
          },
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
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
        ));
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

  getUsername(String email) async {
    await FirebaseQueries.getUserData(email).then((value) {
      setState(() {
        getusername = value.toString();
      });
    });
  }

  @override
  void initState() {
    _fetchUserDetails();
    _fetchPlantStatus();
    checkAndShowWelcomeModal();
    _listenToNotifications();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  checkAndShowWelcomeModal() async {
    await FirebaseFirestore.instance
        .collection("user")
        .where("email", isEqualTo: FirebaseAuth.instance.currentUser?.email)
        .get()
        .then((event) async {
      bool welcomeShown = event.docs.first.get("welcomeShown");

      if (!welcomeShown) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showWelcomeModal(context);
        });
      }
    });
  }

  void showWelcomeModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Welcome to Hortijoy'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                  'Explore our library of care profiles and start your planting journey.'),
              SizedBox(height: 10),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Close the modal
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => PlantLibraryMain()));
              },
              child: Text('Discover Care Profiles'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the modal
                updateWelcomeShown(); // Set welcomeShown to true
              },
              child: Text("Don't show it again"),
            ),
          ],
        );
      },
    );
  }

  updateWelcomeShown() async {
    await FirebaseFirestore.instance
        .collection("user")
        .where("email", isEqualTo: FirebaseAuth.instance.currentUser?.email)
        .get()
        .then((event) async {
      if (event.docs.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection("user")
            .doc(event.docs.first.id)
            .update({"welcomeShown": true});
      }
    });
  }

  addNotification(String title, String subtitle, String notifKey) {
    FirebaseFirestore.instance.collection("notifications").add({
      "title": title,
      "subtitle": subtitle,
      "notif_key": notifKey,
      "datetime_added": DateTime.now().toString(),
      "email": FirebaseAuth.instance.currentUser?.email.toString(),
      "is_read": false,
      "icon": "others",
      "created_at": Timestamp.now()
    });
  }

  _fetchPlantStatus() async {
    bool hasNotificationReminder = false;
    PlantDevices samplePlanterDetails = PlantDevices(
        description: "",
        uid: "",
        maxMoistureLevel: "",
        maxSunlightHour: "",
        minMoistureLevel: "",
        minSunlightHour: "",
        plantName: "",
        speciesName: "",
        type: "",
        waterScaleWarningLevel: "",
        imageURL: "",
        isAlreadyProfiled: "",
        planterDeviceName: "",
        planterDeviceURL: "",
        wateringCareProfileInformation: "",
        sunlightCareProfileInformation: "",
        isLightSensorTurnedOn: false,
        isWaterSensorTurnedOn: false,
        isFertilizerTurnedOn: false,
        isReservoirSensorTurnedOn: false);

    //simple notifs
    await FirebaseFirestore.instance
        .collection("home_notifications")
        .where("email",
            isEqualTo: FirebaseAuth.instance.currentUser?.email.toString())
        .limit(1)
        .get()
        .then((event) async {
      if (event.docs.length > 0) {
        setState(() {
          arePlantsHealthy = event.docs[0].get("are_plants_healthy");
          isWelcome = event.docs[0].get("is_welcome");
          isMilestoneAchieved = event.docs[0].get("is_milestone_achieved");

          if (!event.docs[0].get("is_read")) {
            hasNotificationReminder = true;
            homeNotificationId = event.docs[0].id;
          }

          // if (arePlantsHealthy || isMilestoneAchieved) {
          //   addNotification(
          //       arePlantsHealthy
          //           ? "Your plants are doing great!"
          //           : "Congratulations! You\'ve achieved a care milestone",
          //       arePlantsHealthy
          //           ? "Explore our library of care profiles and find your next plant"
          //           : "You\'ve taken great care of your planter for 6 months, share and celebrate this achievement",);
          // }
        });
      }
    });

    //sensor statuses
    await FirebaseFirestore.instance
        .collection("user_plant_devices")
        .where("email",
            isEqualTo: FirebaseAuth.instance.currentUser?.email.toString())
        .get()
        .then((event) async {
      // Initialize a flag to check if any device meets the condition
      bool foundDevice = false;
      int latestWaterReservoirValue = 0;
      int latestFertilizerValue = 0;

      for (var doc in event.docs) {
        var deviceId = doc.id;
        //water reading
        FirebaseFirestore.instance
            .collection('user_plant_devices')
            .doc(deviceId)
            .collection('water_readings')
            .orderBy('timestamp', descending: true)
            .limit(1)
            .snapshots()
            .listen((QuerySnapshot<Map<String, dynamic>> snapshot) {
          if (snapshot.docs.isNotEmpty) {
            latestWaterReservoirValue = int.parse(snapshot.docs[0]
                .get("water_reservoir_level")
                .toString()
                .replaceAll(RegExp(r"\.0$"), ""));

            if (latestWaterReservoirValue < 25) {
              var data = doc.data();
              setState(() {
                samplePlanterDetails = PlantDevices(
                  uid: doc.data()["uid"].toString(),
                  description: doc.data()["description"].toString(),
                  maxMoistureLevel: doc.data()["max_moisture_level"].toString(),
                  minMoistureLevel: doc.data()["min_moisture_level"].toString(),
                  minSunlightHour: doc.data()["min_sunlight_hour"].toString(),
                  maxSunlightHour: doc.data()["max_sunlight_hour"].toString(),
                  type: doc.data()["type"].toString(),
                  plantName: doc.data()["plant_name"].toString(),
                  speciesName: doc.data()["species_name"].toString(),
                  waterScaleWarningLevel:
                      doc.data()["water_scale_warning_level"].toString(),
                  imageURL: doc.data()["image_url"].toString(),
                  isAlreadyProfiled:
                      doc.data()["is_already_profiled"].toString(),
                  planterDeviceName:
                      doc.data()["planter_device_name"].toString(),
                  planterDeviceURL: doc.data()["image_url"].toString(),
                  wateringCareProfileInformation: doc
                      .data()["watering_care_profile_information"]
                      .toString(),
                  sunlightCareProfileInformation: doc
                      .data()["sunlight_care_profile_information"]
                      .toString(),
                  isFertilizerTurnedOn:
                      doc.data()["is_fertilizer_turned_on"].toString() == "true"
                          ? true
                          : false,
                  isLightSensorTurnedOn:
                      doc.data()["is_light_sensor_turned_on"].toString() ==
                              "true"
                          ? true
                          : false,
                  isReservoirSensorTurnedOn:
                      doc.data()["is_reservoir_sensor_turned_on"].toString() ==
                              "true"
                          ? true
                          : false,
                  isWaterSensorTurnedOn:
                      doc.data()["is_water_sensor_turned_on"].toString() ==
                              "true"
                          ? true
                          : false,
                );

                hasNotificationReminder = true;
                isNotificationClosed = false;
                foundDevice = true;

                statusTitle = 'Fill your water reservoir';
                statusDescription =
                    'The water reservoir of ${doc.data()["planter_device_name"].toString()} needs to be filled';
                statusIcon = 'assets/icons/Left_Button_home_waterreservoir.png';
                buttonText = 'Refill water reservoir';

                onTapAction = () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => FillWaterReservoirScreen(
                              isFirstSetup: false,
                              planterDetails: samplePlanterDetails,
                              isFromNotifHomeFertilizer: true))).then((value) {
                    _fetchPlantStatus();
                  });
                };

                String notifKey = deviceId +
                    "" +
                    snapshot.docs[0].get("timestamp").toString() +
                    FirebaseAuth.instance.currentUser!.email.toString() +
                    "water_reservoir_refill";

                FirebaseFirestore.instance
                    .collection("notifications")
                    .where("email",
                        isEqualTo:
                            FirebaseAuth.instance.currentUser?.email.toString())
                    .where("notif_key", isEqualTo: notifKey)
                    .get()
                    .then((event) async {
                  if (event.docs.length > 0) {
                  } else {
                    addNotification(statusTitle, statusDescription, notifKey);
                  }
                });
              });
            }
          } else {}
        });
        //fertilizer reading
        FirebaseFirestore.instance
            .collection('user_plant_devices')
            .doc(deviceId)
            .collection('fertilizer_readings')
            .orderBy('timestamp', descending: true)
            .limit(1)
            .snapshots()
            .listen((QuerySnapshot<Map<String, dynamic>> snapshot) {
          if (snapshot.docs.isNotEmpty) {
            latestFertilizerValue = int.parse(snapshot.docs[0]
                .get("fertilizer_volume")
                .toString()
                .replaceAll(RegExp(r"\.0$"), ""));

            if (latestFertilizerValue < 10) {
              var data = doc.data();
              setState(() {
                samplePlanterDetails = PlantDevices(
                  uid: doc.data()["uid"].toString(),
                  description: doc.data()["description"].toString(),
                  maxMoistureLevel: doc.data()["max_moisture_level"].toString(),
                  minMoistureLevel: doc.data()["min_moisture_level"].toString(),
                  minSunlightHour: doc.data()["min_sunlight_hour"].toString(),
                  maxSunlightHour: doc.data()["max_sunlight_hour"].toString(),
                  type: doc.data()["type"].toString(),
                  plantName: doc.data()["plant_name"].toString(),
                  speciesName: doc.data()["species_name"].toString(),
                  waterScaleWarningLevel:
                      doc.data()["water_scale_warning_level"].toString(),
                  imageURL: doc.data()["image_url"].toString(),
                  isAlreadyProfiled:
                      doc.data()["is_already_profiled"].toString(),
                  planterDeviceName:
                      doc.data()["planter_device_name"].toString(),
                  planterDeviceURL: doc.data()["image_url"].toString(),
                  wateringCareProfileInformation: doc
                      .data()["watering_care_profile_information"]
                      .toString(),
                  sunlightCareProfileInformation: doc
                      .data()["sunlight_care_profile_information"]
                      .toString(),
                  isFertilizerTurnedOn:
                      doc.data()["is_fertilizer_turned_on"].toString() == "true"
                          ? true
                          : false,
                  isLightSensorTurnedOn:
                      doc.data()["is_light_sensor_turned_on"].toString() ==
                              "true"
                          ? true
                          : false,
                  isReservoirSensorTurnedOn:
                      doc.data()["is_reservoir_sensor_turned_on"].toString() ==
                              "true"
                          ? true
                          : false,
                  isWaterSensorTurnedOn:
                      doc.data()["is_water_sensor_turned_on"].toString() ==
                              "true"
                          ? true
                          : false,
                );

                hasNotificationReminder = true;
                isNotificationClosed = false;
                foundDevice = true;

                statusTitle = 'Fill your fertilizer reservoir';
                statusDescription =
                    'The fertilizer reservoir of ${doc.data()["planter_device_name"].toString()} needs to be filled';
                statusIcon =
                    'assets/icons/left_button_home_fertilizer_reservoir.png';
                buttonText = 'Refill fertilizer reservoir';

                onTapAction = () {
                  Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => FillFertilizerScreen(
                                  isFirstSetup: true,
                                  planterDetails: samplePlanterDetails)))
                      .then((value) {
                    _fetchPlantStatus();
                  });
                };

                String notifKey = deviceId +
                    "" +
                    snapshot.docs[0].get("timestamp").toString() +
                    FirebaseAuth.instance.currentUser!.email.toString() +
                    "fertilizer_refill";

                FirebaseFirestore.instance
                    .collection("notifications")
                    .where("email",
                        isEqualTo:
                            FirebaseAuth.instance.currentUser?.email.toString())
                    .where("notif_key", isEqualTo: notifKey)
                    .get()
                    .then((event) async {
                  if (event.docs.length > 0) {
                  } else {
                    addNotification(statusTitle, statusDescription, notifKey);
                  }
                });
              });
            }
          } else {}
        });

        if (foundDevice) {
          break;
        }
      }
    });

    setState(() {
      if (isWelcome) {
        statusTitle = 'Welcome to Hortijoy';
        statusDescription =
            'Explore our library of care profiles and start your planting journey.';
        statusIcon = 'assets/icons/Left_Button_home_star.png';
        buttonText = 'Discover Care Profiles';
        onTapAction = () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => PlantLibraryMain()));
        };
      } else if (arePlantsHealthy) {
        statusTitle = 'Your plants are doing great!';
        statusDescription =
            'Explore our library of care profiles and find your next plant.';
        statusIcon = 'assets/icons/Left_Button_home_heart.png';
        buttonText = 'Discover Care Profiles';

        onTapAction = () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => PlantLibraryMain()));
        };
      } else if (isMilestoneAchieved) {
        statusTitle = 'Congratulations! You\'ve achieved a care milestone.';
        statusDescription =
            'You\'ve taken great care of your Monstera in Chee for 6 months. Share and celebrate this achievement.';
        statusIcon = 'assets/icons/Left_Button_home_heart.png';
        buttonText = 'Share';

        onTapAction = () async {
          final String shareText =
              "Hooray! I've successfully taken good care of my Chee for 6 months with Hortijoy smart planter!";
          final RenderBox? box = context.findRenderObject() as RenderBox?;
// Download the image to a temporary directory
          final tempDir = await getTemporaryDirectory();
          final tempFile = File('${tempDir.path}/shared_plant_image.png');
          final response = await http.get(Uri.parse(
              "https://firebasestorage.googleapis.com/v0/b/hortijoy-staging.appspot.com/o/plant_cropped_photos%2FScreenshot%202024-01-29%20at%206.09.56%20PM.png?alt=media&token=a35ea324-4c2b-4a9f-941a-2235408f4bb0"));

          if (response.statusCode == 200) {
            await tempFile.writeAsBytes(response.bodyBytes);

            // Share the downloaded file
            await Share.shareXFiles(
              [
                XFile(tempFile.path),
              ],
              text: shareText,
              subject: statusTitle,
              sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
            );
          } else {
            // Handle the error - show a message or retry
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to download image for sharing.'),
              ),
            );
          }
        };
      }
    });

    if (!hasNotificationReminder) {
      setState(() {
        isNotificationClosed = true;
      });
    } else {
      setState(() {
        isNotificationClosed = false;
      });
    }
  }

  _fetchUserDetails() {
    SharedPreferenceService.getLoggedInUserEmail().then((value) {
      setState(() {
        print(value.toString());
        getUserEmail = value.toString();
      });
      getUsername(getUserEmail);
    });
  }

  @override
  Widget build(BuildContext context) {
    final searchController = TextEditingController().obs;
    int selectedIndex = 0;
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
            backgroundColor: AppColors.scaffoldBackgroundColor,
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
                  } else if (selectedIndex == 3) {
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
                  BottomNavigationBarItem(
                      icon: SvgPicture.asset(
                        "assets/icons/home_outlined.svg",
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
                      "assets/icons/planter_outlined.svg",
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
            body: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 30),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: EdgeInsets.only(left: 25, bottom: 20),
                          child: Text(
                            "Hi, $getusername",
                            style: GoogleFonts.openSans(
                                fontSize: 20.0, fontWeight: FontWeight.w600),
                          ),
                        ),
                        GestureDetector(
                          child: Container(
                              padding: EdgeInsets.only(right: 25, bottom: 30),
                              child: Icon(
                                Icons.settings_outlined,
                                color: AppColors.black,
                                size: 30.0,
                              )),
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MainMenuBody(),
                                ));
                          },
                        )
                      ]),
                  plantStatusNotificationBar(),
                  SizedBox(height: 20),
                  Container(
                      decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(30),
                              topRight: Radius.circular(30))),
                      // padding: const EdgeInsets.symmetric(vertical: 20),

                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              padding:
                                  EdgeInsets.only(left: 25, top: 20, right: 25),
                              child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Planters",
                                      style: GoogleFonts.openSans(
                                          fontSize: 20.0,
                                          fontWeight: FontWeight.w600),
                                    ),
                                    GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    const PlanterList(),
                                              ));
                                        },
                                        child: Text(
                                          "View all",
                                          style: GoogleFonts.openSans(
                                              fontSize: 14.0,
                                              color: AppColors.primaryColor,
                                              fontWeight: FontWeight.w600),
                                        ))
                                  ]),
                            ),
                            Container(
                                height: !isNotificationClosed
                                    ? MediaQuery.of(context).size.height -
                                        (MediaQuery.of(context).size.height *
                                            0.57)
                                    : MediaQuery.of(context).size.height -
                                        (MediaQuery.of(context).size.height *
                                            0.30),
                                padding: EdgeInsets.only(left: 10, right: 10),
                                child:
                                    StreamBuilder<
                                            QuerySnapshot<
                                                Map<String, dynamic>>>(
                                        stream: FirebaseFirestore.instance
                                            .collection('user_plant_devices')
                                            .where("email",
                                                isEqualTo: FirebaseAuth
                                                    .instance.currentUser?.email
                                                    .toString())
                                            .snapshots(),
                                        builder: (context, snapshot) {
                                          if (snapshot.hasData &&
                                              snapshot.data != null) {
                                            if (snapshot.data?.docs.length ==
                                                0) {
                                              return Column(
                                                children: [
                                                  SizedBox(height: 40),
                                                  Image.asset(
                                                    'assets/images/no_planter.png',
                                                    scale: 1.1,
                                                    // width: double.infinity,
                                                  ),
                                                  SizedBox(height: 20),
                                                  Text(
                                                      "You haven't added any planters yet",
                                                      style: GoogleFonts
                                                          .openSans(
                                                              color: AppColors
                                                                  .primaryColor,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              fontSize: 15)),
                                                  SizedBox(
                                                    height: 20,
                                                  ),
                                                  Container(
                                                    margin:
                                                        const EdgeInsets.only(
                                                            left: 15.0,
                                                            right: 15.0),
                                                    child:
                                                        MyCustomInfiniteButton(
                                                      onPressed: () =>
                                                          _showAddDeviceOptions(
                                                              context),
                                                      buttonText: 'Add Planter',
                                                    ),
                                                  ),
                                                ],
                                              );
                                            }
                                            return ListView.builder(
                                                itemCount:
                                                    snapshot.data?.docs.length,
                                                scrollDirection: Axis.vertical,
                                                physics:
                                                    const BouncingScrollPhysics(),
                                                itemBuilder:
                                                    (BuildContext context,
                                                        int index) {
                                                  return GestureDetector(
                                                      onTap: () {},
                                                      child: PlantWidget(
                                                          cont: context,
                                                          index: index,
                                                          documentId: snapshot
                                                              .data!
                                                              .docs[index]
                                                              .id,
                                                          plantList:
                                                              snapshot
                                                                  .data!.docs
                                                                  .map(
                                                                    (e) =>
                                                                        PlantDevices(
                                                                      uid: e
                                                                          .get(
                                                                              "uid")
                                                                          .toString(),
                                                                      description: e
                                                                          .get(
                                                                              "description")
                                                                          .toString(),
                                                                      maxMoistureLevel: e
                                                                          .get(
                                                                              "max_moisture_level")
                                                                          .toString(),
                                                                      minMoistureLevel: e
                                                                          .get(
                                                                              "min_moisture_level")
                                                                          .toString(),
                                                                      minSunlightHour: e
                                                                          .get(
                                                                              "min_sunlight_hour")
                                                                          .toString(),
                                                                      maxSunlightHour: e
                                                                          .get(
                                                                              "max_sunlight_hour")
                                                                          .toString(),
                                                                      type: e
                                                                          .get(
                                                                              "type")
                                                                          .toString(),
                                                                      plantName: e
                                                                          .get(
                                                                              "plant_name")
                                                                          .toString(),
                                                                      speciesName: e
                                                                          .get(
                                                                              "species_name")
                                                                          .toString(),
                                                                      waterScaleWarningLevel: e
                                                                          .get(
                                                                              "water_scale_warning_level")
                                                                          .toString(),
                                                                      imageURL: e
                                                                          .get(
                                                                              "image_url")
                                                                          .toString(),
                                                                      isAlreadyProfiled: e
                                                                          .get(
                                                                              "is_already_profiled")
                                                                          .toString(),
                                                                      planterDeviceName: e
                                                                          .get(
                                                                              "planter_device_name")
                                                                          .toString(),
                                                                      planterDeviceURL: e
                                                                              .data()
                                                                              .toString()
                                                                              .contains('planter_image_url')
                                                                          ? e.get("planter_image_url").toString()
                                                                          : "",
                                                                      wateringCareProfileInformation: e
                                                                              .data()
                                                                              .toString()
                                                                              .contains('watering_care_profile_information')
                                                                          ? e.get("watering_care_profile_information").toString()
                                                                          : "",
                                                                      sunlightCareProfileInformation: e
                                                                              .data()
                                                                              .toString()
                                                                              .contains('sunlight_care_profile_information')
                                                                          ? e.get("sunlight_care_profile_information").toString()
                                                                          : "",
                                                                      isFertilizerTurnedOn: e
                                                                              .data()
                                                                              .toString()
                                                                              .contains('is_fertilizer_turned_on')
                                                                          ? e.get("is_fertilizer_turned_on").toString() == "true"
                                                                              ? true
                                                                              : false
                                                                          : false,
                                                                      isLightSensorTurnedOn: e
                                                                              .data()
                                                                              .toString()
                                                                              .contains('is_light_sensor_turned_on')
                                                                          ? e.get("is_light_sensor_turned_on").toString() == "true"
                                                                              ? true
                                                                              : false
                                                                          : false,
                                                                      isReservoirSensorTurnedOn: e
                                                                              .data()
                                                                              .toString()
                                                                              .contains('is_reservoir_sensor_turned_on')
                                                                          ? e.get("is_reservoir_sensor_turned_on").toString() == "true"
                                                                              ? true
                                                                              : false
                                                                          : false,
                                                                      isWaterSensorTurnedOn: e
                                                                              .data()
                                                                              .toString()
                                                                              .contains('is_water_sensor_turned_on')
                                                                          ? e.get("is_water_sensor_turned_on").toString() == "true"
                                                                              ? true
                                                                              : false
                                                                          : false,
                                                                    ),
                                                                  )
                                                                  .toList()));
                                                });
                                          } else {
                                            return CustomLoadingScreen();
                                          }
                                        })),
                          ])),
                ],
              ),
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

  Widget plantStatusNotificationBar() {
    return Visibility(
      child: Container(
        padding: EdgeInsets.only(top: 5),
        margin: EdgeInsets.only(left: 25, right: 25),
        width: double.infinity,
        height: isMilestoneAchieved ? 255 : 200,
        decoration: BoxDecoration(
            color: Color(0xffEBEDEB),
            borderRadius: BorderRadius.all(Radius.circular(10))),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                  padding: EdgeInsets.only(right: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        child: Icon(Icons.close),
                        onTap: () async {
                          setState(() {
                            isNotificationClosed = true;
                          });

                          await FirebaseFirestore.instance
                              .collection("home_notifications")
                              .doc(homeNotificationId)
                              .update({
                            "is_read": true,
                            "is_milestone_achieved": false
                          });
                        },
                      )
                    ],
                  )),
              Padding(
                  padding: EdgeInsets.only(left: 25, right: 25, top: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(statusTitle,
                                  style: GoogleFonts.openSans(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: AppColors.primaryColor)),
                              Padding(
                                  padding: EdgeInsets.only(top: 8),
                                  child: Text(statusDescription,
                                      style: GoogleFonts.openSans(
                                          fontWeight: FontWeight.normal,
                                          fontSize: 14,
                                          color: AppColors.primaryColor)))
                            ]),
                      ),
                      Image.asset(statusIcon)
                    ],
                  )),
              SizedBox(height: 18),
              GestureDetector(
                child: Container(
                  margin: EdgeInsets.only(left: 20, right: 20),
                  height: 42,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor,
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  child: Center(
                      child: Text(
                    buttonText,
                    style: GoogleFonts.openSans(
                      color: AppColors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  )),
                ),
                onTap: onTapAction,
              ),
            ]),
      ),
      visible: !isNotificationClosed,
    );
  }
}
