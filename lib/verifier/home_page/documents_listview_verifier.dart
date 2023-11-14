import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:credcheck/constants.dart';
import 'package:credcheck/user/view_page/pdf_viewer.dart';
import 'package:credcheck/verifier/send_mail/send_email_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:uuid/uuid.dart';

class DocumentsListViewVerifier extends StatefulWidget {
  final List<Map<String, dynamic>> documentList;
  final String status;
  final String documentId;
  final String name;
  const DocumentsListViewVerifier(
      {super.key,
      required this.documentList,
      required this.status,
      required this.name,
      required this.documentId});

  @override
  State<DocumentsListViewVerifier> createState() =>
      _DocumentsListViewVerifierState();
}

class _DocumentsListViewVerifierState extends State<DocumentsListViewVerifier> {
  var uuid = Uuid();

  var isTappedList;

  void showSnackBarDown(String content) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Center(
          child: Text(
        content,
        style:
            TextStyle(fontFamily: kFontFamily, fontSize: 15.0, color: kWhite),
      )),
      backgroundColor: kGrey,
      elevation: 0.0,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.only(bottom: 80.0),
      //shape: BoxBorder(b),
    ));
  }

  void addVerifyDocInfo(String fileDocId, String verifyValue) {
    try {
      final CollectionReference documentCollectionReference = FirebaseFirestore
          .instance
          .collection('documents')
          .doc("documents")
          .collection(widget.documentId);
      final CollectionReference alertsUserCollectionReference =
          FirebaseFirestore.instance
              .collection('alerts')
              .doc("alerts")
              .collection(widget.documentId);
      final CollectionReference alertsVerifierCollectionReference =
          FirebaseFirestore.instance
              .collection('alerts')
              .doc("alerts")
              .collection(FirebaseAuth.instance.currentUser!.email.toString());
      Map<String, dynamic> alertsData = {
        'title':
            "Document ${verifyValue[0].toLowerCase() + verifyValue.substring(1)}",
        'message': "${widget.name}'s file $fileDocId has been $verifyValue",
        'uplodedByName': widget.name,
        'uplodedByEmail': widget.documentId,
        'status': verifyValue,
        'dateTime': Timestamp.fromDate(DateTime.now())
      };
      if (verifyValue == "approved") {
        documentCollectionReference
            .doc(fileDocId)
            .update({'status': verifyValue, "uid": uuid.v1()});
      } else {
        documentCollectionReference
            .doc(fileDocId)
            .update({'status': verifyValue});
      }

      alertsUserCollectionReference
          .doc(DateTime.now().toString())
          .set(alertsData);
      alertsVerifierCollectionReference
          .doc(DateTime.now().toString())
          .set(alertsData);
      showSnackBarDown('The Document is $verifyValue');
    } catch (e) {
      print('Failed to update user: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    isTappedList = List.filled(widget.documentList.length, false);
  }

  @override
  Widget build(BuildContext context) {
    return (widget.documentList.isEmpty)
        ? Container(
            color: kBlack,
            width: kwidth,
            margin: (widget.status == "base")
                ? const EdgeInsets.only(left: 5.0, right: 5.0)
                : const EdgeInsets.all(0.0),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    top: 100.0,
                  ),
                  child: Text(
                    "No ${widget.status} documents",
                    style: const TextStyle(color: kWhite, fontSize: 16.0),
                  ),
                ),
              ],
            ),
          )
        : Container(
            color: kBlack,
            padding: EdgeInsets.only(left: 25.0, right: 25.0, top: 20.0),
            child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: widget.documentList.length,
                itemBuilder: ((context, index) {
                  DateTime documentDateTime =
                      (widget.documentList[index]['dateTime'] as Timestamp)
                          .toDate();
                  String fileName = widget.documentList[index]['fileName'];

                  String date =
                      "${documentDateTime.day}-${documentDateTime.month}-${documentDateTime.year}";
                  String time = DateFormat('hh:mm a').format(documentDateTime);

                  return InkWell(
                    onTap: () {
                      setState(() {
                        isTappedList =
                            List.filled(widget.documentList.length, false);
                        isTappedList[index] = true;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 15.0),
                      decoration: BoxDecoration(
                          color: kWhite,
                          borderRadius: BorderRadius.circular(10.0)),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 15.0, horizontal: 10.0),
                            child: Row(
                              children: [
                                Image.asset(
                                  'assets/images/pdf.png',
                                  height: 50.0,
                                ),
                                const SizedBox(
                                  width: 25.0,
                                ),
                                Expanded(
                                    child: Container(
                                  color: kWhite,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Text(date),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 15.0),
                                            child: Text(time),
                                          ),
                                        ],
                                      ),
                                      Text(
                                        fileName,
                                        maxLines: 3,
                                        style: const TextStyle(
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                          "${widget.documentList[index]['fileSize']}MB"),
                                    ],
                                  ),
                                )),
                                Column(
                                  children: [
                                    //if document is appreove show qr
                                    if (widget.status == "approved")
                                      InkWell(
                                        onTap: () {
                                          showDialog(
                                              context: context,
                                              builder: (context) {
                                                return Dialog(
                                                  child: Container(
                                                    width: kwidth! * 0.35,
                                                    height: 250,
                                                    decoration: BoxDecoration(
                                                        color: kWhite,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                                    15.0)),
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceEvenly,
                                                      children: [
                                                        SizedBox(
                                                          height: 180.0,
                                                          width: 180.0,
                                                          child: QrImageView(
                                                            padding:
                                                                EdgeInsets.zero,
                                                            data: widget
                                                                    .documentList[
                                                                index]['uid'],
                                                            version:
                                                                QrVersions.auto,
                                                          ),
                                                        ),
                                                        Text(
                                                          fileName,
                                                          maxLines: 3,
                                                          style: const TextStyle(
                                                              fontSize: 16.0,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              });
                                        },
                                        child: const Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Icon(FontAwesomeIcons.qrcode),
                                        ),
                                      ),
                                    //if not uploaded ie aproved or rejected show eye
                                    if (widget.status != "uploaded")
                                      InkWell(
                                          onTap: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        DocumentPdfViewer(
                                                          pdfFileName: fileName,
                                                          pdfUrl: widget
                                                                  .documentList[
                                                              index]['fileURL'],
                                                        )));
                                          },
                                          child: const Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Icon(FontAwesomeIcons.eye),
                                          ))
                                  ],
                                )
                              ],
                            ),
                          ),
                          //if List tile is tapped
                          if (isTappedList[index])
                            ///// if the certificate is base
                            (widget.status == "base")
                                ? Container(
                                    padding:
                                        EdgeInsets.symmetric(vertical: 10.0),
                                    decoration: BoxDecoration(
                                        color: kGrey,
                                        borderRadius:
                                            BorderRadius.circular(5.0)),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        InkWell(
                                            onTap: () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          DocumentPdfViewer(
                                                            pdfFileName:
                                                                fileName,
                                                            pdfUrl: widget
                                                                    .documentList[
                                                                index]['fileURL'],
                                                          )));
                                            },
                                            child: IconText(
                                                FontAwesomeIcons.eye, "View")),
                                        InkWell(
                                            onTap: () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          SendEmailPage(
                                                            userName:
                                                                widget.name,
                                                            fileName: fileName,
                                                            fileUrl: widget
                                                                    .documentList[
                                                                index]['fileURL'],
                                                          )));
                                            },
                                            child: IconText(
                                                FontAwesomeIcons.paperPlane,
                                                "Send")),
                                      ],
                                    ),
                                  )
                                ///// if the certificate is uloadded
                                : (widget.status == "uploaded")
                                    ? Container(
                                        padding: EdgeInsets.symmetric(
                                            vertical: 10.0),
                                        decoration: BoxDecoration(
                                            color: kGrey,
                                            borderRadius:
                                                BorderRadius.circular(5.0)),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            InkWell(
                                                onTap: () {
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              DocumentPdfViewer(
                                                                pdfFileName:
                                                                    fileName,
                                                                pdfUrl: widget
                                                                            .documentList[
                                                                        index]
                                                                    ['fileURL'],
                                                              )));
                                                },
                                                child: IconText(
                                                    FontAwesomeIcons.eye,
                                                    "View")),
                                            InkWell(
                                                onTap: () => addVerifyDocInfo(
                                                    widget.documentList[index]
                                                        ['documentId'],
                                                    "approved"),
                                                child: IconText(
                                                    FontAwesomeIcons.check,
                                                    "Approve")),
                                            InkWell(
                                                onTap: () => addVerifyDocInfo(
                                                    widget.documentList[index]
                                                        ['documentId'],
                                                    "rejected"),
                                                child: IconText(
                                                    FontAwesomeIcons.xmark,
                                                    "Reject")),
                                            InkWell(
                                                onTap: () {
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              SendEmailPage(
                                                                userName:
                                                                    widget.name,
                                                                fileName:
                                                                    fileName,
                                                                fileUrl: widget
                                                                            .documentList[
                                                                        index]
                                                                    ['fileURL'],
                                                              )));
                                                },
                                                child: IconText(
                                                    FontAwesomeIcons.paperPlane,
                                                    "Send")),
                                          ],
                                        ),
                                      )
                                    : Container()
                        ],
                      ),
                    ),
                  );
                })),
          );
  }
}

Widget IconText(IconData icon, String text) {
  return Container(
      width: 70.0,
      padding: EdgeInsets.all(5),
      decoration: BoxDecoration(
          color: kWhite, borderRadius: BorderRadius.circular(5.0)),
      child: Column(children: [
        Icon(
          icon,
          size: 23.0,
        ),
        Text(text)
      ]));
}
