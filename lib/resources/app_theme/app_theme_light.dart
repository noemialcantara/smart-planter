import 'package:flutter/material.dart';
import 'package:flutter/src/services/system_chrome.dart';
import 'package:flutter/src/foundation/diagnostics.dart';
import 'package:google_fonts/google_fonts.dart';

import '../colors.dart';

class AppThemeLight {
  AppThemeLight();

  static AppBarTheme get appBarTheme {
    /// ICON THEME : PRIMARY COLOR
    /// ICON SIZE : 24px
    /// ELEVATION : 0
    /// CENTER TITLE : TRUE
    /// TITLE FONT COLORE : PRIMARY COLOR
    /// TITLE FONT SIZE : 17px
    /// TITLE FONT WEIGHT : SEMI-BOLD
    return AppBarTheme(
      iconTheme: const IconThemeData(color: AppColors.white, size: 24.0),
      backgroundColor: AppColors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.openSans(
        color: AppColors.white,
        fontSize: 17.0,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  static TabBarTheme get tabBarTheme {
    return TabBarTheme(
      indicator: UnderlineTabIndicator(
          insets: EdgeInsets.zero,
          borderSide: BorderSide(color: AppColors.white)),
      labelColor: AppColors.white,
      labelStyle: TextStyle(
        color: AppColors.white,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelColor: AppColors.white,
      unselectedLabelStyle: TextStyle(
        color: AppColors.white,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  static IconThemeData get storeDetailsIconTheme {
    return IconThemeData(
      color: AppColors.brandingColor,
    );
  }

  static TextStyle get itemDetailsItemTitle {
    /// FONT SIZE : 17px
    /// FONT WEIGHT : SEMI-BOLD
    return TextStyle(
        color: AppColors.white, fontSize: 17.0, fontWeight: FontWeight.w600);
  }

  static EdgeInsets get appMargins {
    /// LEFT : 20px
    /// TOP : 0
    /// RIGHT : 20px
    /// BOTTOM : 0
    return EdgeInsets.symmetric(horizontal: 10);
  }

  static EdgeInsets get marketPlaceVerticalSpacing {
    /// LEFT : 0
    /// TOP : 0
    /// RIGHT : 0
    /// BOTTOM : 16px
    return EdgeInsets.fromLTRB(0, 0, 0, 16);
  }
}
