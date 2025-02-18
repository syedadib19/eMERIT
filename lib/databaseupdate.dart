import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Update Database'),
        ),
        body: Center(
          child: UpdateButton(),
        ),
      ),
    );
  }
}

class UpdateButton extends StatefulWidget {
  @override
  _UpdateButtonState createState() => _UpdateButtonState();
}

class _UpdateButtonState extends State<UpdateButton> {
  String _responseMessage = '';

  Future<void> _updateDatabase() async {
    final url = Uri.parse('https://mrsmbetongsarawak.edu.my/emerit/update_data.php'); // Replace with your server URL

    try {
      final response = await http.post(url);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        setState(() {
          _responseMessage = jsonResponse['message'];
        });
      } else {
        setState(() {
          _responseMessage = 'Failed to update database. Status code: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _responseMessage = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: _updateDatabase,
          child: Text('Update Database'),
        ),
        SizedBox(height: 20),
        Text(_responseMessage),
      ],
    );
  }
}