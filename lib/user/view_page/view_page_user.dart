import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:credcheck/constants.dart';
import 'package:credcheck/user/view_page/documnet_listview_user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ViewPageUser extends StatefulWidget {
  const ViewPageUser({super.key});

  @override
  State<ViewPageUser> createState() => _ViewPageUserState();
}

class _ViewPageUserState extends State<ViewPageUser>
    with TickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> userDocuments = [];
  List<Map<String, dynamic>> uploadedDocuments = [];
  List<Map<String, dynamic>> approvedDocuments = [];
  List<Map<String, dynamic>> rejectedDocuments = [];
  List<Map<String, dynamic>> baseDocuments = [];
  void segregateList(List<Map<String, dynamic>> userDocumentsList) {
    uploadedDocuments.clear();
    approvedDocuments.clear();
    rejectedDocuments.clear();
    baseDocuments.clear();
    userDocumentsList.forEach(
      (element) {
        if (element['status'] == 'uploaded') {
          uploadedDocuments.add(element);
        } else if (element['status'] == 'approved') {
          approvedDocuments.add(element);
        } else if (element['status'] == 'rejected') {
          rejectedDocuments.add(element);
        } else if (element['status'] == 'base') {
          baseDocuments.add(element);
        } else {
          print('status not correct');
        }
      },
    );
  }

  @override
  void initState() {
    _tabController = TabController(length: 3, vsync: this);
    super.initState();
    userDocuments.clear();
    uploadedDocuments.clear();
    approvedDocuments.clear();
    rejectedDocuments.clear();
    baseDocuments.clear();
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kWhite,
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: InkWell(
        onTap: () {
          showModalBottomSheet<void>(
            context: context,
            builder: (BuildContext context) {
              return SizedBox(
                  height: 500,
                  child: Container(
                    color: kWhite,
                    child: Column(
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(15.0),
                          child: Text(
                            "BASE DOCUMENTS",
                            style: TextStyle(
                                fontSize: 17.0, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Expanded(
                            child: DocumentsListViewUser(
                                documentList: baseDocuments, status: "base")),
                      ],
                    ),
                  ));
            },
          );
        },
        child: Container(
          width: 150.0,
          padding: const EdgeInsets.all(10.0),
          decoration: BoxDecoration(
              color: kWhite,
              borderRadius: BorderRadius.circular(5.0),
              border: Border.all(color: kBlack, width: 2.0)),
          child: const Row(
            children: [
              Icon(FontAwesomeIcons.eye),
              SizedBox(
                width: 10.0,
              ),
              Text(
                "Base\nDocuments",
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(
            height: 15.0,
          ),
          Container(
            height: 40.0,
            decoration: BoxDecoration(
                color: kGrey,
                borderRadius: BorderRadius.circular(7.0),
                border: Border.all(color: kBlack, width: 1.5)),
            child: TabBar(
                labelStyle: TextStyle(
                    fontSize: 15.0, color: kWhite, fontFamily: kFontFamily),
                unselectedLabelStyle: TextStyle(
                    fontSize: 15.0, color: kBlack, fontFamily: kFontFamily),
                indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(2.0), color: kBlack),
                controller: _tabController,
                isScrollable: true,
                labelPadding: const EdgeInsets.symmetric(horizontal: 15.0),
                tabs: const [
                  Tab(
                      child: Text(
                    'UPLOADED',
                    textScaleFactor: 1.0,
                  )),
                  Tab(
                      child: Text(
                    'APPROVED',
                    textScaleFactor: 1.0,
                  )),
                  Tab(
                      child: Text(
                    'REJECTED',
                    textScaleFactor: 1.0,
                  ))
                ]),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 15.0),
            child: Text("Tap to view document"),
          ),

          // //TAB BAR VIEW
          Expanded(
            child: StreamBuilder<QuerySnapshot<Object?>>(
                stream: FirebaseFirestore.instance
                    .collection("documents")
                    .doc("documents")
                    .collection(
                        FirebaseAuth.instance.currentUser!.email.toString())
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                        child: CircularProgressIndicator(
                      color: kBlack,
                    ));
                  }
                  if (snapshot.hasData) {
                    userDocuments = snapshot.data!.docs
                        .map((DocumentSnapshot<Object?> document) {
                      Map<String, dynamic> data =
                          document.data() as Map<String, dynamic>;
                      // Optionally, you can also include the document ID in the map
                      data['documentId'] = document.id;
                      return data;
                    }).toList();
                    segregateList(userDocuments);
                    return TabBarView(
                      controller: _tabController,
                      children: [
                        //UPLAODED
                        DocumentsListViewUser(
                            documentList: uploadedDocuments,
                            status: "uploaded"),
                        DocumentsListViewUser(
                            documentList: approvedDocuments,
                            status: "approved"),
                        DocumentsListViewUser(
                            documentList: rejectedDocuments,
                            status: "rejected"),
                      ],
                    );
                  }
                  return const Center(
                      child: CircularProgressIndicator(
                    color: Colors.black,
                  ));
                }),
          ),
        ],
      ),
    );
  }
}
