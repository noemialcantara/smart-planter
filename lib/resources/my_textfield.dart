// ignore_for_file: prefer_typing_uninitialized_variables

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';

class MyTextField extends StatelessWidget {
  final controller;
  final String hintText;
  final bool obscureText;
  final Icon prefixIcon;
  final Function()? onChanged;

  const MyTextField(
      {super.key,
      required this.controller,
      required this.hintText,
      required this.obscureText,
      required this.prefixIcon,
      this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      cursorColor: HexColor("#4f4f4f"),
      decoration: InputDecoration(
        hintText: hintText,
        contentPadding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
        hintStyle: GoogleFonts.openSans(
          fontSize: 15,
          color: HexColor("#8d8d8d"),
        ),
      ),
    );
  }
}

class MyTextField2 extends StatelessWidget {
  final controller;
  final String hintText;
  final int maxLine;
  final bool obscureText;
  final Function()? onChanged;

  const MyTextField2(
      {super.key,
      required this.controller,
      required this.hintText,
      required this.obscureText,
      required this.maxLine,
      this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      cursorColor: HexColor("#4f4f4f"),
      maxLines: maxLine,
      decoration: InputDecoration(
        hintText: hintText,
        fillColor: Colors.white24,
        // fillColor: Color.fromARGB(60, 113, 90, 90),
        contentPadding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
        hintStyle: GoogleFonts.openSans(
          fontSize: 15,
          color: HexColor("#8d8d8d"),
        ),
        border: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.black54),
        ),
        prefixIconColor: HexColor("#4f4f4f"),
        filled: true,
      ),
    );
  }
}

// class MyTextField2 extends StatelessWidget {
//   final controller;
//   final String hintText;
//   final int maxLine;
//   final bool obscureText;
//   final Function()? onChanged;

//   const MyTextField2(
//       {super.key,
//       required this.controller,
//       required this.hintText,
//       required this.obscureText,
//       required this.maxLine,
//       this.onChanged});

//   @override
//   Widget build(BuildContext context) {
//     return TextField(
//       controller: controller,
//       obscureText: obscureText,
//       cursorColor: HexColor("#4f4f4f"),
//       maxLines: maxLine,
//       decoration: InputDecoration(
//         hintText: hintText,
//         fillColor: Colors.white24,
//         // fillColor: Color.fromARGB(60, 113, 90, 90),
//         contentPadding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
//         hintStyle: GoogleFonts.openSans(
//           fontSize: 15,
//           color: HexColor("#8d8d8d"),
//         ),
//         border: const UnderlineInputBorder(
//           borderSide: BorderSide(color: Colors.black54),
//         ),
//         prefixIconColor: HexColor("#4f4f4f"),
//         filled: true,
//       ),
//     );
//   }
// }
