import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';

class Themes {
  // Light
  static final light = FlexThemeData.light(
    scheme: FlexScheme.flutterDash,
  ).copyWith(
    splashColor: Colors.transparent,
    highlightColor: Colors.transparent,
    splashFactory: NoSplash.splashFactory,
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: Colors.transparent,
    ),
  );

  // Dark
  static final dark = FlexThemeData.dark(
    scheme: FlexScheme.flutterDash,
    primary: Color(0xFF1B76FF),
    secondary: Color(0xFF5E97DB),
  ).copyWith(
    splashColor: Colors.transparent,
    highlightColor: Colors.transparent,
    splashFactory: NoSplash.splashFactory,
    cupertinoOverrideTheme: CupertinoThemeData(
      textTheme: CupertinoTextThemeData(),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: Colors.transparent,
    ),
  );
}
