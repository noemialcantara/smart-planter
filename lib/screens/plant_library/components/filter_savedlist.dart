import 'dart:convert';

import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:async_task/async_task_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:hortijoy_mobile_app/resources/colors.dart';
import 'package:hortijoy_mobile_app/resources/measurements.dart';
import 'package:hortijoy_mobile_app/models/plants.dart';
import 'package:hortijoy_mobile_app/resources/my_button.dart';
import 'package:hortijoy_mobile_app/resources/my_textfield.dart';
import 'package:hortijoy_mobile_app/resources/widget_properties.dart';
import 'package:hortijoy_mobile_app/screens/add_device_options/add_device_options.dart';
import 'package:hortijoy_mobile_app/screens/home/components/body.dart';
import 'package:hortijoy_mobile_app/screens/home/components/detail_page.dart';
import 'package:hortijoy_mobile_app/screens/home/components/plant_widget.dart';
import 'package:hortijoy_mobile_app/screens/add_device_bluetooth/add_device_bluetooth.dart';
import 'package:hortijoy_mobile_app/screens/home/home_page_body.dart';
import 'package:hortijoy_mobile_app/screens/menu/main_menu.dart';
import 'package:hortijoy_mobile_app/screens/plant_library/components/plant_filter.dart';
import 'package:hortijoy_mobile_app/screens/plant_library/components/plant_library_body.dart';
import 'package:hortijoy_mobile_app/screens/plant_library/components/plant_library_card_widget.dart';
import 'package:hortijoy_mobile_app/screens/plant_library/plant_library_main.dart';
import 'package:hortijoy_mobile_app/screens/planter/planter_select_care_profile.dart';
import 'package:hortijoy_mobile_app/screens/planters/planter_list.dart';
import 'package:hortijoy_mobile_app/screens/shops/shops.dart';
import 'package:page_transition/page_transition.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SavedList extends StatefulWidget {
  final bool cameFromSelectCareProfile;
  final planterDetails;
  final bool isSwitching;
  const SavedList({
    required this.cameFromSelectCareProfile,
    this.planterDetails,
    this.isSwitching = false,
    super.key,
  });

  @override
  State<SavedList> createState() => _SavedList();
}

class _SavedList extends State<SavedList> {
  TextEditingController saveListController = TextEditingController();

