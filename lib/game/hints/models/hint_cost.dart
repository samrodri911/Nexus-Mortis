/// Define el costo en moneda del juego para cada tipo de pista.
class HintCost {
  const HintCost({
    required this.soft,
    required this.medium,
    required this.reveal,
  });

  final int soft;
  final int medium;
  final int reveal;

  /// Valores por defecto del sistema económico.
  static const HintCost defaults = HintCost(
    soft: 25,
    medium: 50,
    reveal: 100,
  );
}
