import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:hortijoy_mobile_app/resources/base.dart';
import 'package:hortijoy_mobile_app/resources/webview_contactus_screen.dart';
import 'package:hortijoy_mobile_app/screens/home/home_screen.dart';
import 'package:hortijoy_mobile_app/screens/planter/planter_edit.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hortijoy_mobile_app/resources/shared_pref_service.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hortijoy_mobile_app/models/plant_devices.dart';
import 'package:hortijoy_mobile_app/manager/permission_manager.dart';
// custom styles
import 'package:hortijoy_mobile_app/resources/text_style.dart';
import 'package:hortijoy_mobile_app/resources/my_button.dart';
import 'package:hortijoy_mobile_app/resources/colors.dart';
import 'package:hortijoy_mobile_app/resources/widget_properties.dart';
import 'package:hortijoy_mobile_app/screens/planter/chart/daylight_chart.dart';
import 'package:hortijoy_mobile_app/screens/planter/chart/water_chart.dart';
// screens imports
import 'package:hortijoy_mobile_app/screens/planter/planter_settings.dart';
import 'package:hortijoy_mobile_app/screens/planter/planter_select_care_profile.dart';
import 'package:hortijoy_mobile_app/screens/planter/planter_plant_description.dart';
import 'package:hortijoy_mobile_app/screens/planter/planter_setup.dart';
import 'package:screenshot/screenshot.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:url_launcher/url_launcher.dart';

class PlanterProfile extends StatefulWidget {
  final planterDetails;
  final hasDefaultClose;
  PlanterProfile(this.planterDetails, this.hasDefaultClose, {super.key});

  @override
  State<PlanterProfile> createState() => _PlanterProfileState();
}

class _PlanterProfileState extends State<PlanterProfile> {
  TextStyle setTextSize = CustomTextStyle.textSize;
  TextStyle setTitleSize2 = CustomTextStyle.headLine2;
  final ScreenshotController screenshotController = ScreenshotController();
  double iconSize = 24.0;

  bool isLightSensorTurnedOn = false;
  bool isWaterSensorTurnedOn = false;
  bool isReservoirSensorTurnedOn = false;
  bool isFertilizerTurnedOn = false;

  String planterUid = "";
  bool isProfiled = false;
  bool isLikeTapped = false;
  bool isDislikeTapped = false;
  bool isReadyToDisplay = false;
  String pickedImagePath = "";
  String useImageUrl = "";
  late PickedFile _image;

  String _nextChartGuide = "1";

  bool _isDaily = true;
  bool _isWeekly = false;
  bool _isMonthly = false;
  var pickedImage;
  File pickedFile = File("");

  Timer? timer;

  // Get time

  String latestLightValue = "0FC";
  String latestWaterReservoirValue = "0%";
  String latestMoistureValue = "0%";
  String latestFertilizerValue = "0%";

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
      _fertilizerSubscription;

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
      _moistureSubscription;

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
      _reservoirSubscription;

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _lightSubscription;

  double _lightIntensityDarkMin = 0;
  double _lightIntensityDarkMax = 200;
  double _lightIntensitySunnyMin = 2000;
  double _lightIntensitySunnyMax = 2100;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final twelveHoursBefore = now.subtract(const Duration(hours: 12));

    _fetchSensorData();

    SharedPreferenceService.getIsAlreadyProfiled().then((value) {
      setState(() {
        if (value == "true") {
          isProfiled = true;
        }
      });
    });

    if (timer != null && timer!.isActive) return;

    // setState(() {
    //   isReadyToDisplay = true;
    // });

    timer = Timer.periodic(const Duration(seconds: 7776000), (timer) {
      //7776000
      setState(() {
        isReadyToDisplay = true;
      });
    });

    getLatestLightReading();
    getLatestReservoirReading();
    getLatestMoistureReading();
    getLatestFertilizerReading();

