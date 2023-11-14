import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:credcheck/constants.dart';
import 'package:credcheck/user/docs_page/orgdocs_listview.dart';
import 'package:flutter/material.dart';

class DocsPageUser extends StatefulWidget {
  const DocsPageUser({super.key});

  @override
  State<DocsPageUser> createState() => _DocsPageUserState();
}

class _DocsPageUserState extends State<DocsPageUser> {
  bool isLoading = false;
  Future<List<Map<String, dynamic>>> getOrgDocument() async {
    setState(() {
      isLoading = true;
    });

    List<Map<String, dynamic>> documentList = [];
    List<Map<String, dynamic>> userverifList = [];
    List<String> collectionList = [];
    Map<String, dynamic> userverifData = {};

    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('userverif').get();

    querySnapshot.docs.forEach((doc) {
      userverifData = doc.data() as Map<String, dynamic>;

      if (userverifData['role'] == "verifier") {
        userverifList.add(userverifData);
        collectionList.add(doc.id);
      }
    });

    List<Future<void>> futures = [];

    for (String collectionName in collectionList) {
      Future<void> future = FirebaseFirestore.instance
          .collection("documents")
          .doc("orgDocuments")
          .collection(collectionName)
          .get()
          .then((querySnapshot) {
        querySnapshot.docs.forEach((docu) {
          Map<String, dynamic> documentData =
              docu.data() as Map<String, dynamic>;

          documentData["email"] = collectionName;
          userverifList.forEach(
            (element) {
              if (element["email"] == collectionName) {
                documentData["name"] = element["name"];
              }
            },
          );
          documentList.add(documentData);
        });
      });
      futures.add(future);
    }

    await Future.wait(futures);
    setState(() {
      isLoading = false;
    });
    return documentList;
  }

  List<Map<String, dynamic>> orgDocList = [];
  @override
  void initState() {
    super.initState();
    getOrgDocument().then((documentList) {
      // This code will be executed after the getOrgDocument() function completes
      orgDocList = documentList;
      print(documentList);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 15.0),
            child: Center(
                child: Text(
              "Organisation Documents",
              style: TextStyle(fontSize: 17.0, fontWeight: FontWeight.bold),
            )),
          ),
          (isLoading)
              ? const SizedBox(
                  height: 25.0,
                  width: 25.0,
                  child: CircularProgressIndicator(
                    color: kBlack,
                  ))
              : Expanded(
                  child: DocumentsListViewUser(
                      documentList: orgDocList, status: "uploaded"),
                )
        ],
      ),
    );
  }
}
