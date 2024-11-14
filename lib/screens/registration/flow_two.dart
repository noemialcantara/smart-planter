import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:hortijoy_mobile_app/resources/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hortijoy_mobile_app/resources/shared_pref_service.dart';
import 'package:hortijoy_mobile_app/screens/home/home_page_body.dart';
import 'package:hortijoy_mobile_app/screens/login/login_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hortijoy_mobile_app/resources/my_button.dart';
import 'package:hortijoy_mobile_app/controller/flow_controller.dart';
import 'package:hortijoy_mobile_app/controller/sign_up_controller.dart';
import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hortijoy_mobile_app/custom_widgets/custom_circular_icons.dart';

class SignUpTwo extends StatefulWidget {
  const SignUpTwo({super.key});

  @override
  State<SignUpTwo> createState() => _SignUpTwoState();
}

class _SignUpTwoState extends State<SignUpTwo> {
  final emailController = TextEditingController().obs;
  final passwordController = TextEditingController().obs;
  final mobileNumberController = TextEditingController().obs;
  final usernameController = TextEditingController().obs;
  final addressController = TextEditingController().obs;
  SignUpController signUpController = Get.put(SignUpController());
  FlowController flowController = Get.put(FlowController());
  bool _isLoading = false;

  String _errorMessage = "";
  String _passwordErrorMessage = "";

  Future<bool> checkIfEmailInUse(String emailAddress) async {
    try {
      final list =
          await FirebaseAuth.instance.fetchSignInMethodsForEmail(emailAddress);

      if (list.isNotEmpty) {
        return true;
      } else {
        return false;
      }
    } catch (error) {
      return true;
    }
  }

  void _startLoading() async {
    setState(() {
      _isLoading = true;
    });

    signUpController.postSignUpDetails();

    UserCredential? userCredential = await FirebaseAuth.instance
        .signInWithEmailAndPassword(
            email: signUpController.email.toString(),
            password: signUpController.password.toString());
    if (userCredential != null) {
      SharedPreferenceService.setLoggedInUserEmail(
          signUpController.email.toString());
      setState(() {
        _isLoading = false;
      });

      flowController.setFlow(1);
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => HomeScreenBody()),
      );

      // await FirebaseAuth.instance.createUserWithEmailAndPassword(
      //     email: signUpController.email.toString(),
      //     password: signUpController.password.toString());

      // signUpController.postSignUpDetails();

      // UserCredential? userCredential = await FirebaseAuth.instance
      //     .signInWithEmailAndPassword(
      //         email: signUpController.email.toString(),
      //         password: signUpController.password.toString());
      // if (userCredential != null) {
      //   setState(() {
      //     _isLoading = false;
      //   });

      //   Navigator.push(context,
      //       MaterialPageRoute(builder: (context) => const HomeScreenBody()));
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else {
      return _buildFlowTwoDisplay(context);
    }
  }

  SingleChildScrollView _buildFlowTwoDisplay(BuildContext context) {
    return SingleChildScrollView(
        child: SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(30, 0, 30, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "SIGN UP",
                  style: GoogleFonts.openSans(
                    fontSize: 32,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(30, 0, 30, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: usernameController.value,
                    onChanged: (value) {
                      signUpController.setName(value);
                    },
                    onSubmitted: (value) {
                      signUpController.setName(value);
                    },
                    cursorColor: HexColor("#4f4f4f"),
                    decoration: InputDecoration(
                      hintText: "Username",
                      contentPadding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
                      hintStyle: GoogleFonts.openSans(
                        fontSize: 15,
                        color: HexColor("#8d8d8d"),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
                    child: Text(
                      _errorMessage,
                      style: GoogleFonts.openSans(
                        fontSize: 12,
                        color: Colors.red,
                      ),
                    ),
                  ),
                  TextField(
                    onChanged: (value) {
                      signUpController.setAddress(value);
                    },
                    onSubmitted: (value) {
                      signUpController.setAddress(value);
                    },
                    controller: addressController.value,
                    cursorColor: HexColor("#4f4f4f"),
                    decoration: InputDecoration(
                      hintText: "Zip Code ( For plant care)",
                      contentPadding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
                      hintStyle: GoogleFonts.openSans(
                        fontSize: 15,
                        color: HexColor("#8d8d8d"),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
                    child: Text(
                      _passwordErrorMessage,
                      style: GoogleFonts.openSans(
                        fontSize: 12,
                        color: Colors.red,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  GestureDetector(
                    child: Container(
                      height: 42,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor,
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      child: Center(
                          child: Text(
                        'Sign Up',
                        style: GoogleFonts.openSans(
                          color: AppColors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      )),
                    ),
                    onTap: () async {
                      if (signUpController.username != null &&
                          signUpController.address != null) {
                        _startLoading();
                        // bool isRegistered = await checkIfEmailInUse(
                        //     signUpController.email ?? "");
                      } else {
                        AnimatedSnackBar.material(
                          'Please fill up all the fields',
                          type: AnimatedSnackBarType.error,
                          mobileSnackBarPosition: MobileSnackBarPosition
                              .bottom, // Position of snackbar on mobile devices
                          desktopSnackBarPosition: DesktopSnackBarPosition
                              .bottomCenter, // Position of snackbar on desktop devices
                        ).show(context);
                      }
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text("Already have an account?",
                          style: GoogleFonts.openSans(
                            fontSize: 15,
                            color: HexColor("#8d8d8d"),
                          )),
                      Expanded(
                          child: TextButton(
                              child: Text(
                                "Sign In",
                                style: GoogleFonts.openSans(
                                  fontSize: 15,
                                  color: HexColor("#44564a"),
                                ),
                              ),
                              onPressed: () {
                                flowController.setFlow(1);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const LoginScreen(),
                                  ),
                                );
                              })),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ));
  }

  void validateEmail(String val) {
    if (val.isEmpty) {
      setState(() {
        _errorMessage = "Email can not be empty";
      });
    }
    // else if (!EmailValidator.validate(val, true)) {
    //   setState(() {
    //     _errorMessage = "Invalid Email Address";
    //   });
    else {
      setState(() {
        _errorMessage = "";
      });
    }
  }

  // void validatePassword(String val) {
  //   if (val.isEmpty) {
  //     setState(() {
  //       _passwordErrorMessage = "Password cannot be empty";
  //     });
  //   } else if (val.length < 6) {
  //     setState(() {
  //       _passwordErrorMessage = "Password should be greater than 6 characters";
  //     });
  //   } else {
  //     setState(() {
  //       _passwordErrorMessage = "";
  //     });
  //   }
  // }
}
