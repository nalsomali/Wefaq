import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:wefaq/AdminProjectList.dart';
import 'package:wefaq/FavoritePage.dart';
import 'package:wefaq/ReportedAcc.dart';
import 'package:wefaq/ReportedEvents.dart';
import 'package:wefaq/eventsTabs.dart';
//import 'package:wefaq/favoriteProject.dart';
import 'package:wefaq/profile.dart';
import 'package:wefaq/profileuser.dart';
import 'RJRprojects.dart';
import 'package:wefaq/backgroundHome.dart';
import 'package:flutter/material.dart';
import 'package:wefaq/myProjects.dart';
import 'package:wefaq/userLogin.dart';
import 'package:wefaq/TabScreen.dart';
import 'package:wefaq/bottom_bar_custom.dart';
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'ProjectsTapScreen.dart';

class adminHomeScreen extends StatefulWidget {
  @override
  HomeScreenState createState() => HomeScreenState();
}

Future<void> _signOut() async {
  await FirebaseAuth.instance.signOut();
}

//,,,
class HomeScreenState extends State<adminHomeScreen> {
  final auth = FirebaseAuth.instance;
  late User signedInUser;
  @override
  void initState() {
    getCurrentUser();
    getProjectTitle();
    getProjectTitleOwner();
    super.initState();
  }

  static List<String> ProjectTitleList = [];
  String? Email;
  final _firestore = FirebaseFirestore.instance;
  var name = '${FirebaseAuth.instance.currentUser!.displayName}'.split(' ');
  get FName => name.first;
  void getCurrentUser() {
    try {
      final user = auth.currentUser;
      if (user != null) {
        signedInUser = user;
        Email = signedInUser.email;
        print(signedInUser.email);
      }
    } catch (e) {
      print(e);
    }
  }

  Future getProjectTitleOwner() async {
    if (Email != null) {
      var fillterd = _firestore
          .collection('AllJoinRequests')
          .where('owner_email', isEqualTo: Email)
          .snapshots();
      await for (var snapshot in fillterd)
        for (var Request in snapshot.docs) {
          setState(() {
            if (!ProjectTitleList.contains(Request['project_title'].toString()))
              ProjectTitleList.add(Request['project_title'].toString());
          });
        }
    }
  }

  Future getProjectTitle() async {
    if (Email != null) {
      var fillterd = _firestore
          .collection('AllJoinRequests')
          .where('participant_email', isEqualTo: Email)
          .where('Status', isEqualTo: 'Accepted')
          .snapshots();
      await for (var snapshot in fillterd)
        for (var Request in snapshot.docs) {
          setState(() {
            if (!ProjectTitleList.contains(Request['project_title'].toString()))
              ProjectTitleList.add(Request['project_title'].toString());
          });
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // bottomNavigationBar: CustomNavigationBar(
        //   currentHomeScreen: 0,
        //   updatePage: () {},
        // ),
        body: Stack(
      children: <Widget>[
        SizedBox(
          height: 33,
        ),
        Container(
          margin: EdgeInsets.only(left: 310, top: 40),
          child: IconButton(
              icon: Icon(
                Icons.logout,
                size: 30,
                color: Color.fromARGB(255, 0, 0, 0),
              ),
              onPressed: () {
                showDialogFunc(context);
              }),
        ),
        SizedBox(
          height: 130,
        ),
        Container(
          margin: EdgeInsets.only(left: 10, top: 125),
          alignment: Alignment.topCenter,
          child: Text("Hello!",
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color.fromARGB(255, 0, 0, 0),
                  fontSize: 32),
              textAlign: TextAlign.left),
        ),
        SizedBox(
          height: 200,
        ),
        Padding(
          padding: EdgeInsets.only(top: 290),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 2,
                      childAspectRatio: .85,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                      children: <Widget>[
                        CategoryCard(
                            title: "Upcoming Projects",
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          adminProjectsListViewPage()));
                            }),
                        CategoryCard(
                            title: "Upcoming Events",
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => EventsTabs()));
                            }),
                        CategoryCard(
                            title: "Reported Events",
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          ReportedEventsList()));
                            }),
                        CategoryCard(
                            title: "Reported Accounts",
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ReportedAccList()));
                            }),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
      ],
    ));
  }
}

