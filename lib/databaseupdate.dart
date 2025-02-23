import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


class MyAppsync extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyAppsync> {
  List<Map<String, String>> students = [];

  Future<void> syncAndFetchData() async {
    final response = await http.get(Uri.parse("https://mrsmbetongsarawak.edu.my/emerit/api/sync_mdb_to_mysql.php"));

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result['message'])));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: ${result['message']}")));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Server error!")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text("Sync MDB to MySQL")),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: syncAndFetchData,
                child: Text("Sync Data"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
