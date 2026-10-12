import 'package:flutter/material.dart';

/// Root widget. Theme, localisation and routing arrive in T-107, T-109 and T-111.
class PanjikaApp extends StatelessWidget {
  const PanjikaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(body: SafeArea(child: SizedBox.expand())),
    );
  }
}