    _fetchData();
  }

  @override
  void dispose() {
    _fertilizerSubscription?.cancel();
    _moistureSubscription?.cancel();
    _reservoirSubscription?.cancel();
    _lightSubscription?.cancel();
    super.dispose();
  }

  Future<void> _fetchData() async {
    var fileDocument = await FirebaseFirestore.instance
        .collection("plant_library_test_first")
        .where("common_names", isEqualTo: widget.planterDetails.plantName)
        .limit(1)
        .get();

    if (fileDocument.docs.isNotEmpty) {
      _parseLightIntensity(fileDocument.docs.first.data());
    } else {
      _parseLightIntensity({
        "light_intensity_dark": "<201",
        "light_intensity_too_sunny": ">1999"
      });
    }
  }

  getLatestLightReading() async {
    QuerySnapshot<Map<String, dynamic>> userDevices = await FirebaseFirestore
        .instance
        .collection('user_plant_devices')
        .where('planter_device_name',
            isEqualTo: widget.planterDetails.planterDeviceName)
        .where('email', isEqualTo: FirebaseAuth.instance.currentUser?.email)
        .limit(1)
        .get();

    if (userDevices.docs.isNotEmpty) {
      var deviceId = userDevices.docs.first.id;

      _lightSubscription = FirebaseFirestore.instance
          .collection('user_plant_devices')
          .doc(deviceId)
          .collection('light_readings')
          .orderBy('timestamp', descending: true)
          .limit(1)
          .snapshots()
          .listen((QuerySnapshot<Map<String, dynamic>> snapshot) {
        if (snapshot.docs.isNotEmpty) {
          setState(() {
            latestLightValue = snapshot.docs[0]
                    .get("foot_candle")
                    .toString()
                    .replaceAll(RegExp(r"\.0$"), "") +
                "FC";
          });
        } else {
          setState(() {
            latestLightValue = "1000FC"; //TODO: REMOVE THIS
          });
        }
      });
    }
  }

  getLatestReservoirReading() async {
    QuerySnapshot<Map<String, dynamic>> userDevices = await FirebaseFirestore
        .instance
        .collection('user_plant_devices')
        .where('planter_device_name',
            isEqualTo: widget.planterDetails.planterDeviceName)
        .where('email', isEqualTo: FirebaseAuth.instance.currentUser?.email)
        .limit(1)
        .get();

    if (userDevices.docs.isNotEmpty) {
      var deviceId = userDevices.docs.first.id;

      _reservoirSubscription = FirebaseFirestore.instance
          .collection('user_plant_devices')
          .doc(deviceId)
          .collection('water_readings')
          .orderBy('timestamp', descending: true)
          .limit(1)
          .snapshots()
          .listen((QuerySnapshot<Map<String, dynamic>> snapshot) {
        if (snapshot.docs.isNotEmpty) {
          setState(() {
            latestWaterReservoirValue = snapshot.docs[0]
                    .get("water_reservoir_level")
                    .toString()
                    .replaceAll(RegExp(r"\.0$"), "") +
                "%";
          });
        } else {
          setState(() {
            latestWaterReservoirValue = "100%"; //TODO: REMOVE THIS
          });
        }
      });
    }
  }

  getLatestMoistureReading() async {
    QuerySnapshot<Map<String, dynamic>> userDevices = await FirebaseFirestore
        .instance
        .collection('user_plant_devices')
        .where('planter_device_name',
            isEqualTo: widget.planterDetails.planterDeviceName)
        .where('email', isEqualTo: FirebaseAuth.instance.currentUser?.email)
        .limit(1)
        .get();

    if (userDevices.docs.isNotEmpty) {
      var deviceId = userDevices.docs.first.id;

      _moistureSubscription = FirebaseFirestore.instance
          .collection('user_plant_devices')
          .doc(deviceId)
          .collection('soil_moisture_readings')
          .orderBy('timestamp', descending: true)
          .limit(1)
          .snapshots()
          .listen((QuerySnapshot<Map<String, dynamic>> snapshot) {
        if (snapshot.docs.isNotEmpty) {
          setState(() {
            latestMoistureValue = snapshot.docs[0]
                    .get("soil_moisture_level")
                    .toString()
                    .replaceAll(RegExp(r"\.0$"), "") +
                "%";
          });
        } else {
          setState(() {
            latestMoistureValue = "100%"; //TODO: remove this
          });
        }
      });
    }
  }

  getLatestFertilizerReading() async {
    QuerySnapshot<Map<String, dynamic>> userDevices = await FirebaseFirestore
        .instance
        .collection('user_plant_devices')
        .where('planter_device_name',
            isEqualTo: widget.planterDetails.planterDeviceName)
        .where('email', isEqualTo: FirebaseAuth.instance.currentUser?.email)
        .limit(1)
        .get();

    if (userDevices.docs.isNotEmpty) {
      var deviceId = userDevices.docs.first.id;

      _fertilizerSubscription = FirebaseFirestore.instance
          .collection('user_plant_devices')
          .doc(deviceId)
          .collection('fertilizer_readings')
          .orderBy('timestamp', descending: true)
          .limit(1)
          .snapshots()
          .listen((QuerySnapshot<Map<String, dynamic>> snapshot) {
        if (snapshot.docs.isNotEmpty) {
          setState(() {
            latestFertilizerValue = ((double.parse(snapshot.docs[0]
                                .get("fertilizer_volume")
                                .toString()) /
                            236.00) *
                        100)
                    .toStringAsFixed(2)
                    .replaceAll(RegExp(r"\.0$"), "") +
                "%";
          });
        } else {
          setState(() {
            latestFertilizerValue = "100%"; //TODO: remove this
          });
        }
      });
    }
  }

  _fetchSensorData() {
    setState(() {
      isLightSensorTurnedOn = widget.planterDetails.isLightSensorTurnedOn;
      isWaterSensorTurnedOn = widget.planterDetails.isWaterSensorTurnedOn;
      isReservoirSensorTurnedOn =
          widget.planterDetails.isReservoirSensorTurnedOn;
      isFertilizerTurnedOn = widget.planterDetails.isFertilizerTurnedOn;
    });
  }

  Future<void> _pickImage(BuildContext context) async {
    final picker = ImagePicker();
    pickedImage = await picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        pickedFile = File(pickedImage!.path);
        pickedImagePath = pickedImage.path.toString();
      });

      String fileName = basename(pickedFile.path);
      var storageReference = await FirebaseStorage.instance
          .ref('planter_photos/${fileName}')
          .putFile(pickedFile);

      var downloadURL = await storageReference.ref.getDownloadURL();

      var emailID = await FirebaseFirestore.instance
          .collection("user_plant_devices")
          .where("planter_device_name",
              isEqualTo: widget.planterDetails.planterDeviceName)
          .limit(1)
          .get();
      var userUID = emailID.docs.first.id;

      FirebaseFirestore.instance
          .collection("user_plant_devices")
          .doc(userUID)
          .update({"planter_image_url": downloadURL});

      AwesomeDialog(
          context: context,
          dialogType: DialogType.success,
          animType: AnimType.rightSlide,
          title: 'Success!',
          desc: 'Photo has been added successfully',
          btnOkOnPress: () async {
            Navigator.pop(context);
          },
          btnOkColor: AppColors.primaryColor)
        ..show();
    }
  }

  void removePhoto(context) async {
    var emailID = await FirebaseFirestore.instance
        .collection("user_plant_devices")
        .where("planter_device_name",
            isEqualTo: widget.planterDetails.planterDeviceName)
        .limit(1)
        .get();
    var userUID = emailID.docs.first.id;

    FirebaseFirestore.instance
        .collection("user_plant_devices")
        .doc(userUID)
        .update({
      "planter_image_url":
          "https://www.pulsecarshalton.co.uk/wp-content/uploads/2016/08/jk-placeholder-image.jpg"
    });

    setState(() {
      pickedImagePath = "";
    });

    AwesomeDialog(
        context: context,
        dialogType: DialogType.success,
        animType: AnimType.rightSlide,
        title: 'Success!',
        desc: 'Photo has been removed successfully',
        btnOkOnPress: () async {
          Navigator.pop(context);
          Navigator.pop(context);
        },
        btnOkColor: AppColors.primaryColor)
      ..show();
  }

  void _useImage(context) async {
    var fileDocument = await FirebaseFirestore.instance
        .collection("plant_library_test_first")
        .where("common_names", isEqualTo: widget.planterDetails.plantName)
        .limit(1)
        .get();

    setState(() {
      useImageUrl =
          fileDocument.docs.first.data()["plant_image_url"].toString();
    });

    var emailID = await FirebaseFirestore.instance
        .collection("user_plant_devices")
        .where("planter_device_name",
            isEqualTo: widget.planterDetails.planterDeviceName)
        .limit(1)
        .get();
    var userUID = emailID.docs.first.id;

    FirebaseFirestore.instance
        .collection("user_plant_devices")
        .doc(userUID)
        .update({
      "planter_image_url": fileDocument.docs.first.data()["plant_image_url"]
    });

    AwesomeDialog(
        context: context,
        dialogType: DialogType.success,
        animType: AnimType.rightSlide,
        title: 'Success!',
        desc: 'Photo has been added successfully',
        btnOkOnPress: () async {
          Navigator.pop(context);
        },
        btnOkColor: AppColors.primaryColor)
      ..show();
  }

  Future<void> takePicture(BuildContext context) async {
    try {
      PermissionManager().requestCameraPermission();
      final ImagePicker picker = ImagePicker();
      pickedImage = await picker.pickImage(source: ImageSource.camera);

      if (pickedImage != null) {
        setState(() {
          pickedFile = File(pickedImage.path);
          pickedImagePath = pickedImage.path.toString();
        });

        String fileName = basename(pickedFile.path);
        var storageReference = await FirebaseStorage.instance
            .ref('planter_photos/${fileName}')
            .putFile(pickedFile);

        var downloadURL = await storageReference.ref.getDownloadURL();

        var emailID = await FirebaseFirestore.instance
            .collection("user_plant_devices")
            .where("planter_device_name",
                isEqualTo: widget.planterDetails.planterDeviceName)
            .limit(1)
            .get();
        var userUID = emailID.docs.first.id;

        FirebaseFirestore.instance
            .collection("user_plant_devices")
            .doc(userUID)
            .update({"planter_image_url": downloadURL});

        AwesomeDialog(
            context: context,
            dialogType: DialogType.success,
            animType: AnimType.rightSlide,
            title: 'Success!',
            desc: 'Photo has been added successfully',
            btnOkOnPress: () async {
              Navigator.pop(context);
            },
            btnOkColor: AppColors.primaryColor)
          ..show();
      }
    } catch (e) {
      print(e);
    }
  }

  _showModalBottomSheet(BuildContext context) {
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
            height: 280.0,
            child: Column(
              children: [
                Container(
                    margin: EdgeInsets.all(8.0),
                    width: 50,
                    height: 7,
                    decoration: const BoxDecoration(
                        color: Colors.black45,
                        borderRadius: BorderRadius.all(Radius.circular(20.0)))),
                Expanded(
                  child: ListView(
                    children: [
                      ListTile(
                          leading: Icon(Icons.camera_alt_outlined),
                          title: Text("Take a photo of your planter"),
                          onTap: () {
                            takePicture(context);
                          }),
                      ListTile(
                        leading: Icon(Icons.photo_outlined),
                        title: Text("Upload a photo of your planter"),
                        onTap: () {
                          _pickImage(context);
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.photo_outlined),
                        title: Text("Use care profile Image"),
                        onTap: () {
                          _useImage(context);
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.delete_outline),
                        title: Text("Remove photo"),
                        onTap: () {
                          removePhoto(context);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: Center(
            child: Text("Planter Profile",
                style: GoogleFonts.openSans(color: Colors.black))),
        leading: IconButton(
          icon: const Icon(
            Icons.close,
            color: AppColors.primaryColor,
          ),
          onPressed: () {
            if (widget.hasDefaultClose) {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => HomeScreen()));
            }
          },
        ),
        actions: [
          IconButton(
              icon: const Icon(
                Icons.settings,
                color: AppColors.black,
              ),
              onPressed: () async {
                var emailID = await FirebaseFirestore.instance
                    .collection("user_plant_devices")
                    .where("planter_device_name",
                        isEqualTo: widget.planterDetails.planterDeviceName)
                    .limit(1)
                    .get();
                var userUID = emailID.docs.first.id;

                PlantDevices plantDevices = widget.planterDetails;

                plantDevices.isLightSensorTurnedOn = isLightSensorTurnedOn;
                plantDevices.isWaterSensorTurnedOn = isWaterSensorTurnedOn;
                plantDevices.isReservoirSensorTurnedOn =
                    isReservoirSensorTurnedOn;
                plantDevices.isFertilizerTurnedOn = isFertilizerTurnedOn;

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PlanterSettings(
                        plantId: userUID.toString(),
                        planterDetails: plantDevices),
                  ),
                ).then((value) {
                  if (value != null) {
                    print('Returned data: ${jsonEncode(value)}');
                    setState(() {
                      isLightSensorTurnedOn = value["light_sensor"];
                      isWaterSensorTurnedOn = value["moisture_sensor"];
                      isReservoirSensorTurnedOn = value["reservoir_sensor"];
                      isFertilizerTurnedOn = value["fertilizer_sensor"];
                    });
                  }
                });
              }),
        ],
      ),
      body: _buildProfileBody(context),
    );
  }

  Future<void> _takeScreenshotAndShare() async {
    // Capture the screenshot
    final Uint8List? image = await screenshotController.capture();
    if (image == null) return;

    // Save the image to a file
    final directory = await getApplicationDocumentsDirectory();
    final imagePath = '${directory.path}/screenshot.png';
    final file = File(imagePath);
    await file.writeAsBytes(image);

    // Share the image using shareXFiles
    final xFile = XFile(imagePath);
    Share.shareXFiles([xFile],
        text: 'See my plants thriving with Hortijoy automated planter');
  }

  void _parseLightIntensity(Map<String, dynamic> data) {
    String darkIntensity = data["light_intensity_dark"];
    String sunnyIntensity = data["light_intensity_too_sunny"];

    setState(() {
      _lightIntensityDarkMin = _parseIntensityValue(darkIntensity, isMin: true);
      _lightIntensityDarkMax =
          _parseIntensityValue(darkIntensity, isMin: false);
      _lightIntensitySunnyMin =
          _parseIntensityValue(sunnyIntensity, isMin: true);
      _lightIntensitySunnyMax =
          _parseIntensityValue(sunnyIntensity, isMin: false);
    });
  }

  double _parseIntensityValue(String intensity, {required bool isMin}) {
    if (intensity.startsWith('>')) {
      return isMin ? double.parse(intensity.substring(1)) : 1100;
    } else if (intensity.startsWith('<')) {
      return isMin ? 0 : double.parse(intensity.substring(1));
    } else if (intensity.contains('-')) {
      var parts = intensity.split('-');
      return isMin ? double.parse(parts[0]) : double.parse(parts[1]);
    }
    return 0;
  }

  _buildProfileBody(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          Screenshot(
              controller: screenshotController,
              child: Container(
                  color: Colors.white,
                  child: Column(children: [
                    Container(
                      child: Stack(
                        alignment: Alignment.topRight,
                        children: [
                          useImageUrl != ""
                              ? Container(
                                  width: double.infinity,
                                  height: 1000,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: NetworkImage(useImageUrl),
                                      fit: BoxFit.fitWidth,
                                    ),
                                  ),
                                )
                              : pickedImagePath == ""
                                  ? widget.planterDetails.planterDeviceURL != ""
                                      ? Container(
                                          width: double.infinity,
                                          height: 1000,
                                          child: Image.network(
                                            widget.planterDetails
                                                .planterDeviceURL,
                                            fit: BoxFit
                                                .cover, // Ensures the image covers the entire container
                                          ),
                                        )
                                      : Container(
                                          width: double.infinity,
                                          height: 1000,
                                          child: Image.network(
                                            widget.planterDetails.imageURL,
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                  : Image.file(File(pickedImagePath)),
                          GestureDetector(
                            onTap: () {
                              _showModalBottomSheet(context);
                            },
                            child: Container(
                                margin: const EdgeInsets.all(8.0),
                                padding: const EdgeInsets.all(10.0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(100),
                                  color: AppColors.editIconColor,
                                ),
                                child: const Icon(Icons.edit)),
                          ),
                        ],
                      ),
                      height: 300,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Flexible(
                                  child: Row(
                                children: <Widget>[
                                  Flexible(
                                      child: GestureDetector(
                                    child: Text(
                                      widget.planterDetails.plantName == null
                                          ? "Planter Name"
                                          : widget
                                              .planterDetails.planterDeviceName,
                                      style: const TextStyle(
                                          fontSize: 25,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    onTap: () async {
                                      var emailID = await FirebaseFirestore
                                          .instance
                                          .collection("user_plant_devices")
                                          .where("planter_device_name",
                                              isEqualTo: widget.planterDetails
                                                  .planterDeviceName)
                                          .where("email",
                                              isEqualTo: FirebaseAuth
                                                  .instance.currentUser?.email)
                                          .get();
                                      String planterId = emailID.docs.first.id;
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => EditPlanter(
                                                  planterId: planterId,
                                                  oldLocationName: widget
                                                      .planterDetails
                                                      .description,
                                                  oldPlanterName: widget
                                                      .planterDetails
                                                      .planterDeviceName,
                                                )),
                                      ).then((value) {
                                        setState(() {
                                          widget.planterDetails.description =
                                              value["location"];
                                          widget.planterDetails
                                                  .planterDeviceName =
                                              value["name"];
                                        });
                                      });
                                    },
                                  )),
                                  const SizedBox(
                                    width: 5.0,
                                  ),
                                  const Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                  )
                                ],
                              )),
                              GestureDetector(
                                  child: SvgPicture.asset(
                                    "assets/icons/share_outline.svg",
                                    width: 20,
                                    height: 20,
                                  ),
                                  onTap: () async {
                                    _takeScreenshotAndShare();
                                  }),
                            ],
                          ),
                          const SizedBox(
                            height: 5.0,
                          ),
                          Text(widget.planterDetails.description ??
                              "No location available"),
                          _plantProperties(context),
                        ],
                      ),
                    ),
                  ]))),
          isProfiled
              ? Container()
              : Container(
                  margin: const EdgeInsets.only(left: 15.0, right: 15.0),
                  child: MyCustomInfiniteButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PlanterSelectCareProfile(
                          planterDetails: widget.planterDetails,
                          isSwitching: false,
                          selectedFilters: [],
                        ),
                      ),
                    ),
                    buttonText: 'Select care Profile',
                  ),
                ),
          if (isProfiled && isReadyToDisplay) _displayPlantReview(context),
          isProfiled ? _displayReports(context) : Container(),
        ],
      ),
    );
  }

  _displayPlantReview(BuildContext context) {
    return Container(
        margin: EdgeInsets.only(left: 25, right: 25),
        width: double.infinity,
        height: isLikeTapped || isDislikeTapped ? 170 : 130,
        decoration: BoxDecoration(
            color: Color(0xffEBEDEB),
            borderRadius: BorderRadius.all(Radius.circular(10))),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                  padding: EdgeInsets.only(left: 25, top: 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Plant Check",
                          style: GoogleFonts.openSans(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: AppColors.primaryColor)),
                      IconButton(
                          onPressed: () {
                            setState(() {
                              isReadyToDisplay = false;
                            });
                          },
                          icon: Icon(Icons.close))
                    ],
                  )),
              Padding(
                  padding: EdgeInsets.only(left: 25, right: 25),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                  padding: EdgeInsets.only(top: 8),
                                  child: Text("How is your plant doing so far?",
                                      style: GoogleFonts.openSans(
                                          fontWeight: FontWeight.normal,
                                          fontSize: 14,
                                          color: AppColors.primaryColor)))
                            ]),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            isLikeTapped = !isLikeTapped;
                            isDislikeTapped = false;
                          });
                        },
                        child: isLikeTapped
                            ? Image.asset(
                                'assets/images/tapped_like_review_icon.png')
                            : Image.asset('assets/images/like_review_icon.png'),
                      ),
                      SizedBox(width: 10),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            isDislikeTapped = !isDislikeTapped;
                            isLikeTapped = false;
                          });
                        },
                        child: isDislikeTapped
                            ? Image.asset(
                                'assets/images/tapped_dislike_review_icon.png')
                            : Image.asset(
                                'assets/images/dislike_review_icon.png'),
                      ),
                    ],
                  )),
              SizedBox(height: 18),
              if (isLikeTapped)
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
                      "Write a review",
                      style: GoogleFonts.openSans(
                        color: AppColors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    )),
                  ),
                  onTap: () async {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => WebviewContactus(),
                        ));
                  },
                ),
              if (isDislikeTapped)
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
                      "View Plant Care Tips",
                      style: GoogleFonts.openSans(
                        color: AppColors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    )),
                  ),
                  onTap: () async {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => WebviewContactus(),
                        ));
                  },
                )
            ]));
  }

  _plantProperties(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8.0, 15.0, 100.0, 8.0),
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                children: <Widget>[
                  SvgPicture.asset(
                    "assets/icons/light_outlined.svg",
                    width: 24,
                    height: 24,
                  ),
                  const SizedBox(
                    width: 8.0,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text("Light",
                          style: isLightSensorTurnedOn
                              ? GoogleFonts.openSans(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w700)
                              : GoogleFonts.openSans(
                                  color: Color(0xfff9DA2AB))),
                      if (isLightSensorTurnedOn)
                        Text(latestLightValue,
                            style: double.parse(latestLightValue.replaceAll("FC", "")) <
                                        _lightIntensitySunnyMin &&
                                    double.parse(latestLightValue.replaceAll("FC", "")) >
                                        _lightIntensityDarkMax
                                ? GoogleFonts.openSans(
                                    color: Color(0xfff36B37E),
                                    fontWeight: FontWeight.w700)
                                : int.parse(latestLightValue.replaceAll("FC", "")) <=
                                            _lightIntensityDarkMin &&
                                        int.parse(latestLightValue.replaceAll(
                                                "FC", "")) >=
                                            0
                                    ? GoogleFonts.openSans(
                                        color: Color(0xfff707D6D),
                                        fontWeight: FontWeight.w700)
                                    : GoogleFonts.openSans(
                                        color:
                                            Color.fromARGB(223, 223, 220, 58),
                                        fontWeight: FontWeight.w700)),
                      if (!isLightSensorTurnedOn)
                        Text(
                          "0FC",
                          style: GoogleFonts.openSans(
                              color: Color(0xfff9DA2AB),
                              fontWeight: FontWeight.w700),
                        ),
                    ],
                  )
                ],
              ),
              Row(
                children: <Widget>[
                  Image.asset(
                    "assets/icons/Moisture_Icon.png",
                    width: 18,
                    height: 24,
                    color: isWaterSensorTurnedOn
                        ? Colors.grey.shade600
                        : Color(0xfff9DA2AB),
                  ),
                  const SizedBox(
                    width: 8.0,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text("Moisture",
                          style: isWaterSensorTurnedOn
                              ? GoogleFonts.openSans(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w700)
                              : GoogleFonts.openSans(
                                  color: Color(0xfff9DA2AB))),
                      if (isWaterSensorTurnedOn)
                        Text(latestMoistureValue,
                            style: int.parse(latestMoistureValue.replaceAll("%", "")) <=
                                        100 &&
                                    int.parse(latestMoistureValue.replaceAll("%", "")) >=
                                        75
                                ? GoogleFonts.openSans(
                                    color: Color(0xfff36B37E),
                                    fontWeight: FontWeight.w700)
                                : int.parse(latestMoistureValue.replaceAll("%", "")) <=
                                            74 &&
                                        int.parse(latestMoistureValue
                                                .replaceAll("%", "")) >=
                                            25
                                    ? GoogleFonts.openSans(
                                        color:
                                            Color.fromARGB(223, 223, 220, 58),
                                        fontWeight: FontWeight.w700)
                                    : GoogleFonts.openSans(
                                        color: Color.fromARGB(255, 233, 26, 26),
                                        fontWeight: FontWeight.w700)),
                      if (!isWaterSensorTurnedOn)
                        Text("N/A",
                            style: GoogleFonts.openSans(
                                color: Color(0xfff9DA2AB))),
                    ],
                  )
                ],
              ),
            ],
          ),
          const SizedBox(height: 18.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                children: <Widget>[
                  SvgPicture.asset(
                    "assets/icons/water_outlined.svg",
                    width: iconSize,
                    height: iconSize,
                    color: isReservoirSensorTurnedOn
                        ? Colors.grey.shade600
                        : Color(0xfff9DA2AB),
                  ),
                  const SizedBox(
                    width: 8.0,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text("Reservoir",
                          style: isReservoirSensorTurnedOn
                              ? GoogleFonts.openSans(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w700)
                              : GoogleFonts.openSans(
                                  color: Color(0xfff9DA2AB))),
                      if (isReservoirSensorTurnedOn)
                        Text(latestWaterReservoirValue,
                            style: int.parse(latestWaterReservoirValue.replaceAll("%", "")) <=
                                        100 &&
                                    int.parse(latestWaterReservoirValue.replaceAll("%", "")) >=
                                        75
                                ? GoogleFonts.openSans(
                                    color: Color(0xfff36B37E),
                                    fontWeight: FontWeight.w700)
                                : int.parse(latestWaterReservoirValue.replaceAll("%", "")) <=
                                            74 &&
                                        int.parse(latestWaterReservoirValue
                                                .replaceAll("%", "")) >=
                                            25
                                    ? GoogleFonts.openSans(
                                        color:
                                            Color.fromARGB(223, 223, 220, 58),
                                        fontWeight: FontWeight.w700)
                                    : GoogleFonts.openSans(
                                        color: Color.fromARGB(255, 233, 26, 26),
                                        fontWeight: FontWeight.w700)),
                      if (!isReservoirSensorTurnedOn)
                        Text("N/A",
                            style: GoogleFonts.openSans(
                                color: Color(0xfff9DA2AB))),
                    ],
                  )
                ],
              ),
              Row(
                children: <Widget>[
                  SvgPicture.asset(
                    "assets/icons/nutrient.svg",
                    width: iconSize,
                    height: iconSize,
                    color: isFertilizerTurnedOn
                        ? Colors.grey.shade600
                        : Color(0xfff9DA2AB),
                  ),
                  const SizedBox(
                    width: 8.0,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text("Fertilizer",
                          style: isFertilizerTurnedOn
                              ? GoogleFonts.openSans(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w700)
                              : GoogleFonts.openSans(
                                  color: Color(0xfff9DA2AB))),
                      if (isFertilizerTurnedOn)
                        Text(
                            double.parse(latestFertilizerValue.replaceAll("%", "")) % 1 == 0
                                ? double.parse(latestFertilizerValue.replaceAll("%", "")).toStringAsFixed(0) +
                                    "%"
                                : double.parse(latestFertilizerValue.replaceAll("%", ""))
                                        .toStringAsFixed(2) +
                                    "%",
                            style: double.parse(latestFertilizerValue.replaceAll("%", "")) <= 100 &&
                                    double.parse(latestFertilizerValue.replaceAll("%", "")) >=
                                        75
                                ? GoogleFonts.openSans(
                                    color: Color(0xfff36B37E),
                                    fontWeight: FontWeight.w700)
                                : double.parse(latestFertilizerValue.replaceAll("%", "")) <= 74 &&
                                        double.parse(latestFertilizerValue.replaceAll("%", "")) >=
                                            10
                                    ? GoogleFonts.openSans(
                                        color:
                                            Color.fromARGB(223, 223, 220, 58),
                                        fontWeight: FontWeight.w700)
                                    : GoogleFonts.openSans(
                                        color: Color.fromARGB(255, 233, 26, 26),
                                        fontWeight: FontWeight.w700)),
                      if (!isFertilizerTurnedOn)
                        Text("N/A",
                            style: GoogleFonts.openSans(
                                color: Color(0xfff9DA2AB))),
                    ],
                  )
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  _displayReports(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(0.0, 30.0, 0.0, 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            margin: const EdgeInsets.only(left: 12.0, right: 12.0),
            child: Text(
              "REPORTS",
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(
            height: 15.0,
          ),
          Container(
            margin: const EdgeInsets.only(left: 12.0, right: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Daylight",
                  style: CustomTextStyle.headLine3,
                ),
                Wrap(
                  spacing: 5,
                  children: <Widget>[
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isDaily = true;
                          _isWeekly = false;
                          _isMonthly = false;
                        });
                      },
                      child: CustomContainerWeek(
                        textDisplay: "Daily",
                        bgColor:
                            _isDaily ? Color(0xff475743) : Color(0xffebedeb),
                        textColor:
                            _isDaily ? Color(0xffebedeb) : Color(0xff475743),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isDaily = false;
                          _isWeekly = true;
                          _isMonthly = false;
                        });
                      },
                      child: CustomContainerWeek(
                        textDisplay: "Weekly",
                        bgColor:
                            _isWeekly ? Color(0xff475743) : Color(0xffebedeb),
                        textColor:
                            _isWeekly ? Color(0xffebedeb) : Color(0xff475743),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isDaily = false;
                          _isWeekly = false;
                          _isMonthly = true;
                        });
                      },
                      child: CustomContainerWeek(
                        textDisplay: "Monthly",
                        bgColor:
                            _isMonthly ? Color(0xff475743) : Color(0xffebedeb),
                        textColor:
                            _isMonthly ? Color(0xffebedeb) : Color(0xff475743),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
          const SizedBox(
            height: 18.0,
          ),
          Container(
            margin: const EdgeInsets.only(left: 40.0, right: 40.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Wrap(spacing: 10, children: <Widget>[
                  Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          color: Color(0xfff707D6D),
                          border: Border.all(
                            width: 1,
                            color: Color(0xfff707D6D),
                          )),
                      child: Icon(
                        Icons.circle,
                        color: const Color(0xfffff9da),
                        size: 20,
                      )),
                  Text("Too Bright")
                ]),
                Wrap(spacing: 10, children: <Widget>[
                  Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          color: Color(0xfff707D6D),
                          border: Border.all(
                            width: 1,
                            color: Color(0xfff707D6D),
                          )),
                      child: Icon(Icons.circle,
                          color: const Color(0xffebedeb), size: 20)),
                  Text("Too dark")
                ]),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                        child: Image.asset(
                            "assets/images/chart_information_icon.png"),
                        onTap: () {
                          _showChartInfo(context);
                        }),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18.0),
          // Image.asset("assets/images/profile_placeholder.png"),

          // const DayLightChart(),
          _isDaily
              ? DailyChart(
                  planterDetails: widget.planterDetails,
                )
              : Container(),
          _isWeekly
              ? WeeklyChart(
                  planterDetails: widget.planterDetails,
                )
              : Container(),
          _isMonthly
              ? MonthChart(
                  planterDetails: widget.planterDetails,
                )
              : Container(),

          const SizedBox(
            height: 50.0,
          ),
          Container(
            margin: const EdgeInsets.only(left: 12.0, right: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Soil Moisture",
                  style: CustomTextStyle.headLine3,
                ),
                Wrap(
                  spacing: 5,
                  children: <Widget>[
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isDaily = true;
                          _isWeekly = false;
                          _isMonthly = false;
                        });
                      },
                      child: CustomContainerWeek(
                        textDisplay: "Daily",
                        bgColor:
                            _isDaily ? Color(0xff475743) : Color(0xffebedeb),
                        textColor:
                            _isDaily ? Color(0xffebedeb) : Color(0xff475743),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isDaily = false;
                          _isWeekly = true;
                          _isMonthly = false;
                        });
                      },
                      child: CustomContainerWeek(
                        textDisplay: "Weekly",
                        bgColor:
                            _isWeekly ? Color(0xff475743) : Color(0xffebedeb),
                        textColor:
                            _isWeekly ? Color(0xffebedeb) : Color(0xff475743),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isDaily = false;
                          _isWeekly = false;
                          _isMonthly = true;
                        });
                      },
                      child: CustomContainerWeek(
                        textDisplay: "Monthly",
                        bgColor:
                            _isMonthly ? Color(0xff475743) : Color(0xffebedeb),
                        textColor:
                            _isMonthly ? Color(0xffebedeb) : Color(0xff475743),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
          const SizedBox(
            height: 15.0,
          ),
          // const WaterChart(),
          _isDaily
              ? WaterDailyChart(
                  planterDetails: widget.planterDetails,
                )
              : Container(),
          _isWeekly
              ? WaterWeeklyChart(
                  planterDetails: widget.planterDetails,
                )
              : Container(),
          _isMonthly
              ? WaterMonthChart(
                  planterDetails: widget.planterDetails,
                )
              : Container(),
          const SizedBox(
            height: 15.0,
          ),
          PlantDescriptions(planterDetails: widget.planterDetails),
        ],
      ),
    );
  }

  _showChartInfo(BuildContext context) {
    return showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (BuildContext context, setState) {
            return FractionallySizedBox(
                heightFactor: 0.90,
                child: Container(
                  child: Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.all(8.0),
                        width: 50,
                        height: 7,
                        decoration: const BoxDecoration(
                            color: Colors.black45,
                            borderRadius:
                                BorderRadius.all(Radius.circular(20.0))),
                      ),
                      Flexible(
                          child: Column(
                        children: [
                          SizedBox(height: 50),
                          Padding(
                            child: Text(
                              'Light Chart Guide',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColors.primaryColor,
                                fontSize: 20.0,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            padding: EdgeInsets.only(left: 10, right: 10),
                          ),
                          SizedBox(height: 20),
                          Image.asset(
                            _nextChartGuide == "1"
                                ? 'assets/images/light_chart_guide1.png'
                                : _nextChartGuide == "2"
                                    ? 'assets/images/light_chart_guide2.png'
                                    : 'assets/images/light_chart_guide3.png',
                            // height: 400,
                          ),
                          Image.asset(
                            'assets/images/chart_x_axis_data_demo.png',
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Padding(
                            child: Text(
                              _nextChartGuide == "1"
                                  ? 'Ensure that the plant spends most of the daylight time in the ideal light zone.'
                                  : _nextChartGuide == "2"
                                      ? 'Adjust to a brighter space if the plant spends most of the daylight time in “Too Dark” zone.'
                                      : "Adjust to a shadier space if the plant spends most of the daylight time in “Too Bright” zone and shows signs of sunburn.",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.openSans(
                                color: AppColors.primaryColor,
                                fontSize: 16.0,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            padding: EdgeInsets.only(left: 30, right: 30),
                          ),
                          SizedBox(
                            height: 120,
                          ),
                          Image.asset(
                            _nextChartGuide == "1"
                                ? 'assets/images/points1.png'
                                : _nextChartGuide == "2"
                                    ? 'assets/images/points2.png'
                                    : 'assets/images/points3.png',
                            height: 50,
                          ),
                          const SizedBox(
                            height: 1,
                          ),
                          Padding(
                            child: GestureDetector(
                              child: Container(
                                height: 42,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: AppColors.primaryColor,
                                  borderRadius: BorderRadius.circular(30.0),
                                ),
                                child: Center(
                                    child: Text(
                                  _nextChartGuide == "3" ? 'Continue' : 'Next',
                                  style: GoogleFonts.openSans(
                                    color: AppColors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                )),
                              ),
                              onTap: () {
                                if (_nextChartGuide == "1") {
                                  setState(() {
                                    _nextChartGuide = "2";
                                  });
                                } else if (_nextChartGuide == "2") {
                                  setState(() {
                                    _nextChartGuide = "3";
                                  });
                                } else {
                                  setState(() {
                                    _nextChartGuide = "1";
                                  });
                                  Navigator.pop(context);
                                }
                              },
                            ),
                            padding: EdgeInsets.only(left: 60, right: 60),
                          ),
                        ],
                      )),
                    ],
                  ),
                ));
          });
        });
  }
}
