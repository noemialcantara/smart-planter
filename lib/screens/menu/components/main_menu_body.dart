import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/cupertino.dart';
import 'package:hortijoy_mobile_app/resources/text_style.dart';
import 'package:hortijoy_mobile_app/resources/my_button.dart';
import 'package:hortijoy_mobile_app/resources/colors.dart';
import 'package:hortijoy_mobile_app/resources/widget_properties.dart';
import 'package:hortijoy_mobile_app/screens/change_password/change_password.dart';
import 'package:hortijoy_mobile_app/screens/edit_profile/edit_profile_screen.dart';
import 'package:hortijoy_mobile_app/screens/home/components/privacy_screen.dart';
import 'package:hortijoy_mobile_app/screens/planter/planter_edit.dart';
import 'package:hortijoy_mobile_app/screens/home/components/help_center_screen.dart';
import 'package:hortijoy_mobile_app/screens/welcome/welcome_screen.dart';

class MainMenuBody extends StatefulWidget {
  const MainMenuBody({super.key});

  @override
  State<MainMenuBody> createState() => _MainMenuBodyState();
}

class _MainMenuBodyState extends State<MainMenuBody> {
  // bool isSwitched = false;
  bool toggleReservoir = false;
  bool toggleFertilizer = false;
  bool toggleMisting = false;
  bool togglePestCheck = false;

  // String controlHighlightIcon = "LIGHT";

  bool controlLightIcon = true;
  bool controlMoistureIcon = true;
  bool controlReservoirIcon = true;
  bool controlNutrientIcon = true;

  bool isPushNotificationOn = false;
  bool isPlanterReminderOn = false;
  bool isPlanterEventOn = false;
  bool isPromoEventOn = false;

  String zipcode = "";
  String username = "";
  String email = "";

  @override
  void initState() {
    super.initState();
    _fetchProfileDetails();
  }

