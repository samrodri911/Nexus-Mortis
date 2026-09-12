import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_mortis/data/repositories/progress_repository.dart';
import 'package:nexus_mortis/features/hints/hint_panel.dart';
import 'package:nexus_mortis/game/board/controllers/board_controller.dart';
import 'package:nexus_mortis/game/clues/evaluators/clue_evaluator.dart';
import 'package:nexus_mortis/game/clues/evaluators/spatial_clue_evaluator.dart';
import 'package:nexus_mortis/game/hints/models/hint_cost.dart';
import 'package:nexus_mortis/game/hints/services/hint_economy_service.dart';
import 'package:nexus_mortis/game/hints/services/hint_service.dart';
import 'package:nexus_mortis/game/progression/models/player_progress.dart';
import 'package:nexus_mortis/game/progression/progression_service.dart';
import 'package:nexus_mortis/game/puzzles/data/demo_case_001.dart';
import 'package:nexus_mortis/game/puzzles/models/case_data.dart';
import 'package:nexus_mortis/game/validation/validation_service.dart';

class _FakeProgressRepo implements ProgressRepository {
  @override
  Future<void> clearProgress() async {}
  @override
  Future<PlayerProgress> loadProgress() async => PlayerProgress.empty();
  @override
  Future<void> saveProgress(PlayerProgress progress) async {}
}

void main() {
  group('HintPanel Widget Tests', () {
    late CaseData testCase;
    late BoardController controller;
    late ProgressionService progressionService;
    late HintEconomyService economyService;
    late ValidationService validationService;

    setUp(() {
      testCase = demoCase001;
      controller = BoardController.fromCase(testCase);
      progressionService = ProgressionService(
        _FakeProgressRepo(),
        initialProgress: const PlayerProgress(
          coins: 20,
          totalStars: 5,
          completedCases: {},
        ),
      );
      final clueEvaluator = const ClueEvaluator(SpatialClueEvaluator());
      final hintService = HintService(
        clueEvaluator: clueEvaluator,
      );
      economyService = HintEconomyService(
        progressionService: progressionService,
        hintService: hintService,
        costs: const HintCost(soft: 5, medium: 15, reveal: 30),
      );
      validationService = ValidationService(
        caseData: testCase,
        clueEvaluator: clueEvaluator,
      );
    });

    Widget createWidgetUnderTest() {
      return MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              HintPanel(
                economyService: economyService,
                progressionService: progressionService,
                boardController: controller,
                validationService: validationService,
                caseData: testCase,
              ),
              const Expanded(child: SizedBox()),
            ],
          ),
        ),
      );
    }

    testWidgets('HintPanel inicia en estado COLLAPSED con saldo de monedas visible y altura compacta', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Verificar que se muestra el dinero (20 monedas)
      expect(find.text('20'), findsOneWidget);
      expect(find.text('AYUDAS'), findsOneWidget);
      expect(find.text('Consultar opciones'), findsOneWidget);

      // En estado colapsado NO se muestran las opciones con sus descripciones
      expect(find.text('Sugerencia sutil'), findsNothing);
      expect(find.text('Evalúa marcas'), findsNothing);
      expect(find.text('Ubicación clave'), findsNothing);

      // Altura inicial compacta (38px)
      final containerFinder = find.byType(AnimatedContainer);
      expect(containerFinder, findsOneWidget);
      final RenderBox box = tester.renderObject(containerFinder);
      expect(box.size.height, equals(38.0));
    });

    testWidgets('Al pulsar la barra, HintPanel se expande y muestra las 3 ayudas con sus costos', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Tocar la barra de cabecera
      await tester.tap(find.text('AYUDAS'));
      await tester.pumpAndSettle();

      // Verificar que el estado ahora indica que se puede ocultar
      expect(find.text('Toca para ocultar'), findsOneWidget);

      // Ahora deben aparecer las 3 opciones con sus títulos, descripciones y costos
      expect(find.text('Suave'), findsOneWidget);
      expect(find.text('Sugerencia sutil'), findsOneWidget);
      expect(find.text('Media'), findsOneWidget);
      expect(find.text('Evalúa marcas'), findsOneWidget);
      expect(find.text('Revelar'), findsOneWidget);
      expect(find.text('Ubicación clave'), findsOneWidget);

      // Verificar los costos de las pistas
      expect(find.text('${economyService.costs.soft}'), findsOneWidget);
      expect(find.text('${economyService.costs.medium}'), findsOneWidget);
      expect(find.text('${economyService.costs.reveal}'), findsOneWidget);

      // Altura expandida
      final RenderBox box = tester.renderObject(find.byType(AnimatedContainer));
      expect(box.size.height, equals(122.0));

      // Tocar nuevamente para colapsar
      await tester.tap(find.text('AYUDAS'));
      await tester.pumpAndSettle();

      // Vuelve a estar colapsado a 38px
      final RenderBox collapsedBox = tester.renderObject(find.byType(AnimatedContainer));
      expect(collapsedBox.size.height, equals(38.0));
    });

    testWidgets('Comprar una ayuda descuenta monedas y colapsa el panel automáticamente', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Abrir panel
      await tester.tap(find.text('AYUDAS'));
      await tester.pumpAndSettle();

      // Tocar la opción "Suave" (cuesta 5 monedas, el jugador tiene 20)
      await tester.tap(find.text('Suave'));
      await tester.pumpAndSettle();

      // Se abre el diálogo del informador con el resultado
      expect(find.text('Informe del Informador'), findsOneWidget);
      expect(find.text('Entendido'), findsOneWidget);

      // Las monedas se descuentan (20 - 5 = 15)
      expect(progressionService.progress.coins, equals(15));

      // Cerrar diálogo
      await tester.tap(find.text('Entendido'));
      await tester.pumpAndSettle();

      // El panel se ha colapsado automáticamente devolviendo espacio al tablero
      final RenderBox box = tester.renderObject(find.byType(AnimatedContainer));
      expect(box.size.height, equals(38.0));
      expect(find.text('15'), findsOneWidget);
    });
  });
}
