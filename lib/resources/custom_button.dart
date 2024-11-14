import 'package:hortijoy_mobile_app/custom_widgets/custom_outlined_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final double height;
  final bool visibility;
  final Function onTap;

  CustomButton(
      {required this.text,
      required this.height,
      required this.visibility,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Visibility(
            visible: visibility,
            child: Container(
              height: height,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: OutlinedButtonStandard(
                buttonStyle: outlinedButtonStandardStyle(),
                onPressed: onTap(),
                child: Text(text),
              ),
            )),
        Visibility(
            visible: !visibility,
            child: Container(
              height: height,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ElevatedButton(
                onPressed: onTap(),
                child: Text(text),
              ),
            ))
      ],
    );
  }
}
