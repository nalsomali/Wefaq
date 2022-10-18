import 'dart:convert';
import 'dart:math';
import 'package:cool_alert/cool_alert.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:wefaq/ProjectsTapScreen.dart';
import 'package:wefaq/screens/detail_screens/projectDetail.dart';
import 'package:wefaq/screens/detail_screens/project_detail_screen.dart';
import 'package:wefaq/service/local_push_notification.dart';
import 'package:http/http.dart' as http;

import 'UserLogin.dart';
import 'bottom_bar_custom.dart';

// Main Stateful Widget Start
class userProjects extends StatefulWidget {
  String userEmail;
  userProjects({required this.userEmail});

  ListViewPageState createState() => ListViewPageState(this.userEmail);
}

class ListViewPageState extends State<userProjects> {
  String userEmail;
  ListViewPageState(this.userEmail);

  final TextEditingController _JoiningASController = TextEditingController();
  final TextEditingController _ParticipantNoteController =
      TextEditingController();
  @override
  void initState() {
    getCurrentUser();
    getProjects();

    super.initState();
  }

  final auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  late User signedInUser;

  // Title list
  List<String> nameList = [];

  List<String> joiningAs = [];

  String? Email;
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

  //get all projects
  Future getProjects() async {
    await for (var snapshot in _firestore
        .collection("AllJoinRequests")
        .where("participant_email", isEqualTo: userEmail)
        .where("Status", isEqualTo: "Accepted")
        .snapshots())
      for (var r in snapshot.docs) {
        setState(() {
          nameList.add(r['project_title']);
          joiningAs.add(r["joiningAs"]);
        });
      }
  }

  @override
  Widget build(BuildContext context) {
    // MediaQuery to get Device Width

    return Column(
      children: [
        Expanded(
          child: Scaffold(
            appBar: AppBar(
              title: Text('Projects', style: TextStyle(color: Colors.white)),
              actions: <Widget>[
                IconButton(
                    icon: Icon(
                      Icons.logout,
                      color: Color.fromARGB(255, 255, 255, 255),
                    ),
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => UserLogin()));
                    }),
              ],
              backgroundColor: Color.fromARGB(255, 162, 148, 183),
            ),
            bottomNavigationBar: CustomNavigationBar(
              currentHomeScreen: 0,
              updatePage: () {},
            ),
            // Main List View With Builder
            body: Scrollbar(
              thumbVisibility: true,
              child: ListView.builder(
                //itemCount: tokens.length,

                itemBuilder: (context, index) {
                  // Card Which Holds Layout Of ListView Item

                  return SizedBox(
                    height: 100,
                    child: GestureDetector(
                        child: Card(
                          color: const Color.fromARGB(255, 255, 255, 255),
                          //shadowColor: Color.fromARGB(255, 255, 255, 255),
                          //  elevation: 7,

                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                SizedBox(
                                  height: 10,
                                ),
                                Column(
                                  children: [
                                    Row(children: <Widget>[
                                      Text(
                                        "      " + nameList[index] + " ",
                                        style: const TextStyle(
                                          fontSize: 19,
                                          color:
                                              Color.fromARGB(212, 82, 10, 111),
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      Expanded(
                                        child: SizedBox(
                                          width: 240,
                                        ),
                                      ),
                                    ]),
                                  ],
                                ),
                                Expanded(
                                  child: Row(
                                    children: <Widget>[
                                      const Text("     "),
                                      const Icon(Icons.person,
                                          color:
                                              Color.fromARGB(173, 64, 7, 87)),
                                      Text(joiningAs[index],
                                          style: const TextStyle(
                                            fontSize: 16,
                                            color: Color.fromARGB(
                                                255, 34, 94, 120),
                                          )),
                                      Expanded(
                                          child: SizedBox(
                                        width: 100,
                                      )),
                                      IconButton(
                                          icon: Icon(
                                            Icons.arrow_forward_ios,
                                            color: Color.fromARGB(
                                                255, 170, 169, 179),
                                          ),
                                          onPressed: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        projectDetail(
                                                            projecName:
                                                                nameList[index],
                                                            email: userEmail)));
                                          }),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => projectDetail(
                                      projecName: nameList[index],
                                      email: userEmail)));
                        }),
                  );
                },
                itemCount: nameList.length,
                // itemCount:_textEditingController!.text.isNotEmpty? nameListsearch.length  : nameListsearch.length,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
