/// Representa una anotación global aplicada a una celda por el investigador.
/// 
/// A diferencia de los candidatos, que pertenecen a un sospechoso específico,
/// las anotaciones son propiedades inherentes a la posición física en el escenario.
enum CellAnnotation {
  /// La celda no tiene ninguna anotación.
  none,
  
  /// El investigador ha marcado esta celda con una 'X', 
  /// descartándola como posible posición para cualquier sospechoso.
  /// (Solo aplica a celdas libres, no bloqueadas).
  eliminated,
}
