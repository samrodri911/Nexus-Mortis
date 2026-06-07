import 'package:flutter/material.dart';
import 'package:nexus_mortis/features/home/home_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const NexusMortisApp());
}

/// The root widget of the Nexus Mortis application.
class NexusMortisApp extends StatelessWidget {
  const NexusMortisApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nexus Mortis',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF121214),
      ),
      home: const HomePage(),
    );
  }
}
