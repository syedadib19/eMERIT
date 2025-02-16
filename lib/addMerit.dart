import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Emerit System',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[100],
      ),
      home: EmeritSystem(),
    );
  }
}

class EmeritSystem extends StatefulWidget {
  @override
  _EmeritSystemState createState() => _EmeritSystemState();
}

class _EmeritSystemState extends State<EmeritSystem> {
  final TextEditingController _collegeNumberController = TextEditingController();
  final TextEditingController _meritPointsController = TextEditingController();
  Map<String, dynamic>? _studentData;
  bool _isLoading = false;

  Future<void> _fetchStudent() async {
    setState(() => _isLoading = true);
    final collegeNumber = _collegeNumberController.text;
    final response = await http.get(Uri.parse('https://mrsmbetongsarawak.edu.my/emerit/api/getStudent.php?college_number=$collegeNumber'));

    if (response.statusCode == 200) {
      setState(() {
        _studentData = json.decode(response.body);
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Student not found.'),
        backgroundColor: Colors.red,
      ));
    }
  }

  Future<void> _updateMerits(String action) async {
    final collegeNumber = _collegeNumberController.text;
    final meritPoints = int.tryParse(_meritPointsController.text) ?? 0;

    final url = action == 'add'
        ? 'https://mrsmbetongsarawak.edu.my/emerit/api/addMerit.php'
        : 'https://mrsmbetongsarawak.edu.my/emerit/api/removeMerit.php';

    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'college_number': collegeNumber,
        'merit_points': meritPoints,
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('$action Merit successfully added!'),
        backgroundColor: Colors.green,
      ));
      _fetchStudent(); // Refresh student data
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to $action Merit points.'),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Emerit System'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.purple],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          // Gradient Background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade50, Colors.purple.shade50],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _collegeNumberController,
                  decoration: InputDecoration(
                    labelText: 'College Number',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _fetchStudent,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 12),
                    backgroundColor: Colors.blue,
                  ),
                  child: Text('Fetch Student', style: TextStyle(fontSize: 16)),
                ),
                SizedBox(height: 20),
                if (_isLoading)
                  Center(child: CircularProgressIndicator()),
                if (!_isLoading && _studentData != null)
                  AnimatedOpacity(
                    opacity: 1,
                    duration: Duration(milliseconds: 500),
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Name: ${_studentData!['name']}', style: TextStyle(fontSize: 18)),
                            Text('College Number: ${_studentData!['college_number']}', style: TextStyle(fontSize: 16)),
                            Text('Merit Points: ${_studentData!['merit_points']}', style: TextStyle(fontSize: 16)),
                          ],
                        ),
                      ),
                    ),
                  ),
                SizedBox(height: 20),
                TextField(
                  controller: _meritPointsController,
                  decoration: InputDecoration(
                    labelText: 'Merit Points',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _updateMerits('add'),
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 12),
                          backgroundColor: Colors.green,
                        ),
                        child: Text('Add Merit', style: TextStyle(fontSize: 16)),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _updateMerits('remove'),
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 12),
                          backgroundColor: Colors.red,
                        ),
                        child: Text('Remove Merit', style: TextStyle(fontSize: 16)),
                      ),
                    ),
                  ],
                ),

              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _collegeNumberController.clear();
          _meritPointsController.clear();
          setState(() => _studentData = null);
        },
        child: Icon(Icons.refresh),
        tooltip: 'Reset',
      ),
    );
  }
}