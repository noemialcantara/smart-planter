import 'dart:convert';
import 'dart:math';

import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:async_task/async_task_extension.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:hortijoy_mobile_app/resources/colors.dart';
import 'package:hortijoy_mobile_app/resources/measurements.dart';
import 'package:hortijoy_mobile_app/models/plants.dart';
import 'package:hortijoy_mobile_app/resources/my_button.dart';
import 'package:hortijoy_mobile_app/resources/my_textfield.dart';
import 'package:hortijoy_mobile_app/resources/widget_properties.dart';
import 'package:hortijoy_mobile_app/screens/add_device_options/add_device_options.dart';
import 'package:hortijoy_mobile_app/screens/home/components/body.dart';
import 'package:hortijoy_mobile_app/screens/home/components/detail_page.dart';
import 'package:hortijoy_mobile_app/screens/home/components/plant_widget.dart';
import 'package:hortijoy_mobile_app/screens/add_device_bluetooth/add_device_bluetooth.dart';
import 'package:hortijoy_mobile_app/screens/home/home_page_body.dart';
import 'package:hortijoy_mobile_app/screens/menu/main_menu.dart';
import 'package:hortijoy_mobile_app/screens/plant_library/components/filter_sensor_instruction_screen.dart';
import 'package:hortijoy_mobile_app/screens/plant_library/components/plant_filter.dart';
import 'package:hortijoy_mobile_app/screens/plant_library/components/plant_library_body.dart';
import 'package:hortijoy_mobile_app/screens/plant_library/components/plant_library_card_widget.dart';
import 'package:hortijoy_mobile_app/screens/plant_library/plant_library_main.dart';
import 'package:hortijoy_mobile_app/screens/planters/planter_list.dart';
import 'package:hortijoy_mobile_app/screens/shops/shops.dart';
import 'package:page_transition/page_transition.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LightSensorPlanterList extends StatefulWidget {
  List<String> selectedFilters;
  LightSensorPlanterList({super.key, required this.selectedFilters});

  @override
  State<LightSensorPlanterList> createState() => _LightSensorPlanterList();
}

class _LightSensorPlanterList extends State<LightSensorPlanterList> {
  TextEditingController saveListController = TextEditingController();

  final CollectionReference collection =
      FirebaseFirestore.instance.collection("user_plant_devices");

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Scaffold(
        backgroundColor: AppColors.white,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: Text(
            'Select Planter',
            textAlign: TextAlign.center,
            style: GoogleFonts.openSans(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          backgroundColor: AppColors.white,
          actions: const [],
          centerTitle: true,
          elevation: 0,
        ),
        body: SafeArea(
          child: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(),
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(10, 0, 10, 0),
              child: StreamBuilder<QuerySnapshot>(
                  stream: collection
                      .where("email",
                          isEqualTo: FirebaseAuth.instance.currentUser?.email
                              .toString())
                      .snapshots(),
                  builder: ((context, snapshot) {
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CustomLoadingScreen();
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
                            margin:
                                const EdgeInsets.only(left: 15.0, right: 15.0),
                            child: MyCustomInfiniteButton(
                              onPressed: () => _showAddDeviceOptions(context),
                              buttonText: 'Add Planter',
                            ),
                          ),
                        ],
                      );
                    }
                    return ListView.builder(
                      padding: EdgeInsets.only(left: 15, right: 15),
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        var document = snapshot.data!.docs[index];
                        var documentId = document.reference.id;
                        var data = document.data() as Map<String, dynamic>;

                        return Container(
                            padding: EdgeInsets.only(top: 15),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          data["planter_name"].toString(),
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          data["description"].toString(),
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium,
                                        ),
                                      ],
                                    ),
                                    onTap: () {
                                      int randomNumber =
                                          100 + Random().nextInt(1500 - 100);
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                FilterSensorInstructionScreen(
                                              selectedFilters:
                                                  selectedValueList,
                                              lightValue: randomNumber,
                                              planterDeviceName:
                                                  data["planter_name"]
                                                      .toString(),
                                            ),
                                          ));
                                    },
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.keyboard_arrow_right,
                                    color: Colors.black,
                                  ),
                                  onPressed: () {
                                    int randomNumber =
                                        100 + Random().nextInt(1500 - 100);
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              FilterSensorInstructionScreen(
                                            selectedFilters: selectedValueList,
                                            lightValue: randomNumber,
                                            planterDeviceName:
                                                data["planter_name"].toString(),
                                          ),
                                        ));
                                  },
                                ),
                              ],
                            ));
                      },
                    );
                  })),
            ),
          ),
        ),
      ),
    );
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
}
