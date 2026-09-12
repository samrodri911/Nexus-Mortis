import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_mortis/features/home/clue_panel.dart';
import 'package:nexus_mortis/game/board/controllers/board_controller.dart';
import 'package:nexus_mortis/game/puzzles/data/demo_case_001.dart';
import 'package:nexus_mortis/game/puzzles/models/board_rule_data.dart';
import 'package:nexus_mortis/game/puzzles/models/case_data.dart';

void main() {
  group('CluePanel Widget Tests', () {
    late CaseData testCase;
    late BoardController controller;

    setUp(() {
      testCase = demoCase001.copyWith(
        globalRules: const [
          BoardRuleData(
            id: 'rule_1',
            type: BoardRuleType.singleOccupantZone,
            text: 'Solo una persona estuvo en la Habitación del Hotel.',
          ),
        ],
      );

      controller = BoardController.fromCase(testCase);
    });

    testWidgets('CluePanel inicia en estado COLLAPSED con altura compacta y badge de pistas', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                const Expanded(child: SizedBox()),
                CluePanel(
                  controller: controller,
                  caseData: testCase,
                ),
              ],
            ),
          ),
        ),
      );

      // Verificar que el header muestra "PISTAS" y el badge con el conteo
      expect(find.text('PISTAS'), findsOneWidget);
      final totalExpected = testCase.globalRules.length + testCase.clues.length;
      expect(find.text('$totalExpected disponibles'), findsOneWidget);

      // Verificar que el cuerpo de tarjetas no está desplegado
      expect(find.text('PISTA GENERAL'), findsNothing);

      // Altura inicial compacta (~46px)
      final containerFinder = find.byType(AnimatedContainer);
      expect(containerFinder, findsOneWidget);
      final RenderBox box = tester.renderObject(containerFinder);
      expect(box.size.height, equals(46.0));
    });

    testWidgets('Al pulsar la barra, CluePanel se expande y muestra la Pista General y las Declaraciones', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                const Expanded(child: SizedBox()),
                CluePanel(
                  controller: controller,
                  caseData: testCase,
                ),
              ],
            ),
          ),
        ),
      );

      // Tocar la barra de cabecera
      await tester.tap(find.text('PISTAS'));
      await tester.pumpAndSettle();

      // Ahora debe mostrar la Pista General y tarjetas de pistas
      expect(find.text('PISTA GENERAL'), findsOneWidget);
      expect(find.text('Solo una persona estuvo en la Habitación del Hotel.'), findsOneWidget);

      // La altura debe haber aumentado considerablemente (estado EXPANDED)
      final RenderBox box = tester.renderObject(find.byType(AnimatedContainer));
      expect(box.size.height, greaterThan(150.0));

      // Tocar nuevamente para colapsar
      await tester.tap(find.text('PISTAS'));
      await tester.pumpAndSettle();

      // Vuelve a estar colapsado a 46px
      final RenderBox collapsedBox = tester.renderObject(find.byType(AnimatedContainer));
      expect(collapsedBox.size.height, equals(46.0));
    });
  });
}
