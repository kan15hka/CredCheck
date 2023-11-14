import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:credcheck/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfilePageUser extends StatefulWidget {
  const ProfilePageUser({super.key});

  @override
  State<ProfilePageUser> createState() => _ProfilePageUserState();
}

class _ProfilePageUserState extends State<ProfilePageUser> {
  String orgName = "";
  String userName = "";
  String userEmail = "";
  String orgLocation = "";
  String userImageUrl = "";

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
        orgLocation = data?['location'];
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
        userName = data?['name'];
        userEmail = data?['email'];
        userImageUrl = data?['imageUrl'];
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
      backgroundColor: Color.fromARGB(255, 190, 190, 190),
      body: SingleChildScrollView(
        child: Container(
          width: kwidth,
          child: Column(
            children: [
              Container(
                width: kwidth,
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                decoration: BoxDecoration(
                    color: kWhite,
                    border: Border.all(color: kBlack, width: 2.0)),
                child: Column(
                  children: [
                    Text(
                      (orgName == "") ? "<Organisgation Name>" : orgName,
                      style: const TextStyle(
                          fontSize: 18.0, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      (orgLocation == "") ? "<Location>" : orgLocation,
                      style: const TextStyle(
                        fontSize: 17.0,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: kheight! * 0.15),
              Container(
                  width: kwidth! * 0.8,
                  decoration: BoxDecoration(
                      color: kWhite,
                      border: Border.all(color: kBlack, width: 2.0),
                      borderRadius: BorderRadius.circular(10.0)),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned(
                          top: -75.0,
                          left: kwidth! * 0.4 - 60,
                          child: ProfileImage(150.0, 120.0)),
                      SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: Column(
                            children: [
                              const SizedBox(
                                height: 100.0,
                              ),
                              TextRow("Name",
                                  (userName == "") ? "<User Name>" : userName),
                              TextRow(
                                  "Email",
                                  (userEmail == "")
                                      ? "<xxxxxxx@gmail.com>"
                                      : userEmail),
                              TextRow(
                                  "Role",
                                  (userRole == "")
                                      ? "<Role>"
                                      : userRole[0].toUpperCase() +
                                          userRole.substring(1)),
                              TextRow("DOB", "12/08/2003"),
                              const SizedBox(
                                height: 15.0,
                              ),
                              SizedBox(
                                height: 40.0,
                                width: 200.0,
                                child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      elevation: 0.0,
                                      backgroundColor: kBlack,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                    ),
                                    onPressed: () {
                                      FirebaseAuth.instance.signOut();
                                    },
                                    child: const Text(
                                      "Sign Out",
                                      style: TextStyle(
                                          color: kWhite,
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.bold),
                                    )),
                              ),
                              const SizedBox(
                                height: 15.0,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Widget ProfileImage(double height, double width) {
    return Stack(
      alignment: AlignmentDirectional.center,
      children: [
        Container(
          height: height + 4.0,
          width: width + 4.0,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            color: kBlack,
          ),
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(10.0),
          child: CachedNetworkImage(
            imageUrl: userImageUrl,
            fit: BoxFit.cover,
            height: height,
            width: width,
            placeholder: (context, url) =>
                Image.asset("assets/images/placeholder.jpg", fit: BoxFit.cover),
            errorWidget: (context, url, error) => Image.asset(
                "assets/images/placeholderError.jpg",
                fit: BoxFit.cover),
          ),
        ),
      ],
    );
  }

  Widget TextRow(String title, String data) {
    return Center(
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              //color: Colors.red,
              child: Text(
                title,
                style: const TextStyle(
                    color: kBlack, fontSize: 16.0, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(
            width: 5.0,
          ),
          Expanded(
            flex: 8,
            child: Container(
              //scolor: Colors.amber,
              child: Text(
                ": $data",
                style: const TextStyle(color: kBlack, fontSize: 16.0),
              ),
            ),
          )
        ],
      ),
    );
  }
}
