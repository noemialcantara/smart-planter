import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hortijoy_mobile_app/resources/colors.dart';
import 'package:hortijoy_mobile_app/resources/measurements.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hortijoy_mobile_app/models/auth/user.dart' as Users;
import 'package:hortijoy_mobile_app/resources/colors.dart';

class HeaderWithSearchBox extends StatefulWidget {
  const HeaderWithSearchBox({Key? key, required this.size}) : super(key: key);

  final Size size;

  @override
  State<HeaderWithSearchBox> createState() => _HeaderWithSearchBoxState();
}

class _HeaderWithSearchBoxState extends State<HeaderWithSearchBox> {
  var name = "User";

  getUserData(String email) async {
    await FirebaseFirestore.instance
        .collection("user")
        .where("email", isEqualTo: email)
        .get()
        .then((event) async {
      if (event.docs.isNotEmpty) {
        setState(() {
          name = "${event.docs.first.get("name")}";
        });
      }
    }).catchError((e) => print("error fetching data: $e"));
  }

  @override
  void initState() {
    super.initState();
    getUserData(FirebaseAuth.instance.currentUser?.email.toString() ?? "user");
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: Measurements.defaultPadding * 2.5),
      // It will cover 20% of our total height
      height: widget.size.height * 0.2,
      child: Stack(
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(
              left: Measurements.defaultPadding,
              right: Measurements.defaultPadding,
              bottom: 36 + Measurements.defaultPadding,
            ),
            height: widget.size.height * 0.2 - 27,
            decoration: BoxDecoration(
              color: AppColors.primaryColor,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(36),
                bottomRight: Radius.circular(36),
              ),
            ),
            child: Row(
              children: <Widget>[
                Text(
                  'Hello ${name.split(" ")[0]}',
                  maxLines: 1,
                  style: Theme.of(context).textTheme.headline5?.copyWith(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
                Spacer(),
                Image.asset("assets/images/logo.png")
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              alignment: Alignment.center,
              margin:
                  EdgeInsets.symmetric(horizontal: Measurements.defaultPadding),
              padding:
                  EdgeInsets.symmetric(horizontal: Measurements.defaultPadding),
              height: 54,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    offset: Offset(0, 10),
                    blurRadius: 50,
                    color: AppColors.primaryColor.withOpacity(0.23),
                  ),
                ],
              ),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      onChanged: (value) {},
                      decoration: InputDecoration(
                        hintText: "Search",
                        hintStyle: TextStyle(
                          color: AppColors.primaryColor.withOpacity(0.5),
                        ),
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        // surffix isn't working properly  with SVG
                        // thats why we use row
                        // suffixIcon: SvgPicture.asset("assets/icons/search.svg"),
                      ),
                    ),
                  ),
                  SvgPicture.asset("assets/icons/search.svg"),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
