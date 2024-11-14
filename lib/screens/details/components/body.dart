import 'package:flutter/material.dart';
import 'package:hortijoy_mobile_app/resources/colors.dart';
import 'package:hortijoy_mobile_app/resources/measurements.dart';

import 'image_and_icons.dart';
import 'title_and_price.dart';

class Body extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          ImageAndIcons(size: size),
          TitleAndPrice(
              title: "Asparagus Fern", country: "Status: Healthy", price: 440),
          SizedBox(height: Measurements.defaultPadding),
          Row(
            children: <Widget>[
              SizedBox(
                width: size.width / 2,
                height: 84,
                child: TextButton(
                  style: TextButton.styleFrom(
                    shape: const RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.only(topRight: Radius.circular(20)),
                    ),
                    backgroundColor: AppColors.primaryColor,
                  ),
                  onPressed: () {},
                  child: Text(
                    "Configure",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    primary: Colors.black, // Text Color
                  ),
                  child: Text("Description"),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