  final CollectionReference collection =
      FirebaseFirestore.instance.collection("user_filter_saved_lists");

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Scaffold(
        backgroundColor: AppColors.white,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: Text(
            'Saved Lists',
            textAlign: TextAlign.center,
            style: GoogleFonts.openSans(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          backgroundColor: AppColors.white,
          actions: const [],
          centerTitle: true,
          elevation: 0,
        ),
        body: SafeArea(
          child: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(),
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(10, 0, 10, 0),
              child: StreamBuilder<QuerySnapshot>(
                  stream: collection
                      .where("email",
                          isEqualTo: FirebaseAuth.instance.currentUser?.email
                              .toString())
                      .snapshots(),
                  builder: ((context, snapshot) {
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CustomLoadingScreen();
                    }
                    return ListView.builder(
                      padding: EdgeInsets.only(left: 15, right: 15),
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        var document = snapshot.data!.docs[index];
                        var documentId = document.reference.id;
                        var data = document.data() as Map<String, dynamic>;
                        return Container(
                            padding: EdgeInsets.only(top: 15),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          data["list_title"].toString(),
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          data["record_count"].toString() +
                                              " Profiles",
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium,
                                        ),
                                      ],
                                    ),
                                    onTap: () {
                                      var categoryList = json
                                          .decode(data["category_list"])
                                          .cast<String>()
                                          .toList();

                                      var valueList = json
                                          .decode(data["value_list"])
                                          .cast<String>()
                                          .toList();

                                      List<String> selectedValueList = [];

                                      for (int i = 0;
                                          i < categoryList.length;
                                          i++) {
                                        if (categoryList[i] == "light_sensor") {
                                          selectedValueList.add(
                                              categoryList[i] +
                                                  "-" +
                                                  valueList[i]);
                                        } else {
                                          selectedValueList.add(
                                              categoryList[i] +
                                                  "-" +
                                                  valueList[i]);
                                        }
                                      }

                                      print("SELECTED FILTERS: " +
                                          jsonEncode(selectedValueList));
                                      widget.cameFromSelectCareProfile
                                          ? Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    PlanterSelectCareProfile(
                                                  planterDetails:
                                                      widget.planterDetails,
                                                  isSwitching:
                                                      widget.isSwitching,
                                                  selectedFilters:
                                                      selectedValueList,
                                                ),
                                              ))
                                          : Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    PlantLibraryBody(
                                                  selectedFilters:
                                                      selectedValueList,
                                                ),
                                              ));
                                    },
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.more_horiz,
                                    color: Colors.black,
                                  ),
                                  onPressed: () {
                                    _listDetails(context, documentId);
                                  },
                                ),
                              ],
                            ));
                      },
                    );
                  })),
              // Column(
              //   mainAxisSize: MainAxisSize.min,
              //   crossAxisAlignment: CrossAxisAlignment.start,
              //   children: [
              //     ListView(
              //       padding: EdgeInsets.zero,
              //       shrinkWrap: true,
              //       scrollDirection: Axis.vertical,
              //       children: [
              //         Row(
              //           mainAxisSize: MainAxisSize.max,
              //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //           children: [
              //             Expanded(
              //               child: Column(
              //                 mainAxisSize: MainAxisSize.max,
              //                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              //                 crossAxisAlignment: CrossAxisAlignment.start,
              //                 children: [
              //                   const Text(
              //                     'List Name',
              //                     style: TextStyle(
              //                       fontWeight: FontWeight.bold,
              //                     ),
              //                   ),
              //                   Text(
              //                     '56 Profiles',
              //                     style: Theme.of(context).textTheme.bodyMedium,
              //                   ),
              //                 ],
              //               ),
              //             ),
              //             IconButton(
              //               icon: const Icon(
              //                 Icons.more_horiz,
              //                 color: Colors.black,
              //               ),
              //               onPressed: () {
              //                 _listDetails(context);
              //               },
              //             ),
              //           ],
              //         ),
              //       ],
              //     ),
              //   ],
              // ),
            ),
          ),
        ),
      ),
    );
  }

  void _listDetails(context, documentId) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        builder: (BuildContext context) {
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
                  height: 150,
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
                      GestureDetector(
                        child: SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Image.asset(
                                'assets/icons/Edit_List_icon.png',
                                scale: 1,
                              ),
                              Text("Edit List")
                            ],
                          ),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          updateList(context, documentId);
                        },
                      ),
                      GestureDetector(
                        child: SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Image.asset(
                                'assets/icons/delete_icon.png',
                                scale: 1,
                              ),
                              Text("Delete List")
                            ],
                          ),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          deleteList(context, documentId);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }

  void editList(documentId) async {
    await FirebaseFirestore.instance
        .collection("user_filter_saved_lists")
        .doc(documentId)
        .update({"list_title": saveListController.text.toString()});

    AnimatedSnackBar.material(
      "Updated successfully!",
      type: AnimatedSnackBarType.success,
      mobileSnackBarPosition:
          MobileSnackBarPosition.top, // Position of snackbar on mobile devices
      desktopSnackBarPosition: DesktopSnackBarPosition
          .topCenter, // Position of snackbar on desktop devices
    ).show(context);
    Navigator.pop(context);
  }

  void updateList(context, documentId) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        builder: (BuildContext context) {
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
                  height: 250,
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
                      Text("Choose a name for this list ",
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xff0b172e))),
                      MyTextField2(
                        hintText: 'List Name',
                        maxLine: 1,
                        obscureText: false,
                        controller: saveListController,
                      ),
                      const SizedBox(
                        height: 30.0,
                      ),
                      Align(
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Container(
                                  width: 150,
                                  height: 55,
                                  child: OutlinedButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    style: OutlinedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                        side: BorderSide(
                                          color: AppColors
                                              .primaryColor, //Color of the border
                                          style: BorderStyle
                                              .solid, //Style of the border
                                          width: 3, //width of the border
                                        ),
                                      ),
                                    ),
                                    child: Text(
                                      'Cancel',
                                      style: TextStyle(
                                        color: AppColors.primaryColor,
                                      ),
                                    ),
                                  )),
                              SizedBox(width: 8.0),
                              Container(
                                width: 150,
                                height: 55,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    if (!saveListController.text.isEmpty) {
                                      editList(documentId);
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    primary: AppColors.primaryColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                  child: Text(
                                    'Save',
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ))
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }

  void deleteList(context, documentId) async {
    await FirebaseFirestore.instance
        .collection("user_filter_saved_lists")
        .doc(documentId)
        .delete();

    AnimatedSnackBar.material(
      "Deleted successfully!",
      type: AnimatedSnackBarType.success,
      mobileSnackBarPosition:
          MobileSnackBarPosition.top, // Position of snackbar on mobile devices
      desktopSnackBarPosition: DesktopSnackBarPosition
          .topCenter, // Position of snackbar on desktop devices
    ).show(context);
    Navigator.pop(context);
  }
}
