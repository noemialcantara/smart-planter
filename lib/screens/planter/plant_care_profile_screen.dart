import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hortijoy_mobile_app/api_services/plant_care_profile_api.dart';

// custom styles
import 'package:hortijoy_mobile_app/resources/text_style.dart';
import 'package:hortijoy_mobile_app/resources/my_button.dart';
import 'package:hortijoy_mobile_app/resources/colors.dart';

class PlantCareProfileScreen extends StatefulWidget {
  final plantDetails;
  PlantCareProfileScreen({super.key, this.plantDetails});

  @override
  State<PlantCareProfileScreen> createState() => _PlantCareProfileScreenState();
}

class _PlantCareProfileScreenState extends State<PlantCareProfileScreen> {
  String plantName = "";
  String description = "";
  String type = "";
  String speciesName = "";
  String standardLightIntensity = "";
  String standardWaterProfile = "";
  String plantDescription = "";
  String plantImageUrl = "";
  String _wateringDescription = "";
  String _sunlightDescription = "";
  String _pruningDescription = "";

  @override
  void initState() {
    super.initState();
    // SharedPreferenceService.getAddedPlanterUID().then((value) {
    //   setState(() {
    //     print(value.toString());
    //   });
    // });
    setState(() {
      plantName = widget.plantDetails.commonNames;
      description = widget.plantDetails.botanicalName;
      type = widget.plantDetails.plantType;
      speciesName = widget.plantDetails.plantType;
      plantImageUrl = widget.plantDetails.plantImageUrl;
      standardLightIntensity = widget.plantDetails.standardLightIntensity != ""
          ? widget.plantDetails.standardLightIntensity[0]
                  .toString()
                  .toUpperCase() +
              widget.plantDetails.standardLightIntensity.toString().substring(1)
          : "";
      standardWaterProfile =
          widget.plantDetails.standardWaterProfileStatus != ""
              ? widget.plantDetails.standardWaterProfileStatus[0]
                      .toString()
                      .toUpperCase() +
                  widget.plantDetails.standardWaterProfileStatus
                      .toString()
                      .substring(1)
              : "";
      plantDescription = widget.plantDetails.plantDescription;
      _wateringDescription = widget.plantDetails.wateringCareProfileInformation;
      _sunlightDescription = widget.plantDetails.sunlightCareProfileInformation;
    });

    _fetchProfileInformationAPI(description);
  }

  Future<void> _fetchProfileInformationAPI(String genusName) async {
    try {
      int speciesId = 0;

      final PlantCareProfileApi plantCareApi = PlantCareProfileApi();
      final genusInfo = await plantCareApi.fetchGenusId(genusName);

      speciesId = genusInfo.entries.first.value[0]["id"];

      final careProfileInfo = await plantCareApi.fetchDescription(speciesId);

      setState(() {
        // _wateringDescription = careProfileInfo
        //     .entries.first.value[0]["section"][0]["description"]
        //     .toString();
        // _sunlightDescription = careProfileInfo
        //     .entries.first.value[0]["section"][1]["description"]
        //     .toString();
        // _pruningDescription = careProfileInfo
        //     .entries.first.value[0]["section"][2]["description"]
        //     .toString();
      });
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: Text("Care Profile",
            style: GoogleFonts.openSans(
              color: Colors.black,
              fontSize: 16,
            )),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: AppColors.primaryColor,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [],
      ),
      body: SingleChildScrollView(
          child: Column(children: <Widget>[
        Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SizedBox(
                height: 6.0,
              ),
              _buildDisplayComprehensiveInformation(context),
            ],
          ),
        )
      ])),
    );
  }

  _buildDisplayComprehensiveInformation(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
      child: SingleChildScrollView(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          plantImageUrl != ""
              ? Container(
                  width: 200,
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: CircleAvatar(
                      radius: 500,
                      backgroundColor: AppColors.primaryColor,
                      backgroundImage:
                          NetworkImage(widget.plantDetails.plantImageUrl),
                    ),
                  ),
                  decoration: BoxDecoration(shape: BoxShape.circle),
                )
              : Image.asset('assets/images/profile_placeholder.png'),
          Container(
              margin: const EdgeInsets.only(left: 15.0, right: 15.0, top: 20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    description,
                    style: CustomTextStyle.headLine1,
                  ),
                  const SizedBox(
                    height: 5.0,
                  ),
                  Text(
                    plantName ?? "Plant Name",
                    style: CustomTextStyle.subtitle.copyWith(
                      fontWeight: FontWeight.normal,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(
                    height: 6.0,
                  ),
                  Text(type.toString(),
                      style: CustomTextStyle.subtitle
                          .copyWith(fontWeight: FontWeight.normal)),
                  const SizedBox(
                    height: 20.0,
                  ),
                  Text(
                    plantDescription,
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
                        children: <Widget>[
                          Text("Indoor Light",
                              style: GoogleFonts.openSans(
                                  fontSize: 18, fontWeight: FontWeight.w700)),
                          SizedBox(
                            height: 10.0,
                          ),
                          Text(
                            standardLightIntensity,
                            style: CustomTextStyle.subtitle,
                          )
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text("Water Needed",
                              style: GoogleFonts.openSans(
                                  fontSize: 18, fontWeight: FontWeight.w700)),
                          SizedBox(
                            height: 10.0,
                          ),
                          Text(
                            standardWaterProfile,
                            style: CustomTextStyle.subtitle,
                          )
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20.0),
                  const SizedBox(height: 20.0),

                  if (_sunlightDescription != "")
                    const Text(
                      "Sunlight",
                      style: CustomTextStyle.headLine3,
                    ),
                  if (_sunlightDescription != "")
                    const SizedBox(
                      height: 10.0,
                    ),
                  if (_sunlightDescription != "")
                    Text(
                      _sunlightDescription,
                      style: CustomTextStyle.paragraph,
                    ),
                  if (_sunlightDescription != "")
                    const SizedBox(
                      height: 20.0,
                    ),
                  if (_wateringDescription != "")
                    const Text(
                      "Watering",
                      style: CustomTextStyle.headLine3,
                    ),
                  if (_wateringDescription != "")
                    const SizedBox(
                      height: 10.0,
                    ),
                  if (_wateringDescription != "")
                    Text(
                      _wateringDescription,
                      style: CustomTextStyle.paragraph,
                    ),
                  if (_wateringDescription != "")
                    const SizedBox(
                      height: 20.0,
                    ),
                  // if (_pruningDescription != "")
                  //   const Text(
                  //     "Pruning",
                  //     style: CustomTextStyle.headLine3,
                  //   ),
                  // if (_pruningDescription != "")
                  //   const SizedBox(
                  //     height: 10.0,
                  //   ),
                  // if (_pruningDescription != "")
                  //   Text(
                  //     _pruningDescription,
                  //     style: CustomTextStyle.paragraph,
                  //   ),
                  // if (_pruningDescription != "")
                  //   const SizedBox(
                  //     height: 20.0,
                  //   ),
                ],
              ))
        ],
      )),
    );
  }
}
