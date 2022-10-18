import 'dart:io';
import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/route_manager.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:line_icons/line_icons.dart';
import 'package:multiselect/multiselect.dart';
import 'package:wefaq/profile.dart';
import 'package:wefaq/profileuser.dart';
import 'package:flutter/material.dart';
import 'package:wefaq/UserLogin.dart';
import 'package:wefaq/background.dart';
import 'package:wefaq/editProfile.dart';
import 'package:wefaq/select_photo_options_screen.dart';
import 'bottom_bar_custom.dart';
import 'package:wefaq/myProjects.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wefaq/eventsTabs.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wefaq/userProjects.dart';
import 'select_photo_options_screen.dart';

class editprofile extends StatefulWidget {
  const editprofile({super.key});
  static const id = 'set_photo_screen';

  @override
  State<editprofile> createState() => _editprofileState();
}

class _editprofileState extends State<editprofile> {
  final _firestore = FirebaseFirestore.instance;
  final TextEditingController _aboutEditingController = TextEditingController();
  final TextEditingController _gitHubEditingController =
      TextEditingController();
  final TextEditingController _experienceEditingController =
      TextEditingController();
  final TextEditingController _certificationsEditingController =
      TextEditingController();
  final TextEditingController _nameEditingController = TextEditingController();
  final TextEditingController _roleEditingController = TextEditingController();
  List<String> options = [];
  List<String> selectedOptionList = [];
  var selectedOption;
  /*late File image;
  final imagepicker = ImagePicker();
  uploadImage() async {
    var pickedimage = await imagepicker.getImage(source: ImageSource.gallery);
    if(pickedimage != null){ image =File(pickedimage.path);}
    else
   ;
  }*/

  File? _image;
  final auth = FirebaseAuth.instance;
  late User signedInUser;
  String userEmail = "";
  String fname = "";
  String lname = "";
  String about = "";
  String experince = "";
  String cerifi = "";
  String skills = "";
  String role = "";
  String gitHub = "";

  @override
  void initState() {
    getCurrentUser();
    getCategoryList();
    getUser();

    super.initState();
  }

  Future _pickImage(ImageSource source) async {
    try {
      final image = await ImagePicker().pickImage(source: source);
      if (image == null) return;
      File? img = File(image.path);
      img = await _cropImage(imageFile: img);
      setState(() {
        _image = img;
        Navigator.of(context).pop();
      });
    } on PlatformException catch (e) {
      print(e);
      Navigator.of(context).pop();
    }
  }

  Future<File?> _cropImage({required File imageFile}) async {
    CroppedFile? croppedImage =
        await ImageCropper().cropImage(sourcePath: imageFile.path);
    if (croppedImage == null) return null;
    return File(croppedImage.path);
  }

