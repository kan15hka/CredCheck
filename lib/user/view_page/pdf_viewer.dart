import 'package:credcheck/constants.dart';
import 'package:flutter/material.dart';
import 'package:easy_pdf_viewer/easy_pdf_viewer.dart';

class DocumentPdfViewer extends StatefulWidget {
  final String pdfFileName;
  final String pdfUrl;
  const DocumentPdfViewer(
      {super.key, required this.pdfFileName, required this.pdfUrl});

  @override
  State<DocumentPdfViewer> createState() => _DocumentPdfViewerState();
}

class _DocumentPdfViewerState extends State<DocumentPdfViewer> {
  PDFDocument? pdfDocument;
  void initialisePdf() async {
    pdfDocument = await PDFDocument.fromURL(widget.pdfUrl);
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    initialisePdf();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        automaticallyImplyLeading: true,
        backgroundColor: Colors.black,
        centerTitle: true,
        title: Text(widget.pdfFileName),
      ),
      body: (pdfDocument != null)
          ? PDFViewer(
              scrollDirection: Axis.vertical,
              indicatorBackground: kBlack,
              indicatorText: kWhite,
              backgroundColor: kWhite,
              progressIndicator: CircularProgressIndicator(
                color: kBlack,
              ),
              pickerButtonColor: kBlack,
              document: pdfDocument!)
          : const Center(
              child: CircularProgressIndicator(
                color: kBlack,
              ),
            ),
    );
  }
}
