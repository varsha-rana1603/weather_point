import 'package:flutter/material.dart';
import 'package:weather_point/ui/get_started.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Weather Point',
      home: GetStarted(),
      debugShowCheckedModeBanner: false,
    );
  }
}

