import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hortijoy_mobile_app/resources/colors.dart';
import 'package:hortijoy_mobile_app/resources/my_button.dart';
import 'package:hortijoy_mobile_app/screens/home/home_page_body.dart';
import 'package:http/http.dart' as http;
import 'package:hexcolor/hexcolor.dart';
import 'package:hortijoy_mobile_app/models/device.dart';
import 'package:lan_scanner/lan_scanner.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter_gif/flutter_gif.dart';
import 'package:wifi_scan/wifi_scan.dart';

/// Example app for wifi_scan plugin.
class WifiProvisioning extends StatefulWidget {
  const WifiProvisioning({Key? key}) : super(key: key);

  @override
  State<WifiProvisioning> createState() => _WifiProvisioningState();
}

class _WifiProvisioningState extends State<WifiProvisioning>
    with TickerProviderStateMixin {
  final wifiPasswordController = TextEditingController().obs;
  List<Device> deviceList = [];
  double percent = 0.0;
  bool isEnd = true;
  bool btn = true;
  String? wifiName = " ";
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  scanNetwork() async {
    final info = NetworkInfo();
    final scanner = LanScanner();
    int i = 0;
    setState(() {
      _isLoading = true;
    });

    List<String> sampleDeviceIds = [
      "PDID0000001",
      "PDID0000002",
      "PDID0000003",
      "PDID0000001",
      "PDID0000002",
      "PDID0000003",
      "PDID0000001",
      "PDID0000002",
      "PDID0000003",
      "PDID0000001",
    ];

    setState(() {
      isEnd = true;
      btn = false;
      deviceList = [];
      percent = 0.0;
    });

    await info.getWifiName().then((value) => setState(() {
          wifiName = value;
        }));

    final String? ip = await info.getWifiIP();
    final String subnet = ip!.substring(0, ip.lastIndexOf('.'));

    final stream = scanner.icmpScan(subnet, progressCallback: (progress) {
      setState(() {
        percent = progress;
        print("PERCENTAGE: $percent");
        if (percent == 1.0) {
          isEnd = false;
          btn = true;
        }
      });
    });

    stream.listen((HostModel device) {
      deviceList
          .add(Device(id: sampleDeviceIds[i].toString(), ipAddress: device.ip));
      i++;
    });
  }

  connectingToWifi(String value) {}

  @override
  Widget build(BuildContext context) {
    FlutterGifController flutterGifController =
        FlutterGifController(vsync: this);
    FlutterGifController flutterGifController2 =
        FlutterGifController(vsync: this);

    WidgetsBinding.instance?.addPostFrameCallback((_) {
      flutterGifController.repeat(
        min: 0,
        max: 50,
        period: const Duration(milliseconds: 3000),
        reverse: true,
      );
      flutterGifController2.repeat(
        min: 0,
        max: 30,
        period: const Duration(milliseconds: 3000),
        reverse: true,
      );
    });
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "WIFI Connections",
          style: GoogleFonts.openSans(color: AppColors.black),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: AppColors.primaryColor,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      backgroundColor: AppColors.white,
      body: Container(
          padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 30),
          child: Stack(children: [
            isEnd && !_isLoading
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text("Turn on your phone's WIFI and start scanning",
                          style: GoogleFonts.openSans(
                              fontSize: 15, fontWeight: FontWeight.w600)),
                      SizedBox(height: 20),
                      GestureDetector(
                        child: Container(
                          height: 42,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor,
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          child: Center(
                              child: Text(
                            'Scan for WIFI',
                            style: GoogleFonts.openSans(
                              color: AppColors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          )),
                        ),
                        onTap: () {
                          scanNetwork();
                        },
                      ),
                    ],
                  )
                : isEnd && _isLoading
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text("Searching for WIFI...",
                              style: GoogleFonts.openSans(
                                  fontSize: 15, fontWeight: FontWeight.w600)),
                          SizedBox(height: 20),
                          GestureDetector(
                            child: Container(
                              height: 42,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                border: Border.all(style: BorderStyle.solid),
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                              child: Center(
                                  child: Text(
                                'Cancel',
                                style: GoogleFonts.openSans(
                                  color: AppColors.primaryColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              )),
                            ),
                            onTap: () {},
                          ),
                        ],
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text("Didn't find your WIFI? Try scanning again.",
                              style: GoogleFonts.openSans(
                                  fontSize: 15, fontWeight: FontWeight.w600)),
                          SizedBox(height: 20),
                          GestureDetector(
                            child: Container(
                              height: 42,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: AppColors.primaryColor,
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                              child: Center(
                                  child: Text(
                                'Scan for WIFI',
                                style: GoogleFonts.openSans(
                                  color: AppColors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              )),
                            ),
                            onTap: () {
                              scanNetwork();
                            },
                          ),
                        ],
                      ),
            isEnd && !_isLoading
                ? Positioned(
                    child: Center(
                        child: Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primaryColor,
                    ),
                    child: Icon(Icons.wifi, size: 60, color: AppColors.white),
                    alignment: Alignment.center,
                  )))
                : isEnd && _isLoading
                    ? Positioned(
                        child: Center(
                            child: Container(
                        height: 150,
                        width: 150,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primaryColor,
                        ),
                        child:
                            Icon(Icons.wifi, size: 80, color: AppColors.white),
                        alignment: Alignment.center,
                      )))
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: deviceList.length,
                        itemBuilder: (context, index) {
                          int i = 1;
                          i += index;
                          return GestureDetector(
                            child: Card(
                              elevation: 0,
                              color: AppColors.white,
                              child: ListTile(
                                  contentPadding:
                                      EdgeInsets.fromLTRB(0, 0, 0, 20),
                                  leading: CircleAvatar(
                                    backgroundImage: ExactAssetImage(
                                        "assets/images/image2.jpg"),
                                    radius: 30,
                                  ),
                                  title: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      SizedBox(height: 10),
                                      Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "Device $i",
                                              style: GoogleFonts.openSans(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.black),
                                            ),
                                            Icon(Icons.arrow_forward)
                                          ]),
                                      SizedBox(height: 10),
                                    ],
                                  )),
                            ),
                            onTap: () {
                              AwesomeDialog(
                                context: context,
                                animType: AnimType.scale,
                                dialogType: DialogType.noHeader,
                                body: Center(
                                  child: Container(
                                    child: Column(
                                      children: [
                                        TextField(
                                          obscureText: true,
                                          onSubmitted: (value) {
                                            connectingToWifi(value);
                                          },
                                          onChanged: (value) {},
                                          controller:
                                              wifiPasswordController.value,
                                          cursorColor: HexColor("#fffaf5"),
                                          decoration: InputDecoration(
                                            hintText:
                                                "Please enter WiFi Password",
                                            contentPadding:
                                                const EdgeInsets.fromLTRB(
                                                    20, 0, 20, 0),
                                            hintStyle: GoogleFonts.openSans(
                                              fontSize: 15,
                                              color: HexColor("#8d8d8d"),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                btnOkOnPress: () {
                                  AwesomeDialog(
                                      context: context,
                                      dialogType: DialogType.success,
                                      animType: AnimType.rightSlide,
                                      title: 'Success!',
                                      desc:
                                          'WiFi has been connected and the plant device has been added successfully.',
                                      btnOkOnPress: () async {
                                        await FirebaseFirestore.instance
                                            .collection("plant_devices")
                                            .where("uid",
                                                isEqualTo: deviceList[index].id)
                                            .get()
                                            .then((event) async {
                                          if (event.docs.isNotEmpty) {
                                            String imageURL =
                                                "${event.docs.first.get("image_url")}";
                                            String plantName =
                                                "${event.docs.first.get("plant_name")}";
                                            String description =
                                                "${event.docs.first.get("description")}";
                                            String maxMoistureLevel =
                                                "${event.docs.first.get("max_moisture_level")}";
                                            String minMoistureLevel =
                                                "${event.docs.first.get("min_moisture_level")}";
                                            String minSunlightHour =
                                                "${event.docs.first.get("min_sunlight_hour")}";
                                            String maxSunlightHour =
                                                "${event.docs.first.get("max_sunlight_hour")}";
                                            String speciesName =
                                                "${event.docs.first.get("species_name")}";
                                            String type =
                                                "${event.docs.first.get("type")}";
                                            String waterScaleWarningLevel =
                                                "${event.docs.first.get("water_scale_warning_level")}";
                                            String isAlreadyProfiled = "false";
                                            String planterDeviceName =
                                                "Medium-Sized Planter";
                                            String
                                                sunlightCareProfileInformation =
                                                "${event.docs.first.get("sunlight_care_profile_information")}";
                                            String
                                                wateringCareProfileInformation =
                                                "${event.docs.first.get("watering_care_profile_information")}";
                                            await FirebaseFirestore.instance
                                                .collection(
                                                    "user_plant_devices")
                                                .add({
                                              "email": FirebaseAuth.instance
                                                      .currentUser?.email
                                                      .toString() ??
                                                  "user@gmail.com",
                                              "description": description,
                                              "max_moisture_level":
                                                  maxMoistureLevel,
                                              "max_sunlight_hour":
                                                  maxSunlightHour,
                                              "min_moisture_level":
                                                  minMoistureLevel,
                                              "min_sunlight_hour":
                                                  minSunlightHour,
                                              "plant_name": plantName,
                                              "planter_device_name":
                                                  "Medium-sized Planter",
                                              "is_already_profiled": false,
                                              "species_name": speciesName,
                                              "type": type,
                                              "uid": deviceList[index].id,
                                              "water_scale_warning_level":
                                                  waterScaleWarningLevel,
                                              "image_url": imageURL,
                                              "water_scale_warning_level":
                                                  waterScaleWarningLevel,
                                              "image_url": imageURL,
                                              "watering_care_profile_information":
                                                  wateringCareProfileInformation,
                                              "sunlight_care_profile_information":
                                                  sunlightCareProfileInformation,
                                              "is_fertilizer_turned_on": false,
                                              "is_light_sensor_turned_on": true,
                                              "is_reservoir_sensor_turned_on":
                                                  true,
                                              "is_water_sensor_turned_on": false
                                            });

                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      HomeScreenBody(),
                                                ));
                                          }
                                        });
                                      },
                                      btnOkColor: AppColors.primaryColor)
                                    ..show();
                                },
                              )..show();
                            },
                          );
                        },
                      ),
          ])),
    );
  }
}
