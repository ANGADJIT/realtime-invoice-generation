import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';

class CustomMediaQuery {
  // making it singelton

  final CustomMediaQuery _instance = CustomMediaQuery._init();

  CustomMediaQuery._init();

  static double makeHeight(BuildContext context, double percentage) =>
      context.screenHeight * percentage;

  static double makeWidth(BuildContext context, double percentage) =>
      context.screenWidth * percentage;

  static double makeRadius(BuildContext context, double percentage) =>
      (context.screenWidth / 10) * percentage;

  static double makeTextSize(BuildContext context, double percentage) =>
      (context.screenWidth / 10) * percentage;

  static double makeSize(BuildContext context, double percentage) =>
      (context.screenWidth / 5) * percentage;
}