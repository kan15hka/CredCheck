import 'dart:io';

import 'package:credcheck/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:credcheck/login/components/my_textfield_password.dart';
import 'package:credcheck/login/pages/add_email.dart';
import 'package:image_picker/image_picker.dart';
import '../components/my_textfield.dart';
import '../components/my_button.dart';

class RegisterPage extends StatefulWidget {
  final Function()? onTap;
  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  //Text editing controllers
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  String roleDropDownValue = 'user';

  // List of items in our dropdown menu
  var items = [
    'user',
    'verifier',
  ];
  //sig user up method
  void signUserUp() async {
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
    //try creating the user
    try {
      //check if password is confirmed
      if (passwordController.text == confirmPasswordController.text) {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: emailController.text, password: passwordController.text);
        AddEmail(emailController.text, nameController.text, roleDropDownValue,
            _image);
      } else {
        showErrorMessage("Passwords don't match");
      }

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

  File? _image;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
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
                      height: 10.0,
                    ),
                    //logo
                    const Icon(
                      Icons.lock_person_outlined,
                      size: 100.0,
                      color: kBlack,
                    ),
                    const SizedBox(height: 20.0),
                    //lets create your account
                    const Text(
                      'Let\'s create an account for you!',
                      style: TextStyle(
                        color: kBlack,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 15.0),
                    InkWell(onTap: _pickImage, child: ImageHolderContainer()),
                    const SizedBox(height: 15.0),
                    //username textfield
                    MyTextField(
                      controller: nameController,
                      hintText: 'Username',
                      obscureText: false,
                    ),
                    const SizedBox(height: 10.0),

                    //username textfield
                    MyTextField(
                      controller: emailController,
                      hintText: 'Email',
                      obscureText: false,
                    ),
                    const SizedBox(height: 10.0),

                    //password textfield

                    MyTextFieldPassword(
                      controller: passwordController,
                      hintText: 'Password',
                      obscureText: true,
                    ),
                    const SizedBox(height: 10.0),

                    //cofirm password textfield

                    MyTextFieldPassword(
                      controller: confirmPasswordController,
                      hintText: 'Confirm Password',
                      obscureText: true,
                    ),
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        "Enter your role",
                        style: TextStyle(
                          color: kBlack,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25.0),
                      child: DropdownButtonFormField(
                        value: roleDropDownValue,
                        icon: const Icon(Icons.keyboard_arrow_down),
                        items: items.map((String items) {
                          return DropdownMenuItem(
                            alignment: Alignment.center,
                            value: items,
                            child: Text(items.toString()[0].toUpperCase() +
                                items.substring(1)),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            roleDropDownValue = newValue!;
                          });
                        },
                        decoration: const InputDecoration(
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: kGrey, width: 2.0)),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: kBlack, width: 2.0),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 25.0),
                    //Sign in button
                    MyButton(
                      text: "Sign up",
                      onTap: signUserUp,
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
                          'Already have an  account?',
                        ),
                        const SizedBox(width: 4.0),
                        GestureDetector(
                          onTap: widget.onTap,
                          child: const Text(
                            'Login now',
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

  Widget ImageHolderContainer() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 120.0,
          width: 100,
          decoration: BoxDecoration(
              color: kBlack, borderRadius: BorderRadius.circular(10.0)),
          child: (_image == null)
              ? const Center(
                  child: Text(
                    'Insert\nImage',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: kWhite,
                      fontSize: 16,
                    ),
                  ),
                )
              : ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: Image.file(
                    _image!,
                    fit: BoxFit.cover,
                  ),
                ),
        ),
        const Positioned(
          bottom: -7.5,
          right: -7.5,
          child: CircleAvatar(
            radius: 15.0,
            backgroundColor: kGrey,
            child: Center(
              child: Icon(
                Icons.add,
                color: kBlack,
              ),
            ),
          ),
        )
      ],
    );
  }
}
