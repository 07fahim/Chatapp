// ignore: unused_import
import 'dart:convert';
// ignore: unused_import
import 'dart:developer';

// ignore: unused_import
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
// ignore: unused_import
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
// ignore: unused_import
import 'package:google_sign_in/google_sign_in.dart';
// ignore: unused_import
import 'package:gropie/api/apis.dart';
// ignore: unused_import
import 'package:gropie/helper/dialogs.dart';
import 'package:gropie/helper/my_date_utill.dart';
// ignore: unused_import
import 'package:gropie/main.dart';
// ignore: unused_import
import 'package:gropie/screens/auth/login_Screen.dart';

// ignore: unused_import
import 'package:gropie/widgets/chat_user_card.dart';

// ignore: unused_import
import 'package:image_picker/image_picker.dart';

import '../models/chat_user.dart';

class ViewProfileScreen extends StatefulWidget {
  final ChatUser user;
  const ViewProfileScreen({super.key, required this.user});

  @override
  State<ViewProfileScreen> createState() => _ViewProfileScreenState();
}

class _ViewProfileScreenState extends State<ViewProfileScreen> {
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
              title: Text(widget.user.name,
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
            floatingActionButton: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Joined On :',
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                ),
                Text(
                    MyDateUtill.getLastMessageTime(
                        context: context,
                        time: widget.user.createdAt,
                        showYear: true),
                    style: TextStyle(color: Colors.black54, fontSize: 15)),
              ],
            ),
            body: Padding(
              padding: EdgeInsets.symmetric(horizontal: mq.width * .05),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(
                      width: mq.width,
                      height: mq.height * .03,
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(mq.height * .1),
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
                    SizedBox(height: mq.height * .03),
                    Text(widget.user.email,
                        style: TextStyle(color: Colors.black87, fontSize: 16)),
                    SizedBox(
                      height: mq.height * .02,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'About :',
                          style: TextStyle(
                              fontWeight: FontWeight.w500, fontSize: 15),
                        ),
                        Text(widget.user.about,
                            style:
                                TextStyle(color: Colors.black54, fontSize: 16)),
                      ],
                    ),
                  ],
                ),
              ),
            )),
      ),
    );
  }
}
