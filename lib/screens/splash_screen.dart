import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:gropie/api/apis.dart';
import 'package:gropie/main.dart';

// ignore: unused_import
import 'auth/login_Screen.dart';
// ignore: unused_import
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 2000), () {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setSystemUIOverlayStyle(
          SystemUiOverlayStyle(systemNavigationBarColor: Colors.white));
      if (APIs.auth.currentUser != null) {
        log('\nUser : ${APIs.auth.currentUser}');

        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const HomeScreen()));
      } else {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const LoginScreen()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;
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
            Positioned(
                top: mq.height * .15,
                right: mq.width * .15,
                width: mq.width * .7,
                child: Image.asset('images/login.png')),
            Positioned(
              bottom: mq.height * .15,
              width: mq.width,
              child: Text(
                "𝜶 Alpha",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 26, color: Color.fromARGB(255, 201, 44, 49)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
