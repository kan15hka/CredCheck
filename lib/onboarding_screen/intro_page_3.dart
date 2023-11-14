import 'package:credcheck/constants.dart';
import 'package:credcheck/onboarding_screen/style.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class IntroPage3 extends StatelessWidget {
  const IntroPage3({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kWhite,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Lottie.asset('assets/lottie/page3.json', height: 400.0),
          Padding(
            padding: const EdgeInsets.all(30.0),
            child: Text(
              'Users can obtain secured way of Validation through Unique id generation',
              style: textStyleScreen,
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(
            height: 50.0,
          )
        ],
      ),
    );
  }
}
