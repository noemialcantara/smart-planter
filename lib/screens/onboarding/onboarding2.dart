import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_onboarding_slider/flutter_onboarding_slider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hortijoy_mobile_app/resources/colors.dart';

import 'package:hortijoy_mobile_app/screens/login/login_body.dart';
import 'package:hortijoy_mobile_app/screens/login/login_screen.dart';
import 'package:hortijoy_mobile_app/screens/onboarding/onboarding3.dart';
import 'package:hortijoy_mobile_app/screens/registration/registration_screen.dart';

class Onboarding2 extends StatelessWidget {
  const Onboarding2({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Onboarding2Content(),
    );
  }
}

class Onboarding2Content extends StatelessWidget {
  final Color primaryColor = AppColors.primaryColor;

  const Onboarding2Content({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.white,
        body: Container(
            color: AppColors.white,
            child: Column(children: [
              Image.asset(
                'assets/images/setup1.png',
                height: 400,
              ),
              SizedBox(height: 30),
              Padding(
                child: Text(
                  'Setup',
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
                  '4 easy setup steps. Plant house plant into the Hortijoy planter. Place sensor and watering tube in soil. Fill water & fertilizer reservoir. Add matching Plant Care profile on app.',
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
                'assets/images/points2.png',
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
                      'Next',
                      style: GoogleFonts.openSans(
                        color: AppColors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    )),
                  ),
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (builder) => Onboarding3()));
                  },
                ),
                padding: EdgeInsets.only(left: 60, right: 60),
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
            ])));
  }
}
