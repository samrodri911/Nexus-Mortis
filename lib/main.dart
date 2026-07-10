import 'package:flutter/material.dart';
import 'package:nexus_mortis/features/case_selection/case_selection_page.dart';
import 'package:nexus_mortis/game/progression/progression_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Instancia única (no singleton global estático) que vivirá mientras 
  // viva la aplicación. Se inyecta en el widget principal.
  final progressionService = ProgressionService();

  runApp(NexusMortisApp(progressionService: progressionService));
}

/// The root widget of the Nexus Mortis application.
class NexusMortisApp extends StatelessWidget {
  const NexusMortisApp({
    super.key,
    required this.progressionService,
  });

  final ProgressionService progressionService;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nexus Mortis',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF121214),
      ),
      home: CaseSelectionPage(progressionService: progressionService),
    );
  }
}
