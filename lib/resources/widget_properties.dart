import 'package:flutter/material.dart';
import 'package:hortijoy_mobile_app/models/request_response.dart';
import 'package:hortijoy_mobile_app/resources/base.dart';
import 'package:hortijoy_mobile_app/resources/colors.dart';
import 'package:hortijoy_mobile_app/resources/custom_gesture_detector.dart';
import 'package:hortijoy_mobile_app/resources/text_style.dart';
import 'package:hortijoy_mobile_app/resources/themed_widgets.dart';

class WidgetProperties {
  navigateToRegistrationPage(BuildContext context) {
    Navigator.pushNamed(context, Routes.REGISTRATION_SCREEN);
  }

  static Widget textBuilder(
    String text, {
    Color? color = AppColors.white,
    double fontSize = 13,
    FontWeight fontWeight = FontWeight.normal,
  }) {
    return Text(
      text,
      textAlign: TextAlign.left,
      style: TextStyle(
        color: color,
        fontWeight: fontWeight,
        fontSize: fontSize,
        fontFamily: 'Roboto',
      ),
    );
  }
}

class CustomContainerWeek extends StatelessWidget {
  final String textDisplay;
  final Color bgColor;
  final Color textColor;
  CustomContainerWeek(
      {super.key,
      required this.textDisplay,
      required this.bgColor,
      required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.all(Radius.circular(20.0))),
        padding: const EdgeInsets.fromLTRB(6.0, 4.0, 6.0, 4.0),
        child: Text(
          textDisplay,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: textColor,
          ),
        ));
  }
}

class CustomLoadingScreen extends StatelessWidget {
  CustomLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: 150,
        width: 150,
        child: const CircularProgressIndicator(),
      ),
    );
  }
}
