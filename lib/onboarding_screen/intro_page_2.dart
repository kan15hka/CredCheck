import 'package:credcheck/constants.dart';
import 'package:credcheck/onboarding_screen/style.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class IntroPage2 extends StatelessWidget {
  const IntroPage2({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kWhite,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Lottie.asset('assets/lottie/page2.json', height: 400.0),
          SizedBox(
            height: 50.0,
          ),
          Padding(
            padding: const EdgeInsets.all(30.0),
            child: Text(
              'Users and Verifiers are connected seamlessly through alerts',
              style: textStyleScreen,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
