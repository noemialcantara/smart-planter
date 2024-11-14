import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:hortijoy_mobile_app/resources/colors.dart';
import 'package:hortijoy_mobile_app/resources/common_navbar.dart';
import 'package:hortijoy_mobile_app/screens/home/components/body.dart';
import 'package:hortijoy_mobile_app/screens/menu/components/main_menu_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hortijoy_mobile_app/screens/login/auth_page.dart';
import 'package:hortijoy_mobile_app/screens/plant_library/components/plant_library_body.dart';
import 'package:hortijoy_mobile_app/screens/shops/components/shops_body.dart';
import 'package:hortijoy_mobile_app/screens/shops/shops.dart';
import 'package:hortijoy_mobile_app/screens/welcome/welcome_screen.dart';
import 'package:hortijoy_mobile_app/screens/add_device_bluetooth/add_device_bluetooth.dart';
import 'package:hortijoy_mobile_app/screens/notifications/components/notification_body.dart';
import 'package:hortijoy_mobile_app/screens/planters/components/plant_list_body.dart';

class MainMenu extends StatefulWidget {
  const MainMenu({super.key});

  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  // final _drawerController = ZoomDrawerController();
  int currentIndex = 4;

  void signUserOut() {
    FirebaseAuth.instance.signOut();
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => WelcomeScreen(),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return currentScreen();
  }

  Widget currentScreen() {
    if (currentIndex == 5) {
      signUserOut();
    } else {
      switch (currentIndex) {
        case 0:
          return Body();
        case 1:
          return PlantLibraryBody(
            selectedFilters: [],
          );
        case 2:
          return PlantListBody();
        case 3:
          return ShopsBody();
        case 4:
          return NotificationBody(
            selectedFilters: [],
          );
        default:
          return Body();
      }
    }
    return AuthPage();
  }
}
