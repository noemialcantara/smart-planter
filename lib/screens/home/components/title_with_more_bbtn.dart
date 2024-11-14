import 'package:flutter/material.dart';
import 'package:hortijoy_mobile_app/resources/measurements.dart';
import 'package:hortijoy_mobile_app/resources/colors.dart';

class TitleWithMoreBtn extends StatelessWidget {
  const TitleWithMoreBtn({
    Key? key,
    required this.title,
    required this.press,
  }) : super(key: key);
  final String title;
  final Function press;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: Measurements.defaultPadding),
      child: Row(
        children: <Widget>[
          TitleWithCustomUnderline(text: title),
          Spacer(),
          TextButton(
            style: TextButton.styleFrom(
                backgroundColor: AppColors.primaryColor, // Text Color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                )),
            onPressed: () {
              press();
            },
            child: Text(
              "More",
              style: TextStyle(color: Colors.white),
            ),
          )
        ],
      ),
    );
  }
}

class TitleWithCustomUnderline extends StatelessWidget {
  const TitleWithCustomUnderline({
    Key? key,
    required this.text,
  }) : super(key: key);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 24,
      child: Stack(
        children: <Widget>[
          Padding(
            padding:
                const EdgeInsets.only(left: Measurements.defaultPadding / 4),
            child: Text(
              text,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              margin: EdgeInsets.only(right: Measurements.defaultPadding / 4),
              height: 7,
              color: AppColors.primaryColor.withOpacity(0.2),
            ),
          )
        ],
      ),
    );
  }
}
