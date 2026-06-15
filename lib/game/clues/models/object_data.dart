/// Representa un objeto físico fijo del escenario (cama, mesa, silla, etc.).
///
/// Múltiples instancias del mismo tipo de objeto son posibles,
/// por eso cada instancia tiene su propio [id] único.
class ObjectData {
  const ObjectData({required this.id, required this.name});

  final String id;
  final String name;
}
