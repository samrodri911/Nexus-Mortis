import 'package:nexus_mortis/game/hints/models/hint_type.dart';

/// Resultado generado al solicitar una pista.
class HintResult {
  const HintResult({
    required this.type,
    required this.message,
  });

  final HintType type;
  final String message;
}
