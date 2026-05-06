import 'package:flutter/material.dart';

import '../screens/title_screen.dart';

class ShadowParryApp extends StatelessWidget {
  const ShadowParryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shadow Parry',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF8B1E3F),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const TitleScreen(),
    );
  }
}
