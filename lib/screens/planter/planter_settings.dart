import 'dart:convert';
import 'dart:async';
import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hortijoy_mobile_app/resources/my_textfield.dart';

import 'package:hortijoy_mobile_app/resources/text_style.dart';
import 'package:hortijoy_mobile_app/resources/my_button.dart';
import 'package:hortijoy_mobile_app/resources/colors.dart';
import 'package:hortijoy_mobile_app/resources/widget_properties.dart';
import 'package:hortijoy_mobile_app/screens/plant_library/plant_library_main.dart';
import 'package:hortijoy_mobile_app/screens/planter/planter_edit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:hortijoy_mobile_app/screens/planter/planter_select_care_profile.dart';
import 'package:hortijoy_mobile_app/screens/test_sensors/fill_fertilizer_screen.dart';
import 'package:hortijoy_mobile_app/screens/test_sensors/fill_water_reservoir_screen.dart';
import 'package:hortijoy_mobile_app/screens/test_sensors/light_sensor_test_screen.dart';
import 'package:hortijoy_mobile_app/screens/test_sensors/moisture_sensor_test_screen.dart';
import 'package:hortijoy_mobile_app/screens/home/home_page_body.dart';

class PlanterSettings extends StatefulWidget {
  final String plantId;
  final planterDetails;
  const PlanterSettings(
      {super.key, required this.planterDetails, required this.plantId});

  @override
  State<PlanterSettings> createState() => _PlanterSettingsState();
}

class _PlanterSettingsState extends State<PlanterSettings> {
  final customReminderController = TextEditingController();
  final editCustomReminderController = TextEditingController();

  // bool isSwitched = false;
  bool toggleReservoir = true;
  bool toggleFertilizer = true;
  bool togglereservoirrefill = true;
  bool toggleNutrient = false;
  bool toggleWater = false;
  bool togglefertilizerrefill = true;

  bool _isFromRefillWaterReservoir = false;

  bool controlLightIcon = true;
  bool controlMoistureIcon = false;
  bool controlReservoirIcon = false;
  bool controlNutrientIcon = false;

