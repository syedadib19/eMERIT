import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class NFCMeritPage extends StatefulWidget {
  @override
  _NFCMeritPageState createState() => _NFCMeritPageState();
}

class _NFCMeritPageState extends State<NFCMeritPage> {
  String collegeNumber = "Tap an NFC card to read";
  String studentName = "";
  int meritPoints = 0;
  TextEditingController meritController = TextEditingController();

  void startNFC() async {
    if (!await NfcManager.instance.isAvailable()) {
      print('NFC not available');
      return;
    }

    NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
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
          String extractedCollegeNumber = data.substring(3); // Skip UTF-8 encoding bytes

          setState(() {
            collegeNumber = "College Number: $extractedCollegeNumber";
          });

          await fetchStudentName(extractedCollegeNumber);

          if (meritPoints > 0) {
            await grantMerit(extractedCollegeNumber, meritPoints);
          }
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
    });
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

  Future<void> grantMerit(String collegeNumber, int meritPoints) async {
    String apiUrl = 'https://mrsmbetongsarawak.edu.my/emerit/api/grant_merit.php';

    try {
      var response = await http.post(
        Uri.parse(apiUrl),
        body: {
          'college_number': collegeNumber,
          'merit_points': meritPoints.toString(),
        },
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['success']) {
          print('Merit granted to college number $collegeNumber');
        } else {
          print('Error: ${data['message']}');
        }
      } else {
        print('Failed to connect to server');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('NFC Merit System')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: meritController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Enter merit points per student',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    meritPoints = int.tryParse(value) ?? 0;
                  });
                },
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                startNFC();
              },
              child: Text('Start NFC Scan'),
            ),
            SizedBox(height: 20),
            Text(collegeNumber, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text(studentName, style: TextStyle(fontSize: 18, color: Colors.blue)),
          ],
        ),
      ),
    );
  }
}
