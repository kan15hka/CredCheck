import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:credcheck/constants.dart';
import 'package:credcheck/user/home_page/base_documents.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class UploadDcuments extends StatefulWidget {
  const UploadDcuments({super.key});

  @override
  State<UploadDcuments> createState() => _UploadDcumentsState();
}

class _UploadDcumentsState extends State<UploadDcuments> {
  CollectionReference userDocuments = FirebaseFirestore.instance
      .collection('documents')
      .doc('documents')
      .collection(FirebaseAuth.instance.currentUser!.email.toString());

  File? pdfFile;
  String pdfFileName = "";
  double? pdfFileSize;
  bool isUploading = false;
  Future<void> pickPdf() async {
    final pickedFile = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (pickedFile != null) {
      setState(() {
        pdfFileName = pickedFile.files.single.name;
        pdfFile = File(pickedFile.files.single.path!);
      });
    }
    int fileSizeInBytes = await pdfFile!.length();
    double fileSizeInKB = fileSizeInBytes / 1024;
    pdfFileSize = fileSizeInKB / 1024;
  }

  double? uploadProgress;
  String? downloadURL;
  List recordList = [];

  void showSnackBarDown(String content) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Center(
          child: Text(
        content,
        style:
            TextStyle(fontFamily: kFontFamily, fontSize: 15.0, color: kWhite),
      )),
      backgroundColor: kBlack,

      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.only(bottom: 80.0),
      //shape: BoxBorder(b),
    ));
  }

  Future<void> uploadPdf() async {
    setState(() {
      isUploading = true;
    });
    try {
      DocumentSnapshot documentSnapshot =
          await userDocuments.doc(pdfFileName).get();
      if (documentSnapshot.exists) {
        showSnackBarDown("File exists already");
        setState(() {
          uploadProgress = null;
          pdfFile = null;
          pdfFileName = "";
          downloadURL = "";
          pdfFileSize = null;
        });
        return;
      }
    } catch (e) {
      showSnackBarDown("Error While Fetching Info");
    }
    Reference storageReference =
        FirebaseStorage.instance.ref().child('pdfs/$pdfFileName');

    UploadTask uploadTask = storageReference.putFile(pdfFile!);
    //proress bar
    uploadTask.snapshotEvents.listen((event) {
      setState(() {
        uploadProgress =
            event.bytesTransferred.toDouble() / event.totalBytes.toDouble();
      });
      if (event.state == TaskState.success) {
        uploadProgress = null;
      }
    }).onError((error) {
      print(error);
    });
    downloadURL = await storageReference.getDownloadURL();
    await uploadTask.whenComplete(() async {
      showSnackBarDown('Document Uploaded successfully');
      //Documents collection add
      Map<String, dynamic> documentsData = {
        'fileName': pdfFileName,
        'fileURL': downloadURL.toString(),
        'status': 'uploaded',
        'fileSize': pdfFileSize!.toStringAsFixed(2),
        'dateTime': Timestamp.fromDate(DateTime.now())
      };
      //Alerts collection add
      Map<String, dynamic> alertsData = {
        'title': "Document Uploaded",
        'message': "Your file $pdfFileName has been uploaded",
        'status': 'uploaded',
        'dateTime': Timestamp.fromDate(DateTime.now())
      };
      print("alertsdata" + alertsData.toString());
      CollectionReference userAlerts = FirebaseFirestore.instance
          .collection('alerts')
          .doc('alerts')
          .collection(FirebaseAuth.instance.currentUser!.email.toString());
      try {
        await userDocuments.doc(pdfFileName).set(documentsData);
        await userAlerts.doc(pdfFileName).set(alertsData);
        showSnackBarDown('Document Info Added successfully');
      } catch (e) {
        showSnackBarDown('Error uploading data: $e');
        print('Error uploading data: $e');
      }

      setState(() {
        isUploading = false;
        uploadProgress = null;
        pdfFile = null;
        pdfFileSize = null;
        pdfFileName = "";
        downloadURL = "";
      });
    });
  }

  @override
  void initState() {
    super.initState();
    uploadProgress = null;
    pdfFile = null;
    pdfFileSize = null;
    pdfFileName = "";
    downloadURL = "";
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        /////////////////////////////////////
        //UPLOAD DOC
        /////////////////////////////////////
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 20.0),
          child: Text(
            "Upload a Certificate that has to be verified",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16.0),
          ),
        ),
        (pdfFile == null)
            ? InkWell(
                onTap: pickPdf, child: SelectPDFButton('Upload a Certificate'))
            : InkWell(onTap: uploadPdf, child: UploadPDFButton(pdfFileName)),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 20.0),
          child: Text(
            "Upload Base Certificates for verification",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16.0),
          ),
        ),
        /////////////////////////////////////
        //UPLOAD BASE DOC
        /////////////////////////////////////
        InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => UploadBaseDocuments()));
            },
            child: SelectPDFButton("Upload Base\n Certificates"))
      ],
    );
  }

  Widget SelectPDFButton(String buttonName) {
    return Container(
      //color: Colors.amber,
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Container(
        height: 70.0,
        width: 250.0,
        decoration: shadowBoxDecoration,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const Icon(
              FontAwesomeIcons.cloudArrowUp,
              size: 30.0,
            ),
            Text(
              buttonName,
              style: const TextStyle(fontSize: 16.0),
            )
          ],
        ),
      ),
    );
  }

  Widget UploadPDFButton(String fileName) {
    return Container(
      // height: 70.0,
      width: 250.0,

      decoration: shadowBoxDecoration,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (isUploading)
                const Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: SizedBox(
                    height: 15.0,
                    width: 15.0,
                    child: CircularProgressIndicator(
                      color: kBlack,
                    ),
                  ),
                ),
              const Padding(
                padding: EdgeInsets.only(left: 15.0, right: 15.0, top: 10.0),
                child: Text(
                  "Selected File",
                  style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
            child: Text(
              fileName,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16.0),
            ),
          ),
          Container(
              height: 25.0,
              width: 250.0,
              decoration: const BoxDecoration(
                  color: kGrey,
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(8.0),
                      bottomRight: Radius.circular(8.0))),
              child: (uploadProgress == null)
                  ? const Center(
                      child: Text(
                      "Tap to Upload",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ))
                  : Stack(
                      alignment: Alignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(8.0),
                              bottomRight: Radius.circular(8.0)),
                          child: LinearProgressIndicator(
                            value: uploadProgress,
                            backgroundColor: kGrey,
                            valueColor:
                                const AlwaysStoppedAnimation<Color>(kBlack),
                            minHeight: 25.0,
                          ),
                        ),
                        Text(
                          "${uploadProgress!.toStringAsFixed(2)}%",
                          style: const TextStyle(
                              color: kWhite, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ))
        ],
      ),
    );
  }
}
