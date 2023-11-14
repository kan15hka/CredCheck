import 'package:credcheck/constants.dart';
import 'package:flutter/material.dart';

class MyTextFieldPassword extends StatefulWidget {
  final controller;
  final String hintText;
  final bool obscureText;
  const MyTextFieldPassword(
      {super.key,
      required this.controller,
      required this.hintText,
      required this.obscureText});

  @override
  State<MyTextFieldPassword> createState() => _MyTextFieldPasswordState();
}

class _MyTextFieldPasswordState extends State<MyTextFieldPassword> {
  bool passwordVisible = true;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: TextField(
        style: const TextStyle(
          color: kBlack,
        ),
        controller: widget.controller,
        obscureText: passwordVisible,
        decoration: InputDecoration(
            suffixIcon: IconButton(
              icon: Icon(
                passwordVisible ? Icons.visibility_off : Icons.visibility,
                color: kBlack,
              ),
              onPressed: () {
                setState(
                  () {
                    passwordVisible = !passwordVisible;
                  },
                );
              },
            ),
            enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: kBlack, width: 2.0)),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: kGrey, width: 2.0),
            ),
            fillColor: kWhite,
            filled: true,
            hintText: widget.hintText,
            hintStyle: const TextStyle(
              color: kGrey,
            )),
      ),
    );
  }
}
