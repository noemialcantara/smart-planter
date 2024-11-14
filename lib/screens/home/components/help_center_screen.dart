import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:hortijoy_mobile_app/resources/colors.dart';
import 'package:hortijoy_mobile_app/resources/measurements.dart';
import 'package:hortijoy_mobile_app/models/plants.dart';
import 'package:hortijoy_mobile_app/resources/my_button.dart';
import 'package:hortijoy_mobile_app/screens/add_device_options/add_device_options.dart';
import 'package:hortijoy_mobile_app/screens/home/components/body.dart';
import 'package:hortijoy_mobile_app/screens/home/components/detail_page.dart';
import 'package:hortijoy_mobile_app/screens/home/components/plant_widget.dart';
import 'package:hortijoy_mobile_app/screens/add_device_bluetooth/add_device_bluetooth.dart';
import 'package:hortijoy_mobile_app/screens/home/home_page_body.dart';
import 'package:hortijoy_mobile_app/screens/menu/main_menu.dart';
import 'package:hortijoy_mobile_app/screens/notifications/components/notification_body.dart';
import 'package:hortijoy_mobile_app/screens/plant_library/components/plant_library_card_widget.dart';
import 'package:hortijoy_mobile_app/screens/plant_library/plant_library_main.dart';
import 'package:hortijoy_mobile_app/screens/planters/planter_list.dart';
import 'package:hortijoy_mobile_app/screens/shops/shops.dart';
import 'package:page_transition/page_transition.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:webview_flutter/webview_flutter.dart';

class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen> {
  AppBar buildAppBar() {
    return AppBar(
      title: Text(
        "Help Center",
        style: GoogleFonts.openSans(color: AppColors.black),
      ),
      leading: IconButton(
        icon: Icon(
          Icons.close,
          color: AppColors.primaryColor,
        ),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            backgroundColor: AppColors.white,
            appBar: buildAppBar(),
            body: Column(
              children: const [
                Expanded(
                  flex: 1,
                  child: HelpCenterWebView(),
                ),
              ],
            )));
  }
}

class HelpCenterWebView extends StatefulWidget {
  const HelpCenterWebView({super.key});

  @override
  State<HelpCenterWebView> createState() => _HelpCenterWebView();
}

class _HelpCenterWebView extends State<HelpCenterWebView> {
  late final WebViewController controller;

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(
        Uri.parse('https://www.hortijoy.com/contact-us'),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WebViewWidget(
        controller: controller,
      ),
    );
  }
}
