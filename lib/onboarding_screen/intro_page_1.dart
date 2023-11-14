import 'package:credcheck/constants.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class IntroPage1 extends StatelessWidget {
  const IntroPage1({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kWhite,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Lottie.asset('assets/lottie/page1.json', height: 400.0),
          SizedBox(
            height: 30.0,
          ),
          Padding(
            padding: const EdgeInsets.all(30.0),
            child: Text(
              'CreCheck is a Document verification and validation app',
              style: TextStyle(fontSize: 17.0),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
