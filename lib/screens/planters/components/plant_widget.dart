import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hortijoy_mobile_app/models/plants.dart';
import 'package:hortijoy_mobile_app/models/plant_devices.dart';
import 'package:hortijoy_mobile_app/resources/colors.dart';
import 'package:hortijoy_mobile_app/screens/home/components/detail_page.dart';
import 'package:hortijoy_mobile_app/screens/planter/planter_plant_description.dart';
import 'package:page_transition/page_transition.dart';

class PlantWidget extends StatelessWidget {
  const PlantWidget(
      {Key? key,
      required this.index,
      required this.plantList,
      required this.documentId,
      required this.cont})
      : super(key: key);

  final int index;
  final List<PlantDevices> plantList;
  final String documentId;
  final BuildContext cont;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  PlantDescriptions(planterDetails: plantList),
            ));
      },
      child: SafeArea(
          child: Scaffold(
              backgroundColor: AppColors.white,
              body: Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                height: 150.0,
                padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
                margin: const EdgeInsets.only(bottom: 10, right: 10, top: 10),
                width: size.width,
                child: 
                
                // Slidable(
                //   endActionPane:
                //       ActionPane(motion: const StretchMotion(), children: [
                //     SlidableAction(
                //       backgroundColor: Colors.green,
                //       label: 'Settings',
                //       onPressed: (context) {},
                //     ),
                //     SlidableAction(
                //       backgroundColor: Colors.red,
                //       label: 'Delete',
                //       onPressed: (context) {
                //         AwesomeDialog(
                //           context: cont,
                //           dialogType: DialogType.warning,
                //           animType: AnimType.topSlide,
                //           showCloseIcon: true,
                //           title: "Warning",
                //           desc: "Are you sure you want to delete this plant?",
                //           btnCancelOnPress: () {},
                //           btnOkOnPress: () async {
                //             await deletePlant(documentId, cont);
                //           },
                //         ).show();
                //       },
                //     ),
                //   ]),
                //   child: 
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: 120.0,
                            height: 120.0,
                            decoration: const BoxDecoration(
                              color: AppColors.tanFifty,
                              shape: BoxShape.circle,
                            ),
                          ),
                          Positioned(
                            bottom: 10,
                            left: 0,
                            right: 0,
                            child: SizedBox(
                              height: 80.0,
                              child: Image.network(plantList[index].imageURL),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            left: 130,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  plantList[index].plantName,
                                  style: GoogleFonts.openSans(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: AppColors.black,
                                  ),
                                ),
                                Text(plantList[index].type,
                                    style: GoogleFonts.openSans()),
                                Text(plantList[index].description,
                                    style: GoogleFonts.openSans()),
                                const SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  children: [
                                    Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Image.asset(
                                          'assets/icons/solar_icon.png',
                                          fit: BoxFit.cover,
                                          height: 25,
                                          width: 25,
                                        ),
                                        // you can replace
                                        const CircularProgressIndicator(
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  AppColors.sensorIconColor),
                                          value: 30,
                                          strokeWidth: 3,
                                        ),
                                      ],
                                    ),
                                    SizedBox(width: 10),
                                    Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Image.asset(
                                          // you can replace this with Image.asset
                                          'assets/icons/water_level.jpg',
                                          fit: BoxFit.cover,
                                          height: 20,
                                          width: 17,
                                        ),
                                        // you can replace
                                        const CircularProgressIndicator(
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  AppColors.sensorIconColor),
                                          value: 30,
                                          strokeWidth: 3,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(width: 10),
                                    Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Image.asset(
                                          // you can replace this with Image.asset
                                          'assets/icons/moisture.png',
                                          fit: BoxFit.cover,
                                          height: 20,
                                          width: 15,
                                        ),
                                        // you can replace
                                        const CircularProgressIndicator(
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  AppColors.sensorIconColor),
                                          value: 30,
                                          strokeWidth: 3,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(width: 10),
                                    Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Image.asset(
                                          // you can replace this with Image.asset
                                          'assets/icons/soil_moisture.png',
                                          fit: BoxFit.cover,
                                          height: 20,
                                          width: 15,
                                        ),
                                        // you can replace
                                        const CircularProgressIndicator(
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  AppColors.sensorIconColor),
                                          value: 30,
                                          strokeWidth: 3,
                                        ),
                                      ],
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                // ),
              ))),
    );
  }

  Future<void> deletePlant(String docuName, BuildContext context) async {
    await FirebaseFirestore.instance
        .collection('user_plant_devices')
        .doc(docuName)
        .delete()
        .then((value) => {
              AwesomeDialog(
                      context: context,
                      dialogType: DialogType.success,
                      animType: AnimType.rightSlide,
                      title: 'Success!',
                      desc:
                          'This planter device has been successfully added to your list',
                      btnOkOnPress: () async {},
                      btnOkColor: AppColors.primaryColor)
                  .show()
            });
  }
}
