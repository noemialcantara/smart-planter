import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:async_task/async_task_extension.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hortijoy_mobile_app/manager/permission_manager.dart';
import 'package:hortijoy_mobile_app/resources/colors.dart';
import 'package:hortijoy_mobile_app/resources/my_button.dart';
import 'package:hortijoy_mobile_app/screens/planter/success_banner.dart/success.dart';
import 'package:http/http.dart' as http;
import 'package:hortijoy_mobile_app/models/device.dart';
import 'package:hortijoy_mobile_app/screens/add_device_bluetooth/device_list_item.dart';
import 'package:hortijoy_mobile_app/screens/wifi_provisioning/wifi_provisioning.dart';
import 'package:lan_scanner/lan_scanner.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter_gif/flutter_gif.dart';
import 'package:flutter_blue/flutter_blue.dart';

/// Example app for wifi_scan plugin.
class AddDeviceBluetooth extends StatefulWidget {
  const AddDeviceBluetooth({Key? key}) : super(key: key);

  @override
  State<AddDeviceBluetooth> createState() => _AddDeviceBluetoothState();
}

class _AddDeviceBluetoothState extends State<AddDeviceBluetooth> {
  FlutterBlue? flutterBlue = FlutterBlue.instance;
  // List<Device> deviceList = [];
  List<BluetoothDevice> deviceList = [];
  StreamSubscription? scanSubscription;
  double percent = 0.0;
  bool isEnd = true;
  bool btn = true;
  bool _isLoading = false;
  String? wifiName = " ";

