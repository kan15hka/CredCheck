import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:credcheck/user/view_page/pdf_viewer.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../constants.dart';

class ScanQRCode extends StatefulWidget {
  const ScanQRCode({super.key});

  @override
  State<ScanQRCode> createState() => _ScanQRCodeState();
}

class _ScanQRCodeState extends State<ScanQRCode> {
  bool isInvalid = true;
  bool? isLoading;
  final bool _isLoading = false;
  Map<String, dynamic> scannedDocument = {};
  Map<String, dynamic> scannedUserVerif = {};
  //QR Scanner
  final GlobalKey _globalKey = GlobalKey();
  String scannedCode = '';
  bool isScanning = true;
  QRViewController? qrViewController;
  Barcode? scannedBarCode;

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

  void onQRViewCreated(QRViewController qrViewController) {
    this.qrViewController = qrViewController;
    qrViewController.scannedDataStream.listen((event) {
      if (isScanning) {
        setState(() {
          scannedBarCode = event;
          scannedCode = scannedBarCode!.code.toString();
          isScanning = false;
        });
      }
      qrViewController.pauseCamera();
      checkDocumentInfo(scannedCode);
    });
  }

  void checkDocumentInfo(String scannedCode) async {
    setState(() {
      isLoading = true;
    });
    qrViewController!.dispose();
    List<Map<String, dynamic>> dataList = [];
    List<Map<String, dynamic>> userverifList = [];
    List<String> collectionList = [];
    Map<String, dynamic> userverifData = {};

    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('userverif').get();

    querySnapshot.docs.forEach((doc) {
      userverifData = doc.data() as Map<String, dynamic>;

      if (userverifData['role'] == "user") {
        userverifList.add(userverifData);
        collectionList.add(doc.id);
      }
    });
    List<Future<void>> futures = [];

    for (String collectionName in collectionList) {
      Future<void> future = FirebaseFirestore.instance
          .collection("documents")
          .doc("documents")
          .collection(collectionName)
          .get()
          .then((querySnapshot) {
        querySnapshot.docs.forEach((docu) {
          Map<String, dynamic> documentData =
              docu.data() as Map<String, dynamic>;

          if (documentData['status'] == "approved") {
            documentData["email"] = collectionName;
            userverifList.forEach(
              (element) {
                if (element["email"] == collectionName) {
                  documentData["name"] = element["name"];
                }
              },
            );
            dataList.add(documentData);
          }
        });
      });
      futures.add(future);
    }

    await Future.wait(futures);
    setState(() {
      isLoading = false;
    });
    var flagList = List.filled(dataList.length, 0);
    for (int i = 0; i < dataList.length; i++) {
      if (dataList[i]["uid"] == scannedCode) {
        setState(() {
          scannedDocument = dataList[i];
          isInvalid = false;
        });
        showSnackBarDown("The Document is Valid");
      } else {
        flagList[i] = 1;
      }
    }

    if (!(flagList.contains(0))) {
      showSnackBarDown("The Document is Invalid");
      setState(() {
        isInvalid = true;
      });
    }
  }

  void dispose() {
    qrViewController!.dispose();
    super.dispose();
  }

