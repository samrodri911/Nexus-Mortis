/// Contrato para las futuras implementaciones de divisas (Monedas In-game, IAP, Ads).
/// Define la capacidad de leer un balance y gastar una cantidad.
abstract class HintCurrencyProvider {
  /// Devuelve el saldo actual disponible.
  int getBalance();

  /// Descuenta la cantidad especificada.
  /// Se asume que getBalance() fue verificado previamente.
  void spend(int amount);
}
