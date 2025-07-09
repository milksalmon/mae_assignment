import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Color.fromARGB(255, 246, 245, 245),
        body: Center (
          child: Text(
            "Test",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,

            )

          )

        )

      )

    );

  }

}