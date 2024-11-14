import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:hortijoy_mobile_app/resources/colors.dart';
import 'package:hortijoy_mobile_app/screens/onboarding/onboarding1.dart';
import 'package:hortijoy_mobile_app/screens/login/login_body.dart';
import 'package:hortijoy_mobile_app/screens/registration/registration_screen.dart';

class MainWelcomeOnboarding extends StatelessWidget {
  const MainWelcomeOnboarding({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: WelcomeOnboarding(),
    );
  }
}

class WelcomeOnboarding extends StatelessWidget {
  const WelcomeOnboarding({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/samplebg.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: Center(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'WELCOME TO',
                style: GoogleFonts.openSans(
                    fontSize: 20.0,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xfffff9da)),
              ),
              const SizedBox(height: 5),
              Text(
                'HORTIJOY',
                style: GoogleFonts.openSans(
                    fontSize: 40.0,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xfffff9da)),
              ),
              const SizedBox(height: 20),
              Text(
                'Indoor plant care made easy',
                style: GoogleFonts.openSans(
                  color: const Color(0xfffff9da),
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 50),
              // GestureDetector(
              //   onTap: () {
              //     Navigator.push(context,
              //         MaterialPageRoute(builder: (builder) => const Onboarding()));
              //   },
              //   child: Container(
              //     padding: const EdgeInsets.symmetric(
              //       vertical: 10.0,
              //       horizontal: 100.00,
              //     ),
              //     decoration: BoxDecoration(
              //       color: AppColors.primaryColor,
              //       borderRadius: BorderRadius.circular(30.0),
              //     ),
              //     child: Text(
              //       "Let's Go",
              //       style: GoogleFonts.openSans(
              //         color: const Color(0xfffff9da),
              //         fontSize: 16,
              //         fontWeight: FontWeight.w600,
              //       ),
              //     ),
              //   ),
              // ),
              GestureDetector(
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (builder) => Onboarding1()));
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10.0,
                    horizontal: 100.00,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xfffff9da),
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  child: Text(
                    'Get Started',
                    style: GoogleFonts.openSans(
                      color: AppColors.primaryColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 25),
            ],
          ))),
    );
  }
}
