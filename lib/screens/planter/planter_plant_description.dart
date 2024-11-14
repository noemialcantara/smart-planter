import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hortijoy_mobile_app/api_services/plant_care_profile_api.dart';
import 'package:hortijoy_mobile_app/screens/planter/plant_care_profile_screen.dart';
import 'package:provider/provider.dart';

// custom styles
import 'package:hortijoy_mobile_app/resources/text_style.dart';
import 'package:hortijoy_mobile_app/resources/my_button.dart';
import 'package:hortijoy_mobile_app/resources/colors.dart';

class PlantDescriptions extends StatefulWidget {
  final planterDetails;
  PlantDescriptions({super.key, this.planterDetails});

  @override
  State<PlantDescriptions> createState() => _PlantDescriptionsState();
}

class _PlantDescriptionsState extends State<PlantDescriptions> {
  bool slideDownInformations = false;

  String plantName = "";
  String description = "";
  String type = "";
  String planterDeviceName = "";
  String speciesName = "";
  String standardLightIntensity = "";
  String standardWaterProfile = "";
  String plantDescription = "";
  String plantImageUrl = "";
  Map<String, dynamic> _careProfileInfo = {};
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
      plantName = jsonDecode(widget.planterDetails.plantName)
          .map((data) => data[0].toUpperCase() + data.toString().substring(1))
          .toList()
          .join(", ");
      description = widget.planterDetails.description;
      type = jsonDecode(widget.planterDetails.type)
          .map((data) => data[0].toUpperCase() + data.toString().substring(1))
          .toList()
          .join(", ");
      planterDeviceName = widget.planterDetails.planterDeviceName;
      speciesName = jsonDecode(widget.planterDetails.speciesName)
          .map((data) => data[0].toUpperCase() + data.toString().substring(1))
          .toList()
          .join(", ");
      plantDescription = "";
      _wateringDescription =
          widget.planterDetails?.wateringCareProfileInformation;
      _sunlightDescription =
          widget.planterDetails?.sunlightCareProfileInformation;
    });

    fetchPlantData(widget.planterDetails.plantName, widget.planterDetails.type);
  }

  fetchPlantData(String botanicalName, String type) async {
    await FirebaseFirestore.instance
        .collection("plant_library_test_first")
        .where("common_names", isEqualTo: botanicalName)
        .where("plant_type", isEqualTo: type)
        .get()
        .then((event) async {
      if (event.docs.isNotEmpty) {
        setState(() {
          standardLightIntensity =
              "${event.docs.first.get("standard_light_intensity").toString()[0].toUpperCase() + event.docs.first.get("standard_light_intensity").toString().substring(1)}";
          standardWaterProfile =
              "${event.docs.first.get("standard_water_profile_status").toString()[0].toUpperCase() + event.docs.first.get("standard_water_profile_status").toString().substring(1)}";
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 15.0, right: 15.0, top: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              const Text(
                "Care Profile",
                style: CustomTextStyle.headLine2,
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    slideDownInformations = !slideDownInformations;
                  });
                },
                child: Transform.rotate(
                  angle: slideDownInformations ? 3.14159 : 0.0,
                  child: const Icon(
                    Icons.keyboard_arrow_down,
                    size: 35,
                    color: AppColors.formTextColor,
                  ),
                ),
              )
            ],
          ),
          const SizedBox(
            height: 6.0,
          ),
          const Divider(),
          const SizedBox(
            height: 6.0,
          ),
          _buildDisplayComprehensiveInformation(context),
        ],
      ),
    );
  }

  _buildDisplayComprehensiveInformation(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
      child: SingleChildScrollView(
        child: slideDownInformations
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    speciesName,
                    style: CustomTextStyle.headLine1,
                  ),
                  const SizedBox(
                    height: 5.0,
                  ),
                  Text(
                    plantName ?? "Plant Name",
                    style: CustomTextStyle.subtitle
                        .copyWith(fontWeight: FontWeight.normal),
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
                          Text(
                            "Indoor Light",
                            style: CustomTextStyle.headLine3,
                          ),
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
                          Text(
                            "Water Needed",
                            style: CustomTextStyle.headLine3,
                          ),
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
              )
            : const SizedBox.shrink(),
      ),
    );
  }
}
