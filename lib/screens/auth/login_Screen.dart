import 'dart:developer';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:gropie/api/apis.dart';
import 'package:gropie/helper/dialogs.dart';
import 'package:gropie/main.dart';

import '../home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // ignore: unused_field
  bool _isAnimate = false;
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1500), () {
      setState(() {
        _isAnimate = true;
      });
    });
  }

  _handleGoogleBtnClick() {
    Dialogs.showProgressBar(context);
    _signInWithGoogle().then((user) async {
      Navigator.pop(context);
      if (user != null) {
        log('\nUser : ${user.user}');
        log('\nUserAdditionalInfo : ${user.additionalUserInfo}');
        if ((await APIs.userExists())) {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => const HomeScreen()));
        } else {
          await APIs.createUser().then((value) {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (_) => const HomeScreen()));
          });
        }
      }
    });
  }

  Future<UserCredential?> _signInWithGoogle() async {
    try {
      await InternetAddress.lookup('google.com');
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Once signed in, return the UserCredential
      return await APIs.auth.signInWithCredential(credential);
    } catch (e) {
      log('\n_signInWithGoogle: $e');
      Dialogs.showSnackBar(context, 'Something Went Wrong (Check Internet)');
    }
    return null;
  }

  //signout function
  //_signOut() async{
  //await firebaseAuth.instance.signOut();
  //await GooglesignIn().signOut();}

  @override
  Widget build(BuildContext context) {
    // mq = MediaQuery.of(context).size;
    return Container(
      decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.topRight,
              colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.secondary
          ])),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Welcome to Groupie',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge!
                  .copyWith(fontWeight: FontWeight.bold)),
          centerTitle: true,
          elevation: 0,
          actions: [
            IconButton(
                onPressed: () {
                  Get.changeThemeMode(
                      Get.isDarkMode ? ThemeMode.light : ThemeMode.dark);
                  print(Get.isDarkMode);
                },
                icon:
                    Icon(Get.isDarkMode ? Icons.dark_mode : Icons.light_mode)),
          ],
        ),
        body: Stack(
          children: [
            AnimatedPositioned(
                top: mq.height * .15,
                right: _isAnimate ? mq.width * .15 : -mq.width * .5,
                width: mq.width * .7,
                duration: const Duration(seconds: 1),
                child: Image.asset('images/login.png')),
            Positioned(
              bottom: mq.height * .15,
              left: mq.width * .05,
              width: mq.width * .9,
              height: mq.height * .05,
              child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                      shape: StadiumBorder(), elevation: 1),
                  onPressed: () {
                    _handleGoogleBtnClick();
                  },
                  icon: Image.asset(
                    'images/google.png',
                    height: mq.height * .04,
                  ),
                  label: RichText(
                      text: const TextSpan(
                          style: TextStyle(color: Colors.black, fontSize: 19),
                          children: [
                        TextSpan(text: 'Login with '),
                        TextSpan(
                            text: 'Google',
                            style: TextStyle(fontWeight: FontWeight.w500))
                      ]))),
            )
          ],
        ),
      ),
    );
  }
}
