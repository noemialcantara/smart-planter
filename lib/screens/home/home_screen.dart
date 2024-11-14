import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/services.dart';

import 'package:flutter/material.dart';
import 'package:hortijoy_mobile_app/resources/base.dart';
import 'package:hortijoy_mobile_app/resources/colors.dart';
import 'package:platform_device_id/platform_device_id.dart';
import 'package:hortijoy_mobile_app/screens/home/home_page_body.dart';

import 'package:flutter/services.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  navigateToLoginPage(BuildContext context) {
    Navigator.of(context).pushNamed(Routes.LOGIN_SCREEN);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: Scaffold(
        body: Center(child: HomeScreenBody()),
      ),
    );
  }
}
