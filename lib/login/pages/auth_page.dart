import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:credcheck/constants.dart';
import 'package:credcheck/user/user_screen.dart';
import 'package:credcheck/verifier/verifier_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:credcheck/login/pages/login_or_register_page.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  String role = "";
  Future<void> _getDocumentById(
      String collectionName, String documentId) async {
    try {
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection(collectionName)
          .doc(documentId)
          .get();

      if (documentSnapshot.exists) {
        // Document exists, you can access its data
        Map<String, dynamic> data =
            documentSnapshot.data() as Map<String, dynamic>;
        setState(() {
          role = data["role"];
        });
      } else {
        print('Document does not exist');
      }
    } catch (e) {
      print('Error getting document: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          //user is logged in

          if (snapshot.hasData) {
            final user = FirebaseAuth.instance.currentUser!;
            _getDocumentById("userverif", user.email.toString());

            if (role == 'user') {
              return const UserScreen();
            } else if (role == 'verifier') {
              return const VerifierScreen();
            } else {
              return Scaffold(
                body: SizedBox(
                  width: kwidth,
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 25.0,
                        width: 25.0,
                        child: CircularProgressIndicator(
                          color: kBlack,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Text(
                          "Fetching User Details...",
                          style: TextStyle(
                            fontSize: 17.0,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              );
            }
          }
          //useris not logged in
          else {
            return const LoginOrRegisterPage();
          }
        },
      ),
    );
  }
}