  void _showSelectPhotoOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25.0),
        ),
      ),
      builder: (context) => DraggableScrollableSheet(
          initialChildSize: 0.28,
          maxChildSize: 0.4,
          minChildSize: 0.28,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: SelectPhotoOptionsScreen(
                onTap: _pickImage,
              ),
            );
          }),
    );
  }

  void getCurrentUser() {
    try {
      final user = auth.currentUser;
      if (user != null) {
        signedInUser = user;
        userEmail = signedInUser.email.toString();
      }
    } catch (e) {
      print(e);
    }
  }

  void getCategoryList() async {
    final categoriesE = await _firestore.collection('skills').get();
    for (var category in categoriesE.docs) {
      for (var element in category['skills']) {
        setState(() {
          options.add(element);
        });
      }
    }
  }

  Future getUser() async {
    var fillterd = _firestore
        .collection('users')
        .where("Email", isEqualTo: userEmail)
        .snapshots();
    await for (var snapshot in fillterd)
      for (var user in snapshot.docs) {
        setState(() {
          fname = user["FirstName"].toString();
          lname = user["LastName"].toString();
          about = user["about"].toString();
          experince = user["experince"].toString();
          cerifi = user["cerifi"].toString();
          role = user["role"].toString();
          gitHub = user["gitHub"].toString();
          _aboutEditingController.text = user["about"].toString();
          _gitHubEditingController.text = user["gitHub"].toString();
          _certificationsEditingController.text = user["cerifi"].toString();
          _nameEditingController.text =
              user["FirstName"].toString() + " " + user["LastName"].toString();
          _roleEditingController.text = user["role"].toString();
          _experienceEditingController.text = user["experince"].toString();
          for (var skill in user["skills"])
            selectedOptionList.add(skill.toString());
        });
      }
  }

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 238, 237, 240),
      appBar: AppBar(
        title: Text('Edit Profile', style: TextStyle(color: Colors.white)),
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
      body: SingleChildScrollView(
        child: Stack(
          //key: _formKey,
          children: <Widget>[
            SizedBox(
              height: 220,
              width: double.infinity,
              child: Image(
                image: AssetImage(
                  "assets/images/header.jpg",
                ),
                fit: BoxFit.cover,
              ),
            ),
            Form(
              key: _formKey,
              child: Container(
                margin: EdgeInsets.fromLTRB(15, 200, 15, 15),
                child: Column(
                  children: <Widget>[
                    Stack(
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.all(15),
                          margin: EdgeInsets.only(top: 0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                margin: EdgeInsets.only(left: 95),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    TextFormField(
                                      decoration: const InputDecoration(
                                        border: UnderlineInputBorder(),
                                        //  labelText: 'About',
                                      ),
                                      controller: _nameEditingController,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        /*Container(
                          width: 80,
                          height: 80,
                          margin: EdgeInsets.only(left: 15, top: 10),
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                offset: Offset(0, 0),
                                blurRadius: 10,
                                color: Colors.black.withOpacity(0.15),
                              ),
                            ],
                            borderRadius: BorderRadius.circular(10),
                            image: DecorationImage(
                              image: AssetImage(
                                "/Users/layanalwadie/Desktop/Wefaq/wefaq/assets/images/layanP.jpg",
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),*/
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Center(
                            child: GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onTap: () {
                                //   _showSelectPhotoOptions(context);
                              },
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                          height: 50,
                                          width: 50,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.grey.shade200,
                                          ),
                                          child: Center(
                                            child: _image == null
                                                ? Image.asset(
                                                    "assets/images/layanP.jpg",
                                                  )
                                                : CircleAvatar(
                                                    backgroundImage:
                                                        FileImage(_image!),
                                                    radius: 100.0,
                                                  ),
                                          )),
                                      IconButton(
                                        iconSize: 20,
                                        icon: Icon(
                                          Icons.camera_alt,
                                          color: Color.fromARGB(
                                              255, 141, 136, 146),
                                        ),
                                        onPressed: () {
                                          _showSelectPhotoOptions(context);
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Column(
                        children: <Widget>[
                          ListTile(
                            title: Text("General Information"),
                          ),
                          Divider(),
                          ListTile(
                            title: Text("About"),
                            subtitle: TextFormField(
                                decoration: const InputDecoration(
                                  border: UnderlineInputBorder(),
                                  //  labelText: 'About',
                                ),
                                controller: _aboutEditingController,
                                validator: (value) {
                                  if (value == null ||
                                      value.isEmpty ||
                                      value.trim() == '') {
                                    return 'required';
                                  }
                                  return null;
                                }),
                            leading: Icon(Icons.format_align_center),
                          ),
                          ListTile(
                            title: Text("Role"),
                            subtitle: TextFormField(
                                decoration: const InputDecoration(
                                  border: UnderlineInputBorder(),
                                  //  labelText: 'About',
                                ),
                                controller: _roleEditingController,
                                validator: (value) {
                                  if (value == null ||
                                      value.isEmpty ||
                                      value.trim() == '') {
                                    return 'required';
                                  }
                                }),
                            leading: Icon(Icons.person),
                          ),
                          Divider(
                            color: Color.fromARGB(115, 176, 176, 176),
                          ),
                          Divider(
                            color: Color.fromARGB(115, 176, 176, 176),
                          ),
                          ListTile(
                            title: Text("GitHub"),
                            subtitle: TextFormField(
                                decoration: const InputDecoration(
                                  border: UnderlineInputBorder(),
                                  //  labelText: 'About',
                                ),
                                controller: _gitHubEditingController,
                                validator: (value) {
                                  if (value == null ||
                                      value.isEmpty ||
                                      value.trim() == '') {
                                    return 'required';
                                  }
                                }),
                            leading: Icon(
                              LineIcons.github,
                              size: 35,
                              color: Color.fromARGB(255, 93, 18, 107),
                            ),
                          ),
                          Divider(
                            color: Color.fromARGB(115, 176, 176, 176),
                          ),
                          ListTile(
                            title: Text("Experience"),
                            subtitle: TextFormField(
                                decoration: const InputDecoration(
                                  border: UnderlineInputBorder(),
                                  //  labelText: 'About',
                                ),
                                controller: _experienceEditingController,
                                validator: (value) {
                                  if (value == null ||
                                      value.isEmpty ||
                                      value.trim() == '') {
                                    return 'required';
                                  }
                                }),
                            leading: Icon(Icons.calendar_view_day),
                          ),
                          Divider(
                            color: Color.fromARGB(115, 176, 176, 176),
                          ),
                          ListTile(
                            title: Text("Skills"),
                            subtitle: Column(
                              children: [
                                DropDownMultiSelect(
                                    options: options,
                                    whenEmpty: 'Select your skills',
                                    onChanged: (value) {
                                      selectedOptionList = value;
                                      selectedOption = "";
                                      selectedOptionList.forEach((element) {
                                        selectedOption =
                                            selectedOption + " " + element;
                                      });
                                    },
                                    selectedValues: selectedOptionList),
                              ],
                            ),
                            leading: Icon(Icons.schema_rounded),
                          ),
                          Divider(
                            color: Color.fromARGB(115, 176, 176, 176),
                          ),
                          ListTile(
                            title: Text("Licenses & certifications"),
                            subtitle: TextFormField(
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                decoration: const InputDecoration(
                                  border: UnderlineInputBorder(),
                                  //  labelText: 'About',
                                ),
                                controller: _certificationsEditingController,
                                validator: (value) {
                                  if (value == null ||
                                      value.isEmpty ||
                                      value.trim() == ' ' ||
                                      value == ' ') {
                                    return 'space dose not allowed ';
                                  }
                                }),
                            leading: Icon(
                              Icons.workspace_premium,
                              size: 33,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                      width: 80,
                    ),
                    Row(children: <Widget>[
                      Expanded(
                          child: Column(children: <Widget>[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Stack(
                            children: <Widget>[
                              Positioned.fill(
                                child: Container(
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: <Color>[
                                        Color.fromARGB(255, 89, 13, 161),
                                        Color.fromARGB(255, 101, 42, 155),
                                        Color.fromARGB(255, 117, 85, 148),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              TextButton(
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.only(
                                      top: 15.0,
                                      left: 40,
                                      right: 40,
                                      bottom: 15),
                                  textStyle: const TextStyle(fontSize: 20),
                                ),
                                onPressed: () async {
                                  if (_formKey.currentState!.validate()) {
                                    // If the form is valid, display a snackbar. In the real world,
                                    // you'd often call a server or save the information in a database.
                                    // for sorting purpose

                                    _firestore
                                        .collection('users')
                                        .doc(signedInUser.email)
                                        .set({
                                      "about": _aboutEditingController.text,
                                      "experince":
                                          _experienceEditingController.text,
                                      "cerifi":
                                          _certificationsEditingController.text,
                                      "skills": selectedOptionList,
                                      "role": _roleEditingController.text,
                                      "gitHub": _gitHubEditingController.text,
                                    }, SetOptions(merge: true));

                                    //sucess message
                                    CoolAlert.show(
                                      context: context,
                                      title: "Success!",
                                      confirmBtnColor:
                                          Color.fromARGB(144, 64, 7, 87),
                                      onConfirmBtnTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    viewprofile(
                                                      userEmail: userEmail,
                                                    )));
                                      },
                                      type: CoolAlertType.success,
                                      backgroundColor:
                                          Color.fromARGB(221, 212, 189, 227),
                                      text: "Profile edited successfuly",
                                    );
                                  }
                                },
                                child: const Text('Save'),
                              ),
                            ],
                          ),
                        ),
                      ])),
                      Expanded(
                        child: Column(
                          children: <Widget>[
                            ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Stack(
                                children: <Widget>[
                                  Positioned.fill(
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: <Color>[
                                            Color.fromARGB(255, 152, 152, 152),
                                            Color.fromARGB(255, 186, 180, 191),
                                            Color.fromARGB(255, 152, 152, 152),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.only(
                                          top: 15.0,
                                          left: 40,
                                          right: 40,
                                          bottom: 15),
                                      textStyle: const TextStyle(fontSize: 20),
                                    ),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => viewprofile(
                                                  userEmail: userEmail,
                                                )),
                                      );
                                    },
                                    child: const Text('Cancel'),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ]),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
