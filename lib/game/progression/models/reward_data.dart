/// Recompensas otorgadas al jugador tras completar un caso.
class RewardData {
  const RewardData({
    required this.coins,
    required this.stars,
  });

  final int coins;
  final int stars;

  factory RewardData.fromJson(Map<String, dynamic> json) {
    return RewardData(
      coins: json['coins'] as int? ?? 0,
      stars: json['stars'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'coins': coins,
      'stars': stars,
    };
  }
}
