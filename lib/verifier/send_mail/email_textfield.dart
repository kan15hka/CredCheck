import 'package:credcheck/constants.dart';
import 'package:flutter/material.dart';

class SendEmailTextField extends StatelessWidget {
  final controller;
  final String hintText;
  final bool obscureText;
  final int minLines;
  const SendEmailTextField(
      {super.key,
      required this.controller,
      required this.hintText,
      required this.obscureText,
      required this.minLines});
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      minLines: minLines,
      maxLines: 5,
      style: const TextStyle(
        color: kBlack,
      ),
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
          // enabledBorder: const OutlineInputBorder(
          //     borderSide: BorderSide(color: kBlack, width: 2.0)),
          focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: kGrey, width: 2.0)),
          fillColor: kWhite,
          filled: true,
          hintText: hintText,
          hintStyle: const TextStyle(
            color: kGrey,
          )),
    );
  }
}
