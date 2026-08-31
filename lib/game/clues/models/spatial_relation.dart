/// Tipos de relaciones espaciales y lógicas entre entidades en el tablero.
enum SpatialRelation {
  // Adyacencia ortogonal (Von Neumann)
  adjacentTo,
  notAdjacentTo,

  // Relaciones cardinales relativas
  leftOf,
  rightOf,
  above,
  below,

  // Pertenencia a Zonas
  inZone,
  notInZone,

  // Co-localización en filas y columnas
  sameRow,
  sameColumn,
  differentRow,
  differentColumn,

  // Relaciones direccionales inmediatas
  immediatelyNorthOf,
  immediatelySouthOf,
  immediatelyEastOf,
  immediatelyWestOf,
}
