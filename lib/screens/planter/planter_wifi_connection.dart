import 'dart:convert';
import 'dart:typed_data';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';

import 'package:hortijoy_mobile_app/resources/colors.dart';
import 'package:hortijoy_mobile_app/resources/firebase_firestore.dart';
import 'package:hortijoy_mobile_app/resources/my_button.dart';
import 'package:hortijoy_mobile_app/resources/my_textfield.dart';
import 'package:hortijoy_mobile_app/resources/shared_pref_service.dart';
import 'package:hortijoy_mobile_app/resources/text_style.dart';
import 'package:hortijoy_mobile_app/resources/widget_properties.dart';
import 'package:hortijoy_mobile_app/screens/planter/success_banner.dart/success.dart';
import 'package:hortijoy_mobile_app/screens/planters/planter_list.dart';

class WifiConnectionList extends StatefulWidget {
  final targetCharacteristic;
  final String planterId;
  const WifiConnectionList(
      {this.targetCharacteristic, required this.planterId, super.key});

  @override
  State<WifiConnectionList> createState() => _WifiConnectionListState();
}

class _WifiConnectionListState extends State<WifiConnectionList> {
  final wifiControllerPassword = TextEditingController();
  bool _isLoading = false;
  String uid = "";
  var targetCharacteristic;
  final List<String> items = ['Wifi Name 1', 'Wifi Name 2', 'Wifi Name 3'];

  void initState() {
    super.initState();
    // Initialize the value here
    targetCharacteristic = widget.targetCharacteristic;
    uid = widget.planterId;
  }

  void _sendData(String wifiName, String wifiPassword) async {
    if (targetCharacteristic == null) return;

    final data = {
      "wifi_name": wifiName,
      "wifi_password": wifiPassword,
      "planter_id": uid
    };
    final jsonString = jsonEncode(data);
    final bytes = Uint8List.fromList(utf8.encode(jsonString));

    await targetCharacteristic!.write(bytes);
  }

  _showModalBottomSheet(BuildContext context, wifi_name) {
    SharedPreferenceService.getAddedPlanterUID().then((value) {
      setState(() {
        uid = value.toString();
      });
    });
    return showModalBottomSheet(
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
                      Text("Connect to $wifi_name",
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xff0b172e))),
                      MyTextField2(
                        hintText: 'Password',
                        maxLine: 1,
                        obscureText: true,
                        controller: wifiControllerPassword,
                      ),
                      const SizedBox(
                        height: 30.0,
                      ),
                      MyCustomInfiniteButton(
                        onPressed: () {
                          if (wifiControllerPassword.text != "" ||
                              wifiControllerPassword.text.isNotEmpty) {
                            _sendData(wifi_name, wifiControllerPassword.text);

                            setState(() {
                              _isLoading = true;
                            });
                            try {
                              FirebaseQueries.updatePlantDevices(
                                uid,
                                wifi_name,
                                wifiControllerPassword.text,
                              );
                            } on FirebaseException catch (e) {
                              setState(() {
                                _isLoading = false;
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
                              _isLoading = false;
                            });
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const SuccessNavigateToWifi(),
                              ),
                            );
                          }
                        },
                        buttonText: "Connect",
                      )
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: AppColors.primaryColor,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        title: Text(
          "WiFi Connections",
          style: GoogleFonts.openSans(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.black),
        ),
        actions: [
          IconButton(
              icon: Icon(Icons.replay_outlined, color: Colors.black),
              onPressed: () {}),
        ],
      ),
      body: _isLoading ? CustomLoadingScreen() : _buildDisplayLists(context),
    );
  }

  _buildDisplayLists(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      itemCount: items.length,
      itemBuilder: (context, index) {
        return ListTile(
          tileColor: AppColors.white,
          title: Text(items[index],
              style: GoogleFonts.openSans(color: Colors.black)),
          trailing: const Icon(Icons.chevron_right_sharp),
          onTap: () => _showModalBottomSheet(context, items[index]),
        );
      },
    );
  }
}
