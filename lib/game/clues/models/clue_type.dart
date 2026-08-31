/// Categoría lógica de una pista de investigación.
enum ClueType {
  /// Relaciones espaciales cardinales (al oeste, al este, al norte, al sur).
  cardinal,

  /// Adyacencia ortogonal inmediata (junto a, no junto a).
  adjacency,

  /// Pertenencia o exclusión de una habitación o zona.
  zone,

  /// Co-localización de línea (misma fila/columna, fila/columna distinta).
  coLocation,
}
