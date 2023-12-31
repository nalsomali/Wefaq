import 'dart:math';
import 'package:cool_alert/cool_alert.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:wefaq/AdminEventDetails.dart';
import 'package:wefaq/AdminHomePage.dart';
import 'package:wefaq/AdminNavBar.dart';
import 'package:wefaq/UserLogin.dart';
import 'package:url_launcher/link.dart';

// Main Stateful Widget Start
class adminEventsListViewPage extends StatefulWidget {
  @override
  _ListViewPageState createState() => _ListViewPageState();
}

class _ListViewPageState extends State<adminEventsListViewPage> {
  @override
  void initState() {
    getProjects();
    getCategoryList();
    _getCurrentPosition();

    super.initState();
  }

  final _firestore = FirebaseFirestore.instance;
  var categoryListDisplay = [];
  var categoryListController = [];
  // Title list
  var nameList = [];

  // Description list
  var descList = [];

  // location list
  var locList = [];

  //url list
  var urlList = [];

  //category list
  var categoryList = [];

  //category list
  var dateTimeList = [];

  List<String> ownerEmail = [];

  var TimeList = [];
  var latList = [];

  var lngList = [];
  List<int> countlist = [];

  List<String> creatDate = [];
  Position? _currentPosition;
  var lat;
  var lng;

  void getCategoryList() async {
    final categories = await _firestore.collection('categoriesE').get();
    for (var category in categories.docs) {
      for (var element in category['catE']) {
        setState(() {
          categoryListDisplay.add(element);
        });
      }
    }
  }

//get all projects
  Future getProjectsHi() async {
    //clear first
    setState(() {
      nameList = [];
      descList = [];
      locList = [];
      urlList = [];
      categoryList = [];
      dateTimeList = [];
      TimeList = [];
      latList = [];
      lngList = [];
      creatDate = [];
      ownerEmail = [];
      countlist = [];
    });
    await for (var snapshot in _firestore
        .collection('AllEvent')
        .orderBy('count', descending: true)
        .snapshots())
      for (var events in snapshot.docs) {
        setState(() {
          nameList.add(events['name']);
          descList.add(events['description']);
          locList.add(events['location']);
          urlList.add(events['regstretion url ']);
          categoryList.add(events['category']);
          dateTimeList.add(events['date']);
          TimeList.add(events['time']);
          latList.add(events['lat']);
          lngList.add(events['lng']);
          creatDate.add(events['cdate']);
          ownerEmail.add(events['email']);
          countlist.add(events['count']);
        });
      }
  }

  Future getProjects() async {
    //clear first
    setState(() {
      nameList = [];
      descList = [];
      locList = [];
      urlList = [];
      categoryList = [];
      dateTimeList = [];
      TimeList = [];
      latList = [];
      lngList = [];
      creatDate = [];
      ownerEmail = [];
      countlist = [];
    });
    await for (var snapshot in _firestore
        .collection('AllEvent')
        .orderBy('created', descending: true)
        .snapshots())
      for (var events in snapshot.docs) {
        setState(() {
          nameList.add(events['name']);
          descList.add(events['description']);
          locList.add(events['location']);
          urlList.add(events['regstretion url ']);
          categoryList.add(events['category']);
          dateTimeList.add(events['date']);
          TimeList.add(events['time']);
          latList.add(events['lat']);
          lngList.add(events['lng']);
          creatDate.add(events['cdate']);
          ownerEmail.add(events['email']);
          countlist.add(events['count']);

          //  dateTimeList.add(project['dateTime ']);
        });
      }
  }

