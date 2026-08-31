# INFORME DE GENERACIÓN MASIVA — OPERADOR DE CLAUSURA GLOBAL (300 CASOS)
Fecha de auditoría: 2026-08-30T10:58:27.543723

## NIVEL: EASY (100 Casos Objetivos)
Configuración: 4x4 | 3 Sospechosos | 2 Objetos

### Ejemplo Completo Deducible — Caso #case_200000_5
- **Título:** Misterio en el Real Jardín
- **Descripción:** La víctima fue hallada sin vida entre los senderos y estanques del botánico. Reconstruye los movimientos de cada sospechoso.
- **Zonas:** Vivero de Orquídeas (4 celdas), Laboratorio Botánico (3 celdas), Rosaleda Victoriana (8 celdas), Pabellón Tropical (1 celdas)
- **Objetos:** Mesa en (1,0), Lámpara en (3,2)
- **Pista General:** Ninguna (0 redundancia: resuelto puramente por descarte Murdoku)
- **Tarjetas de Declaración:**
  * [suspect_carlos]: Carlos se encontraba en el Laboratorio Botánico, estaba en la misma fila que la Mesa.
  * [suspect_pedro]: Pedro estaba inmediatamente al norte de la Mesa.
  * [VÍCTIMA]: La víctima. Estaba a solas con el asesino.
- **Traza Deductiva del Simulador (3 pasos):**
  Paso 1: suspect_carlos (14 -> 1) [Tarjeta de Pista: Carlos se encontraba en el Laboratorio Botánico, estaba en la misma fila que la Mesa.]
  Paso 2: suspect_pedro (14 -> 1) [Tarjeta de Pista: Pedro estaba inmediatamente al norte de la Mesa.]
  Paso 3: victim (14 -> 10) [Regla de Asesinato: La víctima debe estar en una zona con al menos un sospechoso (el asesino)]
  Paso 4: victim (10 -> 5) [Exclusión Murdoku por posición fijada de suspect_carlos en (1, 3)]
  Paso 5: victim (5 -> 1) [Exclusión Murdoku por posición fijada de suspect_pedro en (0, 0)]
- **Asesino Real:** suspect_pedro | **Deducido:** suspect_pedro | **Match:** true

**Resumen Nivel easy:**
- Casos aceptados: 100 / 100
- Intentos requeridos: 401 (Promedio 4.0 intentos/caso)
- Casos resueltos SIN regla global: 58 (58.0%)
- Casos con Pista General de clausura: 42 (42.0%)
- Promedio tarjetas de pistas: 3.00
- Promedio pasos deductivos: 3.00

## NIVEL: MEDIUM (100 Casos Objetivos)
Configuración: 4x4 | 4 Sospechosos | 3 Objetos

### Ejemplo Completo Deducible — Caso #case_300000_0
- **Título:** La Sombra en el Observatorio
- **Descripción:** La cúpula astronómica se convirtió en la escena de un misterio. Reconstruye el paradero de los presentes para desenmascarar al culpable.
- **Zonas:** Sala de Cartografía (6 celdas), Laboratorio Óptico (2 celdas), Cúpula Central (5 celdas), Terraza Este (3 celdas)
- **Objetos:** Lámpara en (0,2), Armario en (3,3), Silla en (3,1)
- **Pista General:** Ninguna (0 redundancia: resuelto puramente por descarte Murdoku)
- **Tarjetas de Declaración:**
  * [suspect_pedro]: Pedro estaba inmediatamente al norte de la Silla.
  * [suspect_carlos]: Carlos se encontraba en el Cúpula Central, estaba al oeste de la Lámpara.
  * [suspect_diego]: Diego se encontraba en la Sala de Cartografía, estaba en la misma columna que el Armario.
  * [VÍCTIMA]: La víctima. Estaba a solas con el asesino.
- **Traza Deductiva del Simulador (3 pasos):**
  Paso 1: suspect_pedro (13 -> 1) [Tarjeta de Pista: Pedro estaba inmediatamente al norte de la Silla.]
  Paso 2: suspect_carlos (13 -> 3) [Tarjeta de Pista: Carlos se encontraba en el Cúpula Central, estaba al oeste de la Lámpara.]
  Paso 3: suspect_diego (13 -> 2) [Tarjeta de Pista: Diego se encontraba en la Sala de Cartografía, estaba en la misma columna que el Armario.]
  Paso 4: victim (13 -> 12) [Regla de Asesinato: La víctima debe estar en una zona con al menos un sospechoso (el asesino)]
  Paso 5: suspect_diego (2 -> 1) [Exclusión Murdoku por posición fijada de suspect_pedro en (2, 1)]
  Paso 6: suspect_carlos (3 -> 1) [Exclusión Murdoku por posición fijada de suspect_pedro en (2, 1)]
  Paso 7: victim (12 -> 6) [Exclusión Murdoku por posición fijada de suspect_pedro en (2, 1)]
  Paso 8: victim (6 -> 3) [Exclusión de fila 1 porque suspect_diego está forzada en esa fila]
  Paso 9: victim (3 -> 2) [Exclusión de columna 3 porque suspect_diego está forzada en esa columna]
  Paso 10: victim (2 -> 1) [Exclusión de fila 0 porque suspect_carlos está forzada en esa fila]
