import 'package:flutter/material.dart';

// colors
const Color kcPrimaryColor = Color(0xff22A45D);
const Color kcMediumGreyColor = Color(0xff868686);
const Color backgroundColor = Color(0xFFF4F5F6);

// TextStyle
const TextStyle ktsMediumGreyBodyText = TextStyle(
  color: kcMediumGreyColor,
  fontSize: kBodyTextSize,
);

const TextStyle buttonTitleTextStyle =
    const TextStyle(fontWeight: FontWeight.w700, color: Colors.white);

// Font Sizing
const double kBodyTextSize = 16;

// Box Decorations

BoxDecoration fieldDecortaion = BoxDecoration(
    borderRadius: BorderRadius.circular(5), color: Colors.grey[200]);

BoxDecoration disabledFieldDecortaion = BoxDecoration(
    borderRadius: BorderRadius.circular(5), color: Colors.grey[100]);

// Field Variables

const double fieldHeight = 55;
const double smallFieldHeight = 40;
const double inputFieldBottomMargin = 30;
const double inputFieldSmallBottomMargin = 0;
const EdgeInsets fieldPadding = const EdgeInsets.symmetric(horizontal: 15);
const EdgeInsets largeFieldPadding =
    const EdgeInsets.symmetric(horizontal: 15, vertical: 15);

const TextStyle bigButton =
    TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14);
