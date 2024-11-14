import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hortijoy_mobile_app/screens/onboarding/welcome_onboarding.dart';
import 'firebase_options.dart';
import 'dart:async';

import 'package:hortijoy_mobile_app/resources/app_theme/app_theme_light.dart';
import 'package:hortijoy_mobile_app/resources/base.dart';
import 'package:hortijoy_mobile_app/resources/colors.dart';
import 'package:hortijoy_mobile_app/screens/home/home_page_body.dart';
import 'package:hortijoy_mobile_app/screens/login/login_screen.dart';
import 'package:hortijoy_mobile_app/screens/registration/registration_screen.dart';
import 'package:hortijoy_mobile_app/screens/login/auth_page.dart';
import 'package:hortijoy_mobile_app/screens/onboarding/onboarding.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // if (Platform.isAndroid) {
    //only for Android
   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  // } else {
  //   await Firebase.initializeApp();
  // }
  SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarColor: AppColors.white));
  await Firebase.initializeApp(
      name: "Hortijoy", options: DefaultFirebaseOptions.currentPlatform);

  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isFirstTime = prefs.getBool('isFirstTime') ?? true;

  if (isFirstTime) {
    await prefs.setBool('isFirstTime', false);
    Timer(const Duration(seconds: 1), () {
      // navigateToOnboarding(context);
      runApp(const MainWelcomeOnboarding());
    });
  } else {
    runApp(const Main());
  }
}

class Main extends StatelessWidget {
  const Main({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: child as Widget),
      title: 'Hortijoy',
      theme: ThemeData(
        primaryColor: AppColors.primaryColor,
        scaffoldBackgroundColor: AppColors.primaryBackgroundColor,
        //primarySwatch: AppColors.themeColor,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        tabBarTheme: AppThemeLight.tabBarTheme,
        fontFamily: GoogleFonts.openSans().fontFamily,
        textTheme: const TextTheme(
          headline4: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: AppColors.black,
          ),
          headline5: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: AppColors.black,
          ),
          headline6: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryColor,
          ),
          subtitle1: TextStyle(
            fontWeight: FontWeight.w500,
            color: AppColors.subtitleColor,
          ),
          button: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        appBarTheme: AppThemeLight.appBarTheme,
      ),
      onGenerateRoute: (RouteSettings settings) {
        // final arg = settings.arguments;
        switch (settings.name) {
          case Routes.LOGIN_SCREEN:
            return MaterialPageRoute(
              builder: (context) => const LoginScreen(),
            );
          case Routes.REGISTRATION_SCREEN:
            return MaterialPageRoute(
              builder: (context) => const RegistrationScreen(),
            );
          case Routes.HOME_SCREEN:
            return MaterialPageRoute(
              builder: (context) => const HomeScreenBody(),
            );
          case Routes.ONBOARDING:
            return MaterialPageRoute(
              builder: (context) => const Onboarding(),
            );
          default:
            return MaterialPageRoute(
              builder: (context) => const AuthPage(),
            );
        }
      },
    );
  }
}
