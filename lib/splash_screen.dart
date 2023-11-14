import 'package:credcheck/constants.dart';
import 'package:credcheck/onboarding_screen/onboarding_screen.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToOnBoardingScreen();
  }

  _navigateToOnBoardingScreen() async {
    await Future.delayed(const Duration(seconds: 3), () {});
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => OnBoardingScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: kWhite,
      body: Center(
        child: SizedBox(
          height: 150.0,
          width: 150.0,
          child: Image(
            image: AssetImage('assets/images/logow.png'),
            height: 400.0,
          ),
        ),
      ),
    );
  }
}
