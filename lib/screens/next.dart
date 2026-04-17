import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? name;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Test Shared prefrences'),
        backgroundColor: Colors.blue,
      ),
      body: ListView(
        children: [
          MaterialButton(
            onPressed: () async {
              SharedPreferences sharedPreferences =
                  await SharedPreferences.getInstance();
              sharedPreferences.setString("name", "Ahmed");
            },
            child: Text('setdata'),
          ),
          MaterialButton(
            onPressed: () async {
              SharedPreferences sharedPreferences =
                  await SharedPreferences.getInstance();
              String? name = sharedPreferences.getString("name");
              bool? seen = sharedPreferences.getBool("onboardingSeen");
              print(name ?? "no Value");
              print(seen ?? "null");
            },
            child: Text("getData"),
          )
        ],
      ),
    );
  }
}
