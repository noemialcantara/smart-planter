import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';

import 'package:hortijoy_mobile_app/resources/colors.dart';
import 'package:hortijoy_mobile_app/resources/my_textfield.dart';
import 'package:hortijoy_mobile_app/resources/my_button.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final currentPasswordController = TextEditingController();
  final passwordController = TextEditingController();
  final rePasswordController = TextEditingController();

  String reEnterPasswordError = "";
  String enterPasswordError = "";
  String currentPasswordError = "";
  bool isLoading = false; // Loading state

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
        title: Text("Change Password",
            style: GoogleFonts.openSans(
                fontSize: 16,
                color: Colors.black,
                fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(
            Icons.close,
            color: AppColors.primaryColor,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: _buildDisplayEdit(context),
    );
  }

  _buildDisplayEdit(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.fromLTRB(0.0, 30.0, 0.0, 0),
        width: MediaQuery.of(context).size.width * 0.9,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text("Current Password",
                style: TextStyle(fontWeight: FontWeight.bold)),
            MyTextField2(
              controller: currentPasswordController,
              hintText: "Enter your current password",
              obscureText: true,
              maxLine: 1,
              onChanged: () {
                setState(() {
                  currentPasswordError = "";
                });
              },
            ),
            Text(
              currentPasswordError,
              style: const TextStyle(color: Colors.redAccent),
            ),
            const SizedBox(
              height: 15.0,
            ),
            const Text("New Password",
                style: TextStyle(fontWeight: FontWeight.bold)),
            MyTextField2(
              controller: passwordController,
              hintText: "Enter your new password",
              obscureText: true,
              maxLine: 1,
              onChanged: () {
                setState(() {
                  enterPasswordError = "";
                });
              },
            ),
            Text(
              enterPasswordError,
              style: const TextStyle(color: Colors.redAccent),
            ),
            const SizedBox(
              height: 15.0,
            ),
            const Text("Re-enter New Password",
                style: TextStyle(fontWeight: FontWeight.bold)),
            MyTextField2(
              controller: rePasswordController,
              hintText: "Confirm your new password",
              obscureText: true,
              maxLine: 1,
              onChanged: () {
                setState(() {
                  reEnterPasswordError = "";
                });
              },
            ),
            Text(
              reEnterPasswordError,
              style: const TextStyle(color: Colors.redAccent),
            ),
            const SizedBox(
              height: 20.0,
            ),
            GestureDetector(
              onTap: () {
                isLoading ? null : _changePassword();
              },
              child: Container(
                padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                height: 45,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: HexColor('#475743'),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: isLoading
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              color: AppColors.white,
                              strokeWidth: 2.0,
                            ),
                          ),
                          SizedBox(width: 10),
                          Text(
                            "Saving...",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.openSans(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          )
                        ],
                      )
                    : Text(
                        "Save Changes",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.openSans(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _changePassword() async {
    String password = passwordController.text;
    String rePassword = rePasswordController.text;
    String currentPassword = currentPasswordController.text;

    setState(() {
      enterPasswordError = "";
      reEnterPasswordError = "";
      currentPasswordError = "";
    });

    // Validation
    if (currentPassword.isEmpty) {
      setState(() {
        currentPasswordError = "Please enter your current password";
      });
      return;
    }

    if (password.isEmpty) {
      setState(() {
        enterPasswordError = "Please enter your new password";
      });
      return;
    }

    if (rePassword.isEmpty) {
      setState(() {
        reEnterPasswordError = "Please re-enter your new password";
      });
      return;
    }

    if (password.length < 6) {
      setState(() {
        enterPasswordError = "Password must be at least 6 characters long";
      });
      return;
    }

    if (password == currentPassword) {
      setState(() {
        enterPasswordError =
            "New password cannot be the same as the current password";
      });
      return;
    }

    if (password != rePassword) {
      setState(() {
        reEnterPasswordError =
            "Re-entered password does not match the new password";
      });
      return;
    }

    // Show loading indicator
    setState(() {
      isLoading = true;
    });

    try {
      // Reauthenticate the user
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: FirebaseAuth.instance.currentUser!.email.toString(),
          password: currentPassword);

      if (credential.user != null) {
        final user = FirebaseAuth.instance.currentUser;

        // Reauthenticate with credential
        final cred = EmailAuthProvider.credential(
            email: credential.user!.email!, password: currentPassword);

        await user!.reauthenticateWithCredential(cred);

        // Update the password in Firebase Auth
        await user.updatePassword(password);

        // Optionally, update the password in Firestore
        await FirebaseFirestore.instance
            .collection("user")
            .where("email", isEqualTo: user.email)
            .get()
            .then((event) async {
          if (event.docs.isNotEmpty) {
            await FirebaseFirestore.instance
                .collection("user")
                .doc(event.docs.first.id)
                .update({"password": password});
          }
        });

        // Hide loading indicator
        setState(() {
          isLoading = false;
        });

        // Show success dialog
        AwesomeDialog(
          context: context,
          animType: AnimType.scale,
          btnOkColor: AppColors.primaryColor,
          dialogType: DialogType.success,
          title: 'Success',
          desc: 'Your password has been changed successfully!',
          btnOkOnPress: () {
            Navigator.pop(context);
          },
        )..show();
      }
    } on FirebaseAuthException catch (e) {
      // Hide loading indicator
      setState(() {
        isLoading = false;
      });

      // Handle specific FirebaseAuthException errors
      if (e.code == 'wrong-password') {
        setState(() {
          currentPasswordError = "Current password entered is incorrect";
        });
      } else {
        // Show error dialog for other errors
        AwesomeDialog(
          context: context,
          animType: AnimType.scale,
          btnOkColor: AppColors.primaryColor,
          dialogType: DialogType.error,
          title: 'Error',
          desc: e.message ?? "An error occurred. Please try again.",
          btnOkOnPress: () {
            Navigator.pop(context);
          },
        )..show();
      }
    } catch (e) {
      // Hide loading indicator and show error dialog for any other exceptions
      setState(() {
        isLoading = false;
      });

      AwesomeDialog(
        context: context,
        animType: AnimType.scale,
        btnOkColor: AppColors.primaryColor,
        dialogType: DialogType.error,
        title: 'Error',
        desc: e.toString(),
        btnOkOnPress: () {
          Navigator.pop(context);
        },
      )..show();
    }
  }
}
