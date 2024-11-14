import 'package:hortijoy_mobile_app/resources/colors.dart';
import 'package:flutter/material.dart';

class OutlinedButtonStandard extends OutlinedButton {
  const OutlinedButtonStandard(
      {Key? key,
      @required VoidCallback? onPressed,
      required Widget child,
      ButtonStyle? buttonStyle,
      EdgeInsetsGeometry? padding})
      : super(
          key: key,
          onPressed: onPressed,
          child: child,
          style: buttonStyle,
        );
}

ButtonStyle outlinedButtonInvertedStyle() {
  return ButtonStyle(foregroundColor:
      MaterialStateProperty.resolveWith<Color>((Set<MaterialState> state) {
    if (state.contains(MaterialState.pressed)) {
      return AppColors.primaryColor;
    }
    return AppColors.white;
  }), backgroundColor:
      MaterialStateProperty.resolveWith<Color>((Set<MaterialState> state) {
    if (state.contains(MaterialState.pressed)) {
      return AppColors.white;
    }
    return AppColors.primaryColor;
  }), shape: MaterialStateProperty.resolveWith<OutlinedBorder>(
    (Set<MaterialState> state) {
      if (state.contains(MaterialState.pressed)) {}

      return RoundedRectangleBorder(borderRadius: BorderRadius.circular(10));
    },
  ), side:
      MaterialStateProperty.resolveWith<BorderSide>((Set<MaterialState> state) {
    return const BorderSide(color: AppColors.primaryColor);
  }));
}

ButtonStyle outlinedButtonStandardStyle() {
  return ButtonStyle(
      minimumSize: MaterialStateProperty.all(Size.fromHeight(44)),
      foregroundColor:
          MaterialStateProperty.resolveWith<Color>((Set<MaterialState> state) {
        if (state.contains(MaterialState.pressed)) {
          return AppColors.white;
        }
        return AppColors.primaryColor;
      }),
      backgroundColor:
          MaterialStateProperty.resolveWith<Color>((Set<MaterialState> state) {
        if (state.contains(MaterialState.pressed)) {
          return AppColors.primaryColor;
        }
        return AppColors.white;
      }),
      shape: MaterialStateProperty.resolveWith<OutlinedBorder>(
        (Set<MaterialState> state) {
          if (state.contains(MaterialState.pressed)) {}
          return RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10));
        },
      ),
      side: MaterialStateProperty.resolveWith<BorderSide>(
          (Set<MaterialState> state) {
        return const BorderSide(color: AppColors.primaryColor);
      }));
}

ButtonStyle outlinedButtonDisabledStyle() {
  return ButtonStyle(
      minimumSize: MaterialStateProperty.all(Size.fromHeight(44)),
      shape: MaterialStateProperty.resolveWith<OutlinedBorder>(
        (Set<MaterialState> state) {
          if (state.contains(MaterialState.pressed)) {}
          return RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10));
        },
      ),
      side: MaterialStateProperty.resolveWith<BorderSide>(
          (Set<MaterialState> state) {
        return const BorderSide(color: Colors.grey);
      }));
}
