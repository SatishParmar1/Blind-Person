import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_tts/flutter_tts.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  TextEditingController ipaddress = TextEditingController();
  int distance = 0;
  String status = "Disconnected";
  String connectionStatus = "Unknown";


  // Function to fetch data from ESP8266
  Future<void> fetchData() async {
    try {
      final response = await http.get(Uri.parse('http://192.168.228.170/')); // Replace with your ESP8266 IP
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          status = data['status']; // Get the 'status' value from JSON response
          distance = data['distance']; // Get the 'distance' value from JSON response
        });

        // Play sound if connected
        if (status == "connected" && (distance>=10&& distance<=150) ) {
          String anotherValue = '$distance';
          flutterTts.speak('Object at $anotherValue');
        }
        fetchData();
      } else {
        status = "Disconnect";
        distance = 0;
        throw Exception('Failed to load data');
      }
    } catch (e) {
      setState(() {
        status = "Disconnected";
      });
    }
  }

  // Function to play sound
  final FlutterTts flutterTts = FlutterTts();
  @override
  void initState() {
    super.initState();

    fetchData(); // Fetch data when the app starts
  }

  void distancespeek(){
    if (status == "connected" && (distance>=30&& distance<=100) ) {
      String anotherValue = '$distance';
      flutterTts.speak('$distance');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Distance Measurement'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[

              Text(
                'Status: $status',
                style: TextStyle(fontSize: 24),
              ),
              Text(
                'Distance from sensor:',
                style: TextStyle(fontSize: 24),
              ),
              Text(
                '$distance cm',
                style: TextStyle(fontSize: 48),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: fetchData, // Fetch data when button is pressed
                child: Text('Refresh Data'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
