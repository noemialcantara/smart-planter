import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';

import 'package:hortijoy_mobile_app/resources/colors.dart';
import 'package:hortijoy_mobile_app/resources/my_textfield.dart';
import 'package:hortijoy_mobile_app/resources/my_button.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final usernameController = TextEditingController();
  final zipcodeController = TextEditingController();

  String enterZipcodeError = "";
  String enterUsernameError = "";

  // Loading state variable
  bool isLoading = false;

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
        zipcodeController.text = event.docs.first.data()["address"].toString();
        usernameController.text = event.docs.first.data()["name"].toString();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
        title: Text("Edit Profile",
            style: GoogleFonts.openSans(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.black)),
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
            const Text("Username",
                style: TextStyle(fontWeight: FontWeight.bold)),
            MyTextField2(
              controller: usernameController,
              hintText: "Enter your username",
              onChanged: () {
                if (usernameController.text.isNotEmpty) {
                  setState(() {
                    enterUsernameError = "";
                  });
                } else {
                  setState(() {
                    enterUsernameError = "Please enter username";
                  });
                }
              },
              obscureText: false,
              maxLine: 1,
            ),
            Text(
              enterUsernameError,
              style: TextStyle(color: Colors.redAccent),
            ),
            const SizedBox(
              height: 15.0,
            ),
            const Text("Zip Code",
                style: TextStyle(fontWeight: FontWeight.bold)),
            MyTextField2(
              controller: zipcodeController,
              onChanged: () {
                if (zipcodeController.text.isNotEmpty) {
                  setState(() {
                    enterZipcodeError = "";
                  });
                } else {
                  setState(() {
                    enterZipcodeError = "Please enter zipcode";
                  });
                }
              },
              hintText: "Enter your Zip Code",
              obscureText: false,
              maxLine: 1,
            ),
            Text(
              enterZipcodeError,
              style: TextStyle(color: Colors.redAccent),
            ),
            const SizedBox(
              height: 20.0,
            ),
            GestureDetector(
              onTap: isLoading ? null : _updateProfile,
              child: Container(
                padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                height: 45,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: HexColor('#475743'),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: isLoading
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              color: AppColors.white,
                              strokeWidth: 2.0,
                            ),
                          ),
                          SizedBox(width: 10),
                          Text(
                            "Saving...",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.openSans(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          )
                        ],
                      )
                    : Text(
                        "Save Changes",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.openSans(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _updateProfile() async {
    String username = usernameController.text;
    String zipcode = zipcodeController.text;
    enterUsernameError = "";
    enterZipcodeError = "";

    if (username.isEmpty) {
      setState(() {
        enterUsernameError = "Please enter username";
      });
    }

    if (zipcode.isEmpty) {
      setState(() {
        enterZipcodeError = "Please enter zip code";
      });
    }

    if (username.isNotEmpty && zipcode.isNotEmpty) {
      setState(() {
        isLoading = true;
      });
      await FirebaseFirestore.instance
          .collection("user")
          .where("email",
              isEqualTo: FirebaseAuth.instance.currentUser?.email.toString())
          .get()
          .then((event) async {
        if (event.docs.isNotEmpty) {
          await FirebaseFirestore.instance
              .collection("user")
              .doc(event.docs.first.id)
              .update({"name": username, "address": zipcode});

          setState(() {
            isLoading = false;
          });

          AwesomeDialog(
            context: context,
            animType: AnimType.scale,
            btnOkColor: AppColors.primaryColor,
            dialogType: DialogType.success,
            title: 'Success',
            desc: 'Your profile has been updated successfully!',
            btnOkOnPress: () {
              Navigator.pop(context);
            },
          )..show();
        }
      }).catchError((e) {
        setState(() {
          isLoading = false;
        });
        print("error fetching data: $e");
      });
    }
  }
}
