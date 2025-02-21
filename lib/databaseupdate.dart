import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FetchDataPage extends StatefulWidget {
  @override
  _FetchDataPageState createState() => _FetchDataPageState();
}

class _FetchDataPageState extends State<FetchDataPage> {
  List<dynamic> students = [];
  bool isLoading = false;
  String errorMessage = "";

  Future<void> fetchData() async {
    setState(() {
      isLoading = true;
      errorMessage = "";
    });

    try {
      final response = await http.get(Uri.parse("https://mrsmbetongsarawak.edu.my/emerit/api/get_data.php"));
      final result = json.decode(response.body);

      if (result["success"] == true) {
        setState(() {
          students = result["data"];
        });
      } else {
        setState(() {
          errorMessage = result["error"] ?? "Unknown error";
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Failed to fetch data: ${e.toString()}";
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData(); // Auto-fetch data when page loads
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Students from Access DB")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading) CircularProgressIndicator(),
            if (errorMessage.isNotEmpty) Text(errorMessage, style: TextStyle(color: Colors.red)),
            if (!isLoading && students.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: students.length,
                  itemBuilder: (context, index) {
                    final student = students[index];
                    return ListTile(
                      title: Text(student["name"]),
                      subtitle: Text("College #: ${student["college_number"]} | Address: ${student["address"]}"),
                    );
                  },
                ),
              ),
            ElevatedButton(
              onPressed: fetchData,
              child: Text("Refresh Data"),
            ),
          ],
        ),
      ),
    );
  }
}