  _fetchProfileDetails() async {
    await FirebaseFirestore.instance
        .collection("user")
        .where("email",
            isEqualTo: FirebaseAuth.instance.currentUser?.email.toString())
        .get()
        .then((event) async {
      setState(() {
        email = FirebaseAuth.instance.currentUser?.email.toString() ?? "";
        zipcode = event.docs.first.data()["address"].toString();
        username = event.docs.first.data()["name"].toString();
        isPushNotificationOn =
            event.docs.first.data()["is_push_notification_on"] == null
                ? false
                : !event.docs.first.data()["is_push_notification_on"];
        isPlanterReminderOn =
            event.docs.first.data()["is_planter_reminder_on"] == null
                ? false
                : !event.docs.first.data()["is_planter_reminder_on"];
        isPlanterEventOn =
            event.docs.first.data()["is_planter_event_on"] == null
                ? false
                : !event.docs.first.data()["is_planter_event_on"];
        isPromoEventOn = event.docs.first.data()["is_promo_event_on"] == null
            ? false
            : !event.docs.first.data()["is_promo_event_on"];
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: AppColors.primaryColor,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        elevation: 0,
        centerTitle: true,
        backgroundColor: AppColors.white,
        title: Text("General Settings",
            style: GoogleFonts.openSans(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.black)),
        actions: [],
      ),
      body: _buildDisplaySettings(context),
    );
  }

  _buildDisplaySettings(BuildContext context) {
    return SingleChildScrollView(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
            margin: const EdgeInsets.all(10.0),
            child: _displayReminders(context)),
        Divider(
          color: Colors.black,
          thickness: 0.5,
        ),
        const SizedBox(
          height: 20,
        ),
        Padding(
            padding: EdgeInsets.only(left: 20, right: 20),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: <
                    Widget>[
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(
                  "Profile",
                  style: CustomTextStyle.headLine2,
                ),
                GestureDetector(
                    child: Text(
                      "Edit Profile",
                      style: TextStyle(
                          fontSize: 16,
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.bold),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => EditProfileScreen()),
                      ).then((_) => {_fetchProfileDetails()});
                    }),
              ]),
              const SizedBox(
                height: 15,
              ),
              Text(
                "Email",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                email,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w200),
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Username",
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 10),
                        Text(
                          username,
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w200),
                        ),
                      ],
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Zip Code",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 10),
                        Text(
                          zipcode,
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w200),
                        ),
                      ],
                    ),
                  ]),
              const SizedBox(
                height: 10,
              ),
              Text(
                "Privacy Policy",
                textAlign: TextAlign.left,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 10,
              ),
              GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PrivacyPolicyScreen(),
                        ));
                  },
                  child: Text(
                    "https://www.hortijoy.com/privacy",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w200),
                  )),
              const SizedBox(
                height: 10,
              ),
            ])),
        SizedBox(height: 20),
        Padding(
            padding: EdgeInsets.only(left: 20, right: 20),
            child: CustomOutlinedButton(
              customColor: AppColors.primaryColor,
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChangePasswordScreen(),
                    ));
              },
              buttonText: 'Change Password',
            )),
        const SizedBox(height: 10),
        Padding(
            padding: EdgeInsets.only(left: 20, right: 20),
            child: CustomOutlinedButton(
              customColor: AppColors.primaryColor,
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HelpCenterScreen(),
                    ));
              },
              buttonText: 'Help Center',
            )),
        const SizedBox(height: 10),
        Padding(
            padding: EdgeInsets.only(left: 20, right: 20),
            child: CustomOutlinedButton(
              customColor: Colors.red,
              onPressed: () {
                signUserOut();
              },
              buttonText: 'Sign Out',
            )),
        const SizedBox(height: 30),
      ],
    ));
  }

  void signUserOut() {
    FirebaseAuth.instance.signOut();
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => WelcomeScreen(),
        ));
  }

  _updateReminder(String reminderName, bool isOn) async {
    var dataObject = {reminderName: isOn};

    var emailID = await FirebaseFirestore.instance
        .collection("user")
        .where("email",
            isEqualTo: FirebaseAuth.instance.currentUser?.email.toString())
        .limit(1)
        .get();

    var userUID = emailID.docs.first.id;

    FirebaseFirestore.instance
        .collection("user")
        .doc(userUID)
        .update(dataObject);
  }

  _displayReminders(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
            child: Text(
              "Notifications",
              style: CustomTextStyle.headLine2,
            ),
            padding: EdgeInsets.only(left: 15, right: 15)),
        const SizedBox(
          height: 5,
        ),
        ListTile(
          leading: const Text(
            "Push Notifications",
            style: TextStyle(fontSize: 16),
          ),
          trailing: Transform.scale(
              scale: 0.9,
              child: CupertinoSwitch(
                value: isPushNotificationOn,
                onChanged: (value) {
                  setState(() {
                    isPushNotificationOn = value;
                  });

                  _updateReminder(
                      "is_push_notification_on", !isPushNotificationOn);
                },
                trackColor: AppColors.primaryColor,
                activeColor: Colors.white,
                thumbColor: Colors.white,
              )),
        ),
        ListTile(
          leading:
              const Text("Planter Reminders", style: TextStyle(fontSize: 16)),
          trailing: Transform.scale(
              scale: 0.9,
              child: CupertinoSwitch(
                value: isPlanterReminderOn,
                onChanged: (value) {
                  setState(() {
                    isPlanterReminderOn = value;
                  });

                  _updateReminder(
                      "is_planter_reminder_on", !isPlanterReminderOn);
                },
                trackColor: AppColors.primaryColor,
                activeColor: Colors.white,
                thumbColor: Colors.white,
              )),
        ),
        ListTile(
          leading: const Text("Planter Events", style: TextStyle(fontSize: 16)),
          trailing: Transform.scale(
              scale: 0.9,
              child: CupertinoSwitch(
                value: isPlanterEventOn,
                onChanged: (value) {
                  setState(() {
                    isPlanterEventOn = value;
                  });

                  _updateReminder("is_planter_event_on", !isPlanterEventOn);
                },
                trackColor: AppColors.primaryColor,
                activeColor: Colors.white,
                thumbColor: Colors.white,
              )),
        ),
        ListTile(
          leading: const Text("Promo Event", style: TextStyle(fontSize: 16)),
          trailing: Transform.scale(
              scale: 0.9,
              child: CupertinoSwitch(
                value: isPromoEventOn,
                onChanged: (value) {
                  setState(() {
                    isPromoEventOn = value;
                  });

                  _updateReminder("is_promo_event_on", !isPromoEventOn);
                },
                trackColor: AppColors.primaryColor,
                activeColor: Colors.white,
                thumbColor: Colors.white,
              )),
        ),
      ],
    );
  }
}