  void showSnackbar(String text) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        text,
        textAlign: TextAlign.center,
      ),
      margin: EdgeInsets.only(bottom: kheight! * 0.75, left: 20.0, right: 20.0),
      behavior: SnackBarBehavior.floating,
      elevation: 0.0,
      // backgroundColor: kPrimaryColor.withOpacity(0.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 60.0,
        centerTitle: true,
        backgroundColor: kBlack,
        elevation: 0.0,
        title: Text(
          "QR Scan Check",
          style: TextStyle(fontSize: 22.0, color: kWhite),
        ),
      ),
      body: SingleChildScrollView(
        child: SizedBox(
          width: kwidth,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 40.0, vertical: 25.0),
                child: Text(
                  "Hold the Camera towards the Qr Code",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 17.0),
                ),
              ),
              Stack(alignment: AlignmentDirectional.center, children: [
                Container(
                  height: kwidth! * 0.62 + 10.0,
                  width: kwidth! * 0.62 + 10.0,
                  decoration: BoxDecoration(
                      border: Border.all(color: kBlack, width: 2.0),
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10.0)),
                ),
                SizedBox(
                  height: kwidth! * 0.62,
                  width: kwidth! * 0.62,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10.0),
                    child: QRView(
                      key: _globalKey,
                      //overlayMargin: EdgeInsets.all(10.0),
                      overlay: QrScannerOverlayShape(
                          borderColor: const Color.fromARGB(255, 255, 255, 255),
                          borderLength: 30.0,
                          borderRadius: 10.0,
                          cutOutSize: 180.0,
                          overlayColor: Color.fromARGB(100, 0, 0, 0),
                          borderWidth: 10.0),
                      onQRViewCreated: onQRViewCreated,
                    ),
                  ),
                ),
                (scannedBarCode != null)
                    ? Stack(
                        alignment: AlignmentDirectional.center,
                        children: [
                          SizedBox(
                              height: kwidth! * 0.625,
                              width: kwidth! * 0.625,
                              child: QrImageView(
                                data: scannedCode,
                                backgroundColor: Colors.white,
                              )),
                          (_isLoading)
                              ? const Center(
                                  child: SizedBox(
                                    height: 40.0,
                                    width: 40.0,
                                    child: CircularProgressIndicator(
                                      color: kBlack,
                                      strokeWidth: 6.0,
                                    ),
                                  ),
                                )
                              : Container(
                                  height: 40.0,
                                  width: 200.0,
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 15.0),
                                  decoration: BoxDecoration(
                                      color: kGrey,
                                      borderRadius:
                                          BorderRadius.circular(10.0)),
                                  child: const Center(
                                    child: Text(
                                      "SCAN SUCCESSFULL",
                                      style: TextStyle(
                                          fontSize: 16.0,
                                          color: kBlack,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                )
                        ],
                      )
                    : Container()
              ]),
              const SizedBox(
                height: 10.0,
              ),
              //QR SCAN STATUS
              (isLoading == null)
                  ? Container()
                  : (isLoading!)
                      ? const SizedBox(
                          height: 25.0,
                          width: 25.0,
                          child: CircularProgressIndicator(
                            color: kBlack,
                          ))
                      : (scannedBarCode != null && !isInvalid)
                          ? Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20.0, vertical: 10.0),
                              child: Column(
                                children: [
                                  RichText(
                                    textAlign: TextAlign.center,
                                    text: TextSpan(
                                      children: <TextSpan>[
                                        TextSpan(
                                          text: 'The scanned document is ',
                                          style: TextStyle(
                                            fontFamily: kFontFamily,
                                            color: Colors.black,
                                            fontSize: 17.0,
                                          ),
                                        ),
                                        TextSpan(
                                          text: scannedDocument["name"],
                                          style: TextStyle(
                                              fontFamily: kFontFamily,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 17.0,
                                              color: Colors.black),
                                        ),
                                        TextSpan(
                                          text: "'s approved ",
                                          style: TextStyle(
                                              fontFamily: kFontFamily,
                                              fontSize: 17.0,
                                              color: Colors.black),
                                        ),
                                        TextSpan(
                                          text: scannedDocument["fileName"],
                                          style: TextStyle(
                                              fontFamily: kFontFamily,
                                              fontSize: 17.0,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black),
                                        ),
                                      ],
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  DocumentPdfViewer(
                                                      pdfFileName:
                                                          scannedDocument[
                                                              "fileName"],
                                                      pdfUrl: scannedDocument[
                                                          "fileURL"])));
                                    },
                                    child: Container(
                                      width: kwidth! * 0.7,
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 15.0),
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 10.0, vertical: 10.0),
                                      decoration: BoxDecoration(
                                          color: kBlack,
                                          borderRadius:
                                              BorderRadius.circular(5.0)),
                                      child: Row(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 5.0),
                                            child: Icon(
                                              FontAwesomeIcons.eye,
                                              color: kWhite,
                                            ),
                                          ),
                                          Expanded(
                                            child: Text(
                                              scannedDocument["fileName"],
                                              maxLines: 5,
                                              style: TextStyle(
                                                  fontFamily: kFontFamily,
                                                  fontSize: 16.0,
                                                  fontWeight: FontWeight.bold,
                                                  color: kWhite),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                  const Text(
                                    "The Scanned Code",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 17.0,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    scannedCode,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 16.0,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : const Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 30.0, vertical: 15.0),
                              child: Text(
                                "The Scanned Document is invalid or not found",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 17.0,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
              Padding(
                  padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom))
            ],
          ),
        ),
      ),
    );
  }
}