- **Asesino Real:** suspect_diego | **Deducido:** suspect_diego | **Match:** true

**Resumen Nivel medium:**
- Casos aceptados: 100 / 100
- Intentos requeridos: 110 (Promedio 1.1 intentos/caso)
- Casos resueltos SIN regla global: 100 (100.0%)
- Casos con Pista General de clausura: 0 (0.0%)
- Promedio tarjetas de pistas: 4.00
- Promedio pasos deductivos: 3.03

## NIVEL: HARD (100 Casos Objetivos)
Configuración: 5x5 | 5 Sospechosos | 4 Objetos

### Ejemplo Completo Deducible — Caso #case_400000_1
- **Título:** El Enigma de la Gran Galería
- **Descripción:** Varios visitantes recorrían las salas de exhibición cuando ocurrió el incidente. Deduce sus posiciones mediante las pistas recopiladas.
- **Zonas:** Sala Egipcia (9 celdas), Patio de Esculturas (1 celdas), Bóveda de Reliquias (1 celdas), Pabellón Renacentista (3 celdas), Taller de Restauración (11 celdas)
- **Objetos:** Lámpara en (3,2), Silla en (2,4), Mesa en (4,3), Caja en (0,0)
- **Pista General:** Ninguna (0 redundancia: resuelto puramente por descarte Murdoku)
- **Tarjetas de Declaración:**
  * [suspect_pedro]: Pedro estaba en la misma columna que la Mesa, y estaba en la misma fila que la Caja.
  * [suspect_juan]: Juan estaba inmediatamente al sur de la Lámpara.
  * [suspect_lucia]: Lucía estaba en la misma fila que la Silla, y estaba al este de la Caja.
  * [suspect_sofia]: Sofía estaba inmediatamente al sur de la Silla.
  * [VÍCTIMA]: La víctima. Estaba a solas con el asesino.
- **Traza Deductiva del Simulador (3 pasos):**
  Paso 1: suspect_pedro (21 -> 1) [Tarjeta de Pista: Pedro estaba en la misma columna que la Mesa, y estaba en la misma fila que la Caja.]
  Paso 2: suspect_juan (21 -> 1) [Tarjeta de Pista: Juan estaba inmediatamente al sur de la Lámpara.]
  Paso 3: suspect_lucia (21 -> 3) [Tarjeta de Pista: Lucía estaba en la misma fila que la Silla, y estaba al este de la Caja.]
  Paso 4: suspect_sofia (21 -> 1) [Tarjeta de Pista: Sofía estaba inmediatamente al sur de la Silla.]
  Paso 5: victim (21 -> 12) [Regla de Asesinato: Zona z4 tiene 3 sospechosos fijados (máximo 1)]
  Paso 6: victim (12 -> 8) [Regla de Asesinato: La víctima debe estar en una zona con al menos un sospechoso (el asesino)]
  Paso 7: suspect_lucia (3 -> 2) [Exclusión Murdoku por posición fijada de suspect_juan en (4, 2)]
  Paso 8: victim (8 -> 5) [Exclusión Murdoku por posición fijada de suspect_juan en (4, 2)]
  Paso 9: suspect_lucia (2 -> 1) [Exclusión Murdoku por posición fijada de suspect_pedro en (0, 3)]
  Paso 10: victim (5 -> 4) [Exclusión Murdoku por posición fijada de suspect_pedro en (0, 3)]
  Paso 11: victim (4 -> 2) [Exclusión de fila 2 porque suspect_lucia está forzada en esa fila]
  Paso 12: victim (2 -> 1) [Exclusión de columna 1 porque suspect_lucia está forzada en esa columna]
- **Asesino Real:** suspect_lucia | **Deducido:** suspect_lucia | **Match:** true

**Resumen Nivel hard:**
- Casos aceptados: 100 / 100
- Intentos requeridos: 130 (Promedio 1.3 intentos/caso)
- Casos resueltos SIN regla global: 100 (100.0%)
- Casos con Pista General de clausura: 0 (0.0%)
- Promedio tarjetas de pistas: 5.00
- Promedio pasos deductivos: 3.04

## ESTADÍSTICAS GLOBALES DE CLAUSURA (300 CASOS)
- **Total Casos Aceptados:** 300 / 300 (100.0%)
- **Total Intentos Utilizados:** 641
- **Tasa de Rechazo Interno Preventivo:** 341 intentos descartados preventivamente
- **Casos cerrados 100% por Murdoku (Sin Pista General):** 258 (86.0%)
- **Casos que requirieron Operador de Clausura Global:** 42 (14.0%)
- **Reducción promedio de candidatos lograda por la Pista General:** 1.24 celdas
- **Promedio Global de Tarjetas:** 4.00 por caso
- **Promedio Global de Pasos Deductivos:** 3.02 pasos
- **Unicidad Matemática CSP:** 100%
- **Deducción Humana Determinista (0 guessing):** 100%
- **Agotamiento Espacial de la Víctima (0 pistas directas):** 100%
- **Identificación Inequívoca del Asesino al Final:** 100%

### Desglose de Reglas Globales de Clausura Utilizadas:
- **singleOccupantZone:** 42 veces (100.0% de los casos con regla)

