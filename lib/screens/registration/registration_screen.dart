import 'package:hortijoy_mobile_app/resources/colors.dart';
import 'package:hortijoy_mobile_app/screens/registration/sign_up_body.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hortijoy_mobile_app/controller/flow_controller.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({Key? key}) : super(key: key);

  @override
  State<RegistrationScreen> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationScreen> {
  bool showErrorMessage = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      resizeToAvoidBottomInset: false,
      body: Stack(
        clipBehavior: Clip.none,
        fit: StackFit.expand,
              children: [
                   Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: 380, // Adjust the height as needed
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/leaves_signup_screen.png'),  // Replace with the actual path to your bottom image file
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ), 
             
             
                Center(
                child: SignUpBodyScreen(),
              ),
              ])
    );
  }
}
