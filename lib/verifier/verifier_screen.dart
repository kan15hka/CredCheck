import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:credcheck/chat/chat_page.dart';
import 'package:credcheck/constants.dart';
import 'package:credcheck/verifier/alerts_page/alerts_page_verifier.dart';
import 'package:credcheck/verifier/check_page/check_page_verifier.dart';
import 'package:credcheck/verifier/home_page/home_page_verifier.dart';
import 'package:credcheck/verifier/profile_page/profile_page_verifier.dart';
import 'package:credcheck/verifier/upload_page/upload_page_verifier.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class VerifierScreen extends StatefulWidget {
  const VerifierScreen({super.key});

  @override
  State<VerifierScreen> createState() => _VerifierScreenState();
}

class _VerifierScreenState extends State<VerifierScreen> {
  int _currentIndex = 2;
  //NAV BAR ITEMS
  List<IconData> navBarIcons = [
    FontAwesomeIcons.qrcode,
    FontAwesomeIcons.cloudArrowUp,
    FontAwesomeIcons.house,
    FontAwesomeIcons.bell,
    FontAwesomeIcons.user,
  ];
  List<String> navBarText = ['CHECK', 'UPLOADS', 'HOME', 'ALERTS', 'PROFILE'];

  //NAV BAR WIDGETS
  List<Widget> navBarWidgets = [
    const CheckPageVerifier(),
    const UploadPageVerifier(),
    const HomePageVerifier(),
    const AlertsPageVerifier(),
    const ProfilePageVerifier()
  ];

  PageController pageController = PageController(
    initialPage: 2,
    keepPage: true,
  );

  Widget buildPageView() {
    return PageView(
        controller: pageController,
        onPageChanged: (index) {
          pageChanged(index);
        },
        children: navBarWidgets);
  }

  void pageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void bottomTapped(int index) {
    setState(() {
      _currentIndex = index;
      pageController.jumpToPage(index);
    });
  }

  String userRole = "<ROLE>";
  void getInformation() async {
    //UserVerif
    var userverifDocSnapshot = await FirebaseFirestore.instance
        .collection('userverif')
        .doc(FirebaseAuth.instance.currentUser!.email)
        .get();

    if (userverifDocSnapshot.exists) {
      Map<String, dynamic>? data = userverifDocSnapshot.data();
      setState(() {
        userRole = data?['role'];
      });
    }
  }

  @override
  void initState() {
    super.initState();

    getInformation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        elevation: 0.0,
        toolbarHeight: 70.0,
        automaticallyImplyLeading: false,
        leading: Container(
          height: 25.0,
          width: 60.0,
          margin: EdgeInsets.symmetric(vertical: 20, horizontal: 5.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0),
            color: kGrey,
          ),
          child: Center(
            child: Text(
              userRole.toUpperCase(),
              style: const TextStyle(
                  fontSize: 14.0, color: kBlack, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        leadingWidth: 80.0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: IconButton(
                onPressed: () {
                  FirebaseAuth.instance.signOut();
                },
                icon: const Icon(
                  Icons.logout,
                  color: kWhite,
                )),
          )
        ],
        backgroundColor: Colors.black,
        centerTitle: true,
        title: const Text(
          "CREDCHECK",
          style: TextStyle(color: Colors.white, fontSize: 25.0),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => ChatPage()));
        },
        backgroundColor: kWhite,
        shape: RoundedRectangleBorder(
            side: BorderSide(width: 2.0, color: kBlack),
            borderRadius: BorderRadius.circular(100)),
        child: Icon(
          MdiIcons.forumOutline,
          color: kBlack,
        ),
      ),
      body: buildPageView(),
      //body: navBarWidgets[_currentIndex],
      bottomNavigationBar: Container(
        color: Colors.black,
        padding: const EdgeInsets.only(
            left: 10.0, right: 10.0, bottom: 5.0, top: 5.0),
        child: Container(
          height: 60.0,
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.15),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
            borderRadius: BorderRadius.circular(15),
          ),
          child: ListView.builder(
            itemCount: 5,
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: kwidth! * .02),
            itemBuilder: (context, index) => InkWell(
              onTap: () {
                bottomTapped(index);
              },
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.fastEaseInToSlowEaseOut,
                    margin: EdgeInsets.only(
                      bottom: index == _currentIndex ? 0 : kwidth! * .029,
                      right: kwidth! * .025,
                      left: kwidth! * .025,
                    ),
                    width: kwidth! * .128,
                    height: index == _currentIndex ? kwidth! * .014 : 0,
                    decoration: const BoxDecoration(
                      color: kBlack,
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(10),
                      ),
                    ),
                  ),
                  Icon(
                    navBarIcons[index],
                    size: 20.0,
                    color: index == _currentIndex ? kBlack : kGrey,
                  ),
                  Text(
                    navBarText[index],
                    style: TextStyle(
                      fontSize: 10.0,
                      fontWeight: FontWeight.bold,
                      color: index == _currentIndex ? kBlack : kGrey,
                    ),
                  ),
                  SizedBox(height: kwidth! * .03),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
