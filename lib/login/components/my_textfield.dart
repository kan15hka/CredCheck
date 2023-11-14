import 'package:credcheck/constants.dart';
import 'package:flutter/material.dart';

class MyTextField extends StatelessWidget {
  final controller;
  final String hintText;
  final bool obscureText;
  const MyTextField(
      {super.key,
      required this.controller,
      required this.hintText,
      required this.obscureText});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: TextField(
        style: const TextStyle(
          color: kBlack,
        ),
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
            enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: kBlack, width: 2.0)),
            focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: kGrey, width: 2.0)),
            fillColor: kWhite,
            filled: true,
            hintText: hintText,
            hintStyle: const TextStyle(
              color: kGrey,
            )),
      ),
    );
  }
}
