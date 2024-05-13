import 'package:test_bench/src/res/colors.dart';
import 'package:flutter/material.dart';

ThemeData get loggerTheme => ThemeData(
      primaryColor: TestBenchColors.primaryColor,
      brightness: Brightness.light,
      indicatorColor: TestBenchColors.accentColor,
      iconTheme: const IconThemeData(
        color: TestBenchColors.primaryColor,
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: TestBenchColors.black,
      ),
      dialogTheme: const DialogTheme(
        backgroundColor: Colors.white,
        contentTextStyle: TextStyle(
          color: Colors.black87,
          fontSize: 16,
        ),
        titleTextStyle: TextStyle(
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        shape: Border(),
      ),
      cardTheme: CardTheme(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        elevation: 6,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: TestBenchColors.backgroundGrey,
        elevation: 0,
      ),
      canvasColor: TestBenchColors.white,
      popupMenuTheme: const PopupMenuThemeData(color: TestBenchColors.white),
      colorScheme: ColorScheme.fromSwatch().copyWith(
        secondary: TestBenchColors.accentColor,
        onSecondary: TestBenchColors.primaryColor,
      ),
      scaffoldBackgroundColor: TestBenchColors.backgroundGrey,
      fontFamily: 'Epilogue',
    );
