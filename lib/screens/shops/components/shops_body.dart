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

class ShopsBody extends StatefulWidget {
  const ShopsBody({super.key});

  @override
  State<ShopsBody> createState() => _ShopsBodyState();
}

class _ShopsBodyState extends State<ShopsBody> {
  AppBar buildAppBar() {
    return AppBar(
        elevation: 0,
        leading: IconButton(
          icon: SvgPicture.asset(
            "assets/icons/menu.svg",
            color: Colors.black,
          ),
          onPressed: () {
            // ZoomDrawer.of(context)!.toggle();
          },
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddDeviceOptions(),
                      ));
                },
                child: Icon(
                  Icons.add,
                  color: AppColors.black,
                  size: 30.0,
                ))
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    final searchController = TextEditingController().obs;
    int selectedIndex = 3;
    Size size = MediaQuery.of(context).size;

    //List of the pages icons
    List<IconData> iconList = [
      Icons.dashboard_outlined,
      Icons.energy_savings_leaf_outlined,
      Icons.library_books_outlined,
      Icons.person_2_outlined,
    ];

    return SafeArea(
        child: Scaffold(
            backgroundColor: AppColors.white,
            bottomNavigationBar: BottomNavigationBar(
                onTap: (index) {
                  setState(() => selectedIndex = index);

                  if (selectedIndex == 0) {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HomeScreenBody(),
                        ));
                  } else if (selectedIndex == 1) {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PlantLibraryMain(),
                        ));
                  } else if (selectedIndex == 2) {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PlanterList(),
                        ));
                  }
                  // else if (selectedIndex == 3) {
                  //   Navigator.push(
                  //       context,
                  //       MaterialPageRoute(
                  //         builder: (context) => const Shops(),
                  //       ));
                  // }
                  else if (selectedIndex == 3) {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NotificationBody(
                            selectedFilters: [],
                          ),
                        ));
                  }
                },
                items: <BottomNavigationBarItem>[
                  const BottomNavigationBarItem(
                      icon: ImageIcon(
                        AssetImage("assets/icons/home.png"),
                      ),
                      backgroundColor: AppColors.white,
                      label: "Home"),
                  const BottomNavigationBarItem(
                      icon: ImageIcon(
                        AssetImage("assets/icons/discover.png"),
                      ),
                      backgroundColor: Colors.white,
                      label: "Discover"),
                  BottomNavigationBarItem(
                    icon: SvgPicture.asset(
                      "assets/icons/planter_outlined.svg",
                    ),
                    label: "Planters",
                    backgroundColor: Colors.white,
                  ),
                  // const BottomNavigationBarItem(
                  //     icon: ImageIcon(
                  //       AssetImage("assets/icons/shop.png"),
                  //     ),
                  //     // backgroundColor: Colors.white,
                  //     label: "Shop"),
                  const BottomNavigationBarItem(
                    icon: ImageIcon(
                      AssetImage("assets/icons/notification.png"),
                    ),
                    label: "Notifications",
                    backgroundColor: Colors.white,
                  ),
                ],
                type: BottomNavigationBarType.fixed,
                currentIndex: selectedIndex,
                selectedItemColor: AppColors.primaryColor,
                iconSize: 25,
                elevation: 5),
            body: Column(
              children: const [
                Expanded(
                  flex: 1,
                  child: HortiJoyWebView(),
                ),
              ],
            )));
  }
}

class HortiJoyWebView extends StatefulWidget {
  const HortiJoyWebView({super.key});

  @override
  State<HortiJoyWebView> createState() => _HortijoyWebView();
}

class _HortijoyWebView extends State<HortiJoyWebView> {
  late final WebViewController controller;

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(
        Uri.parse('https://www.hortijoy.com'),
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
