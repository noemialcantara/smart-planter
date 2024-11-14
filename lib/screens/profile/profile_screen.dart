import 'package:hortijoy_mobile_app/resources/colors.dart';
import 'package:hortijoy_mobile_app/resources/themed_widgets.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Profile',
          style: TextStyle(
            color: AppColors.black,
            fontSize: 25,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  contentPadding: const EdgeInsets.all(0),
                  leading: Image.asset(
                    'assets/images/profile_user.png',
                    color: Colors.grey[300],
                  ),
                  title: CustomWidget.textBuilder(
                    'Erish Sounder Latorre',
                    color: AppColors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                  subtitle: const Text('Passenger'),
                ),
                const SizedBox(height: 5),
                CustomWidget.textBuilder(
                  'Share your referral code',
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
                const SizedBox(height: 5),
                Container(
                  width: double.infinity,
                  height: 45,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.primaryColor, width: 2),
                    borderRadius: const BorderRadius.all(
                      Radius.circular(10),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 7,
                        child: Align(
                          alignment: Alignment.center,
                          child: CustomWidget.textBuilder(
                            'PLOFRF',
                            fontWeight: FontWeight.bold,
                            color: AppColors.black,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      IconButton(
                        splashRadius: 10,
                        color: Colors.grey,
                        onPressed: () {},
                        icon: const Icon(
                          Icons.copy,
                        ),
                      ),
                      Container(
                        width: 150,
                        height: 50,
                        color: AppColors.primaryColor,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(10),
                                bottomRight: Radius.circular(10),
                              ), // <-- Radius
                            ),
                          ),
                          onPressed: () {},
                          child: const Text(
                            'Share Now',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          ListTile(
            title: CustomWidget.textBuilder(
              'View Profile',
              color: AppColors.black,
              fontWeight: FontWeight.bold,
            ),
            trailing: IconButton(
              splashRadius: 15,
              onPressed: () {},
              icon: const Icon(Icons.keyboard_arrow_right_outlined),
            ),
          ),
          ListTile(
            title: CustomWidget.textBuilder(
              'Share Hortijoy',
              color: AppColors.black,
              fontWeight: FontWeight.bold,
            ),
            trailing: IconButton(
              splashRadius: 15,
              onPressed: () {},
              icon: const Icon(
                Icons.share,
                color: AppColors.primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


// class ProfileScreen extends StatefulWidget {
//   const ProfileScreen({Key? key}) : super(key: key);

//   @override
//   _ProfileScreenState createState() => _ProfileScreenState();
// }

// class _ProfileScreenState extends State<ProfileScreen> {
//   final scaffoldKey = GlobalKey<ScaffoldState>();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       key: scaffoldKey,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         automaticallyImplyLeading: false,
//         title: Text(
//           'Profile',
//           style: TextStyle(
//             fontFamily: 'Poppins',
//             fontSize: 22,
//           ),
//         ),
//         actions: [],
//         centerTitle: true,
//         elevation: 2,
//       ),
//       body: Container(
//         height: MediaQuery.of(context).size.height,
//         width: MediaQuery.of(context).size.width,
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           mainAxisSize: MainAxisSize.max,
//           children: [
//             Expanded(
//               flex: 3,
//               child: Padding(
//                 padding: const EdgeInsets.all(10.0),
//                 child: Column(
//                   children: [
//                     Container(
//                       child: Row(
//                         children: [
//                           SizedBox(
//                             height: 80,
//                           ),
//                           Container(
//                             height: 50,
//                             width: 50,
//                             decoration: BoxDecoration(
//                               borderRadius: BorderRadius.circular(50),
//                               color: AppColors.primaryColor,
//                             ),
//                           ),
//                           Padding(
//                             padding: const EdgeInsets.all(8.0),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   'Commuter 1',
//                                   style: TextStyle(
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                                 Text(
//                                   'Passenger',
//                                   style: TextStyle(
//                                     color: Colors.grey,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     SizedBox(
//                       height: 10,
//                     ),
//                     Container(
//                       width: MediaQuery.of(context).size.width,
//                       child: Text(
//                         'Share your Referral code',
//                         style: TextStyle(
//                           fontWeight: FontWeight.bold,
//                           color: AppColors.primaryColor,
//                         ),
//                       ),
//                     ),
//                     Container(
//                       height: 40,
//                       child: Row(
//                         children: [
//                           Expanded(
//                             flex: 7,
//                             child: Container(
//                               decoration: BoxDecoration(
//                                   border:
//                                       Border.all(color: AppColors.primaryColor),
//                                   borderRadius: BorderRadius.only(
//                                     topLeft: Radius.circular(8),
//                                     bottomLeft: Radius.circular(8),
//                                   )),
//                               child: Center(
//                                 child: Text(
//                                   'PGQZEC',
//                                   style: TextStyle(
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                           Expanded(
//                             flex: 3,
//                             child: Container(
//                               decoration: BoxDecoration(
//                                 borderRadius: BorderRadius.only(
//                                   topRight: Radius.circular(8),
//                                   bottomRight: Radius.circular(8),
//                                 ),
//                                 color: AppColors.primaryColor,
//                               ),
//                               child: Center(
//                                 child: Text(
//                                   'Share Now',
//                                   style: TextStyle(
//                                     color: Colors.white,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             const Divider(
//               color: Colors.black12,
//               thickness: 1,
//             ),
//             Expanded(
//               flex: 7,
//               child: Container(
//                 child: Column(
//                   mainAxisSize: MainAxisSize.max,
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Padding(
//                       padding: const EdgeInsets.all(15.0),
//                       child: Container(
//                         width: MediaQuery.of(context).size.width,
//                         child: const Text(
//                           "View Profile",
//                           style: TextStyle(
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
