import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:credcheck/constants.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class UploadBaseDocuments extends StatefulWidget {
  const UploadBaseDocuments({super.key});

  @override
  State<UploadBaseDocuments> createState() => _UploadBaseDocumentsState();
}

class _UploadBaseDocumentsState extends State<UploadBaseDocuments> {
  List<Map<String, dynamic>> pdfFileDoc = [];

  CollectionReference userDocuments = FirebaseFirestore.instance
      .collection('documents')
      .doc('documents')
      .collection(FirebaseAuth.instance.currentUser!.email.toString());

  Future<void> pickPdf(int index) async {
    final pickedFile = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (pickedFile != null) {
      File? pdfFile = File(pickedFile.files.single.path!);
      int fileSizeInBytes = await pdfFile.length();
      double docFileSize = fileSizeInBytes / 1048576;

      setState(() {
        pdfFileDoc[index] = {
          "docIndex": index,
          "docName": pickedFile.files.single.name,
          "docFile": pdfFile,
          "docFileSize": docFileSize,
          "uploadProgress": null,
          "docDownloadUrl": null,
          "isFilePicked": true,
          "isUploading": false
        };
      });
    }
  }

  void showSnackBarDown(String content) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Center(
          child: Text(
        content,
        style:
            TextStyle(fontFamily: kFontFamily, fontSize: 15.0, color: kWhite),
      )),
      backgroundColor: kBlack,
      elevation: 0.0,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.only(bottom: 80.0),
      //shape: BoxBorder(b),
    ));
  }

  Future<void> uploadPdf(int index, String baseDocName) async {
    Map<String, dynamic> selectedDoc = pdfFileDoc[index];
    String pdfFileName = selectedDoc['docName'];
    print(selectedDoc);
    setState(() {
      selectedDoc["isUploading"] = true;
    });
    selectedDoc["isUploading"] = true;

    try {
      DocumentSnapshot documentSnapshot =
          await userDocuments.doc(pdfFileName).get();
      if (documentSnapshot.exists) {
        showSnackBarDown("File exists already");
        setState(() {
          pdfFileDoc.removeWhere((element) => element["docIndex"] == index);
        });
        return;
      }
    } catch (e) {
      showSnackBarDown("Error While Fetching Info");
    }
    Reference storageReference =
        FirebaseStorage.instance.ref().child('pdfs/$pdfFileName');

    UploadTask uploadTask = storageReference.putFile(selectedDoc['docFile']!);
    //proress bar
    uploadTask.snapshotEvents.listen((event) {
      setState(() {
        selectedDoc['uploadProgress'] =
            event.bytesTransferred.toDouble() / event.totalBytes.toDouble();
      });
      if (event.state == TaskState.success) {
        selectedDoc['uploadProgress'] = null;
      }
    }).onError((error) {
      print(error);
    });
    selectedDoc['docDownloadUrl'] = await storageReference.getDownloadURL();
    await uploadTask.whenComplete(() async {
      showSnackBarDown('Document Uploaded successfully');
      //Documents collection add
      Map<String, dynamic> documentsData = {
        'fileName': pdfFileName,
        'fileURL': selectedDoc['docDownloadUrl'].toString(),
        'status': 'base',
        'fileSize': selectedDoc['docFileSize']!.toStringAsFixed(2),
        'dateTime': Timestamp.fromDate(DateTime.now())
      };
      //Alerts collection add
      Map<String, dynamic> alertsData = {
        'title': "Document Uploaded",
        'message': "Your file $pdfFileName has been uploaded",
        'status': 'uploaded',
        'dateTime': Timestamp.fromDate(DateTime.now())
      };
      Map<String, dynamic> baseDocsData = {
        'docName': baseDocName,
        'isUploaded': true,
      };
      CollectionReference userAlerts = FirebaseFirestore.instance
          .collection('alerts')
          .doc('alerts')
          .collection(FirebaseAuth.instance.currentUser!.email.toString());
      CollectionReference userBaseDocuments = FirebaseFirestore.instance
          .collection('documents')
          .doc('documents')
          .collection("baseDocuments");
      try {
        await userDocuments.doc(pdfFileName).set(documentsData);
        await userAlerts.doc(pdfFileName).set(alertsData);
        await userBaseDocuments.doc("base${index + 1}").set(baseDocsData);
        showSnackBarDown('Document Info Added successfully');
      } catch (e) {
        showSnackBarDown('Error uploading data: $e');
        print('Error uploading data: $e');
      }

      setState(() {
        pdfFileDoc.removeWhere((element) => element["docIndex"] == index);
        selectedDoc["isUploading"] = false;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    pdfFileDoc = List.generate(100, (index) {
      return {'docIndex': -1, 'isUploading': false};
    });
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
            "CREDCHECK",
            style: TextStyle(color: Colors.white, fontSize: 25.0),
          ),
        ),
        body: SafeArea(
          child: Column(children: [
            const Padding(
              padding: EdgeInsets.all(15.0),
              child: Text(
                "Upload Base Documents",
                style: TextStyle(fontSize: 17.0, fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              height: 2.0,
              color: kGrey,
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot<Object?>>(
                  stream: FirebaseFirestore.instance
                      .collection("documents")
                      .doc("documents")
                      .collection("baseDocuments")
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }
                    if (snapshot.hasData) {
                      return ListView.builder(
                          physics: BouncingScrollPhysics(),
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (context, index) {
                            DocumentSnapshot baseDocument =
                                snapshot.data!.docs[index];
                            bool exist = false;

                            if (pdfFileDoc.isNotEmpty) {
                              for (int i = 0; i < pdfFileDoc.length; i++) {
                                if (pdfFileDoc[i]["docIndex"] == index) {
                                  exist = true;
                                }
                              }
                            }

                            return (baseDocument["isUploaded"])
                                ? Column(
                                    children: [
                                      Container(
                                        height: 75.0,
                                        color:
                                            Color.fromARGB(255, 214, 214, 214),
                                        child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 20.0,
                                                        vertical: 5.0),
                                                child: Text(
                                                  baseDocument['docName'],
                                                  style: const TextStyle(
                                                      fontSize: 16.0,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                              const Center(
                                                child: Text(
                                                  "The document has been uploaded already",
                                                  style: TextStyle(
                                                    fontSize: 14.0,
                                                  ),
                                                ),
                                              ),
                                            ]),
                                      ),
                                      Container(
                                        height: 2.0,
                                        color: kGrey,
                                      ),
                                    ],
                                  )
                                : Container(
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 20.0,
                                                vertical: 5.0),
                                            child: Text(
                                              baseDocument['docName'],
                                              style: const TextStyle(
                                                  fontSize: 16.0,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 20.0,
                                                vertical: 5.0),
                                            child: Row(
                                              children: [
                                                (exist &&
                                                        pdfFileDoc[index]
                                                            ['isFilePicked'])
                                                    ? InkWell(
                                                        onTap: () {
                                                          uploadPdf(
                                                              index,
                                                              baseDocument[
                                                                  'docName']);
                                                        },
                                                        child: Container(
                                                          height: 40.0,
                                                          width: 120.0,
                                                          decoration: BoxDecoration(
                                                              color: kBlack,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          5.0)),
                                                          child: const Center(
                                                            child: Text(
                                                              "Upload File",
                                                              style: TextStyle(
                                                                  color: kWhite,
                                                                  fontSize:
                                                                      16.0),
                                                            ),
                                                          ),
                                                        ),
                                                      )
                                                    : InkWell(
                                                        onTap: () {
                                                          pickPdf(index);
                                                        },
                                                        child: Container(
                                                          height: 40.0,
                                                          width: 120.0,
                                                          decoration: BoxDecoration(
                                                              color: kBlack,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          5.0)),
                                                          child: const Center(
                                                            child: Text(
                                                              "Choose File",
                                                              style: TextStyle(
                                                                  color: kWhite,
                                                                  fontSize:
                                                                      16.0),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                Container(
                                                  height: 20.0,
                                                  width: 20.0,
                                                  margin: const EdgeInsets.only(
                                                      left: 10.0),
                                                  color: kWhite,
                                                  child: (pdfFileDoc[index]
                                                          ["isUploading"])
                                                      ? const CircularProgressIndicator(
                                                          color: kBlack,
                                                        )
                                                      : Container(),
                                                ),
                                                if (exist)
                                                  Expanded(
                                                    child: Text(
                                                      pdfFileDoc[index]
                                                          ['docName'],
                                                      textAlign:
                                                          TextAlign.center,
                                                      maxLines: 3,
                                                      style: const TextStyle(
                                                          color: kBlack,
                                                          fontSize: 16.0),
                                                    ),
                                                  )
                                              ],
                                            ),
                                          ),
                                          if ((exist) &&
                                              (pdfFileDoc[index]
                                                      ['uploadProgress'] !=
                                                  null))
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 20.0,
                                                      vertical: 5.0),
                                              child: Stack(
                                                alignment: Alignment.center,
                                                children: [
                                                  ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            2.0),
                                                    child:
                                                        LinearProgressIndicator(
                                                      value: pdfFileDoc[index]
                                                          ['uploadProgress'],
                                                      backgroundColor: kGrey,
                                                      valueColor:
                                                          const AlwaysStoppedAnimation<
                                                              Color>(kBlack),
                                                      minHeight: 15.0,
                                                    ),
                                                  ),
                                                  Text(
                                                    "${pdfFileDoc[index]['uploadProgress']!.toStringAsFixed(2)}%",
                                                    style: const TextStyle(
                                                        color: kWhite,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  )
                                                ],
                                              ),
                                            ),
                                          const SizedBox(
                                            height: 5.0,
                                          ),
                                          Container(
                                            height: 2.0,
                                            color: kGrey,
                                          ),
                                        ]),
                                  );
                          });
                    }
                    return const Center(
                      child: SizedBox(
                        height: 20.0,
                        width: 20.0,
                        child: CircularProgressIndicator(
                          color: kBlack,
                        ),
                      ),
                    );
                  }),
            )
          ]),
        ));
  }
}
