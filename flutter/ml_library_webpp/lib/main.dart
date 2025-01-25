import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ml_library_webpp/screens/uploadscreen.dart';
import 'screens/sample1_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Digit Recognition',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => HomePage(),
        '/sample1': (context) => const Sample1Screen(),
      },
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> samples = [];

  @override
  void initState() {
    super.initState();
    loadSamples();
  }

  Future<void> loadSamples() async {
    String data = await rootBundle
        .loadString('assets/ml-models.json'); // Remove extra 'assets/'
    setState(() {
      samples = json.decode(data)['samples'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Home Page")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 3,
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
          children: samples
              .map((sample) => GestureDetector(
                    onTap: () =>
                        Navigator.pushNamed(context, '/sample${sample['id']}'),
                    child: Container(
                      color: Colors.blue,
                      child: Center(
                        child: Text(
                          sample['title'],
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      ),
                    ),
                  ))
              .toList(),
        ),
      ),
    );
  }
}
