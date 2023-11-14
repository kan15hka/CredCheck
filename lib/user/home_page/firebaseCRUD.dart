import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:credcheck/constants.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FirebaseCRUD {
  //PICK PDF
  File? pdfFile;
  String pdfFileName = "";
  double? pdfFileSize;
  Future<FilePickerResult?> pickPdf() async {
    final pickedFile = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (pickedFile != null) {
      pdfFileName = pickedFile.files.single.name;
      pdfFile = File(pickedFile.files.single.path!);
    }
    int fileSizeInBytes = await pdfFile!.length();
    double fileSizeInKB = fileSizeInBytes / 1024;
    pdfFileSize = fileSizeInKB / 1024;
    return pickedFile;
  }

  void showSnackBarDown(String content, BuildContext context) {
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

  CollectionReference userDocuments = FirebaseFirestore.instance
      .collection('documents')
      .doc('documents')
      .collection(FirebaseAuth.instance.currentUser!.email.toString());

  //UPLOAD PDF
  Future<bool> checkExists(BuildContext context, String pdfFileName) async {
    //check wether the document exists already
    try {
      DocumentSnapshot documentSnapshot =
          await userDocuments.doc(pdfFileName).get();
      if (documentSnapshot.exists) {
        return true;
      }
    } catch (e) {
      print(e);
    }
    return false;
  }

  Future<bool> addDocumentInfo(String? downloadURL, double? pdfFileSize) async {
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
    print("123456789" + documentsData.toString());
    CollectionReference userAlerts = FirebaseFirestore.instance
        .collection('alerts')
        .doc('alerts')
        .collection(FirebaseAuth.instance.currentUser!.email.toString());
    try {
      await userDocuments.doc(pdfFileName).set(documentsData);
      await userAlerts.doc(pdfFileName).set(alertsData);
      return true;
    } catch (e) {
      print('Error uploading data: $e');
      return false;
    }
  }
}
