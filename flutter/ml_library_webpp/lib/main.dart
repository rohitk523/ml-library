import 'package:flutter/material.dart';
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

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home Page"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 3,
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
          children: List.generate(9, (index) {
            return GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/sample${index + 1}');
              },
              child: Container(
                color: Colors.blue,
                child: Center(
                  child: Text(
                    'Sample ${index + 1}',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