  List<String> hours = [];
  List<String> minutes = [];
  String selectedHour = "12";
  String selectedMinutes = "0";
  String selectedMedian = "AM";
  String reminderOutput = "Every at";
  bool isReminderFrequencyComplete = false;
  String selectedNumber = "";
  String selectedPeriod = "";
  int reminderCount = 0;

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
    AppColors.black,
    AppColors.black
  ];

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
      _fertilizerSubscription;

  double latestFertilizerValue = 236.00;

  @override
  void initState() {
    super.initState();
    askNotifPermission();
    setState(() {
      controlLightIcon = widget.planterDetails.isLightSensorTurnedOn;
      controlMoistureIcon = widget.planterDetails.isWaterSensorTurnedOn;
      controlReservoirIcon = widget.planterDetails.isReservoirSensorTurnedOn;
      controlNutrientIcon = widget.planterDetails.isFertilizerTurnedOn;

      for (int i = 1; i <= 12; i++) {
        setState(() {
          hours.add(i.toString());
        });
      }
      for (int i = 0; i < 60; i++) {
        setState(() {
          minutes.add(i.toString());
        });
      }
    });

    getReminderCount();

    getRemindersValue();

    getLatestFertilizerReading();
  }

  @override
  void dispose() {
    _fertilizerSubscription?.cancel();
    super.dispose();
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
            latestFertilizerValue = double.parse(
                snapshot.docs[0].get("fertilizer_volume").toString());
          });
        } else {
          setState(() {
            latestFertilizerValue = 236.00;
          });
        }
      });
    }
  }

  setFertilizerTrackerOn() {
    controlNutrientIcon = true;
  }

  setReservoirTrackerOn() {
    controlReservoirIcon = true;
  }

  sampleNotif(String message) async {
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
    // initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('ic_notification');
    final IOSInitializationSettings initializationSettingsIOS =
        IOSInitializationSettings();
    final MacOSInitializationSettings initializationSettingsMacOS =
        MacOSInitializationSettings();
    final InitializationSettings initializationSettings =
        InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsIOS,
            macOS: initializationSettingsMacOS);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails('hortijoy', 'hortijoy', 'hortijoy',
            importance: Importance.max,
            priority: Priority.high,
            showWhen: false);
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
        0,
        'Hortijoy Reminder',
        'Please do not forget to ' +
            message[0].toLowerCase() +
            message.substring(1) +
            " for the planter ${widget.planterDetails.planterDeviceName}",
        platformChannelSpecifics,
        payload: 'reminder');

    _addSampleNotif(
        'Hortijoy Reminder',
        'Please do not forget to ' +
            message[0].toLowerCase() +
            message.substring(1) +
            " for the planter ${widget.planterDetails.planterDeviceName}");
  }

  _addSampleNotif(String title, String subtitle) {
    FirebaseFirestore.instance.collection("notifications").add({
      "title": title,
      "subtitle": subtitle,
      "datetime_added": DateTime.now().toString(),
      "email": FirebaseAuth.instance.currentUser?.email.toString(),
      "is_read": false,
      "icon": "others",
      "created_at": Timestamp.now()
    });
  }

  _deleteReminder(String reminderTitle, String dateTimeAdded) async {
    var emailID = await FirebaseFirestore.instance
        .collection("reminders")
        .where("email",
            isEqualTo: FirebaseAuth.instance.currentUser?.email.toString())
        .where("reminder_title", isEqualTo: reminderTitle)
        .where("datetime_added", isEqualTo: dateTimeAdded)
        .where("plant_id", isEqualTo: widget.plantId.toString())
        .limit(1)
        .get();
    var userUID = emailID.docs.first.id;
    FirebaseFirestore.instance.collection("reminders").doc(userUID).delete();
    getReminderCount();
    AnimatedSnackBar.material(
      "Reminder is deleted successfully!",
      type: AnimatedSnackBarType.success,
      mobileSnackBarPosition: MobileSnackBarPosition.top,
      desktopSnackBarPosition: DesktopSnackBarPosition.topCenter,
    ).show(context);
  }

  askNotifPermission() async {
    // await FirebaseMessaging.instance.requestPermission(
    //   alert: true,
    //   announcement: false,
    //   badge: true,
    //   carPlay: false,
    //   criticalAlert: false,
    //   provisional: true,
    //   sound: true,
    // );

    //foreground notif for ios only
    /*
    FirebaseMessaging messaging = FirebaseMessaging.instance;
messaging.setForegroundNotificationPresentationOptions(
  alert: true,
  badge: true,
  sound: true);*/
  }

  _switchCareProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlanterSelectCareProfile(
          planterDetails: widget.planterDetails,
          isSwitching: true,
          selectedFilters: [],
        ),
      ),
    );
  }

  _deletePlanterProfile(BuildContext context) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.warning,
      animType: AnimType.topSlide,
      showCloseIcon: true,
      title: "Warning",
      desc: "Are you sure you want to delete this planter?",
      btnCancelOnPress: () {},
      btnOkOnPress: () async {
        await FirebaseFirestore.instance
            .collection("user_plant_devices")
            .doc(widget.plantId.toString())
            .delete();
        await Navigator.push(
            context, MaterialPageRoute(builder: (context) => HomeScreenBody()));
      },
    ).show();
  }

  _removeCareProfile() {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.warning,
      animType: AnimType.topSlide,
      showCloseIcon: true,
      title: "Warning",
      desc:
          "Are you sure you want to remove the plant care profile that is linked to this planter device? It will delete all data that are captured from this device. Do you want to continue?",
      btnCancelOnPress: () {},
      btnOkOnPress: () async {
        await FirebaseFirestore.instance
            .collection("user_plant_devices")
            .doc(widget.plantId.toString())
            .update({
          "is_already_profiled": false,
        });

        await Navigator.push(
            context, MaterialPageRoute(builder: (context) => HomeScreenBody()));
      },
    ).show();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: AppColors.white,
        appBar: AppBar(
          leading: Padding(
              padding: EdgeInsets.only(left: 20),
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: AppColors.primaryColor,
                ),
                onPressed: () {
                  var updates = {
                    "light_sensor": controlLightIcon,
                    "moisture_sensor": controlMoistureIcon,
                    "reservoir_sensor": controlReservoirIcon,
                    "fertilizer_sensor": controlNutrientIcon
                  };

                  print(
                      "_isFromRefillWaterReservoir: ${_isFromRefillWaterReservoir}");

                  if (_isFromRefillWaterReservoir) {
                    setState(() {
                      updates = {
                        "light_sensor": controlLightIcon,
                        "moisture_sensor": controlMoistureIcon,
                        "reservoir_sensor": true,
                        "fertilizer_sensor": controlNutrientIcon
                      };
                    });
                  }

                  getRemindersValue();
                  Navigator.pop(context, updates);
                },
              )),
          backgroundColor: AppColors.white,
          title: Text("Planter Settings",
              style: GoogleFonts.openSans(color: Colors.black)),
          actions: [
            // Padding(
            //     padding: EdgeInsets.only(right: 20),
            //     child: IconButton(
            //       icon: const Icon(Icons.edit_outlined, color: Colors.black),
            //       onPressed: () {
            //         Navigator.push(
            //             context,
            //             MaterialPageRoute(
            //               builder: (context) => EditPlanter(),
            //             ));
            //       },
            //     )),
          ],
          centerTitle: true,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          child: _buildDisplaySettings(context),
        ));
  }

  _updateSensor(String sensorType, bool value) async {
    var lightSensor = {"is_light_sensor_turned_on": value};

    var waterSensor = {"is_water_sensor_turned_on": value};

    var reservoirSensor = {"is_reservoir_sensor_turned_on": value};

    var fertilizerSensor = {"is_fertilizer_turned_on": value};

    var output;

    if (sensorType == "light") output = lightSensor;
    if (sensorType == "water") output = waterSensor;
    if (sensorType == "reservoir") output = reservoirSensor;
    if (sensorType == "fertilizer") output = fertilizerSensor;

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
        .update(output);
  }

  _updatePlanterReminder(String reminderName, bool isOn) async {
    var dataObject = {reminderName: isOn};

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
        .update(dataObject);
  }

  _buildDisplaySettings(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
              padding: EdgeInsets.only(left: 15),
              child: const Text("Controls",
                  style:
                      TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold))),
          const SizedBox(
            height: 20.0,
          ),
          _displayIconControls(context),
          const SizedBox(
            height: 15.0,
          ),
          Divider(
            color: Colors.black,
            thickness: 0.20,
          ),
          _displayReminders(context),
          const SizedBox(
            height: 16,
          ),
          CustomOutlinedButton(
            customColor: AppColors.primaryColor,
            onPressed: () {
              _switchCareProfile();
            },
            buttonText: 'Switch care profile',
          ),
          const SizedBox(height: 10),
          CustomOutlinedButton(
            customColor: AppColors.primaryColor,
            onPressed: () {
              _removeCareProfile();
            },
            buttonText: 'Remove care profile',
          ),
          const SizedBox(height: 10),
          CustomOutlinedButton(
            customColor: Colors.red,
            onPressed: () {
              _deletePlanterProfile(context);
            },
            buttonText: 'Delete planter',
          ),
          const SizedBox(height: 10)
        ],
      ),
    );
  }

  _displayIconControls(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            GestureDetector(
              onTap: () async {
                setState(() {
                  controlLightIcon = !controlLightIcon;

                  _updateSensor("light", controlLightIcon);

                  if (controlLightIcon)
                    AwesomeDialog(
                      context: context,
                      animType: AnimType.scale,
                      dialogType: DialogType.success,
                      btnOkColor: AppColors.primaryColor,
                      title: 'Success',
                      desc: 'Light sensor is turned on',
                      btnOkOnPress: () {},
                    )..show();
                  else
                    AwesomeDialog(
                      context: context,
                      animType: AnimType.scale,
                      dialogType: DialogType.success,
                      btnOkColor: AppColors.primaryColor,
                      title: 'Success',
                      desc: 'Light sensor is turned off',
                      btnOkOnPress: () {},
                    )..show();
                });
              },
              child: Container(
                margin: const EdgeInsets.all(8.0),
                padding: const EdgeInsets.all(15.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  color: controlLightIcon
                      ? const Color(0xff475743)
                      : const Color(0xffF8F9FE),
                ),
                child: Image.asset(
                  'assets/icons/Light_Icon.png',
                  fit: BoxFit.fitHeight,
                  height: 24,
                  width: 24,
                  color: controlLightIcon
                      ? const Color(0xffF8F9FE)
                      : const Color(0xff475743),
                ),
              ),
            ),
            const Text("Light")
          ],
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            GestureDetector(
              onTap: () {
                setState(() {
                  controlMoistureIcon = !controlMoistureIcon;

                  _updateSensor("water", controlMoistureIcon);

                  if (controlMoistureIcon)
                    AwesomeDialog(
                      context: context,
                      animType: AnimType.scale,
                      btnOkColor: AppColors.primaryColor,
                      dialogType: DialogType.success,
                      title: 'Success',
                      desc: 'Moisture sensor is turned on',
                      btnOkOnPress: () {},
                    )..show();
                  else
                    AwesomeDialog(
                      context: context,
                      animType: AnimType.scale,
                      dialogType: DialogType.success,
                      title: 'Success',
                      btnOkColor: AppColors.primaryColor,
                      desc: 'Moisture sensor is turned off',
                      btnOkOnPress: () {},
                    )..show();
                });
              },
              child: Container(
                margin: const EdgeInsets.all(9.0),
                padding: const EdgeInsets.all(15.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  color: controlMoistureIcon
                      ? const Color(0xff475743)
                      : const Color(0xffF8F9FE),
                ),
                child: Image.asset(
                  'assets/icons/Moisture_Icon.png',
                  fit: BoxFit.fitHeight,
                  height: 24,
                  width: 24,
                  color: controlMoistureIcon
                      ? const Color(0xffF8F9FE)
                      : const Color(0xff475743),
                ),

                // Icon(
                //   Icons.water_drop_outlined,
                //   color: controlMoistureIcon
                //       ? const Color(0xffF8F9FE)
                //       : const Color(0xff475743),
                // )
              ),
            ),
            const Text("Moisture")
          ],
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            GestureDetector(
              onTap: () {
                setState(() {
                  // controlLightIcon = false;
                  // controlMoistureIcon = false;
                  controlReservoirIcon = !controlReservoirIcon;
                  // controlNutrientIcon = false;

                  _updateSensor("reservoir", controlReservoirIcon);

                  if (controlReservoirIcon)
                    AwesomeDialog(
                      context: context,
                      animType: AnimType.scale,
                      dialogType: DialogType.success,
                      btnOkColor: AppColors.primaryColor,
                      title: 'Success',
                      desc: 'Reservoir sensor is turned on',
                      btnOkOnPress: () {},
                    )..show();
                  else
                    AwesomeDialog(
                      context: context,
                      animType: AnimType.scale,
                      btnOkColor: AppColors.primaryColor,
                      dialogType: DialogType.success,
                      title: 'Success',
                      desc: 'Reservoir sensor is turned off',
                      btnOkOnPress: () {},
                    )..show();
                });
              },
              child: Container(
                margin: const EdgeInsets.all(8.0),
                padding: const EdgeInsets.all(15.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(300),
                  color: controlReservoirIcon
                      ? const Color(0xff475743)
                      : const Color(0xffF8F9FE),
                ),
                child: Image.asset(
                  'assets/icons/Reservoir_Icon.png',
                  fit: BoxFit.fitWidth,
                  height: 24,
                  width: 24,
                  color: controlReservoirIcon
                      ? const Color(0xffF8F9FE)
                      : const Color(0xff475743),
                ),
                // child: Icon(
                //   Icons.water,
                //   color: controlReservoirIcon
                //       ? const Color(0xffF8F9FE)
                //       : const Color(0xff475743),
                // )
              ),
            ),
            const Text("Reservoir")
          ],
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            GestureDetector(
              onTap: () {
                setState(() {
                  if (!controlNutrientIcon) {
                    AwesomeDialog(
                      context: context,
                      animType: AnimType.scale,
                      dialogType: DialogType.warning,
                      btnOkColor: AppColors.primaryColor,
                      title: 'Warning',
                      desc:
                          'Notice: Need to fill fertilizer reservoir first. Select “Fill Fertilizer” in Planter Settings.',
                      btnOkOnPress: () {},
                    )..show();
                  } else {
                    //236.59 ml max volume per refill
                    if (latestFertilizerValue < 10.00) {
                      controlNutrientIcon = !controlNutrientIcon;

                      _updateSensor("fertilizer", controlNutrientIcon);

                      AwesomeDialog(
                        context: context,
                        animType: AnimType.scale,
                        dialogType: DialogType.success,
                        btnOkColor: AppColors.primaryColor,
                        title: 'Success',
                        desc: 'Fertilizer tracker is turned off',
                        btnOkOnPress: () {},
                      )..show();
                    } else {
                      AwesomeDialog(
                        context: context,
                        animType: AnimType.scale,
                        dialogType: DialogType.warning,
                        btnOkColor: AppColors.primaryColor,
                        title: 'Warning',
                        desc:
                            'Notice: Need to stay ON to track remaining fertilizer',
                        btnOkOnPress: () {},
                      )..show();
                    }
                  }
                });
              },
              child: Container(
                margin: const EdgeInsets.all(8.0),
                padding: const EdgeInsets.all(15.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  color: controlNutrientIcon
                      ? const Color(0xff475743)
                      : const Color(0xffF8F9FE),
                ),
                child: Image.asset(
                  'assets/icons/Nutrient_Icon.png',
                  fit: BoxFit.fitWidth,
                  height: 24,
                  width: 24,
                  color: controlNutrientIcon
                      ? const Color(0xffF8F9FE)
                      : const Color(0xff475743),
                ),
              ),
            ),
            const Text("Fertilizer")
          ],
        ),
      ],
    );
  }

  _displayReminders(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.all(14.0),
          child: const Text("Reservoirs",
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(
          height: 10,
        ),
        Padding(
            padding: EdgeInsets.only(left: 15, right: 20, bottom: 25),
            child: GestureDetector(
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Fill Water Reservoir",
                      style: TextStyle(fontSize: 16),
                    ),
                    Icon(
                      Icons.chevron_right,
                      size: 24.0,
                      color: Colors.black,
                    ),
                  ]),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FillWaterReservoirScreen(
                          isFirstSetup: false,
                          planterDetails: widget.planterDetails,
                          isFromPlanterSettings: true),
                    )).then((value) {
                  // getRemindersValue();
                  // Check if the widget is still mounted
                  // if (mounted) {
                  setState(() {
                    _isFromRefillWaterReservoir = true;
                    widget.planterDetails.isReservoirSensorTurnedOn = true;
                    controlReservoirIcon = true;
                    togglereservoirrefill = false;
                  });
                  // }
                });
              },
            )),
        Padding(
            padding: EdgeInsets.only(left: 15, right: 20, bottom: 25),
            child: GestureDetector(
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Fill Fertilizer",
                      style: TextStyle(fontSize: 16),
                    ),
                    Icon(
                      Icons.chevron_right,
                      size: 24.0,
                      color: Colors.black,
                    ),
                  ]),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FillFertilizerScreen(
                        isFirstSetup: false,
                        planterDetails: widget.planterDetails,
                      ),
                    )).then((value) {
                  getRemindersValue();
                  setFertilizerTrackerOn();
                });
              },
            )),
        Divider(
          color: Colors.black,
          thickness: 0.20,
        ),
        Padding(
          padding: EdgeInsets.all(14.0),
          child: const Text("Reminders",
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
        ),
        Padding(
            padding: EdgeInsets.only(left: 15, right: 10),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Reservoir refill",
                    style: TextStyle(fontSize: 16),
                  ),
                  Transform.scale(
                    scaleX: 0.65,
                    scaleY: 0.65,
                    child: CupertinoSwitch(
                        value: togglereservoirrefill,
                        onChanged: (value) {
                          setState(() {
                            togglereservoirrefill = value;
                          });

                          _updatePlanterReminder(
                              "reservoir_refill", !togglereservoirrefill);
                        },
                        // activeTrackColor: const Color(0xff475743),
                        thumbColor: Color.fromARGB(255, 254, 254, 255),
                        trackColor: AppColors.primaryColor,
                        activeColor: Color.fromARGB(255, 254, 254, 255)),
                  ),
                ])),
        Padding(
            padding: EdgeInsets.only(left: 15, right: 10),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Fertilizer refill",
                    style: TextStyle(fontSize: 16),
                  ),
                  Transform.scale(
                    scaleX: 0.65,
                    scaleY: 0.65,
                    child: CupertinoSwitch(
                        value: togglefertilizerrefill,
                        onChanged: (value) {
                          setState(() {
                            togglefertilizerrefill = value;
                          });

                          _updatePlanterReminder(
                              "fertilizer_refill", !togglefertilizerrefill);
                        },
                        // activeTrackColor: const Color(0xff475743),
                        thumbColor: Color.fromARGB(255, 254, 254, 255),
                        trackColor: AppColors.primaryColor,
                        activeColor: Color.fromARGB(255, 254, 254, 255)),
                  ),
                ])),

        StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection('reminders')
                .orderBy("created_at", descending: true)
                .where("email",
                    isEqualTo:
                        FirebaseAuth.instance.currentUser?.email.toString())
                .where("plant_id", isEqualTo: widget.plantId.toString())
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data != null) {
                return ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      return Padding(
                          padding: EdgeInsets.only(left: 15, right: 10),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                    child: Text(
                                  snapshot.data!.docs[index]
                                      .data()["reminder_title"]
                                      .toString(),
                                  style: TextStyle(fontSize: 16),
                                )),
                                Row(children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit_outlined,
                                        color: Colors.black),
                                    onPressed: () {
                                      String selectedNumber = snapshot
                                          .data!.docs[index]
                                          .data()["selected_number"];
                                      String selectedPeriod = snapshot
                                          .data!.docs[index]
                                          .data()["selected_period"];
                                      String selectedHours = snapshot
                                          .data!.docs[index]
                                          .data()["selected_hours"];
                                      String selectedMinutes = snapshot
                                          .data!.docs[index]
                                          .data()["selected_minutes"];
                                      String selectedMedian = snapshot
                                          .data!.docs[index]
                                          .data()["selected_median"];
                                      String reminderTitle = snapshot
                                          .data!.docs[index]
                                          .data()["reminder_title"];
                                      bool isPaused = snapshot.data!.docs[index]
                                          .data()["is_paused"];
                                      String frequencyText = snapshot
                                          .data!.docs[index]
                                          .data()["frequency_text"];
                                      String dateTimeAdded = snapshot
                                          .data!.docs[index]
                                          .data()["datetime_added"];

                                      showEditModalDialog(
                                          selectedNumber,
                                          selectedPeriod,
                                          selectedHours,
                                          selectedMinutes,
                                          selectedMedian,
                                          reminderTitle,
                                          isPaused,
                                          frequencyText,
                                          dateTimeAdded);
                                    },
                                  ),
                                  IconButton(
                                      icon: const Icon(Icons.delete_outlined,
                                          color: Colors.black),
                                      onPressed: () {
                                        String dateTimeAdded = snapshot
                                            .data!.docs[index]
                                            .data()["datetime_added"];
                                        String reminderTitle = snapshot
                                            .data!.docs[index]
                                            .data()["reminder_title"];
                                        _deleteReminder(
                                            reminderTitle, dateTimeAdded);
                                      }),
                                ])
                              ]));
                    });
              } else {
                return Container();
              }
            }),
        SizedBox(height: 20),

        // Padding(
        //     padding: EdgeInsets.only(left: 15, right: 10, bottom: 25),
        //     child: Row(
        //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //         children: [
        //           const Text(
        //             "Open windows",
        //             style: TextStyle(fontSize: 16),
        //           ),
        //           IconButton(
        //             icon: const Icon(Icons.edit_outlined, color: Colors.black),
        //             onPressed: () {},
        //           ),
        //         ])),
        GestureDetector(
            onTap: () {
              if (reminderCount >= 2) {
                AnimatedSnackBar.material(
                  "You cannot add any reminder. Up to 2 records only.",
                  type: AnimatedSnackBarType.error,
                  mobileSnackBarPosition: MobileSnackBarPosition.top,
                  desktopSnackBarPosition: DesktopSnackBarPosition.topCenter,
                ).show(context);
              } else {
                showModalDialog();
              }
            },
            child: Container(
                height: 42,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(
                      style: BorderStyle.solid, color: AppColors.primaryColor),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: Icon(
                          Icons.add,
                          color: AppColors.primaryColor,
                        ),
                      ),
                      Text(
                        'Add reminder',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.openSans(
                          color: AppColors.primaryColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ]))),
        const SizedBox(height: 20),
        Divider(
          color: Colors.black,
          thickness: 0.20,
        ),
        Padding(
          padding: EdgeInsets.all(14.0),
          child: const Text("Tests",
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
        ),
        Padding(
            padding: EdgeInsets.only(left: 15, right: 20, bottom: 10, top: 10),
            child: GestureDetector(
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Test Light Sensor",
                      style: TextStyle(fontSize: 16),
                    ),
                    Icon(
                      Icons.chevron_right,
                      size: 24.0,
                      color: Colors.black,
                    ),
                  ]),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LightSensorTestScreen(
                        isFirstSetup: false,
                        planterDetails: widget.planterDetails,
                      ),
                    ));
              },
            )),
        Padding(
            padding: EdgeInsets.only(left: 15, right: 20, bottom: 10),
            child: GestureDetector(
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Test Moisture Sensor",
                      style: TextStyle(fontSize: 16),
                    ),
                    Icon(
                      Icons.chevron_right,
                      size: 24.0,
                      color: Colors.black,
                    ),
                  ]),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MoistureSensorTestScreen(
                        isFirstSetup: false,
                        planterDetails: widget.planterDetails,
                      ),
                    ));
              },
            )),
        Divider(
          color: Colors.black,
          thickness: 0.20,
        ),
      ],
    );
  }

  getRemindersValue() {
    FirebaseFirestore.instance
        .collection('user_plant_devices')
        .where("planter_device_name",
            isEqualTo: widget.planterDetails.planterDeviceName)
        .where("email",
            isEqualTo: FirebaseAuth.instance.currentUser?.email.toString())
        .get()
        .then((snapshot) {
      snapshot.docs.forEach((element) {
        try {
          setState(() {
            if (element.get("reservoir_refill").toString() == "true") {
              togglereservoirrefill = false;
            } else {
              togglereservoirrefill = true;
            }

            if (element.get("fertilizer_refill").toString() == "true") {
              togglefertilizerrefill = false;
            } else {
              togglefertilizerrefill = true;
            }
          });
        } catch (error) {}
      });
    });
  }

  getReminderCount() {
    FirebaseFirestore.instance
        .collection('reminders')
        .orderBy("created_at", descending: true)
        .where("plant_id", isEqualTo: widget.plantId.toString())
        .where("email",
            isEqualTo: FirebaseAuth.instance.currentUser?.email.toString())
        .get()
        .then((snapshot) {
      setState(() {
        reminderCount = snapshot.docs.length;
      });
    });
  }

  _changeValue(int index, String type, String value, StateSetter setState) {
    if (type == "frequency_number") {
      for (int i = 0; i <= 5; i++) {
        if (i != index) {
          setState(() {
            listButtonColor[i] = Color(0xFFEBEDEB);
            listButtonTextColor[i] = AppColors.black;
          });
        } else if (i == index) {
          setState(() {
            if (listButtonColor[index] == Color(0xFFEBEDEB)) {
              listButtonColor[index] = AppColors.primaryColor;
              listButtonTextColor[index] = AppColors.white;
              selectedNumber = value;
            } else {
              listButtonColor[index] = Color(0xFFEBEDEB);
              listButtonTextColor[index] = AppColors.black;
              selectedNumber = "";
            }
          });
        }
      }
    }

    if (type == "frequency_period") {
      for (int i = 6; i <= 8; i++) {
        if (i != index) {
          setState(() {
            listButtonColor[i] = Color(0xFFEBEDEB);
            listButtonTextColor[i] = AppColors.black;
          });
        } else if (i == index) {
          setState(() {
            if (listButtonColor[index] == Color(0xFFEBEDEB)) {
              listButtonColor[index] = AppColors.primaryColor;
              listButtonTextColor[index] = AppColors.white;
              selectedPeriod = value;
            } else {
              listButtonColor[index] = Color(0xFFEBEDEB);
              listButtonTextColor[index] = AppColors.black;
              selectedPeriod = "";
            }
          });
        }
      }
    }

    if (type == "frequency_meridian") {
      for (int i = 9; i <= 10; i++) {
        if (i != index) {
          setState(() {
            listButtonColor[i] = Color(0xFFEBEDEB);
            listButtonTextColor[i] = AppColors.black;
          });
        } else if (i == index) {
          setState(() {
            if (listButtonColor[index] == Color(0xFFEBEDEB)) {
              listButtonColor[index] = AppColors.primaryColor;
              listButtonTextColor[index] = AppColors.white;
              selectedMedian = value;
            } else {
              listButtonColor[index] = Color(0xFFEBEDEB);
              listButtonTextColor[index] = AppColors.black;
            }
          });
        }
      }
    }

    reminderOutput = "Every " +
        numberToText(selectedNumber) +
        " " +
        insertSuffix(selectedPeriod.toString().toLowerCase()) +
        " at " +
        selectedHour.toString() +
        ":" +
        formatMinutes(selectedMinutes) +
        " " +
        selectedMedian.toString();

    if (selectedNumber != "" &&
        selectedPeriod != "" &&
        selectedMedian != "" &&
        selectedHour != "" &&
        selectedMinutes != "") {
      setState(() {
        isReminderFrequencyComplete = true;
      });
    }
  }

  formatMinutes(String text) {
    if (text.length == 1) {
      return "0" + text;
    }

    return text;
  }

  insertSuffix(String text) {
    if (int.parse(selectedNumber) > 1 && selectedPeriod.isNotEmpty)
      return text + "s";

    return text;
  }

  numberToText(String text) {
    if (text == "1") return "one";
    if (text == "2") return "two";
    if (text == "3") return "three";
    if (text == "4") return "four";
    if (text == "5") return "five";

    return "six";
  }

  _addReminder() {
    FirebaseFirestore.instance.collection("reminders").add({
      "reminder_title": customReminderController.text.toString(),
      "frequency_text": reminderOutput,
      "datetime_added": DateTime.now().toString(),
      "email": FirebaseAuth.instance.currentUser?.email.toString(),
      "selected_number": selectedNumber,
      "selected_period": selectedPeriod,
      "selected_hours": selectedHour,
      "selected_minutes": selectedMinutes,
      "selected_median": selectedMedian,
      "created_at": Timestamp.now(),
      "is_paused": false,
      "plant_id": widget.plantId.toString()
    });

    AnimatedSnackBar.material(
      "Added successfully!",
      type: AnimatedSnackBarType.success,
      mobileSnackBarPosition: MobileSnackBarPosition.top,
      desktopSnackBarPosition: DesktopSnackBarPosition.topCenter,
    ).show(context);

    getReminderCount();
    Navigator.pop(context);

    sampleNotif(customReminderController.text.toString());
  }

  resetChipsState() {
    setState(() {
      reminderOutput = "Every at";
    });

    for (int i = 0; i <= 11; i++) {
      setState(() {
        listButtonColor[i] = Color(0xFFEBEDEB);
        listButtonTextColor[i] = AppColors.black;
      });
    }
  }

  _updateReminder(String oldReminderTitle, String oldFrequencyText,
      String dateTimeAdded) async {
    var emailID = await FirebaseFirestore.instance
        .collection("reminders")
        .where("email",
            isEqualTo: FirebaseAuth.instance.currentUser?.email.toString())
        .where("reminder_title", isEqualTo: oldReminderTitle)
        .where("frequency_text", isEqualTo: oldFrequencyText)
        .where("datetime_added", isEqualTo: dateTimeAdded)
        .where("plant_id", isEqualTo: widget.plantId.toString())
        .limit(1)
        .get();
    var userUID = emailID.docs.first.id;
    FirebaseFirestore.instance.collection("reminders").doc(userUID).update({
      "reminder_title": editCustomReminderController.text.toString(),
      "frequency_text": reminderOutput,
      "email": FirebaseAuth.instance.currentUser?.email.toString(),
      "selected_number": selectedNumber,
      "selected_period": selectedPeriod,
      "selected_hours": selectedHour,
      "selected_minutes": selectedMinutes,
      "selected_median": selectedMedian,
      "is_paused": false
    });

    AnimatedSnackBar.material(
      "Updated successfully!",
      type: AnimatedSnackBarType.success,
      mobileSnackBarPosition: MobileSnackBarPosition.top,
      desktopSnackBarPosition: DesktopSnackBarPosition.topCenter,
    ).show(context);
    Navigator.pop(context);

    sampleNotif(editCustomReminderController.text.toString());
  }

  showModalDialog() {
    resetChipsState();
    setState(() {
      customReminderController.text = "";
      selectedNumber = "";
      selectedPeriod = "";
      selectedMedian = "AM";
      isReminderFrequencyComplete = false;
    });

    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: AppColors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
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
                    height: 650,
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
                        Text("Add Custom Reminder",
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Color(0xff0b172e))),
                        SizedBox(height: 30),
                        Text(
                          "Name",
                          style: TextStyle(
                              color: Color(0xff0B172E),
                              fontWeight: FontWeight.bold),
                        ),
                        MyTextField2(
                          hintText: 'Choose a name for this reminder',
                          maxLine: 1,
                          obscureText: false,
                          controller: customReminderController,
                        ),
                        SizedBox(height: 30),
                        Text(
                          "Frequency",
                          style: TextStyle(
                              color: Color(0xff0B172E),
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 20),
                        Container(
                          decoration: BoxDecoration(
                              color: Color(0xffF8F9FE),
                              borderRadius: BorderRadius.circular(15)),
                          width: double.infinity,
                          height: 80,
                          child: Center(
                              child: Text(
                            reminderOutput,
                            style: TextStyle(color: Color(0xff6D7482)),
                          )),
                        ),
                        SizedBox(height: 10),
                        Container(
                            padding: EdgeInsets.only(left: 10),
                            child: Row(children: [
                              GestureDetector(
                                child: Chip(
                                  backgroundColor: listButtonColor[0],
                                  label: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      SizedBox(width: 6),
                                      Text("1",
                                          textAlign: TextAlign.center,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                  color:
                                                      listButtonTextColor[0])),
                                      SizedBox(width: 12),
                                    ],
                                  ),
                                ),
                                onTap: () {
                                  _changeValue(
                                      0, "frequency_number", "1", setState);
                                },
                              ),
                              SizedBox(width: 10),
                              GestureDetector(
                                child: Chip(
                                  backgroundColor: listButtonColor[1],
                                  label: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      SizedBox(width: 6),
                                      Text("2",
                                          textAlign: TextAlign.center,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                  color:
                                                      listButtonTextColor[1])),
                                      SizedBox(width: 12),
                                    ],
                                  ),
                                ),
                                onTap: () {
                                  _changeValue(
                                      1, "frequency_number", "2", setState);
                                },
                              ),
                              SizedBox(width: 10),
                              GestureDetector(
                                child: Chip(
                                  backgroundColor: listButtonColor[2],
                                  label: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      SizedBox(width: 6),
                                      Text("3",
                                          textAlign: TextAlign.center,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                  color:
                                                      listButtonTextColor[2])),
                                      SizedBox(width: 12),
                                    ],
                                  ),
                                ),
                                onTap: () {
                                  _changeValue(
                                      2, "frequency_number", "3", setState);
                                },
                              ),
                              SizedBox(width: 10),
                              GestureDetector(
                                child: Chip(
                                  backgroundColor: listButtonColor[3],
                                  label: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      SizedBox(width: 6),
                                      Text("4",
                                          textAlign: TextAlign.center,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                  color:
                                                      listButtonTextColor[3])),
                                      SizedBox(width: 12),
                                    ],
                                  ),
                                ),
                                onTap: () {
                                  _changeValue(
                                      3, "frequency_number", "4", setState);
                                },
                              ),
                              SizedBox(width: 10),
                              GestureDetector(
                                child: Chip(
                                  backgroundColor: listButtonColor[4],
                                  label: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      SizedBox(width: 6),
                                      Text("5",
                                          textAlign: TextAlign.center,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                  color:
                                                      listButtonTextColor[4])),
                                      SizedBox(width: 12),
                                    ],
                                  ),
                                ),
                                onTap: () {
                                  _changeValue(
                                      4, "frequency_number", "5", setState);
                                },
                              ),
                              SizedBox(width: 10),
                              GestureDetector(
                                child: Chip(
                                  backgroundColor: listButtonColor[5],
                                  label: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      SizedBox(width: 6),
                                      Text("6",
                                          textAlign: TextAlign.center,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                  color:
                                                      listButtonTextColor[5])),
                                      SizedBox(width: 12),
                                    ],
                                  ),
                                ),
                                onTap: () {
                                  _changeValue(
                                      5, "frequency_number", "6", setState);
                                },
                              ),
                            ])),
                        SizedBox(height: 20),
                        Container(
                            padding: EdgeInsets.only(left: 10),
                            child: Row(children: [
                              GestureDetector(
                                child: Chip(
                                  backgroundColor: listButtonColor[6],
                                  label: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      SizedBox(width: 20),
                                      Text("Day",
                                          textAlign: TextAlign.center,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                  color:
                                                      listButtonTextColor[6])),
                                      SizedBox(width: 20),
                                    ],
                                  ),
                                ),
                                onTap: () {
                                  _changeValue(
                                      6, "frequency_period", "Day", setState);
                                },
                              ),
                              SizedBox(width: 10),
                              GestureDetector(
                                child: Chip(
                                  backgroundColor: listButtonColor[7],
                                  label: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      SizedBox(width: 20),
                                      Text("Week",
                                          textAlign: TextAlign.center,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                  color:
                                                      listButtonTextColor[7])),
                                      SizedBox(width: 20),
                                    ],
                                  ),
                                ),
                                onTap: () {
                                  _changeValue(
                                      7, "frequency_period", "Week", setState);
                                },
                              ),
                              SizedBox(width: 10),
                              GestureDetector(
                                child: Chip(
                                  backgroundColor: listButtonColor[8],
                                  label: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      SizedBox(width: 20),
                                      Text("Month",
                                          textAlign: TextAlign.center,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                  color:
                                                      listButtonTextColor[8])),
                                      SizedBox(width: 20),
                                    ],
                                  ),
                                ),
                                onTap: () {
                                  _changeValue(
                                      8, "frequency_period", "Month", setState);
                                },
                              ),
                            ])),
                        SizedBox(height: 20),
                        Container(
                            padding: EdgeInsets.only(left: 10),
                            child: Row(children: [
                              Container(
                                  width: 70.0,
                                  child: DropdownButton(
                                    value: selectedHour,
                                    icon: const Icon(Icons.keyboard_arrow_down),
                                    isExpanded: true,
                                    items: hours.map((String items) {
                                      return DropdownMenuItem(
                                        value: items,
                                        child: Text(items),
                                      );
                                    }).toList(),
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        selectedHour = newValue!;
                                      });
                                      _changeValue(
                                          14, "none", "none", setState);
                                    },
                                  )),
                              SizedBox(width: 10),
                              Container(
                                  width: 70.0,
                                  child: DropdownButton(
                                    value: selectedMinutes,
                                    icon: const Icon(Icons.keyboard_arrow_down),
                                    isExpanded: true,
                                    items: minutes.map((String items) {
                                      return DropdownMenuItem(
                                        value: items,
                                        child: Text(items),
                                      );
                                    }).toList(),
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        selectedMinutes = newValue!;
                                      });
                                      _changeValue(
                                          14, "none", "none", setState);
                                    },
                                  )),
                              SizedBox(width: 10),
                              GestureDetector(
                                child: Chip(
                                  backgroundColor: listButtonColor[9],
                                  label: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      SizedBox(width: 10),
                                      Text("AM",
                                          textAlign: TextAlign.center,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                  color:
                                                      listButtonTextColor[9])),
                                      SizedBox(width: 10),
                                    ],
                                  ),
                                ),
                                onTap: () {
                                  _changeValue(
                                      9, "frequency_meridian", "AM", setState);
                                },
                              ),
                              SizedBox(width: 10),
                              GestureDetector(
                                child: Chip(
                                  backgroundColor: listButtonColor[10],
                                  label: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      SizedBox(width: 10),
                                      Text("PM",
                                          textAlign: TextAlign.center,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                  color:
                                                      listButtonTextColor[10])),
                                      SizedBox(width: 10),
                                    ],
                                  ),
                                ),
                                onTap: () {
                                  _changeValue(
                                      10, "frequency_meridian", "PM", setState);
                                },
                              ),
                            ])),
                        const SizedBox(
                          height: 30.0,
                        ),
                        Container(
                          padding: EdgeInsets.only(bottom: 10),
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            onPressed: () async {
                              if (customReminderController.text.isNotEmpty &&
                                  isReminderFrequencyComplete) {
                                _addReminder();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              primary:
                                  customReminderController.text.isNotEmpty &&
                                          isReminderFrequencyComplete
                                      ? AppColors.primaryColor
                                      : Color(0xFFEBEDEB),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: Text(
                              'Add Reminder',
                              style: TextStyle(
                                color:
                                    customReminderController.text.isNotEmpty &&
                                            isReminderFrequencyComplete
                                        ? Colors.white
                                        : AppColors.black,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            );
          });
        });
  }

  showEditModalDialog(
      String selectedNumber1,
      String selectedPeriod1,
      String selectedHours1,
      String selectedMinutes1,
      String selectedMedian1,
      String reminderTitle1,
      bool isPaused1,
      String frequencyText1,
      String dateTimeAdded) {
    resetChipsState();
    setState(() {
      editCustomReminderController.text = reminderTitle1;
      selectedNumber = selectedNumber1;
      selectedPeriod = selectedPeriod1;
      selectedHour = selectedHours1;
      selectedMinutes = selectedMinutes;
      selectedMedian = selectedMedian1;
      reminderOutput = frequencyText1;
    });

    if (selectedNumber1 == "1") {
      _changeValue(0, "frequency_number", "1", setState);
    } else if (selectedNumber1 == "2") {
      _changeValue(1, "frequency_number", "2", setState);
    } else if (selectedNumber1 == "3") {
      _changeValue(2, "frequency_number", "3", setState);
    } else if (selectedNumber1 == "4") {
      _changeValue(3, "frequency_number", "4", setState);
    } else if (selectedNumber1 == "5") {
      _changeValue(4, "frequency_number", "5", setState);
    } else if (selectedNumber1 == "6") {
      _changeValue(5, "frequency_number", "6", setState);
    }

    if (selectedPeriod1 == "Day") {
      _changeValue(6, "frequency_period", "Day", setState);
    } else if (selectedPeriod1 == "Week") {
      _changeValue(7, "frequency_period", "Week", setState);
    } else if (selectedPeriod1 == "Month") {
      _changeValue(8, "frequency_period", "Month", setState);
    }

    if (selectedMedian1 == "AM") {
      _changeValue(9, "frequency_meridian", "AM", setState);
    } else if (selectedMedian1 == "PM") {
      _changeValue(10, "frequency_meridian", "PM", setState);
    }

    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: AppColors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return Padding(
              padding: MediaQuery.of(context).viewInsets,
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom),
                  child: Container(
                    margin: const EdgeInsets.only(left: 20.0, right: 20.0),
                    height: 650,
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
                        Text("Edit Custom Reminder",
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Color(0xff0b172e))),
                        SizedBox(height: 30),
                        Text(
                          "Name",
                          style: TextStyle(
                              color: Color(0xff0B172E),
                              fontWeight: FontWeight.bold),
                        ),
                        MyTextField2(
                          hintText: 'Choose a name for this reminder',
                          maxLine: 1,
                          obscureText: false,
                          controller: editCustomReminderController,
                        ),
                        SizedBox(height: 30),
                        Text(
                          "Frequency",
                          style: TextStyle(
                              color: Color(0xff0B172E),
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 20),
                        Container(
                          decoration: BoxDecoration(
                              color: Color(0xffF8F9FE),
                              borderRadius: BorderRadius.circular(15)),
                          width: double.infinity,
                          height: 80,
                          child: Center(
                              child: Text(
                            reminderOutput,
                            style: TextStyle(color: Color(0xff6D7482)),
                          )),
                        ),
                        SizedBox(height: 10),
                        Container(
                            padding: EdgeInsets.only(left: 10),
                            child: Row(children: [
                              GestureDetector(
                                child: Chip(
                                  backgroundColor: listButtonColor[0],
                                  label: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      SizedBox(width: 6),
                                      Text("1",
                                          textAlign: TextAlign.center,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                  color:
                                                      listButtonTextColor[0])),
                                      SizedBox(width: 12),
                                    ],
                                  ),
                                ),
                                onTap: () {
                                  _changeValue(
                                      0, "frequency_number", "1", setState);
                                },
                              ),
                              SizedBox(width: 10),
                              GestureDetector(
                                child: Chip(
                                  backgroundColor: listButtonColor[1],
                                  label: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      SizedBox(width: 6),
                                      Text("2",
                                          textAlign: TextAlign.center,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                  color:
                                                      listButtonTextColor[1])),
                                      SizedBox(width: 12),
                                    ],
                                  ),
                                ),
                                onTap: () {
                                  _changeValue(
                                      1, "frequency_number", "2", setState);
                                },
                              ),
                              SizedBox(width: 10),
                              GestureDetector(
                                child: Chip(
                                  backgroundColor: listButtonColor[2],
                                  label: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      SizedBox(width: 6),
                                      Text("3",
                                          textAlign: TextAlign.center,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                  color:
                                                      listButtonTextColor[2])),
                                      SizedBox(width: 12),
                                    ],
                                  ),
                                ),
                                onTap: () {
                                  _changeValue(
                                      2, "frequency_number", "3", setState);
                                },
                              ),
                              SizedBox(width: 10),
                              GestureDetector(
                                child: Chip(
                                  backgroundColor: listButtonColor[3],
                                  label: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      SizedBox(width: 6),
                                      Text("4",
                                          textAlign: TextAlign.center,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                  color:
                                                      listButtonTextColor[3])),
                                      SizedBox(width: 12),
                                    ],
                                  ),
                                ),
                                onTap: () {
                                  _changeValue(
                                      3, "frequency_number", "4", setState);
                                },
                              ),
                              SizedBox(width: 10),
                              GestureDetector(
                                child: Chip(
                                  backgroundColor: listButtonColor[4],
                                  label: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      SizedBox(width: 6),
                                      Text("5",
                                          textAlign: TextAlign.center,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                  color:
                                                      listButtonTextColor[4])),
                                      SizedBox(width: 12),
                                    ],
                                  ),
                                ),
                                onTap: () {
                                  _changeValue(
                                      4, "frequency_number", "5", setState);
                                },
                              ),
                              SizedBox(width: 10),
                              GestureDetector(
                                child: Chip(
                                  backgroundColor: listButtonColor[5],
                                  label: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      SizedBox(width: 12),
                                      Text("6",
                                          textAlign: TextAlign.center,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                  color:
                                                      listButtonTextColor[5])),
                                      SizedBox(width: 12),
                                    ],
                                  ),
                                ),
                                onTap: () {
                                  _changeValue(
                                      5, "frequency_number", "6", setState);
                                },
                              ),
                            ])),
                        SizedBox(height: 20),
                        Container(
                            padding: EdgeInsets.only(left: 10),
                            child: Row(children: [
                              GestureDetector(
                                child: Chip(
                                  backgroundColor: listButtonColor[6],
                                  label: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      SizedBox(width: 20),
                                      Text("Day",
                                          textAlign: TextAlign.center,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                  color:
                                                      listButtonTextColor[6])),
                                      SizedBox(width: 20),
                                    ],
                                  ),
                                ),
                                onTap: () {
                                  _changeValue(
                                      6, "frequency_period", "Day", setState);
                                },
                              ),
                              SizedBox(width: 10),
                              GestureDetector(
                                child: Chip(
                                  backgroundColor: listButtonColor[7],
                                  label: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      SizedBox(width: 20),
                                      Text("Week",
                                          textAlign: TextAlign.center,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                  color:
                                                      listButtonTextColor[7])),
                                      SizedBox(width: 20),
                                    ],
                                  ),
                                ),
                                onTap: () {
                                  _changeValue(
                                      7, "frequency_period", "Week", setState);
                                },
                              ),
                              SizedBox(width: 10),
                              GestureDetector(
                                child: Chip(
                                  backgroundColor: listButtonColor[8],
                                  label: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      SizedBox(width: 20),
                                      Text("Month",
                                          textAlign: TextAlign.center,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                  color:
                                                      listButtonTextColor[8])),
                                      SizedBox(width: 20),
                                    ],
                                  ),
                                ),
                                onTap: () {
                                  _changeValue(
                                      8, "frequency_period", "Month", setState);
                                },
                              ),
                            ])),
                        SizedBox(height: 20),
                        Container(
                            padding: EdgeInsets.only(left: 10),
                            child: Row(children: [
                              Container(
                                  width: 70.0,
                                  child: DropdownButton(
                                    value: selectedHour,
                                    icon: const Icon(Icons.keyboard_arrow_down),
                                    isExpanded: true,
                                    items: hours.map((String items) {
                                      return DropdownMenuItem(
                                        value: items,
                                        child: Text(items),
                                      );
                                    }).toList(),
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        selectedHour = newValue!;
                                      });
                                      _changeValue(
                                          14, "none", "none", setState);
                                    },
                                  )),
                              SizedBox(width: 10),
                              Container(
                                  width: 70.0,
                                  child: DropdownButton(
                                    value: selectedMinutes,
                                    icon: const Icon(Icons.keyboard_arrow_down),
                                    isExpanded: true,
                                    items: minutes.map((String items) {
                                      return DropdownMenuItem(
                                        value: items,
                                        child: Text(items),
                                      );
                                    }).toList(),
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        selectedMinutes = newValue!;
                                      });
                                      _changeValue(
                                          14, "none", "none", setState);
                                    },
                                  )),
                              SizedBox(width: 10),
                              GestureDetector(
                                child: Chip(
                                  backgroundColor: listButtonColor[9],
                                  label: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      SizedBox(width: 10),
                                      Text("AM",
                                          textAlign: TextAlign.center,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                  color:
                                                      listButtonTextColor[9])),
                                      SizedBox(width: 10),
                                    ],
                                  ),
                                ),
                                onTap: () {
                                  _changeValue(
                                      9, "frequency_meridian", "AM", setState);
                                },
                              ),
                              SizedBox(width: 10),
                              GestureDetector(
                                child: Chip(
                                  backgroundColor: listButtonColor[10],
                                  label: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      SizedBox(width: 10),
                                      Text("PM",
                                          textAlign: TextAlign.center,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                  color:
                                                      listButtonTextColor[10])),
                                      SizedBox(width: 10),
                                    ],
                                  ),
                                ),
                                onTap: () {
                                  _changeValue(
                                      10, "frequency_meridian", "PM", setState);
                                },
                              ),
                            ])),
                        const SizedBox(
                          height: 30.0,
                        ),
                        Container(
                          padding: EdgeInsets.only(bottom: 10),
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            onPressed: () async {
                              if (editCustomReminderController
                                      .text.isNotEmpty &&
                                  isReminderFrequencyComplete) {
                                _updateReminder(reminderTitle1, frequencyText1,
                                    dateTimeAdded);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              primary: editCustomReminderController
                                          .text.isNotEmpty &&
                                      isReminderFrequencyComplete
                                  ? AppColors.primaryColor
                                  : Color(0xFFEBEDEB),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: Text(
                              'Save Changes',
                              style: TextStyle(
                                color: editCustomReminderController
                                            .text.isNotEmpty &&
                                        isReminderFrequencyComplete
                                    ? Colors.white
                                    : AppColors.black,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            );
          });
        });
  }
}
