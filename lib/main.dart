import 'package:flutter/material.dart';
import 'package:object_extract/home_screen.dart';
import 'package:object_extract/global.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: appName,
        // darkTheme: ThemeData.dark(useMaterial3: true),
        // uncomment this for dark mode
        theme: ThemeData(
          fontFamily: "PulpDisplay",
          scaffoldBackgroundColor: appColor,
          appBarTheme: AppBarTheme(backgroundColor: appColor),
          useMaterial3: true,
        ),
        home: const HomeScreen());
  }
}
