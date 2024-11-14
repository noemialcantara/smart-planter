import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:hortijoy_mobile_app/resources/colors.dart';
import 'package:hortijoy_mobile_app/screens/registration/flow_one.dart';
import 'package:hortijoy_mobile_app/screens/registration/flow_two.dart';
import 'package:hortijoy_mobile_app/controller/flow_controller.dart';

class SignUpBodyScreen extends StatefulWidget {
  const SignUpBodyScreen({super.key});

  @override
  State<SignUpBodyScreen> createState() => _SignUpBodyScreenState();
}

class _SignUpBodyScreenState extends State<SignUpBodyScreen> {
  FlowController flowController = Get.put(FlowController());

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return 
      SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(
              height: 50,
            ),
            GetBuilder<FlowController>(
              builder: (context) {
                if (flowController.currentFlow == 2) {
                  return SignUpTwo();
                }
                return SignUpOne();
              },
            ),
          ],
        ),
      )
              
    ;
  }
}
