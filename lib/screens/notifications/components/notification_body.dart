import 'dart:async';
import 'dart:convert';

import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:hortijoy_mobile_app/custom_widgets/custom_outlined_button.dart';
import 'package:hortijoy_mobile_app/main.dart';
import 'package:hortijoy_mobile_app/resources/colors.dart';
import 'package:hortijoy_mobile_app/resources/custom_button.dart';
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
import 'package:hortijoy_mobile_app/screens/planters/planter_list.dart';
import 'package:hortijoy_mobile_app/screens/shops/shops.dart';
import 'package:hortijoy_mobile_app/screens/plant_library/components/notification_card_widget.dart';
import 'package:page_transition/page_transition.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dynamic_icon/flutter_dynamic_icon.dart';

class NotificationBody extends StatefulWidget {
  List<String> selectedFilters;
  NotificationBody({super.key, required this.selectedFilters});

  @override
  State<NotificationBody> createState() => _NotificationBodyState();
}

class _NotificationBodyState extends State<NotificationBody> {
  AppBar buildAppBar() {
    return AppBar(
        elevation: 0,
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

  final saveListController = TextEditingController();
  Query contents =
      FirebaseFirestore.instance.collection('plant_library_test_first');
  List<String> category1 = [];
  List<String> category2 = [];
  List<String> category3 = [];
  List<String> allCategory = [];
  List<String> allValue = [];
  int snapshotDataLength = 0;

  late StreamSubscription<QuerySnapshot> _notificationSubscription;
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    widget.selectedFilters.forEach((element) {
      if (element.contains("standard_water_profile_status")) {
        contents = contents.where(element.split("-")[0],
            isEqualTo: element.split("-")[1]);
      } else if (element.contains("standard_light_intensity")) {
        contents = contents.where(element.split("-")[0],
            isEqualTo: element.split("-")[1]);
      } else if (element.contains("plant_type")) {
        contents = contents.where(element.split("-")[0],
            isEqualTo: element.split("-")[1]);
      }
      allCategory.add(element.split("-")[0]);
      allValue.add(element.split("-")[1]);
    });

    // _addSampleNotif();

    _listenToNotifications();
  }

  @override
  void dispose() {
    _notificationSubscription.cancel();
    super.dispose();
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
        setBadgeCount(_unreadCount);
      });
    }
  }

  setBadgeCount(int count) async {
    try {
      await FlutterDynamicIcon.setApplicationIconBadgeNumber(count);
    } on PlatformException {
      print("Exception Platform not supported");
      await FlutterDynamicIcon.setApplicationIconBadgeNumber(count);
    } catch (e) {
      print("CATCH ERROR: " + e.toString());
    }
  }

  _addSampleNotif() {
    FirebaseFirestore.instance.collection("notifications").add({
      "title": "Sampe Event 1",
      "subtitle": "Sample Event 1 Desc",
      "datetime_added": DateTime.now().toString(),
      "email": FirebaseAuth.instance.currentUser?.email.toString(),
      "is_read": false,
      "icon": "others",
      "created_at": Timestamp.now()
    });
  }

  @override
  Widget build(BuildContext context) {
    final searchController = TextEditingController().obs;
    int selectedIndex = 3;
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
                  const BottomNavigationBarItem(
                      icon: ImageIcon(
                        AssetImage("assets/icons/discover.png"),
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
            body: TextDisplayDiscover(context, searchController, size)));
  }

  SingleChildScrollView TextDisplayDiscover(BuildContext context,
      Rx<TextEditingController> searchController, Size size) {
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
                          "Notifications",
                          style: GoogleFonts.openSans(
                              fontSize: 25.0, fontWeight: FontWeight.w600),
                        ),
                      ])),
              Container(
                  padding: const EdgeInsets.only(left: 15, right: 15),
                  height: size.height * 0.85,
                  child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: FirebaseFirestore.instance
                          .collection('notifications')
                          .orderBy("created_at", descending: true)
                          .where("email",
                              isEqualTo: FirebaseAuth
                                  .instance.currentUser?.email
                                  .toString())
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData && snapshot.data != null) {
                          if (snapshot.data!.docs.isEmpty) {
                            return Center(
                                child: Text("No notification yet",
                                    style: TextStyle(fontSize: 20)));
                          } else {
                            return ListView.builder(
                                itemCount: snapshot.data?.docs.length,
                                scrollDirection: Axis.vertical,
                                physics: const BouncingScrollPhysics(),
                                itemBuilder: (BuildContext context, int index) {
                                  print("DATE: " +
                                      snapshot.data!.docs[index]
                                          .data()["datetime_added"]
                                          .toString());
                                  return NotificationCardWidget(
                                      index: index,
                                      data: snapshot.data!.docs[index]
                                              .data()["title"]
                                              .toString() +
                                          "..." +
                                          snapshot.data!.docs[index]
                                              .data()["subtitle"]
                                              .toString() +
                                          "..." +
                                          snapshot.data!.docs[index]
                                              .data()["datetime_added"]
                                              .toString() +
                                          "..." +
                                          snapshot.data!.docs[index]
                                              .data()["icon"]
                                              .toString() +
                                          "..." +
                                          snapshot.data!.docs[index]
                                              .data()["is_read"]
                                              .toString());
                                });
                          }
                        } else {
                          return CustomLoadingScreen();
                        }
                      }))
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
                  margin: const EdgeInsets.only(left: 20.0, right: 20.0),
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
                                  width: 150,
                                  height: 55,
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
                                width: 150,
                                height: 55,
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
