import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../resources/colors.dart';
import '../../resources/my_textfield.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final emailController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  Future passwordReset() async {
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: emailController.text.trim());
      // ignore: use_build_context_synchronously
      AnimatedSnackBar.material(
        'Link sent!',
        type: AnimatedSnackBarType.success,
        mobileSnackBarPosition: MobileSnackBarPosition
            .top, // Position of snackbar on mobile devices
        desktopSnackBarPosition: DesktopSnackBarPosition
            .bottomCenter, // Position of snackbar on desktop devices
      ).show(context);
    } on FirebaseAuthException catch (e) {
      AnimatedSnackBar.material(
        e.message.toString(),
        type: AnimatedSnackBarType.error,
        mobileSnackBarPosition: MobileSnackBarPosition
            .top, // Position of snackbar on mobile devices
        desktopSnackBarPosition: DesktopSnackBarPosition
            .bottomCenter, // Position of snackbar on desktop devices
      ).show(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: AppColors.white,
          title: Text(
            "Forgot password",
            style: GoogleFonts.openSans(color: AppColors.black),
          ),
          leading: IconButton(
            icon: Icon(
              Icons.close,
              color: AppColors.primaryColor,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        backgroundColor: AppColors.white,
        body: SingleChildScrollView(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Image.asset('assets/images/padlock_plant.png',
                height: 400, width: 400),
            //Some text here
            Padding(
              padding: EdgeInsets.fromLTRB(30, 5, 30, 20),
              child: Text(
                'Enter your email and we will send you a link to reset your password.',
                textAlign: TextAlign.center,
                style: GoogleFonts.openSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            //Email field
            Padding(
              padding: const EdgeInsets.fromLTRB(30, 20, 30, 20),
              child: MyTextField(
                controller: emailController,
                hintText: "Your email address",
                obscureText: false,
                prefixIcon: const Icon(Icons.mail_outline),
              ),
            ),
            const SizedBox(
              height: 65,
            ),
            Center(
                child: GestureDetector(
              onTap: () {
                passwordReset();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 80.0,
                  vertical: 12.0,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor,
                  borderRadius: BorderRadius.circular(30.0),
                ),
                child: Text(
                  'Submit',
                  style: GoogleFonts.openSans(
                    color: AppColors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            )),
          ],
        )),
      ),
    );
  }
}
