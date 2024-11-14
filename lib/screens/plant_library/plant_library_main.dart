import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:hortijoy_mobile_app/resources/colors.dart';
import 'package:hortijoy_mobile_app/resources/common_navbar.dart';
import 'package:hortijoy_mobile_app/screens/home/components/body.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hortijoy_mobile_app/screens/login/auth_page.dart';
import 'package:hortijoy_mobile_app/screens/menu/main_menu.dart';
import 'package:hortijoy_mobile_app/screens/plant_library/components/plant_library_body.dart';
import 'package:hortijoy_mobile_app/screens/shops/components/shops_body.dart';
import 'package:hortijoy_mobile_app/screens/shops/shops.dart';
import 'package:hortijoy_mobile_app/screens/welcome/welcome_screen.dart';
import 'package:hortijoy_mobile_app/screens/planters/components/plant_list_body.dart';
import 'package:hortijoy_mobile_app/screens/add_device_bluetooth/add_device_bluetooth.dart';
import 'package:hortijoy_mobile_app/screens/notifications/components/notification_body.dart';
import 'package:hortijoy_mobile_app/screens/menu/components/main_menu_body.dart';

class PlantLibraryMain extends StatefulWidget {
  const PlantLibraryMain({super.key});

  @override
  State<PlantLibraryMain> createState() => _PlantLibraryMainState();
}

class _PlantLibraryMainState extends State<PlantLibraryMain> {
  // final _drawerController = ZoomDrawerController();
  int currentIndex = 1;

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
    // return ZoomDrawer(
    //   menuScreen: DrawerScreen(
    //     setIndex: (index) {
    //       setState(() {
    //         currentIndex = index;
    //       });
    //     },
    //   ),
    //   mainScreen: currentScreen(),
    //   borderRadius: 30,
    //   showShadow: true,
    //   angle: 0.0,
    //   slideWidth: 220,
    //   menuBackgroundColor: AppColors.primaryColor,
    // );
    return Scaffold(

      body: currentScreen(),
    );
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

// class DrawerScreen extends StatefulWidget {
//   final ValueSetter setIndex;
//   const DrawerScreen({Key? key, required this.setIndex}) : super(key: key);

//   @override
//   State<DrawerScreen> createState() => _DrawerScreenState();
// }

// class _DrawerScreenState extends State<DrawerScreen> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.primaryColor,
//       body: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           drawerList(Icons.dashboard_outlined, "Dashboard", 0),
//           drawerList(Icons.energy_savings_leaf_outlined, "Plant Devices", 1),
//           drawerList(Icons.library_books_outlined, "Plant Library", 2),
//           drawerList(Icons.person_2_outlined, "Profile", 3),
//           drawerList(Icons.logout_outlined, "Logout", 4),
//         ],
//       ),
//     );
//   }

//   Widget drawerList(IconData icon, String text, int index) {
//     return GestureDetector(
//       onTap: () {
//         widget.setIndex(index);
//       },
//       child: Container(
//         margin: EdgeInsets.only(left: 20, bottom: 12),
//         child: Row(
//           children: [
//             Icon(
//               icon,
//               color: Colors.white,
//             ),
//             SizedBox(
//               width: 12,
//             ),
//             Text(
//               text,
//               style: GoogleFonts.openSans(
//                   color: Colors.white, fontWeight: FontWeight.bold),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class DrawerWidget extends StatelessWidget {
//   const DrawerWidget({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return IconButton(
//       onPressed: () {
//         ZoomDrawer.of(context)!.toggle();
//       },
//       icon: Icon(Icons.menu),
//     );
//   }
// }
