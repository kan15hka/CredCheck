import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:credcheck/constants.dart';
import 'package:credcheck/user/docs_page/upi_payment.dart';
import 'package:credcheck/user/view_page/pdf_viewer.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

class DocumentsListViewUser extends StatefulWidget {
  final List<Map<String, dynamic>> documentList;
  final String status;
  const DocumentsListViewUser(
      {super.key, required this.documentList, required this.status});

  @override
  State<DocumentsListViewUser> createState() => _DocumentsListViewUserState();
}

class _DocumentsListViewUserState extends State<DocumentsListViewUser> {
  var isTappedList;
  var isDownloadingList;

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

  Dio dio = Dio();
  double progress = 0.0;

  void downloadPdf(String fileUrl, String fileName) async {
    String path = await _getFilePath(fileName);
    await dio.download(
      fileUrl,
      path,
      onReceiveProgress: (recievedBytes, totalBytes) {
        setState(() {
          progress = recievedBytes / totalBytes;
        });
        print(progress);
      },
      deleteOnError: true,
    ).then((_) {
      setState(() {
        progress = 0.0;
      });
      showSnackBarDown("$fileName Downloaded");
    });
  }

  Future<String> _getFilePath(String fileName) async {
    final dir = await getApplicationDocumentsDirectory();
    return "${dir.path}/$fileName";
  }

  @override
  void initState() {
    super.initState();
    isTappedList = List.filled(widget.documentList.length, false);
    isDownloadingList = List.filled(widget.documentList.length, false);
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
            padding: const EdgeInsets.only(top: 25.0, left: 35, right: 25.0),
            child: ListView.builder(
                physics: BouncingScrollPhysics(),
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
                                    child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Text(date),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 40.0),
                                          child: Text(time),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      fileName,
                                      style: const TextStyle(
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                        "${widget.documentList[index]['fileSize']}MB"),
                                  ],
                                ))
                              ],
                            ),
                          ),
                          if (isTappedList[index])
                            Container(
                              padding: EdgeInsets.symmetric(vertical: 10.0),
                              decoration: BoxDecoration(
                                  color: kGrey,
                                  borderRadius: BorderRadius.circular(5.0)),
                              child: (widget.documentList[index]['isPremium'])
                                  ? !(widget.documentList[index]['isPaid'])
                                      ? InkWell(
                                          onTap: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        UpiPaymentScreen(
                                                            fileName: fileName,
                                                            filePrice: widget
                                                                        .documentList[
                                                                    index][
                                                                'filePrice'])));
                                          },
                                          child: Column(
                                            children: [
                                              const Text(
                                                "It is a premium document",
                                                style: TextStyle(
                                                  fontSize: 15.0,
                                                ),
                                              ),
                                              Text(
                                                "\$${widget.documentList[index]['filePrice']}",
                                                style: const TextStyle(
                                                    fontSize: 17.0,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              const Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(FontAwesomeIcons
                                                      .fileInvoiceDollar),
                                                  SizedBox(
                                                    width: 15.0,
                                                  ),
                                                  Text(
                                                    "Pay to View",
                                                    style: TextStyle(
                                                        fontSize: 17.0,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        )
                                      : Column(
                                          children: [
                                            const Text(
                                              "It is a premium document",
                                              style: TextStyle(
                                                fontSize: 15.0,
                                              ),
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  "\$${widget.documentList[index]['filePrice']}",
                                                  style: const TextStyle(
                                                      fontSize: 17.0,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                const SizedBox(
                                                  width: 10.0,
                                                ),
                                                const Icon(FontAwesomeIcons
                                                    .fileInvoiceDollar),
                                                const SizedBox(
                                                  width: 10.0,
                                                ),
                                                const Text(
                                                  "Paid",
                                                  style: TextStyle(
                                                      fontSize: 17.0,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(
                                              height: 5.0,
                                            ),
                                            Row(
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
                                                                            .documentList[index]
                                                                        [
                                                                        'fileURL'],
                                                                  )));
                                                    },
                                                    child: IconText(
                                                        FontAwesomeIcons.eye,
                                                        "View")),
                                                InkWell(
                                                    onTap: () {
                                                      downloadPdf(
                                                          widget.documentList[
                                                              index]['fileURL'],
                                                          fileName);
                                                    },
                                                    child: (progress != 0.0)
                                                        ? Container(
                                                            width: 90.0,
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(5),
                                                            decoration: BoxDecoration(
                                                                color: kWhite,
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            5.0)),
                                                            child: Column(
                                                                children: [
                                                                  Stack(
                                                                    children: [
                                                                      const CircularProgressIndicator(
                                                                        color:
                                                                            kBlack,
                                                                      ),
                                                                      Text(progress
                                                                          .toStringAsFixed(
                                                                              2))
                                                                    ],
                                                                  ),
                                                                  const Text(
                                                                      "Downloading")
                                                                ]),
                                                          )
                                                        : IconText(
                                                            FontAwesomeIcons
                                                                .cloudArrowDown,
                                                            "Download")),

                                                //show qr if approved
                                              ],
                                            ),
                                          ],
                                        )
                                  : Row(
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
                                              downloadPdf(
                                                  widget.documentList[index]
                                                      ['fileURL'],
                                                  fileName);
                                            },
                                            child: (progress != 0.0)
                                                ? Container(
                                                    width: 90.0,
                                                    padding: EdgeInsets.all(5),
                                                    decoration: BoxDecoration(
                                                        color: kWhite,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5.0)),
                                                    child: Column(children: [
                                                      Stack(
                                                        children: [
                                                          const CircularProgressIndicator(
                                                            color: kBlack,
                                                          ),
                                                          Text(progress
                                                              .toStringAsFixed(
                                                                  2))
                                                        ],
                                                      ),
                                                      const Text("Downloading")
                                                    ]),
                                                  )
                                                : IconText(
                                                    FontAwesomeIcons
                                                        .cloudArrowDown,
                                                    "Download")),

                                        //show qr if approved
                                      ],
                                    ),
                            )
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
      width: 90.0,
      padding: const EdgeInsets.all(5),
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
