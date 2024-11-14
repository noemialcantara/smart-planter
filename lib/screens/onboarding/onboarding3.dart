import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_onboarding_slider/flutter_onboarding_slider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hortijoy_mobile_app/resources/colors.dart';

import 'package:hortijoy_mobile_app/screens/login/login_body.dart';
import 'package:hortijoy_mobile_app/screens/login/login_screen.dart';
import 'package:hortijoy_mobile_app/screens/registration/registration_screen.dart';

class Onboarding3 extends StatelessWidget {
  const Onboarding3({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Onboarding3Content(),
    );
  }
}

class Onboarding3Content extends StatelessWidget {
  final Color primaryColor = AppColors.primaryColor;

  const Onboarding3Content({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.white,
        body: Container(
            color: AppColors.white,
            child: Column(children: [
              Image.asset(
                'assets/images/setup2.png',
                height: 400,
              ),
              SizedBox(height: 30),
              Padding(
                child: Text(
                  'Monitor',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.primaryColor,
                    fontSize: 24.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                padding: EdgeInsets.only(left: 10, right: 10),
              ),
              const SizedBox(
                height: 20,
              ),
              Padding(
                child: Text(
                  'Check plant care status on your Hortijoy smartphone app anywhere, anytime. The app will remind you when water and fertilizer need to be refilled. Simply enjoy your house plant!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.openSans(
                    color: AppColors.primaryColor,
                    fontSize: 16.0,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                padding: EdgeInsets.only(left: 30, right: 30),
              ),
              Image.asset(
                'assets/images/points3.png',
                height: 50,
              ),
              const SizedBox(
                height: 1,
              ),
              Padding(
                child: GestureDetector(
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
                    Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (context) => const LoginBodyScreen(),
                      ),
                    );
                  },
                ),
                padding: EdgeInsets.only(left: 60, right: 60),
              ),
            ])));
  }
}
