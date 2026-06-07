import 'package:flame/game.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_mortis/main.dart';
import 'package:nexus_mortis/game/nexus_game.dart';

void main() {
  testWidgets('NexusMortisApp loads successfully and displays GameWidget', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const NexusMortisApp());

    // Verify that the GameWidget containing NexusGame is present on screen.
    expect(find.byType(GameWidget<NexusGame>), findsOneWidget);
  });
}
