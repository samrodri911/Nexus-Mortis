import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_mortis/game/difficulty/models/difficulty_level.dart';
import 'package:nexus_mortis/game/progression/models/case_progress.dart';
import 'package:nexus_mortis/game/progression/models/player_progress.dart';
import 'package:nexus_mortis/game/puzzles/models/case_data.dart';
import 'package:nexus_mortis/game/puzzles/models/case_origin.dart';
import 'package:nexus_mortis/game/puzzles/models/puzzle_difficulty.dart';
import 'package:nexus_mortis/game/puzzles/models/solution_data.dart';
import 'package:nexus_mortis/game/puzzles/services/procedural_case_service.dart';
import 'package:nexus_mortis/game/puzzles/sources/generated_case_source.dart';
import 'package:nexus_mortis/game/puzzles/sources/static_case_source.dart';
import 'package:nexus_mortis/game/progression/progression_service.dart';

import 'package:mocktail/mocktail.dart';

class MockProgressionService extends Mock implements ProgressionService {}

void main() {
  group('ProceduralCaseService', () {
    test('getNextCase devuelve campaña si hay casos disponibles', () async {
      final mockProgression = MockProgressionService();
      
      final dummyCase = CaseData(
        id: 'dummy_1',
        title: 'Dummy',
        description: '',
        difficulty: PuzzleDifficulty.easy,
        boardRows: 3,
        boardColumns: 3,
        suspects: [],
        placedObjects: [],
        clues: [],
        solution: SolutionData(suspectPositions: {}),
      );

      when(() => mockProgression.getNextCampaignCase(any()))
          .thenReturn(dummyCase);

      final service = ProceduralCaseService(
        progressionService: mockProgression,
        staticSource: const StaticCaseSource(),
        generatedSource: GeneratedCaseSource(),
      );

      final nextCase = await service.getNextCase();
      expect(nextCase.id, 'dummy_1');
      expect(nextCase.origin, CaseOrigin.campaign);
    });

    test('getNextCase genera un caso procedural si la campaña terminó', () async {
      final mockProgression = MockProgressionService();
      
      when(() => mockProgression.getNextCampaignCase(any())).thenReturn(null);
      when(() => mockProgression.progress).thenReturn(
        PlayerProgress(
          coins: 0, 
          totalStars: 0, 
          completedCases: {
            // Simulamos 5 casos completados para probar el generador
            for (var i = 0; i < 5; i++) 'c_$i': CaseProgress(caseId: 'c_$i', completed: true, starsEarned: 3)
          }
        )
      );

      final service = ProceduralCaseService(
        progressionService: mockProgression,
        staticSource: const StaticCaseSource(),
        generatedSource: GeneratedCaseSource(),
      );

      final nextCase = await service.getNextCase();
      
      expect(nextCase.id, startsWith('procedural_'));
      expect(nextCase.origin, CaseOrigin.procedural);
      expect(nextCase.boardRows, 4); // Medium policy -> 4x3
    });
  });
}
