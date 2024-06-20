// ignore: unused_import
import 'dart:convert';
// ignore: unused_import
import 'dart:developer';

// ignore: unused_import
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:gropie/api/apis.dart';
import 'package:gropie/helper/dialogs.dart';
// ignore: unused_import
import 'package:gropie/main.dart';
import 'package:gropie/screens/auth/login_Screen.dart';

// ignore: unused_import
import 'package:gropie/widgets/chat_user_card.dart';

// ignore: unused_import
import 'package:image_picker/image_picker.dart';

import '../models/chat_user.dart';

class ProfileScreen extends StatefulWidget {
  final ChatUser user;
  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _image;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.topRight,
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.secondary,
          ],
        ),
      ),
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
            key: _scaffoldKey, // Add this line

            appBar: AppBar(
              title: Text('Profile Screen',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge!
                      .copyWith(fontWeight: FontWeight.bold)),

              centerTitle: true,
              backgroundColor: Theme.of(context).colorScheme.primary,

              elevation: 0,

              // ... Your existing AppBar code ...
              actions: [
                IconButton(
                  onPressed: () {
                    Get.changeThemeMode(
                      Get.isDarkMode ? ThemeMode.light : ThemeMode.dark,
                    );
                    print(Get.isDarkMode);
                  },
                  icon:
                      Icon(Get.isDarkMode ? Icons.dark_mode : Icons.light_mode),
                ),
              ],
            ),
            floatingActionButton: Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: FloatingActionButton.extended(
                backgroundColor: Colors.redAccent,
                onPressed: () async {
                  Dialogs.showProgressBar(context);

                  await APIs.updateActiveStatus(false);
                  await APIs.auth.signOut().then((value) async {
                    await GoogleSignIn().signOut().then((value) {
                      Navigator.pop(context);

                      APIs.auth = FirebaseAuth.instance;

                      Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (_) => LoginScreen()));
                    });
                  });
                },
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
              ),
            ),
            body: Form(
              key: _formKey,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: mq.width * .05),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(
                        width: mq.width,
                        height: mq.height * .03,
                      ),
                      Stack(
                        children: [
                          _image != null
                              ? ClipRRect(
                                  borderRadius:
                                      BorderRadius.circular(mq.height * .1),
                                  child: Image.file(
                                    File(_image!),
                                    width: mq.height * .2,
                                    height: mq.height * .2,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : ClipRRect(
                                  borderRadius:
                                      BorderRadius.circular(mq.height * .1),
                                  child: CachedNetworkImage(
                                    width: mq.height * .2,
                                    height: mq.height * .2,
                                    fit: BoxFit.cover,
                                    imageUrl: widget.user.image,
                                    errorWidget: (context, url, error) =>
                                        const CircleAvatar(
                                      child: Icon(CupertinoIcons.person),
                                    ),
                                  ),
                                ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: MaterialButton(
                              elevation: 1,
                              onPressed: () {
                                _showBottomSheet();
                              },
                              shape: const CircleBorder(),
                              color: Colors.white,
                              child: Icon(
                                Icons.edit,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          )
                        ],
                      ),
                      SizedBox(
                        height: mq.height * .03,
                      ),
                      Text(widget.user.email,
                          style:
                              TextStyle(color: Colors.black54, fontSize: 16)),
                      SizedBox(
                        height: mq.height * .05,
                      ),
                      TextFormField(
                        initialValue: widget.user.name,
                        onSaved: (val) => APIs.me.name = val ?? '',
                        validator: (val) => val != null && val.isNotEmpty
                            ? null
                            : "Required Field",
                        decoration: InputDecoration(
                            prefixIcon: Icon(
                              Icons.person,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12)),
                            hintText: 'eg. Goku',
                            label: Text(
                              'Name',
                              style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                  fontSize: 20),
                            )),
                      ),
                      SizedBox(
                        height: mq.height * .02,
                      ),
                      TextFormField(
                        initialValue: widget.user.about,
                        onSaved: (val) => APIs.me.about = val ?? '',
                        validator: (val) => val != null && val.isNotEmpty
                            ? null
                            : "Required Field",
                        decoration: InputDecoration(
                            prefixIcon: Icon(
                              Icons.info_outline,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12)),
                            hintText: 'eg. Feeling Sad',
                            label: Text(
                              'About',
                              style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                  fontSize: 18),
                            )),
                      ),
                      SizedBox(
                        height: mq.height * .05,
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                            shape: const StadiumBorder(),
                            minimumSize: Size(mq.width * .5, mq.height * .06)),
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            APIs.updateUserInfo().then((value) {
                              Dialogs.showSnackBar(
                                  context, 'Profile Updated Successfully');
                            });
                          }
                        },
                        icon: const Icon(
                          Icons.edit,
                          size: 28,
                        ),
                        label: const Text(
                          "UPDATE",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )),
      ),
    );
  }

  void _showBottomSheet() {
    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        builder: (_) {
          return ListView(
            shrinkWrap: true,
            padding:
                EdgeInsets.only(top: mq.height * .03, bottom: mq.height * .05),
            children: [
              const Text('Pick Profile Picture',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
              SizedBox(height: mq.height * .02),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: const CircleBorder(),
                          fixedSize: Size(mq.width * .2, mq.height * .10)),
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();
// Pick an image.
                        final XFile? image = await picker.pickImage(
                            source: ImageSource.gallery, imageQuality: 80);
                        if (image != null) {
                          log('Image Path : ${image.path} -- MimeType : ${image.mimeType}');
                          setState(() {
                            _image = image.path;
                          });

                          APIs.updateProfilePicture(File(_image!));
                          Navigator.pop(context);
                        }
                      },
                      child: Image.asset('images/gallery.png')),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: const CircleBorder(),
                          fixedSize: Size(mq.width * .2, mq.height * .10)),
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();
// Pick an image.
                        final XFile? image = await picker.pickImage(
                            source: ImageSource.camera, imageQuality: 80);
                        if (image != null) {
                          log('Image Path : ${image.path} ');
                          setState(() {
                            _image = image.path;
                          });
                          APIs.updateProfilePicture(File(_image!));
                          Navigator.pop(context);
                        }
                      },
                      child: Image.asset('images/camera.png'))
                ],
              )
            ],
          );
        });
  }
}
