import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

double? kheight;
double? kwidth;

const Color kBlack = Colors.black;
const Color kWhite = Color.fromARGB(255, 255, 255, 255);
const Color kGrey = Color.fromARGB(255, 128, 128, 128);
const Color kLGrey = Color.fromARGB(255, 190, 190, 190);
String? kFontFamily = GoogleFonts.poppins().fontFamily;
final shadowBoxDecoration = BoxDecoration(
  color: const Color.fromARGB(255, 255, 255, 255),
  borderRadius: BorderRadius.circular(10.0),
  border: Border.all(color: Colors.black, width: 1.5),
  boxShadow: const [
    BoxShadow(
      color: Color.fromARGB(255, 24, 24, 24),
      offset: Offset(5, 5),
    )
  ],
);
