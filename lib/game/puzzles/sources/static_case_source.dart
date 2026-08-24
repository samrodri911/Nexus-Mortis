import 'dart:async';
import 'package:nexus_mortis/game/puzzles/case_registry.dart';
import 'package:nexus_mortis/game/puzzles/models/case_data.dart';
import 'package:nexus_mortis/game/puzzles/models/case_source.dart';

/// Fuente de casos estáticos (Campaña).
class StaticCaseSource implements CaseSource {
  const StaticCaseSource();

  List<CaseData> get allCases => CaseRegistry.cases;

  @override
  FutureOr<CaseData?> getCase(String id) {
    return CaseRegistry.getCase(id);
  }
}
