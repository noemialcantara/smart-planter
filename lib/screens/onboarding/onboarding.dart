import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_onboarding_slider/flutter_onboarding_slider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hortijoy_mobile_app/resources/colors.dart';

import 'package:hortijoy_mobile_app/screens/login/login_body.dart';
import 'package:hortijoy_mobile_app/screens/login/login_screen.dart';
import 'package:hortijoy_mobile_app/screens/registration/registration_screen.dart';

class DisplauOnboarding extends StatelessWidget {
  const DisplauOnboarding({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Onboarding(),
    );
  }
}

class Onboarding extends StatelessWidget {
  final Color primaryColor = AppColors.primaryColor;

  const Onboarding({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: OnBoardingSlider(
        hasFloatingButton: false,
        hasSkip: false,
        indicatorAbove: false,
        // indicatorPosition: 120,
        finishButtonText: "Let's Go",
        centerBackground: true,
        leading: Container(),
        onFinish: () {
          Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => const LoginScreen(),
            ),
          );
        },
        finishButtonStyle: FinishButtonStyle(
            backgroundColor: primaryColor,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30))),

        controllerColor: primaryColor,
        totalPage: 3,
        headerBackgroundColor: Colors.white,
        pageBackgroundColor: Colors.white,
        background: [
          Image.asset(
            'assets/images/discover_screen.png',
            height: 400,
          ),
          Image.asset(
            'assets/images/setup1.png',
            height: 400,
          ),
          Image.asset(
            'assets/images/setup2.png',
            height: 400,
          ),
        ],
        speed: 1.8,

        pageBodies: [
          Container(
            alignment: Alignment.center,
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                const SizedBox(
                  height: 350,
                ),
                Text(
                  'Discover',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.primaryColor,
                    fontSize: 24.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Text(
                  'Browse over 60+ care profiles that can automatically take care of thousands of house plants to find the right one for your space.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.openSans(
                    color: AppColors.primaryColor,
                    fontSize: 16.0,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(
                  height: 80,
                ),
                GestureDetector(
                  child: Container(
                    height: 42,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor,
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    child: Center(
                        child: Text(
                      'Next',
                      style: GoogleFonts.openSans(
                        color: AppColors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    )),
                  ),
                  onTap: () {
                    // signUserIn();
                  },
                ),
                const SizedBox(
                  height: 5,
                ),
                GestureDetector(
                  child: Container(
                    height: 42,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    child: Center(
                        child: Text(
                      'Skip',
                      style: GoogleFonts.openSans(
                        color: AppColors.primaryColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    )),
                  ),
                  onTap: () {
                    // signUserIn();
                    Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (context) => const LoginBodyScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          Container(
            alignment: Alignment.center,
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                const SizedBox(
                  height: 350,
                ),
                Text(
                  'Setup',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: primaryColor,
                    fontSize: 24.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Text(
                  '4 easy setup steps. Plant house plant into the Hortijoy planter. Place sensor and watering tube in soil. Fill water & fertilizer reservoir. Add matching Plant Care profile on app.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.openSans(
                    color: AppColors.primaryColor,
                    fontSize: 16.0,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(
                  height: 50,
                ),
                GestureDetector(
                  child: Container(
                    height: 42,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor,
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    child: Center(
                        child: Text(
                      'Next',
                      style: GoogleFonts.openSans(
                        color: AppColors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    )),
                  ),
                  onTap: () {
                    // signUserIn();
                  },
                ),
                const SizedBox(
                  height: 5,
                ),
                GestureDetector(
                  child: Container(
                    height: 42,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    child: Center(
                        child: Text(
                      'Skip',
                      style: GoogleFonts.openSans(
                        color: AppColors.primaryColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    )),
                  ),
                  onTap: () {
                    // signUserIn();
                    Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (context) => const LoginBodyScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          Container(
            alignment: Alignment.center,
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                const SizedBox(
                  height: 350,
                ),
                Text(
                  'Monitor',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: primaryColor,
                    fontSize: 24.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Text(
                  'Check plant care status on your Hortijoy smartphone app anywhere, anytime. The app will remind you when water and fertilizer need to be refilled. Simply enjoy your house plant!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.openSans(
                    color: AppColors.primaryColor,
                    fontSize: 16.0,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(height: 30),
                GestureDetector(
                  child: Container(
                    height: 42,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor,
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    child: Center(
                        child: Text(
                      "Let's Go",
                      style: GoogleFonts.openSans(
                        color: AppColors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    )),
                  ),
                  onTap: () {
                    // signUserIn();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
    ;
  }
}
