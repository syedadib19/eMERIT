import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';

void main() {
  runApp(NFCWriterApp());
}

class NFCWriterApp extends StatefulWidget {
  @override
  _NFCWriterAppState createState() => _NFCWriterAppState();
}

class _NFCWriterAppState extends State<NFCWriterApp> {
  TextEditingController collegeNumberController = TextEditingController();
  String message = "Tap an NFC card to write data";

  Future<void> writeToNFC(String collegeNumber) async {
    bool isAvailable = await NfcManager.instance.isAvailable();

    if (!isAvailable) {
      setState(() {
        message = "NFC is not available on this device";
      });
      return;
    }

    NfcManager.instance.startSession(
      onDiscovered: (NfcTag tag) async {
        var ndef = Ndef.from(tag);
        if (ndef == null || !ndef.isWritable) {
          setState(() {
            message = "NFC tag is not writable";
          });
          return;
        }

        NdefMessage ndefMessage = NdefMessage([
          NdefRecord.createText(collegeNumber),
        ]);

        try {
          await ndef.write(ndefMessage);
          setState(() {
            message = "College Number $collegeNumber written successfully!";
          });
          NfcManager.instance.stopSession();
        } catch (e) {
          setState(() {
            message = "Failed to write data: $e";
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text("NFC Writer")),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: collegeNumberController,
                decoration: InputDecoration(
                  labelText: "Enter College Number",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  String collegeNumber = collegeNumberController.text.trim();
                  if (collegeNumber.isNotEmpty) {
                    writeToNFC(collegeNumber);
                  } else {
                    setState(() {
                      message = "Please enter a valid college number";
                    });
                  }
                },
                child: Text("Write to NFC"),
              ),
              SizedBox(height: 20),
              Text(
                message,
                style: TextStyle(fontSize: 16, color: Colors.blue),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
