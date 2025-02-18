import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';

void main() {
  runApp(NFCReaderApp());
}

class NFCReaderApp extends StatefulWidget {
  @override
  _NFCReaderAppState createState() => _NFCReaderAppState();
}

class _NFCReaderAppState extends State<NFCReaderApp> {
  String collegeNumber = "Tap an NFC card to read";

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
            setState(() {
              collegeNumber = "College Number: ${data.substring(3)}"; // Skipping UTF-8 encoding bytes
            });
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
