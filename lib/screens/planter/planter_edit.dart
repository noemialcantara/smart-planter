import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:hortijoy_mobile_app/resources/colors.dart';
import 'package:hortijoy_mobile_app/resources/my_textfield.dart';
import 'package:hortijoy_mobile_app/resources/my_button.dart';

class EditPlanter extends StatefulWidget {
  final String planterId;
  final String oldPlanterName;
  final String oldLocationName;
  const EditPlanter(
      {required this.planterId,
      required this.oldPlanterName,
      required this.oldLocationName,
      Key? key})
      : super(key: key);

  @override
  State<EditPlanter> createState() => EditPlanterState();

  static dart() {}
}

class EditPlanterState extends State<EditPlanter> {
  final nameController = TextEditingController();
  final locationController = TextEditingController();

  var data = {};

  @override
  void initState() {
    super.initState();
    setValues();
  }

  setValues() {
    setState(() {
      nameController.text = widget.oldPlanterName;
      locationController.text = widget.oldLocationName;
    });
  }

  updatePlanterDetails() async {
    String name = nameController.text.toString();
    String location = locationController.text.toString();

    if (name.isEmpty) {
      AnimatedSnackBar.material(
        "Please don't leave the name blank!",
        type: AnimatedSnackBarType.error,
        mobileSnackBarPosition: MobileSnackBarPosition
            .top, // Position of snackbar on mobile devices
        desktopSnackBarPosition: DesktopSnackBarPosition
            .topCenter, // Position of snackbar on desktop devices
      ).show(context);
      return;
    } else if (location.isEmpty) {
      AnimatedSnackBar.material(
        "Please don't leave the location blank!",
        type: AnimatedSnackBarType.error,
        mobileSnackBarPosition: MobileSnackBarPosition
            .top, // Position of snackbar on mobile devices
        desktopSnackBarPosition: DesktopSnackBarPosition
            .topCenter, // Position of snackbar on desktop devices
      ).show(context);
      return;
    } else {
      setState(() {
        data["name"] = name;
        data["location"] = location;
      });

      await FirebaseFirestore.instance
          .collection("user_plant_devices")
          .doc(widget.planterId)
          .update({
        "planter_name": name,
        "planter_device_name": name,
        "description": location
      });

      AwesomeDialog(
        context: context,
        animType: AnimType.scale,
        btnOkColor: AppColors.primaryColor,
        dialogType: DialogType.success,
        title: 'Success',
        desc: 'This planter device details has been updated successfully!',
        btnOkOnPress: () {
          Navigator.pop(context, data);
        },
      )..show();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        title: Text("Edit Planter",
            style: GoogleFonts.openSans(color: Colors.black)),
        leading: IconButton(
          icon: const Icon(
            Icons.close,
            color: AppColors.primaryColor,
          ),
          onPressed: () {
            Navigator.pop(context, data);
          },
        ),
      ),
      body: _buildDisplayEdit(context),
    );
  }

  _buildDisplayEdit(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.fromLTRB(0.0, 30.0, 0.0, 0),
        width: MediaQuery.of(context).size.width * 0.9,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text("Name"),
            MyTextField2(
              controller: nameController,
              hintText: "Planter Name",
              obscureText: false,
              maxLine: 1,
            ),
            const SizedBox(
              height: 15.0,
            ),
            const Text("Location"),
            MyTextField2(
              controller: locationController,
              hintText: "Location details can be read here.",
              obscureText: false,
              maxLine: 3,
            ),
            const SizedBox(
              height: 20.0,
            ),
            MyCustomInfiniteButton(
              onPressed: () {
                updatePlanterDetails();
              },
              buttonText: "Save Changes",
            ),
          ],
        ),
      ),
    );
  }
}
