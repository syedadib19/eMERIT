import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class NFCBatchPage extends StatefulWidget {
  @override
  _NFCBatchPageState createState() => _NFCBatchPageState();
}

class _NFCBatchPageState extends State<NFCBatchPage> {
  List<String> scannedStudents = []; // Store scanned college numbers
  TextEditingController meritController = TextEditingController();
  int meritPoints = 0;
  bool isProcessing = false;

  void startNFC() async {
    if (!await NfcManager.instance.isAvailable()) {
      print('NFC not available');
      return;
    }

    NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
      var ndef = Ndef.from(tag);
      if (ndef == null) {
        return;
      }

      try {
        NdefMessage message = await ndef.read();
        if (message.records.isNotEmpty) {
          String data = String.fromCharCodes(message.records.first.payload);
          String extractedCollegeNumber = data.substring(3); // Skip UTF-8 encoding bytes

          setState(() {
            if (!scannedStudents.contains(extractedCollegeNumber)) {
              scannedStudents.add(extractedCollegeNumber);
            }
          });

          print("Scanned: $extractedCollegeNumber");
        }
      } catch (e) {
        print("Error reading NFC: $e");
      }

      NfcManager.instance.stopSession();
    });
  }

  Future<void> grantMeritBatch() async {
    if (scannedStudents.isEmpty || meritPoints <= 0) {
      print('No students scanned or invalid merit points');
      return;
    }

    setState(() {
      isProcessing = true;
    });

    String apiUrl = 'https://mrsmbetongsarawak.edu.my/emerit/api/grant_merit_batch.php';

    try {
      var response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'college_numbers': scannedStudents,
          'merit_points': meritPoints,
        }),
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['success']) {
          print('Merit granted to all scanned students');
          setState(() {
            scannedStudents.clear(); // Clear list after successful update
          });
        } else {
          print('Error: ${data['message']}');
        }
      } else {
        print('Failed to connect to server');
      }
    } catch (e) {
      print('Error: $e');
    }

    setState(() {
      isProcessing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('NFC Merit System')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
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
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: startNFC,
              child: Text('Start NFC Scan'),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: scannedStudents.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text("College Number: ${scannedStudents[index]}"),
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: isProcessing ? null : grantMeritBatch,
              child: isProcessing ? CircularProgressIndicator() : Text('Grant Merit to All'),
            ),
          ],
        ),
      ),
    );
  }
}
