import 'dart:io';
import 'package:http/http.dart' as http;

import 'package:credcheck/constants.dart';
import 'package:credcheck/verifier/send_mail/email_textfield.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:path_provider/path_provider.dart';

class SendEmailPage extends StatefulWidget {
  final String userName;
  final String fileName;
  final String fileUrl;
  const SendEmailPage(
      {super.key,
      required this.userName,
      required this.fileName,
      required this.fileUrl});

  @override
  State<SendEmailPage> createState() => _SendEmailPageState();
}

class _SendEmailPageState extends State<SendEmailPage> {
  final recipientEmailController = TextEditingController();
  final subjectController = TextEditingController();
  final bodyController = TextEditingController();
  bool isLoading = false;

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

  Future<void> sendEmail(
      String recipientEmail, String subject, String body) async {
    setState(() {
      isLoading = true;
    });
    try {
      var fileUrl = widget.fileUrl;
      Directory appDocDir = await getApplicationDocumentsDirectory();
      String filePath = '${appDocDir.path}/${widget.fileName}';
      var response = await http.get(Uri.parse(fileUrl));

      if (response.statusCode == 200) {
        File pdfFile = File(filePath);
        await pdfFile.writeAsBytes(response.bodyBytes);

        final Email email = Email(
          body: body,
          subject: subject,
          recipients: ['kanishka2727@gmail.com'],
          attachmentPaths: [filePath],
          isHTML: false,
        );

        await FlutterEmailSender.send(email);
        showSnackBarDown('Email sent successfully');
        setState(() {
          isLoading = false;
        });
      } else {
        showSnackBarDown(
            'Failed to download PDF. Status code: ${response.statusCode}');
        setState(() {
          isLoading = false;
        });
      }
    } catch (error) {
      print('Error sending email: $error');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    bodyController.dispose();
    recipientEmailController.dispose();
    subjectController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kGrey,
      appBar: AppBar(
        title: const Text(
          "Send Email",
          style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0.0,
        backgroundColor: kBlack,
        automaticallyImplyLeading: true,
        toolbarHeight: 60.0,
      ),
      body: SingleChildScrollView(
        child: Container(
          width: kwidth,
          color: kGrey,
          padding: const EdgeInsets.symmetric(
            horizontal: 25.0,
          ),
          child: Column(children: [
            const SizedBox(
              height: 30.0,
            ),
            const Text(
              "Send the email to Third Party Organistion for verification",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16.0,
              ),
            ),
            const SizedBox(
              height: 25.0,
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(vertical: 15.0, horizontal: 15.0),
              decoration: BoxDecoration(
                  color: kBlack, borderRadius: BorderRadius.circular(10.0)),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: Text(
                      "From: ${FirebaseAuth.instance.currentUser!.email.toString()}",
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16.0, color: kWhite),
                    ),
                  ),
                  SendEmailTextField(
                    controller: recipientEmailController,
                    hintText: 'Recipient Email',
                    obscureText: false,
                    minLines: 1,
                  ),
                  SendEmailTextField(
                    controller: subjectController,
                    hintText: 'Subject',
                    obscureText: false,
                    minLines: 1,
                  ),
                  SendEmailTextField(
                    controller: bodyController,
                    hintText: 'Body',
                    obscureText: false,
                    minLines: 3,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: Text(
                      "Attached File\nUser: ${widget.userName}",
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16.0, color: kWhite),
                    ),
                  ),
                  Container(
                    constraints: const BoxConstraints(maxWidth: 150.0),
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                        color: kGrey, borderRadius: BorderRadius.circular(8.0)),
                    child: Center(
                      child: Text(
                        widget.fileName,
                        style: const TextStyle(
                            fontSize: 16.0, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      sendEmail(recipientEmailController.text,
                          subjectController.text, bodyController.text);
                    },
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 200.0),
                      padding: const EdgeInsets.all(12.0),
                      margin: const EdgeInsets.symmetric(vertical: 15.0),
                      decoration: BoxDecoration(
                          color: kWhite,
                          borderRadius: BorderRadius.circular(8.0),
                          border: Border.all(color: kGrey, width: 2.0)),
                      child: (isLoading)
                          ? const CircularProgressIndicator(
                              color: kBlack,
                            )
                          : const Center(
                              child: Text(
                                "Send Mail",
                                style: TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                    ),
                  )
                ],
              ),
            )
          ]),
        ),
      ),
    );
  }
}
