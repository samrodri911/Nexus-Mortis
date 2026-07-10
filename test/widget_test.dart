import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_mortis/features/case_selection/case_selection_page.dart';
import 'package:nexus_mortis/game/progression/progression_service.dart';
import 'package:nexus_mortis/main.dart';

void main() {
  testWidgets('NexusMortisApp loads successfully and displays CaseSelectionPage', (WidgetTester tester) async {
    final progressionService = ProgressionService();
    // Build our app and trigger a frame.
    await tester.pumpWidget(NexusMortisApp(progressionService: progressionService));

    // Verify that the CaseSelectionPage is present on screen.
    expect(find.byType(CaseSelectionPage), findsOneWidget);
  });
}