class CategoryCard extends StatelessWidget {
  final String title;
  final Function() onTap;

  const CategoryCard({
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(13),
        child: Container(
          color: Color.fromARGB(255, 129, 154, 160),
          height: 90,
          width: 150,
          alignment: Alignment.center,
          child: TextButton(
            onPressed: onTap,
            child: Text("$title",
                style: TextStyle(
                    fontSize: 15,
                    color: Color.fromARGB(221, 26, 26, 26),
                    fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }
}

showDialogFunc(context) {
  return showDialog(
      context: context,
      builder: (context) {
        return Center(
            child: Material(
                type: MaterialType.transparency,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: const Color.fromARGB(255, 255, 255, 255),
                  ),
                  padding: const EdgeInsets.all(15),
                  height: 150,
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      // Code for acceptance role
                      Row(children: <Widget>[
                        Expanded(
                          flex: 2,
                          child: GestureDetector(
                            child: Text(
                              " Are you sure you want to log out? ",
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color.fromARGB(159, 64, 7, 87),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onTap: () {
                              // go to participant's profile
                            },
                          ),
                        ),
                        // const SizedBox(
                        //   height: 10,
                        // ),
                      ]),
                      SizedBox(
                        height: 35,
                      ),
                      //----------------------------------------------------------------------------
                      Row(
                        children: <Widget>[
                          Text("   "),
                          Text("     "),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              surfaceTintColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(80.0)),
                              padding: const EdgeInsets.all(0),
                            ),
                            child: Container(
                              alignment: Alignment.center,
                              height: 40.0,
                              width: 100,
                              decoration: new BoxDecoration(
                                  borderRadius: BorderRadius.circular(9.0),
                                  gradient: new LinearGradient(colors: [
                                    Color.fromARGB(144, 176, 175, 175),
                                    Color.fromARGB(144, 176, 175, 175),
                                  ])),
                              padding: const EdgeInsets.all(0),
                              child: Text(
                                "Cancel",
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Color.fromARGB(255, 255, 255, 255)),
                              ),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(left: 40),
                            child: ElevatedButton(
                              onPressed: () {
                                _signOut();
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => UserLogin()));
                                // CoolAlert.show(
                                //   context: context,
                                //   title: "Success!",
                                //   confirmBtnColor:
                                //       Color.fromARGB(144, 64, 6, 87),
                                //   type: CoolAlertType.success,
                                //   backgroundColor:
                                //       Color.fromARGB(221, 212, 189, 227),
                                //   text: "You have logged out successfully",
                                //   confirmBtnText: 'Done',
                                //   onConfirmBtnTap: () {
                                //     //send join requist
                                //     _signOut();
                                //     Navigator.push(
                                //         context,
                                //         MaterialPageRoute(
                                //             builder: (context) => UserLogin()));
                                //   },
                                // );
                              },
                              style: ElevatedButton.styleFrom(
                                surfaceTintColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(80.0)),
                                padding: const EdgeInsets.all(0),
                              ),
                              child: Container(
                                alignment: Alignment.center,
                                height: 40.0,
                                width: 100,
                                decoration: new BoxDecoration(
                                    borderRadius: BorderRadius.circular(9.0),
                                    gradient: new LinearGradient(colors: [
                                      Color.fromARGB(144, 210, 2, 2),
                                      Color.fromARGB(144, 210, 2, 2)
                                    ])),
                                padding: const EdgeInsets.all(0),
                                child: Text(
                                  "Log out",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color:
                                          Color.fromARGB(255, 255, 255, 255)),
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                )));
      });
}