import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

ThemeData lightMode = ThemeData(
  textTheme: GoogleFonts.playfairDisplayTextTheme(),
  brightness: Brightness.light,
  scaffoldBackgroundColor: AppColors.lightBackground,
  primaryColor: AppColors.primaryBlue,
  colorScheme: ColorScheme.light(
    primary: AppColors.accentOrange,
    secondary: AppColors.accentOrange,
    surface: AppColors.lightCard,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onSurface: AppColors.lightText,
    onSecondaryFixed: Colors.grey.shade600,
    onInverseSurface: Colors.grey.withValues(alpha: 0.5),
  ),
  appBarTheme: const AppBarTheme(
    systemOverlayStyle: SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
      contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      enabledBorder: _border(AppColors.darkGray),
      focusedBorder: _border(AppColors.accentOrange),
      focusedErrorBorder: _border(Colors.red),
      errorBorder: _border(Colors.red),
      errorStyle: TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 11.sp,
      )
  ),
  textSelectionTheme: TextSelectionThemeData(
    cursorColor: AppColors.accentOrange,
  ),
);

ThemeData darkMode = ThemeData(
  textTheme: GoogleFonts.playfairDisplayTextTheme(),
  brightness: Brightness.dark,
  scaffoldBackgroundColor: AppColors.darkBackground,
  primaryColor: AppColors.primaryBlue,
  colorScheme: ColorScheme.dark(
    primary: AppColors.primaryBlue,
    secondary: AppColors.accentOrange,
    surface: AppColors.darkCard,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onSurface: AppColors.darkText,
    onSecondaryFixed: Colors.grey.shade600,
    onInverseSurface: Colors.black.withValues(alpha: 0.5),
  ),
  appBarTheme: const AppBarTheme(
    systemOverlayStyle: SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
    enabledBorder: _border(AppColors.darkGray),
    focusedBorder: _border(AppColors.primaryBlue),
    focusedErrorBorder: _border(Colors.red),
    errorBorder: _border(Colors.red),
    errorStyle: TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 11.sp,
    )
  ),
  textSelectionTheme: TextSelectionThemeData(
    cursorColor: AppColors.primaryBlue,
  ),
);

_border(Color color) => OutlineInputBorder(
  borderSide: BorderSide(
    color: color,
    width: 2.w
  ),
  borderRadius: BorderRadius.circular(10.r),
);