import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(NFCgatherinfo());
}

class NFCgatherinfo extends StatefulWidget {
  @override
  _NFCgatherinfoState createState() => _NFCgatherinfoState();
}

class _NFCgatherinfoState extends State<NFCgatherinfo> {
  String collegeNumber = "Tap an NFC card to read";
  String studentName = "";

  void startNFCReading() {
    NfcManager.instance.startSession(
      onDiscovered: (NfcTag tag) async {
        var ndef = Ndef.from(tag);
        if (ndef == null) {
          setState(() {
            collegeNumber = "Not a valid NFC card!";
          });
          return;
        }

        try {
          NdefMessage message = await ndef.read();
          if (message.records.isNotEmpty) {
            String data = String.fromCharCodes(message.records.first.payload);
            String extractedCollegeNumber = data.substring(3); // Skipping UTF-8 encoding bytes

            setState(() {
              collegeNumber = "College Number: $extractedCollegeNumber";
            });

            // Fetch student name from MySQL
            fetchStudentName(extractedCollegeNumber);
          } else {
            setState(() {
              collegeNumber = "No data found on NFC card";
            });
          }
        } catch (e) {
          setState(() {
            collegeNumber = "Failed to read NFC: $e";
          });
        }

        NfcManager.instance.stopSession();
      },
    );
  }

  Future<void> fetchStudentName(String collegeNumber) async {
    final url = Uri.parse('https://mrsmbetongsarawak.edu.my/emerit/api/get_student_nfc.php');
    final response = await http.post(url, body: {'college_number': collegeNumber});

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success']) {
        setState(() {
          studentName = "Student Name: ${data['name']}";
        });
      } else {
        setState(() {
          studentName = "Student not found!";
        });
      }
    } else {
      setState(() {
        studentName = "Error fetching data!";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text("NFC Reader")),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                collegeNumber,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              Text(
                studentName,
                style: TextStyle(fontSize: 18, color: Colors.blue),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: startNFCReading,
                child: Text("Scan NFC Card"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
