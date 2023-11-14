import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:credcheck/constants.dart';
import 'package:credcheck/user/home_page/upload_documents.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomePageUser extends StatefulWidget {
  const HomePageUser({super.key});

  @override
  State<HomePageUser> createState() => _HomePageUserState();
}

class _HomePageUserState extends State<HomePageUser> {
  String orgName = "";
  String userRole = "";
  void getInformation() async {
    //Organisation
    var organisationDocSnapshot = await FirebaseFirestore.instance
        .collection('organistion')
        .doc('information')
        .get();

    if (organisationDocSnapshot.exists) {
      Map<String, dynamic>? data = organisationDocSnapshot.data();
      setState(() {
        orgName = data?['name'];
      });
    }
    //UserVerif
    var userverifDocSnapshot = await FirebaseFirestore.instance
        .collection('userverif')
        .doc(FirebaseAuth.instance.currentUser!.email)
        .get();

    if (userverifDocSnapshot.exists) {
      Map<String, dynamic>? data = userverifDocSnapshot.data();
      setState(() {
        userRole = data?['role'];
      });
    }
  }

  @override
  void initState() {
    super.initState();

    getInformation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kWhite,
      body: SizedBox(
        width: kwidth,
        child: Column(children: [
          Container(
            width: kwidth,
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            decoration:
                BoxDecoration(border: Border.all(color: kBlack, width: 2.0)),
            child: Center(
              child: Text(
                (orgName == "") ? "<Organisgation Name>" : orgName,
                style: const TextStyle(
                    fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          UploadDcuments()
        ]),
      ),
    );
  }
}
