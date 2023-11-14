import 'package:credcheck/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:credcheck/login/components/my_textfield_password.dart';

import '../components/my_textfield.dart';
import '../components/my_button.dart';

class LoginPage extends StatefulWidget {
  final Function()? onTap;
  const LoginPage({
    super.key,
    required this.onTap,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  //Text editing controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  //sig user in method
  void signinUserIn() async {
    //show loading circle
    showDialog(
        context: context,
        builder: (context) {
          return const Center(
            child: CircularProgressIndicator(
              color: kBlack,
            ),
          );
        });
    //try sign in
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text, password: passwordController.text);
      //popp the loading circle
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      //popp the loading circle
      Navigator.pop(context);
      showErrorMessage(e.code);
    }
  }

  void showErrorMessage(String message) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: kBlack,
            title: Center(
              child: Text(message,
                  style: const TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      color: kWhite)),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
          backgroundColor: kWhite,
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      height: 20.0,
                    ),
                    //logo
                    const Icon(
                      Icons.lock_person_rounded,
                      size: 100.0,
                      color: kBlack,
                    ),
                    const SizedBox(height: 30.0),
                    //Welcome back
                    const Text(
                      'Welcome Back you\'ve been missed',
                      style: TextStyle(
                        color: kBlack,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 25.0),

                    const SizedBox(height: 10.0),
                    //username textfield
                    MyTextField(
                      controller: emailController,
                      hintText: 'Email',
                      obscureText: false,
                    ),
                    const SizedBox(height: 10.0),
                    //passwor textfield
                    MyTextFieldPassword(
                      controller: passwordController,
                      hintText: 'Password',
                      obscureText: true,
                    ),
                    const SizedBox(height: 10.0),
                    //forgot password
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 25.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            'Forgot Password?',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 25.0),
                    //Sign in button
                    MyButton(
                      text: "Sign in",
                      onTap: signinUserIn,
                    ),
                    const SizedBox(
                      height: 30.0,
                    ),
                    //or continue with
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 25.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Divider(
                              thickness: 0.5,
                              color: kGrey,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10.0),
                            child: Text('Or continue with'),
                          ),
                          Expanded(
                            child: Divider(
                              thickness: 0.5,
                              color: kGrey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 25.0),
                    //google and ios buttons

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Not a member?',
                        ),
                        const SizedBox(width: 4.0),
                        GestureDetector(
                          onTap: widget.onTap,
                          child: const Text(
                            'Register now',
                            style: TextStyle(
                              color: kBlack,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 40.0,
                    )
                  ],
                ),
              ),
            ),
          )),
    );
  }
}
