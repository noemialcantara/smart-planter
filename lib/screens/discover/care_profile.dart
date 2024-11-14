import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hortijoy_mobile_app/resources/shared_pref_service.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hortijoy_mobile_app/models/plants.dart';
// custom styles
import 'package:hortijoy_mobile_app/resources/text_style.dart';
import 'package:hortijoy_mobile_app/resources/my_button.dart';
import 'package:hortijoy_mobile_app/resources/colors.dart';
// screens imports
import 'package:hortijoy_mobile_app/screens/planter/planter_settings.dart';
import 'package:hortijoy_mobile_app/screens/planter/planter_setup.dart';

class CareProfile extends StatefulWidget {
  CareProfile({
    super.key,
    required this.index,
    required this.plantList,
  });

  final int index;
  final List<Plant> plantList;

  @override
  State<CareProfile> createState() => _CareProfileState();
}

class _CareProfileState extends State<CareProfile> {
  TextStyle setTextSize = CustomTextStyle.textSize;
  TextStyle setTitleSize2 = CustomTextStyle.headLine2;
  double iconSize = 24.0;

  String planterUid = "";
  bool isProfiled = false;
  String pickedImagePath = "";
  late PickedFile _image;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.black),
        backgroundColor: AppColors.white,
        title: Text("Care Profile",
            textAlign: TextAlign.center,
            style: GoogleFonts.openSans(color: Colors.black)),
      ),
      body: _buildProfileBody(context),
    );
  }

  _buildProfileBody(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SizedBox(
                height: 5.0,
              ),
              Image.asset('assets/images/profile_placeholder.png'),
              _plantProperties(context),
            ],
          ),
        ],
      ),
    );
  }

  _plantProperties(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.fromLTRB(15.0, 20.0, 15.0, 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.plantList[widget.index].botanicalName.toString(),
              style: CustomTextStyle.headLine1,
            ),
            const SizedBox(
              height: 5.0,
            ),
            Text(
              widget.plantList[widget.index].commonNames.toString(),
              style: CustomTextStyle.subtitle
                  .copyWith(fontWeight: FontWeight.normal),
            ),
            const SizedBox(
              height: 6.0,
            ),
            Text(widget.plantList[widget.index].plantType.toString(),
                style: CustomTextStyle.subtitle
                    .copyWith(fontWeight: FontWeight.normal)),
            const SizedBox(
              height: 20.0,
            ),
            const Text(
              "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",
              style: CustomTextStyle.paragraph,
            ),
            const SizedBox(
              height: 30.0,
            ),
            const Text(
              "Guides",
              style: CustomTextStyle.headLine2,
            ),
            const SizedBox(
              height: 20.0,
            ),
            Wrap(
              spacing: 40.0,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const <Widget>[
                    Text(
                      "Water Needed",
                      style: CustomTextStyle.headLine3,
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    Text(
                      "Medium",
                      style: CustomTextStyle.subtitle,
                    )
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const <Widget>[
                    Text(
                      "Indoor Light",
                      style: CustomTextStyle.headLine3,
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    Text(
                      "Bright",
                      style: CustomTextStyle.subtitle,
                    )
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20.0),
            const Text(
              "Soil Type",
              style: CustomTextStyle.headLine3,
            ),
            const SizedBox(
              height: 10.0,
            ),
            const Text(
              "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",
              style: CustomTextStyle.paragraph,
            ),
            const SizedBox(
              height: 20.0,
            ),
            const Text(
              "Humidity",
              style: CustomTextStyle.headLine3,
            ),
            const SizedBox(
              height: 10.0,
            ),
            const Text(
              "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",
              style: CustomTextStyle.paragraph,
            ),
            const SizedBox(
              height: 20.0,
            ),
            const Text(
              "Toxicity",
              style: CustomTextStyle.headLine3,
            ),
            const SizedBox(
              height: 10.0,
            ),
            const Text(
              "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",
              style: CustomTextStyle.paragraph,
            ),
            const SizedBox(
              height: 20.0,
            ),
            const Text(
              "Pest Control",
              style: CustomTextStyle.headLine3,
            ),
            const SizedBox(
              height: 10.0,
            ),
            const Text(
              "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",
              style: CustomTextStyle.paragraph,
            ),
            const SizedBox(
              height: 15.0,
            ),
          ],
        ));
  }
}
