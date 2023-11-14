import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:credcheck/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AlertsPageUser extends StatefulWidget {
  const AlertsPageUser({super.key});

  @override
  State<AlertsPageUser> createState() => _AlertsPageUserState();
}

class _AlertsPageUserState extends State<AlertsPageUser> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kWhite,
      body: SizedBox(
        width: kwidth,
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20.0),
              child: Text(
                "Alerts from CredCheck",
                style: TextStyle(fontSize: 17.0),
              ),
            ),
            Expanded(
              child: Container(
                width: kwidth,
                padding: const EdgeInsets.only(top: 5.0),
                color: kLGrey,
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection("alerts")
                      .doc("alerts")
                      .collection(
                          FirebaseAuth.instance.currentUser!.email.toString())
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
                      if (snapshot.data!.docs.isEmpty) {
                        return const Center(
                          child: Text(
                            "No Alerts found",
                            style: TextStyle(color: kWhite, fontSize: 16.0),
                          ),
                        );
                      }

                      return ListView.builder(
                          physics: BouncingScrollPhysics(),
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (context, index) {
                            final DocumentSnapshot data =
                                snapshot.data!.docs[index];
                            String alertMessage = data['message'];
                            DateTime alertDateTime =
                                (data['dateTime'] as Timestamp).toDate();
                            String alertTitle = data['title'];
                            String alertStatus = data['status'];
                            String date =
                                "${alertDateTime.day}-${alertDateTime.month}-${alertDateTime.year}";
                            String time =
                                DateFormat('hh:mm a').format(alertDateTime);

                            return Container(
                                height: 120.0,
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 20.0, vertical: 5.0),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10.0, vertical: 10.0),
                                decoration: BoxDecoration(
                                    color: kWhite,
                                    borderRadius: BorderRadius.circular(10.0),
                                    border:
                                        Border.all(color: kBlack, width: 2.0)),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          margin: const EdgeInsets.only(
                                              right: 20.0),
                                          height: 15.0,
                                          width: 15.0,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(2.0),
                                            color: (alertStatus == "approved")
                                                ? Colors.green
                                                : (alertStatus == "rejected")
                                                    ? Colors.red
                                                    : (alertStatus ==
                                                            "uploaded")
                                                        ? Colors.amber
                                                        : Colors.white,
                                          ),
                                        ),
                                        Text(date),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 50.0),
                                          child: Text(time),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      alertTitle,
                                      style: const TextStyle(
                                          fontSize: 15.0,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      alertMessage,
                                      style: const TextStyle(fontSize: 15.0),
                                    ),
                                  ],
                                ));
                          });
                    }
                    return const Center(
                        child: CircularProgressIndicator(
                      color: Colors.black,
                    ));
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