  BluetoothDevice? connectedDevice;
  BluetoothCharacteristic? targetCharacteristic;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    // if (scanSubscription?.isBlank) scanSubscription?.cancel();
    if (scanSubscription != null) {
      scanSubscription?.cancel();
      flutterBlue?.stopScan();
    }
    //
    super.dispose();
  }

  scanNetwork() async {
    flutterBlue?.isScanning.then((value) {
      if (value.isBroadcast) {
        flutterBlue?.stopScan();
      }
    });

    PermissionManager().requestBluetoothPermission();
    setState(() {
      _isLoading = true;
    });
    // final info = NetworkInfo();
    // final scanner = LanScanner();
    // int i = 0;
    // List<String> sampleDeviceIds = [
    //   "PDID0000001",
    //   "PDID0000002",
    //   "PDID0000003",
    //   "PDID0000001",
    //   "PDID0000002",
    //   "PDID0000003",
    //   "PDID0000001",
    //   "PDID0000002",
    //   "PDID0000003",
    //   "PDID0000001",
    // ];

    setState(() {
      isEnd = false;
      btn = false;
      deviceList = [];

      percent = 0.0;
    });

    // final stream = scanner.icmpScan(subnet, progressCallback: (progress) {
    //   setState(() {
    //     percent = progress;
    //     print("PERCENTAGE: $percent");
    //     if (percent == 1.0) {
    //       isEnd = false;
    //       btn = true;
    //       _isLoading = false;
    //     }
    //   });
    // });
    try {
      scanSubscription = flutterBlue?.scan().listen((scanResult) {
        setState(() {
          deviceList.add(scanResult.device);
        });
      }, onDone: () {
        setState(() {
          isEnd = false;
          btn = true;
          _isLoading = false;
        });
      });
    } catch (exception) {}

    // stream.listen((HostModel device) {
    //   deviceList
    //       .add(Device(id: sampleDeviceIds[i].toString(), ipAddress: device.ip));
    //   i++;
    // });
  }

  Future<void> _connectToDevice(BluetoothDevice device) async {
    await device.connect();
    setState(() {
      connectedDevice = device;
    });

    // Discover services
    List<BluetoothService> services = await device.discoverServices();
    for (BluetoothService service in services) {
      for (BluetoothCharacteristic characteristic in service.characteristics) {
        if (characteristic.properties.write) {
          setState(() {
            targetCharacteristic = characteristic;
          });
        }
      }
    }
  }

  void stopScan() {
    flutterBlue?.stopScan();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Bluetooth Scanner",
          style: GoogleFonts.openSans(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.black),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: AppColors.primaryColor,
          ),
          onPressed: () {
            // Cancel the subscription only if it has been initialized
            if (scanSubscription != null) {
              scanSubscription?.cancel();
            }
            flutterBlue?.stopScan();
            setState(() {
              isEnd = false;
              btn = true;
              _isLoading = false;
            });
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
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Turn on your phone's bluetooth and place it close to the planter to start scanning.",
                        style: GoogleFonts.openSans(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 30),
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
                            'Scan for devices',
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
                          Text("Searching for devices..",
                              style: GoogleFonts.openSans(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              )),
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
                                'Stop Scanning',
                                style: GoogleFonts.openSans(
                                  color: AppColors.primaryColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              )),
                            ),
                            onTap: () {
                              scanSubscription?.cancel();
                              flutterBlue?.stopScan();
                              setState(() {
                                isEnd = false;
                                btn = true;
                                _isLoading = false;
                              });
                            },
                          ),
                        ],
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text("Didn't find your device? Try scanning again.",
                              style: GoogleFonts.openSans(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              )),
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
                                'Scan for devices',
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
                    bottom: 350,
                    left: 130,
                    child: Center(
                        child: Container(
                      height: 100,
                      width: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primaryColor,
                      ),
                      child: Image.asset(
                        'assets/icons/bluetooth.png',
                        scale: 1,
                      ),
                      alignment: Alignment.center,
                    )))
                : isEnd && _isLoading
                    ? Positioned(
                        bottom: 330,
                        left: 85,
                        child: Center(
                            child: Container(
                          height: 200,
                          width: 200,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primaryColor,
                          ),
                          child: Image.asset(
                            'assets/icons/bluetooth_loading.png',
                            scale: 1,
                          ),
                          alignment: Alignment.center,
                        )))
                    : Container(
                        height: MediaQuery.of(context).size.height -
                            (MediaQuery.of(context).size.height * .35),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: deviceList.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              child: Card(
                                elevation: 0,
                                color: AppColors.white,
                                child: ListTile(
                                    contentPadding:
                                        EdgeInsets.fromLTRB(0, 0, 0, 20),
                                    title: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        SizedBox(height: 10),
                                        Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                deviceList[index].name.isEmpty
                                                    ? deviceList[index]
                                                        .id
                                                        .toString()
                                                    : deviceList[index].name,
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
                                    animType: AnimType.leftSlide,
                                    dialogType: DialogType.noHeader,
                                    body: Center(
                                      child: Text(
                                        'Are you sure you want to connect to this planter device?',
                                        style: TextStyle(
                                            fontStyle: FontStyle.normal),
                                      ),
                                    ),
                                    btnOkOnPress: () async {
                                      try {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  BluetoothPairDevice(
                                                      targetCharacteristic:
                                                          null),
                                            ));
                                        // _connectToDevice(deviceList[index])
                                        //     .then((value) {
                                        //   Navigator.push(
                                        //       context,
                                        //       MaterialPageRoute(
                                        //         builder: (context) =>
                                        //             BluetoothPairDevice(
                                        //                 targetCharacteristic:
                                        //                     targetCharacteristic),
                                        //       ));
                                        // }).onError((error, stackTrace) {
                                        //   AwesomeDialog(
                                        //       context: context,
                                        //       dialogType: DialogType.error,
                                        //       animType: AnimType.rightSlide,
                                        //       title: 'Error!',
                                        //       desc: jsonEncode(error),
                                        //       btnOkOnPress: () async {},
                                        //       btnOkColor:
                                        //           AppColors.primaryColor)
                                        //     ..show();
                                        // });
                                      } catch (error) {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  BluetoothPairDevice(
                                                      targetCharacteristic:
                                                          null),
                                            ));
                                      }

                                      // await FirebaseFirestore.instance
                                      //     .collection("plant_devices")
                                      //     .where("uid",
                                      //         isEqualTo:
                                      //             deviceList[index]
                                      //                 .id)
                                      //     .get()
                                      //     .then((event) async {
                                      //   if (event.docs.isNotEmpty) {
                                      //     String imageURL =
                                      //         "${event.docs.first.get("image_url")}";
                                      //     String plantName =
                                      //         "${event.docs.first.get("plant_name")}";
                                      //     String description =
                                      //         "${event.docs.first.get("description")}";
                                      //     String maxMoistureLevel =
                                      //         "${event.docs.first.get("max_moisture_level")}";
                                      //     String minMoistureLevel =
                                      //         "${event.docs.first.get("min_moisture_level")}";
                                      //     String minSunlightHour =
                                      //         "${event.docs.first.get("min_sunlight_hour")}";
                                      //     String maxSunlightHour =
                                      //         "${event.docs.first.get("max_sunlight_hour")}";
                                      //     String speciesName =
                                      //         "${event.docs.first.get("species_name")}";
                                      //     String type =
                                      //         "${event.docs.first.get("type")}";
                                      //     String
                                      //         waterScaleWarningLevel =
                                      //         "${event.docs.first.get("water_scale_warning_level")}";
                                      //     await FirebaseFirestore
                                      //         .instance
                                      //         .collection(
                                      //             "user_plant_devices")
                                      //         .add({
                                      //       "email": FirebaseAuth
                                      //               .instance
                                      //               .currentUser
                                      //               ?.email
                                      //               .toString() ??
                                      //           "user@gmail.com",
                                      //       "description":
                                      //           description,
                                      //       "max_moisture_level":
                                      //           maxMoistureLevel,
                                      //       "max_sunlight_hour":
                                      //           maxSunlightHour,
                                      //       "min_moisture_level":
                                      //           minMoistureLevel,
                                      //       "min_sunlight_hour":
                                      //           minSunlightHour,
                                      //       "plant_name": plantName,
                                      //       "species_name":
                                      //           speciesName,
                                      //       "type": type,
                                      //       "uid":
                                      //           deviceList[index].id,
                                      //       "water_scale_warning_level":
                                      //           waterScaleWarningLevel,
                                      //       "image_url": imageURL
                                      //     });
                                      //     AwesomeDialog(
                                      //         context: context,
                                      //         dialogType:
                                      //             DialogType.success,
                                      //         animType:
                                      //             AnimType.rightSlide,
                                      //         title: 'Success!',
                                      //         desc:
                                      //             'This planter device has been successfully added to your list',
                                      //         btnOkOnPress:
                                      //             () async {},
                                      //         btnOkColor: AppColors
                                      //             .primaryColor)
                                      //       ..show();
                                      //   }
                                      // }).catchError((e) => print(
                                      //         "error fetching data: $e"));
                                    },
                                    btnCancelOnPress: () {},
                                    btnCancelText: "No",
                                    btnOkText: "Yes",
                                    btnOkColor: AppColors.primaryColor)
                                  ..show();
                              },
                            );
                          },
                        )),
          ])),
    );
  }
}
