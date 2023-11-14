import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:credcheck/constants.dart';
import 'package:credcheck/verifier/home_page/verify_documents.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomePageVerifier extends StatefulWidget {
  const HomePageVerifier({super.key});

  @override
  State<HomePageVerifier> createState() => _HomePageVerifierState();
}

class _HomePageVerifierState extends State<HomePageVerifier> {
  String orgName = "";
  String userRole = "";
  List<Map<String, dynamic>> userverifData = [];
  List<Map<String, dynamic>> userData = [];
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

  Future<List<int>> getFileCount() async {
    List<String> collectionNames = [];
    for (var element in userData) {
      collectionNames.add(element["documentId"]);
    }
    List<int> counts = [];

    for (String collectionName in collectionNames) {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection("documents")
          .doc("documents")
          .collection(collectionName)
          .get();
      counts.add(querySnapshot.size);
    }

    return counts;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: kwidth,
        child: Column(children: [
          Container(
            width: kwidth,
            decoration: BoxDecoration(
                color: kWhite, border: Border.all(color: kBlack, width: 2.0)),
            padding: const EdgeInsets.symmetric(vertical: 15.0),
            child: Center(
              child: Text(
                (orgName == "") ? "<Organisgation Name>" : orgName,
                style: const TextStyle(
                    fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          SizedBox(
            height: kheight! * 0.025,
          ),
          const Text(
            "Tap to verify uploaded\ndocuments of users",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15.0),
          ),
          SizedBox(
            height: kheight! * 0.025,
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("userverif")
                    .snapshots(),
                builder: (context, userverifSnapshot) {
                  if (userverifSnapshot.hasError) {
                    return Center(
                      child: Text('Error: ${userverifSnapshot.error}',
                          style:
                              const TextStyle(fontSize: 24, color: Colors.red)),
                    );
                  }

                  if (userverifSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        backgroundColor: kBlack,
                      ),
                    );
                  }
                  if (userverifSnapshot.hasData) {
                    userverifData = userverifSnapshot.data!.docs
                        .map((DocumentSnapshot<Object?> document) {
                      Map<String, dynamic> data =
                          document.data() as Map<String, dynamic>;

                      data['documentId'] = document.id;
                      data["fileCount"] = 0;
                      return data;
                    }).toList();
                    userData = userverifData
                        .where((data) => data["role"] == "user")
                        .toList();
                    return FutureBuilder<List<int>>(
                        future: getFileCount(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: SizedBox(
                                height: 25.0,
                                width: 25.0,
                                child: CircularProgressIndicator(
                                  color: kBlack,
                                ),
                              ),
                            );
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          }
                          return Container(
                            color: kGrey,
                            padding: EdgeInsets.only(top: 20.0),
                            child: ListView.builder(
                                //physics: BouncingScrollPhysics(),
                                itemCount: userData.length,
                                itemBuilder: (context, index) {
                                  //getFileCount(userData[index]["documentId"], index);
                                  return InkWell(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  VerifyUploadedDocuments(
                                                    documentId: userData[index]
                                                        ["email"],
                                                    name: userData[index]
                                                        ["name"],
                                                  )));
                                    },
                                    child: UserListTile(
                                        userData[index]["imageUrl"],
                                        userData[index]["name"],
                                        userData[index]["email"],
                                        snapshot.data![index]),
                                  );
                                }),
                          );
                        });
                  }
                  return const Center(
                    child: SizedBox(
                        height: 25.0,
                        width: 25.0,
                        child: CircularProgressIndicator(color: kBlack)),
                  );
                }),
          )
        ]),
      ),
    );
  }
}

Widget UserListTile(String imageUrl, String name, String email, int fileCount) {
  return Column(
    children: [
      Container(
        margin: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
        decoration: BoxDecoration(
            color: kWhite, borderRadius: BorderRadius.circular(10.0)),
        height: 90.0,
        width: kwidth,
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          CachedNetworkImage(
            imageUrl: imageUrl,
            fit: BoxFit.cover,
            placeholder: (context, url) =>
                Image.asset("assets/images/placeholder.jpg", fit: BoxFit.cover),
            imageBuilder: (context, imageProvider) => Container(
              height: 70.0,
              width: 60.0,
              decoration: BoxDecoration(
                border: Border.all(color: kBlack, width: 2.0),
                borderRadius: BorderRadius.circular(8.0),
                image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
              ),
            ),
            errorWidget: (context, url, error) => Image.asset(
                "assets/images/placeholderError.jpg",
                fit: BoxFit.cover),
          ),
          SizedBox(
            width: kwidth! * 0.6,
            //color: Colors.red,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                      fontSize: 17.0, fontWeight: FontWeight.bold),
                ),
                Text(
                  email,
                  style: const TextStyle(fontSize: 16.0),
                ),
                Text(
                  // "${userData[index]["fileCount"]} files",
                  "$fileCount files",
                  style: const TextStyle(fontSize: 14.0),
                ),
              ],
            ),
          )
        ]),
      ),
    ],
  );
}