  //get all projects
  Future getEventsLoc() async {
    //clear first
    setState(() {
      nameList = [];
      descList = [];
      locList = [];
      urlList = [];
      categoryList = [];
      dateTimeList = [];
      TimeList = [];
      latList = [];
      lngList = [];
      creatDate = [];
      countlist = [];
    });

    await for (var snapshot in _firestore
        .collection('AllEvent')
        .orderBy('dis', descending: false)
        .snapshots())
      for (var events in snapshot.docs) {
        setState(() {
          nameList.add(events['name']);
          descList.add(events['description']);
          locList.add(events['location']);
          urlList.add(events['regstretion url ']);
          categoryList.add(events['category']);
          dateTimeList.add(events['date']);
          TimeList.add(events['time']);
          latList.add(events['lat']);
          lngList.add(events['lng']);
          creatDate.add(events['cdate']);
          countlist.add(events['count']);
        });
      }
  }

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location services are disabled. Please enable the services')));
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')));
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location permissions are permanently denied, we cannot request permissions.')));
      return false;
    }
    return true;
  } //permission

  Future<void> _getCurrentPosition() async {
    final hasPermission = await _handleLocationPermission();

    if (!hasPermission) return;
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) {
      setState(() => _currentPosition = position);
    }).catchError((e) {
      debugPrint(e);
    });
    setState(() {
      lat = _currentPosition?.latitude;
      lng = _currentPosition?.longitude;
    });
  }

  double calculateDistance(lat1, lon1, lat2, lon2) {
    var radiansPerDegree = 0.017453292519943295;
    var distanceTerm = 0.5 -
        cos((lat2 - lat1) * radiansPerDegree) / 2 +
        cos(lat1 * radiansPerDegree) *
            cos(lat2 * radiansPerDegree) *
            (1 - cos((lon2 - lon1) * radiansPerDegree)) /
            2;
    return 12742 * asin(sqrt(distanceTerm));
  }

  setDistance() {
    for (var i = 0; i < latList.length; i++) {
      setState(() {
        FirebaseFirestore.instance
            .collection('AllEvent')
            .doc(nameList[i].toString())
            .set({'dis': calculateDistance(latList[i], lngList[i], lat, lng)},
                SetOptions(merge: true));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // MediaQuery to get Device Width
    double width = MediaQuery.of(context).size.width * 0.6;
    return Scaffold(
      bottomNavigationBar: AdminCustomNavigationBar(
        currentHomeScreen: 0,
        updatePage: () {},
      ),
      appBar: AppBar(
        leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: Color.fromARGB(255, 255, 255, 255),
            ),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => adminHomeScreen()));
            }),
        backgroundColor: Color.fromARGB(255, 145, 124, 178),
        actions: <Widget>[
          IconButton(
              icon: Icon(
                Icons.logout,
                color: Color.fromARGB(255, 255, 255, 255),
              ),
              onPressed: () {
                showDialogFunc2(context);
              }),
        ],
        title: Text('Upcoming Events',
            style: TextStyle(
              fontWeight: FontWeight.normal,
              color: Colors.white,
            )),
      ),

      floatingActionButton: PopupMenuButton(
        tooltip: "Filter by",
        icon: CircleAvatar(
          radius: 27,
          backgroundColor: Color.fromARGB(255, 97, 144, 164),
          child: Icon(
            Icons.filter_list,
            color: Color.fromARGB(255, 255, 255, 255),
            size: 40,
          ),
        ),
        itemBuilder: (BuildContext context) => <PopupMenuEntry>[
          PopupMenuItem(
            child: ListTile(
              leading:
                  Icon(Icons.date_range, color: Color.fromARGB(144, 64, 7, 87)),
              title: Text(
                'Latest',
                style: TextStyle(
                  color: Color.fromARGB(221, 81, 122, 140),
                ),
              ),
              onTap: () {
                setState(() {
                  //Filter by created date
                  getProjects();
                });
              },
              selectedTileColor: Color.fromARGB(255, 252, 243, 243),
            ),
          ),
          PopupMenuItem(
            child: ListTile(
              leading:
                  Icon(Icons.date_range, color: Color.fromARGB(144, 64, 7, 87)),
              title: Text(
                'Highest reports',
                style: TextStyle(
                  color: Color.fromARGB(221, 81, 122, 140),
                ),
              ),
              onTap: () {
                setState(() {
                  //Filter by created date
                  getProjectsHi();
                });
              },
              selectedTileColor: Color.fromARGB(255, 252, 243, 243),
            ),
          ),
        ],
      ),

      // Main List View With Builder
      body: Column(
        children: [
          Expanded(
            child: Scaffold(
              body: Scrollbar(
                thumbVisibility: true,
                child: ListView.builder(
                  itemBuilder: (context, index) {
                    // Card Which Holds Layout Of ListView Item
                    int count = countlist[index];
                    return SizedBox(
                      height: 100,
                      child: GestureDetector(
                          child: Card(
                            color: const Color.fromARGB(255, 255, 255, 255),
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
                                            color: Color.fromARGB(
                                                212, 82, 10, 111),
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        Expanded(
                                          child: SizedBox(
                                            width: 240,
                                          ),
                                        ),
                                        Text(
                                          creatDate[index],
                                          style: const TextStyle(
                                            fontSize: 16,
                                            color: Color.fromARGB(
                                                255, 170, 169, 179),
                                            fontWeight: FontWeight.normal,
                                          ),
                                        ),
                                      ]),
                                    ],
                                  ),
                                  Expanded(
                                    child: Row(
                                      children: <Widget>[
                                        const Text("     "),
                                        const Icon(Icons.location_pin,
                                            color:
                                                Color.fromARGB(173, 64, 7, 87)),
                                        Text(locList[index],
                                            style: const TextStyle(
                                              fontSize: 16,
                                              color: Color.fromARGB(
                                                  255, 34, 94, 120),
                                            )),
                                        Expanded(
                                            child: SizedBox(
                                          width: 100,
                                        )),
                                        const Icon(Icons.report_gmailerrorred,
                                            color: Color.fromARGB(
                                                238, 212, 18, 4)),
                                        Text("$count",
                                            style: const TextStyle(
                                              fontSize: 16,
                                              color: Color.fromARGB(
                                                  255, 34, 94, 120),
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
                                                          AdmineventDetailScreen(
                                                            eventName:
                                                                nameList[index],
                                                          )));
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
                                    builder: (context) =>
                                        AdmineventDetailScreen(
                                          eventName: nameList[index],
                                        )));
                          }),
                    );
                  },
                  itemCount: nameList.length,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// This is a block of Model Dialog
showDialogFunc(context, title, desc, category, loc, date, time, urlregstrtion) {
  return showDialog(
    context: context,
    builder: (context) {
      return Center(
        child: Material(
          type: MaterialType.transparency,
          child: Scrollbar(
            thumbVisibility: true,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Color.fromARGB(255, 255, 255, 255),
              ),
              padding: EdgeInsets.all(15),
              height: 500,
              width: MediaQuery.of(context).size.width * 0.9,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      color: Color.fromARGB(230, 64, 7, 87),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Divider(
                    color: Color.fromARGB(255, 74, 74, 74),
                  ),
                  Row(
                    children: <Widget>[
                      const Icon(Icons.location_pin,
                          color: Color.fromARGB(173, 64, 7, 87)),
                      Text(loc,
                          style: TextStyle(
                            fontSize: 16,
                            color: Color.fromARGB(230, 64, 7, 87),
                          ))
                    ],
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Divider(
                    color: Color.fromARGB(255, 102, 102, 102),
                  ),
                  Row(
                    children: <Widget>[
                      const Icon(
                        Icons.timelapse_outlined,
                        color: Color.fromARGB(248, 170, 167, 8),
                        size: 28,
                      ),
                      Text(date,
                          style: TextStyle(
                              fontSize: 16,
                              color: Color.fromARGB(221, 79, 128, 151),
                              fontWeight: FontWeight.normal),
                          maxLines: 2,
                          overflow: TextOverflow.clip),
                    ],
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Divider(
                    color: Color.fromARGB(255, 102, 102, 102),
                  ),
                  Container(
                    // width: 200,
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        "About Event ",
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
                        style: TextStyle(
                            fontSize: 14,
                            color: Color.fromARGB(144, 64, 7, 87)),
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Divider(
                    color: Color.fromARGB(255, 102, 102, 102),
                  ),
                  Container(
                    // width: 200,
                    child: Align(
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
                        maxLines: 3,
                        style: TextStyle(
                            fontSize: 16,
                            color: Color.fromARGB(144, 64, 7, 87)),
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ),
                  Center(
                    child: Link(
                        target: LinkTarget.blank,
                        uri: Uri.parse(urlregstrtion),
                        builder: (context, followLink) => ElevatedButton(
                            onPressed: followLink,
                            child: Text(
                              'Registration link',
                              style: TextStyle(
                                  color: Color.fromARGB(255, 255, 255, 255)),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(195, 117, 45, 141),
                            ))),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}

Future<void> _signOut() async {
  await FirebaseAuth.instance.signOut();
}

showDialogFunc2(context) {
  CoolAlert.show(
    context: context,
    title: "",
    confirmBtnColor: Color.fromARGB(144, 210, 2, 2),
    confirmBtnText: 'log out ',
    onConfirmBtnTap: () {
      _signOut();
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => UserLogin()));
    },
    type: CoolAlertType.confirm,
    backgroundColor: Color.fromARGB(221, 212, 189, 227),
    text: "Are you sure you want to log out?",
  );
}
