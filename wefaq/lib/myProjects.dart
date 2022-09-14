import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:wefaq/UserLogin.dart';
import 'package:wefaq/background.dart';
import 'bottom_bar_custom.dart';
import 'package:wefaq/models/user.dart';

class myProjects extends StatefulWidget {
  @override
  _myProjectState createState() => _myProjectState();
}

class _myProjectState extends State<myProjects> {
  final auth = FirebaseAuth.instance;
  late User signedInUser;
  final _firestore = FirebaseFirestore.instance;

  // Title list
  var nameList = [];

  // Description list
  var descList = [];

  // location list
  var locList = [];

  //Looking for list
  var lookingForList = [];

  //category list
  var categoryList = [];

  String? Email;
  @override
  void initState() {
    getCurrentUser();

    getProjects();
    super.initState();
  }

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
    if (Email != null) {
      var fillterd = _firestore
          .collection('projects')
          .where('email', isEqualTo: Email)
          .orderBy('created', descending: true)
          .snapshots();
      await for (var snapshot in fillterd)
        for (var project in snapshot.docs) {
          setState(() {
            nameList.add(project['name']);
            descList.add(project['description']);
            locList.add(project['location']);
            lookingForList.add(project['lookingFor']);
            categoryList.add(project['category']);
          });
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Color.fromARGB(255, 182, 168, 203),
        title: Text('My projects',
            style: TextStyle(
              fontWeight: FontWeight.normal,
              color: Colors.white,
            )),
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
      ),
      bottomNavigationBar: CustomNavigationBar(
        currentHomeScreen: 1,
        updatePage: () {},
      ),
      body: Scrollbar(
        thumbVisibility: true,
        child: ListView.builder(
          itemCount: nameList.length,
          itemBuilder: (context, index) {
            // Card Which Holds Layout Of ListView Item
            return SizedBox(
              height: 180,
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
                        height: 20,
                      ),
                      Row(children: <Widget>[
                        Text(
                          "      " + nameList[index] + " ",
                          style: const TextStyle(
                            fontSize: 20,
                            color: Color.fromARGB(159, 64, 7, 87),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ]),
                      Divider(
                        color: Color.fromARGB(230, 64, 7, 87),
                        indent: 20,
                        endIndent: 20,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: <Widget>[
                          const Text("     "),
                          const Icon(Icons.location_pin,
                              color: Color.fromARGB(173, 64, 7, 87)),
                          Text(locList[index],
                              style: const TextStyle(
                                fontSize: 16,
                                color: Color.fromARGB(221, 81, 122, 140),
                              ))
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          const Text("     "),
                          const Icon(
                            Icons.search,
                            color: Color.fromARGB(248, 170, 167, 8),
                            size: 28,
                          ),
                          Text(lookingForList[index],
                              style: const TextStyle(
                                  fontSize: 16,
                                  color: Color.fromARGB(221, 79, 128, 151),
                                  fontWeight: FontWeight.normal),
                              maxLines: 2,
                              overflow: TextOverflow.clip),
                        ],
                      ),
                      Expanded(
                          child: //Text("                              "),
                              /*const Icon(
                                    Icons.arrow_downward,
                                    color: Color.fromARGB(255, 58, 44, 130),
                                    size: 28,
                                  ),*/
                              TextButton(
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            'View More',
                            style: TextStyle(
                              color: Color.fromARGB(255, 90, 46, 144),
                            ),
                          ),
                        ),
                        onPressed: () {
                          showDialogFunc(
                              context,
                              nameList[index],
                              descList[index],
                              categoryList[index],
                              locList[index],
                              lookingForList[index]);
                        },
                      ))
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ), // sc
    );
  }
}

// This is a block of Model Dialog
showDialogFunc(context, title, desc, category, loc, lookingFor) {
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
            height: 400,
            width: MediaQuery.of(context).size.width * 0.9,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Color.fromARGB(230, 64, 7, 87),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                const Divider(
                  color: Color.fromARGB(255, 74, 74, 74),
                ),
                Row(
                  children: <Widget>[
                    const Icon(Icons.location_pin,
                        color: Color.fromARGB(173, 64, 7, 87)),
                    Text(loc,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color.fromARGB(230, 64, 7, 87),
                        ))
                  ],
                ),
                const SizedBox(
                  height: 5,
                ),
                const Divider(
                  color: Color.fromARGB(255, 102, 102, 102),
                ),
                Row(
                  children: <Widget>[
                    const Icon(
                      Icons.search,
                      color: Color.fromARGB(248, 170, 167, 8),
                      size: 25,
                    ),
                    Text(lookingFor,
                        style: const TextStyle(
                            fontSize: 16,
                            color: Color.fromARGB(230, 64, 7, 87),
                            fontWeight: FontWeight.normal),
                        maxLines: 2,
                        overflow: TextOverflow.clip),
                  ],
                ),
                const SizedBox(
                  height: 5,
                ),
                const Divider(
                  color: Color.fromARGB(255, 102, 102, 102),
                ),
                Container(
                  // width: 200,
                  child: const Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      "About Project ",
                      style: TextStyle(
                        fontSize: 16,
                        color: Color.fromARGB(230, 64, 7, 87),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Container(
                  // width: 200,
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      desc,
                      maxLines: 3,
                      style: const TextStyle(
                          fontSize: 16, color: Color.fromARGB(144, 64, 7, 87)),
                      textAlign: TextAlign.left,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                const Divider(
                  color: Color.fromARGB(255, 102, 102, 102),
                ),
                Container(
                  // width: 200,
                  child: const Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      "Category",
                      style: TextStyle(
                        fontSize: 16,
                        color: Color.fromARGB(230, 64, 7, 87),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Container(
                  // width: 200,
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      category,
                      style: const TextStyle(
                          fontSize: 16, color: Color.fromARGB(144, 64, 7, 87)),
                      textAlign: TextAlign.left,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
