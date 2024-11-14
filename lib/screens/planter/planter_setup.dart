import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hortijoy_mobile_app/resources/firebase_firestore.dart';
import 'package:hortijoy_mobile_app/resources/shared_pref_service.dart';
import 'package:hortijoy_mobile_app/resources/widget_properties.dart';

import 'package:hortijoy_mobile_app/screens/planter/success_banner.dart/success.dart';

import 'package:hortijoy_mobile_app/resources/colors.dart';
import 'package:hortijoy_mobile_app/resources/my_textfield.dart';
import 'package:hortijoy_mobile_app/resources/my_button.dart';

class PlanterSetup extends StatefulWidget {
  final targetCharacteristic;
  const PlanterSetup({required this.targetCharacteristic, super.key});

  @override
  State<PlanterSetup> createState() => _PlanterSetup();
}

class _PlanterSetup extends State<PlanterSetup> {
  final nameController = TextEditingController();
  final locationController = TextEditingController();
  String email = "";
  String planterId = "";

  bool isLoading = false;

  @override
  void initState() {
    SharedPreferenceService.getLoggedInUserEmail().then((value) {
      setState(() {
        email = value.toString();
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.white,
        appBar: AppBar(
          elevation: 0,
          centerTitle: true,
          backgroundColor: AppColors.white,
          title: Text(
            "Planter Setup",
            style: GoogleFonts.openSans(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.black),
          ),
          leading: IconButton(
            icon: const Icon(
              Icons.close,
              color: AppColors.primaryColor,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: isLoading ? CustomLoadingScreen() : _buildDisplayEdit(context));
  }

  _buildDisplayEdit(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.fromLTRB(0.0, 30.0, 0.0, 0),
        width: MediaQuery.of(context).size.width * 0.9,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              "Name",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            MyTextField2(
              controller: nameController,
              hintText: "Create a name for this planter",
              obscureText: false,
              maxLine: 1,
            ),
            const SizedBox(
              height: 15.0,
            ),
            const Text(
              "Location",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            MyTextField2(
              controller: locationController,
              hintText: "Where is the planter located?",
              obscureText: false,
              maxLine: 3,
            ),
            const SizedBox(
              height: 20.0,
            ),
            MyCustomInfiniteButton(
              onPressed: () {
                setState(() {
                  isLoading = true;
                });
                try {
                  FirebaseQueries.postUserPlantDevices(
                    email,
                    nameController.text,
                    locationController.text,
                  ).then((docReference) {
                    setState(() {
                      planterId = docReference.toString();
                    });
                    SharedPreferenceService.setAddedPlanterUID(
                        docReference.toString());
                  });
                } on FirebaseException catch (e) {
                  setState(() {
                    isLoading = false;
                  });
                  AwesomeDialog(
                      context: context,
                      dialogType: DialogType.error,
                      animType: AnimType.rightSlide,
                      title: 'Error encountered!',
                      desc: e.message,
                      btnOkOnPress: () async {},
                      btnOkColor: AppColors.primaryColor);
                }
                setState(() {
                  isLoading = false;
                });
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SuccessBanner(
                        targetCharacteristic: widget.targetCharacteristic,
                        planterId: planterId),
                  ),
                );
              },
              buttonText: "Next",
            ),
          ],
        ),
      ),
    );
  }
}
