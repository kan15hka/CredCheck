import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:credcheck/constants.dart';
import 'package:credcheck/verifier/home_page/documents_listview_verifier.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class VerifyUploadedDocuments extends StatefulWidget {
  final String name;
  final String documentId;
  const VerifyUploadedDocuments(
      {super.key, required this.documentId, required this.name});

  @override
  State<VerifyUploadedDocuments> createState() =>
      _VerifyUploadedDocumentsState();
}

class _VerifyUploadedDocumentsState extends State<VerifyUploadedDocuments>
    with TickerProviderStateMixin {
  List<Map<String, dynamic>> userDocuments = [];
  List<Map<String, dynamic>> uploadedDocuments = [];
  List<Map<String, dynamic>> approvedDocuments = [];
  List<Map<String, dynamic>> rejectedDocuments = [];
  List<Map<String, dynamic>> baseDocuments = [];
  late TabController _tabController;

  void segregateList(List<Map<String, dynamic>> userDocumentsList) {
    uploadedDocuments.clear();
    approvedDocuments.clear();
    rejectedDocuments.clear();
    baseDocuments.clear();

    for (Map<String, dynamic> element in userDocumentsList) {
      if ((element['status'] == 'uploaded')) {
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
    }
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
        appBar: AppBar(
          elevation: 0.0,
          automaticallyImplyLeading: true,
          backgroundColor: Colors.black,
          centerTitle: true,
          title: const Text(
            "Verify Documents",
            style: TextStyle(color: Colors.white, fontSize: 22.0),
          ),
        ),
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
                              child: DocumentsListViewVerifier(
                            documentList: baseDocuments,
                            status: "base",
                            documentId: widget.documentId,
                            name: widget.name,
                          )),
                        ],
                      ),
                    ));
              },
            );
          },
          child: Container(
            width: 150.0,
            margin: EdgeInsets.only(left: 10.0, bottom: 20.0),
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
        body: SafeArea(
          child: Column(children: [
            Padding(
              padding: EdgeInsets.all(10.0),
              child: Text(
                widget.name,
                style: TextStyle(fontSize: 17.0, fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              height: 2.0,
              color: kGrey,
            ),
            SizedBox(
              height: 20.0,
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
              child: Text("Tap to verify document"),
            ),

            // //TAB BAR VIEW
            Expanded(
              child: StreamBuilder<QuerySnapshot<Object?>>(
                  stream: FirebaseFirestore.instance
                      .collection("documents")
                      .doc("documents")
                      .collection(widget.documentId)
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
                          DocumentsListViewVerifier(
                            documentList: uploadedDocuments,
                            status: "uploaded",
                            documentId: widget.documentId,
                            name: widget.name,
                          ),
                          DocumentsListViewVerifier(
                            documentList: approvedDocuments,
                            status: "approved",
                            documentId: widget.documentId,
                            name: widget.name,
                          ),
                          DocumentsListViewVerifier(
                            documentList: rejectedDocuments,
                            status: "rejected",
                            documentId: widget.documentId,
                            name: widget.name,
                          ),
                        ],
                      );
                    }
                    return const Center(
                        child: CircularProgressIndicator(
                      color: Colors.black,
                    ));
                  }),
            ),
          ]),
        ));
  }
}
