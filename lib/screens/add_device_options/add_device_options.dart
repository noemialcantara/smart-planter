import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hortijoy_mobile_app/resources/colors.dart';
import 'package:hortijoy_mobile_app/resources/my_button.dart';
import 'package:hortijoy_mobile_app/screens/add_device_bluetooth/add_device_bluetooth.dart';
import 'package:hortijoy_mobile_app/screens/qr/connecting_screen.dart';
import 'package:hortijoy_mobile_app/screens/qr/qr_screen.dart';
import 'package:http/http.dart' as http;
import 'package:hortijoy_mobile_app/models/device.dart';
import 'package:hortijoy_mobile_app/screens/add_device_bluetooth/device_list_item.dart';
import 'package:lan_scanner/lan_scanner.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter_gif/flutter_gif.dart';

/// Example app for wifi_scan plugin.
class AddDeviceOptions extends StatefulWidget {
  const AddDeviceOptions({Key? key}) : super(key: key);

  @override
  State<AddDeviceOptions> createState() => _AddDeviceOptionsState();
}

class _AddDeviceOptionsState extends State<AddDeviceOptions>
    with TickerProviderStateMixin {
  List<Device> deviceList = [];
  double percent = 0.0;
  bool isEnd = true;
  bool btn = true;
  String? wifiName = " ";

  @override
  void initState() {
    super.initState();
  }

  scanNetwork() async {
    final info = NetworkInfo();
    final scanner = LanScanner();
    int i = 0;
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

  Future<void> scanQR() async {
    String barcodeScanRes;
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', false, ScanMode.QR);

      await FirebaseFirestore.instance
          .collection("plant_devices")
          .where("uid", isEqualTo: barcodeScanRes)
          .get()
          .then((event) async {
        if (event.docs.isNotEmpty) {
          String imageURL = "${event.docs.first.get("image_url")}";
          String plantName = "${event.docs.first.get("plant_name")}";
          String description = "${event.docs.first.get("description")}";
          String maxMoistureLevel =
              "${event.docs.first.get("max_moisture_level")}";
          String minMoistureLevel =
              "${event.docs.first.get("min_moisture_level")}";
          String minSunlightHour =
              "${event.docs.first.get("min_sunlight_hour")}";
          String maxSunlightHour =
              "${event.docs.first.get("max_sunlight_hour")}";
          String speciesName = "${event.docs.first.get("species_name")}";
          String type = "${event.docs.first.get("type")}";
          String waterScaleWarningLevel =
              "${event.docs.first.get("water_scale_warning_level")}";
          String sunlightCareProfileInformation = "${event.docs.first.get("sunlight_care_profile_information")}";
          String wateringCareProfileInformation = "${event.docs.first.get("watering_care_profile_information")}";
          await FirebaseFirestore.instance
              .collection("user_plant_devices")
              .add({
            "email": FirebaseAuth.instance.currentUser?.email.toString() ??
                "user@gmail.com",
            "description": description,
            "max_moisture_level": maxMoistureLevel,
            "max_sunlight_hour": maxSunlightHour,
            "min_moisture_level": minMoistureLevel,
            "min_sunlight_hour": minSunlightHour,
            "plant_name": plantName,
            "species_name": speciesName,
            "type": type,
            "uid": barcodeScanRes,
            "water_scale_warning_level": waterScaleWarningLevel,
            "image_url": imageURL,
            "sunlight_care_profile_information": sunlightCareProfileInformation,
            "watering_care_profile_information": wateringCareProfileInformation
          });
          AwesomeDialog(
              context: context,
              dialogType: DialogType.success,
              animType: AnimType.rightSlide,
              title: 'Success!',
              desc:
                  'This planter device has been successfully added to your list',
              btnOkOnPress: () async {},
              btnOkColor: AppColors.primaryColor)
            ..show();
        }
      }).catchError((e) => print("error fetching data: $e"));
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }
    if (!mounted) return;
  }

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
            "Add Planter Device",
            style: GoogleFonts.openSans(color: AppColors.black),
          ),
          leading: IconButton(
            icon: Icon(
              Icons.close,
              color: AppColors.primaryColor,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        backgroundColor: AppColors.white,
        body: SingleChildScrollView(
            physics: ScrollPhysics(),
            child: Container(
              padding:
                  EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 30),
              child: Column(children: [
                Text(
                  "Choose from the available method below to add a planter device",
                  style: GoogleFonts.openSans(),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 40),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddDeviceBluetooth(),
                        ));
                  },
                  child: Container(
                    child: Column(
                      children: [
                        Card(
                            child: Container(
                                padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                                width: double.infinity,
                                height: 330,
                                child: Column(
                                  children: [
                                    SizedBox(height: 20),
                                    GifImage(
                                        height: 160,
                                        width: 160,
                                        image: AssetImage(
                                            "assets/images/WIFI.gif"),
                                        controller: flutterGifController2),
                                    SizedBox(height: 30),
                                    Text("Add Planter Device via Bluetooth",
                                        style: GoogleFonts.openSans(
                                            fontWeight: FontWeight.bold)),
                                    SizedBox(height: 10),
                                    Text(
                                      "Make sure that the bluetooth is on to see the list of planters.",
                                      style: GoogleFonts.openSans(),
                                      textAlign: TextAlign.center,
                                    )
                                  ],
                                ))),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),
                GestureDetector(
                    onTap: () {
                      scanQR();
                    },
                    child: Container(
                        child: Column(children: [
                      Card(
                          child: Container(
                              padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                              width: double.infinity,
                              height: 330,
                              child: Column(
                                children: [
                                  SizedBox(height: 20),
                                  GifImage(
                                      height: 180,
                                      width: 180,
                                      image: AssetImage(
                                          "assets/images/ScanQRCode.gif"),
                                      controller: flutterGifController),
                                  SizedBox(height: 30),
                                  Text("Add Planter Device via QR Code",
                                      style: GoogleFonts.openSans(
                                          fontWeight: FontWeight.bold)),
                                  SizedBox(height: 10),
                                  Text(
                                    "Scan the QR Code on the plant pot and it will automatically connect to this device",
                                    style: GoogleFonts.openSans(),
                                    textAlign: TextAlign.center,
                                  )
                                ],
                              ))),
                    ]))),
                SizedBox(height: 30),
              ]),
            )));
  }
}
