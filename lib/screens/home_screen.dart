// ignore: unused_import
import 'dart:convert';
// ignore: unused_import
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:gropie/api/apis.dart';
import 'package:gropie/helper/dialogs.dart';
import 'package:gropie/main.dart';

// ignore: unused_import
import 'package:gropie/widgets/chat_user_card.dart';

import '../models/chat_user.dart';
import 'profile_screen .dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<ChatUser> _list = [];
  // ignore: unused_field
  final List<ChatUser> _searchList = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    APIs.getSelfInfo();

    SystemChannels.lifecycle.setMessageHandler((message) {
      log('Message $message');

      if (APIs.auth.currentUser != null) {
        if ((message.toString().contains('resume')))
          APIs.updateActiveStatus(true);
        if ((message.toString().contains('pause')))
          APIs.updateActiveStatus(false);
      }

      return Future.value(message);
    });
  }

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
        child: WillPopScope(
          onWillPop: () {
            if (_isSearching) {
              setState(() {
                _isSearching = !_isSearching;
              });
              return Future.value(false);
            } else {
              return Future.value(true);
            }
          },
          child: Scaffold(
            key: _scaffoldKey, // Add this line

            appBar: AppBar(
              title: _isSearching
                  ? TextField(
                      decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: "Name, Email,..."),
                      autofocus: true,
                      style: TextStyle(fontSize: 18, letterSpacing: 0.5),
                      onChanged: (val) {
                        _searchList.clear();

                        for (var i in _list) {
                          if (i.name
                                  .toLowerCase()
                                  .contains(val.toLowerCase()) ||
                              i.email
                                  .toLowerCase()
                                  .contains(val.toLowerCase())) {
                            _searchList.add(i);
                          }
                          setState(() {
                            _searchList;
                          });
                        }
                      },
                    )
                  : Text('Groupie',
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
                IconButton(
                    onPressed: () {
                      setState(() {
                        _isSearching = !_isSearching;
                      });
                    },
                    icon: Icon(_isSearching
                        ? CupertinoIcons.clear_circled_solid
                        : Icons.search)),
              ],
            ),

            drawer: Drawer(
              child: ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  DrawerHeader(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.primary,
                          Theme.of(context).colorScheme.secondary,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Text('Groupie',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                            fontSize: 24)),
                  ),
                  ListTile(
                    leading: Icon(Icons.person),
                    title: Text('Profile'),
                    onTap: () {
                      // Implement your logic here
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => ProfileScreen(user: APIs.me)));
                      ; // Close the drawer
                    },
                  ),

                  // Add more ListTile items as needed
                ],
              ),
            ),

            floatingActionButton: Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: FloatingActionButton(
                onPressed: () {
                  _addChatUserDialog();
                },
                child: const Icon(Icons.add_comment_rounded),
              ),
            ),
            body: StreamBuilder(
              stream: APIs.getMyUsersId(),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                  case ConnectionState.none:
                    return const Center(child: CircularProgressIndicator());

                  case ConnectionState.active:
                  case ConnectionState.done:
                    return StreamBuilder(
                        stream: APIs.getAllUsers(
                            snapshot.data?.docs.map((e) => e.id).toList() ??
                                []),
                        builder: (context, snapshot) {
                          switch (snapshot.connectionState) {
                            case ConnectionState.waiting:
                            case ConnectionState.none:
                              return const Center(
                                  child: CircularProgressIndicator());

                            case ConnectionState.active:
                            case ConnectionState.done:
                              final data = snapshot.data?.docs;
                              _list = data
                                      ?.map((e) => ChatUser.fromJson(e.data()))
                                      .toList() ??
                                  [];
                              if (_list.isNotEmpty) {
                                return ListView.builder(
                                    itemCount: _isSearching
                                        ? _searchList.length
                                        : _list.length,
                                    padding:
                                        EdgeInsets.only(top: mq.height * .02),
                                    physics: BouncingScrollPhysics(),
                                    itemBuilder: (context, index) {
                                      return ChatUserCard(
                                          user: _isSearching
                                              ? _searchList[index]
                                              : _list[index]);
                                      //return Text('Name: ${list}');
                                    });
                              } else {
                                return Center(
                                  child: const Text('No Connections Found!',
                                      style: TextStyle(fontSize: 20)),
                                );
                              }
                          }
                        });
                }
              },
            ),
          ),
        ),
      ),
    );
  }

  void _addChatUserDialog() {
    String email = '';

    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              contentPadding: const EdgeInsets.only(
                  left: 24, right: 24, top: 20, bottom: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              title: Row(children: const [
                Icon(
                  Icons.person_add,
                  color: Color.fromARGB(255, 255, 67, 67),
                  size: 28,
                ),
                Text('  Add User')
              ]),
              content: TextFormField(
                maxLines: null,
                onChanged: (value) => email = value,
                decoration: InputDecoration(
                    hintText: 'Email Id',
                    prefixIcon: const Icon(Icons.email,
                        color: Color.fromARGB(255, 250, 103, 103)),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15))),
              ),
              actions: [
                MaterialButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                        color: Color.fromARGB(255, 250, 103, 103),
                        fontSize: 16),
                  ),
                ),
                MaterialButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    if (email.isNotEmpty) {
                      await APIs.addChatUser(email).then((value) {
                        if (!value) {
                          Dialogs.showSnackBar(context, 'User does not Exists');
                        }
                      });
                    }
                  },
                  child: Text(
                    'Add',
                    style: TextStyle(
                        color: Color.fromARGB(255, 250, 103, 103),
                        fontSize: 16),
                  ),
                )
              ],
            ));
  }
}
