import 'package:credcheck/constants.dart';
import 'package:credcheck/verifier/check_page/scan_qrcode.dart';
import 'package:flutter/material.dart';

class CheckPageVerifier extends StatefulWidget {
  const CheckPageVerifier({super.key});

  @override
  State<CheckPageVerifier> createState() => _CheckPageVerifierState();
}

class _CheckPageVerifierState extends State<CheckPageVerifier> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kGrey,
      body: SingleChildScrollView(
        child: SizedBox(
          width: kwidth,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                color: kWhite,
                padding: EdgeInsets.symmetric(horizontal: 40.0, vertical: 25.0),
                child: Text(
                  "Scan the QR code to verify the documents",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 17.0),
                ),
              ),
              SizedBox(
                height: 20.0,
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(15.0), // Image border
                child: SizedBox.fromSize(
                  size: Size.fromRadius(120),
                  // Image radius
                  child: Image.asset('assets/images/qr.jpg', fit: BoxFit.cover),
                ),
              ),
              const SizedBox(
                height: 40.0,
              ),
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ScanQRCode()),
                  );
                },
                child: Container(
                  height: 50.0,
                  width: kwidth! * 0.5,
                  decoration: BoxDecoration(
                      color: kBlack, borderRadius: BorderRadius.circular(8.0)),
                  child: const Center(
                      child: Text(
                    "SCAN QR",
                    style: TextStyle(
                        color: kWhite,
                        fontSize: 17.0,
                        fontWeight: FontWeight.bold),
                  )),
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
