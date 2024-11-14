import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:hortijoy_mobile_app/resources/colors.dart';

class MyButton extends StatelessWidget {
  final Function()? onPressed;
  final String buttonText;
  const MyButton(
      {super.key, required this.onPressed, required this.buttonText});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 10, 10),
        child: Container(
          padding: const EdgeInsets.fromLTRB(0, 8, 0, 10),
          height: 45,
          width: 275,
          decoration: BoxDecoration(
            color: AppColors.defaultIconColor,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Text(
            buttonText,
            textAlign: TextAlign.center,
            style: GoogleFonts.openSans(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class MyCustomInfiniteButton extends StatelessWidget {
  final Function()? onPressed;
  final String buttonText;
  const MyCustomInfiniteButton(
      {super.key, required this.onPressed, required this.buttonText});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
        height: 45,
        width: double.infinity,
        decoration: BoxDecoration(
          color: HexColor('#475743'),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          buttonText,
          textAlign: TextAlign.center,
          style: GoogleFonts.openSans(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class CustomOutlinedButton extends StatelessWidget {
  final Function()? onPressed;
  final String buttonText;
  final Color customColor;
  final Color backgroundColor;

  const CustomOutlinedButton(
      {super.key,
      required this.onPressed,
      required this.buttonText,
      required this.customColor,
      this.backgroundColor = AppColors.white});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Colors.greenAccent,
      borderRadius: BorderRadius.circular(30),
      onTap: onPressed,
      child: Container(
        height: 42,
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(style: BorderStyle.solid, color: customColor),
          borderRadius: BorderRadius.circular(30),
          color: backgroundColor,
        ),
        child: Center(
          child: Text(
            buttonText,
            textAlign: TextAlign.center,
            style: GoogleFonts.openSans(
              color: customColor,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

// class CustomOutlinedButton extends StatelessWidget {
//   final Function()? onPressed;
//   final String buttonText;
//   final Color customColor;
//   const CustomOutlinedButton(
//       {super.key,
//       required this.onPressed,
//       required this.buttonText,
//       required this.customColor});

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: InkWell(
//         splashColor: Colors.greenAccent,
//         borderRadius: BorderRadius.circular(30),
//         onTap: onPressed,
//         child: Container(
//           padding: const EdgeInsets.fromLTRB(0, 14, 0, 10),
//           height: 55,
//           width: 350,
//           decoration: BoxDecoration(
//             border: Border.all(color: customColor),
//             borderRadius: BorderRadius.circular(30),
//           ),
//           child: Text(
//             buttonText,
//             textAlign: TextAlign.center,
//             style: GoogleFonts.openSans(
//               color: customColor,
//               fontSize: 18,
//               fontWeight: FontWeight.normal,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
