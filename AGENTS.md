# AGENTS.md

# Nexus Mortis — Guía Oficial para Agentes de IA

## Propósito del Documento

Este documento define la arquitectura, filosofía, reglas de desarrollo, estándares de código y lineamientos generales del proyecto Nexus Mortis.

Todo agente de IA que participe en el desarrollo debe seguir estas instrucciones antes de generar, modificar o refactorizar código.

Las decisiones aquí descritas tienen prioridad sobre convenciones genéricas o preferencias automáticas del agente.

---

# Descripción del Proyecto

Nexus Mortis es un videojuego de deducción lógica inspirado en juegos tipo Murdoku.

El jugador deberá resolver casos utilizando pistas para deducir relaciones entre diferentes entidades de una investigación.

La experiencia debe sentirse como una mesa de detective moderna e interactiva, enfocada en el razonamiento lógico, la observación y la deducción.

El objetivo principal es ofrecer una experiencia inmersiva, elegante y altamente pulida.

Inspiraciones visuales y de experiencia:

* Ace Attorney
* Professor Layton
* The Room
* Return of the Obra Dinn

---

# Filosofía General

El proyecto debe priorizar:

* UX premium
* Gameplay fluido
* Diseño elegante
* Arquitectura limpia
* Mantenibilidad
* Escalabilidad
* Rendimiento
* Simplicidad
* Offline-first

El proyecto NO debe sobrearquitecturarse.

La solución más simple que cumpla correctamente el objetivo será preferida sobre implementaciones complejas innecesarias.

---

# Stack Tecnológico Oficial

## Frontend

Flutter

Responsable de:

* Navegación
* Pantallas
* Menús
* Configuración
* Overlays
* Estadísticas
* Tutoriales
* UI general
* Responsive layouts

---

## Gameplay

Flame Engine

Responsable de:

* Tablero principal
* Interacción táctil
* Componentes visuales interactivos
* Drag & Drop
* Feedback visual
* Efectos de gameplay
* Animaciones del tablero
* Loop principal del juego

Todo el gameplay interactivo debe vivir en Flame.

---

## Persistencia Local

Isar Database

Responsable de:

* Progreso
* Configuraciones
* Casos completados
* Estadísticas
* Desbloqueos
* Achievements
* Guardado de partidas

---

## Audio

Just Audio

Responsable de:

* Música
* Sonidos
* Ambientes
* Feedback auditivo

---

## Animaciones Avanzadas (Opcional)

Rive

Utilizar únicamente cuando aporte valor visual significativo.

No incorporar Rive de forma prematura.

---

# Filosofía Offline-First

La aplicación debe funcionar completamente sin conexión a internet.

Todo el contenido principal debe estar disponible localmente.

Debe ser posible:

* Iniciar el juego
* Resolver puzzles
* Guardar progreso
* Consultar estadísticas
* Modificar configuraciones
* Desbloquear contenido

Sin conexión.

---

# Restricciones de Arquitectura

Actualmente NO implementar:

* Backend
* APIs externas obligatorias
* Firebase
* Supabase
* Autenticación
* Login
* Cloud Save
* Multiplayer
* Sincronización remota
* Microservicios
* Comunicación con servidores

Internet será considerado únicamente como una expansión futura opcional.

La arquitectura actual NO debe depender de servicios externos.

---

# Estructura Oficial del Proyecto

```text
lib/

core/
│
├── constants/
├── theme/
├── services/
└── utils/

features/
│
├── home/
├── settings/
├── statistics/
└── tutorial/

game/
│
├── nexus_game.dart
│
├── board/
│   ├── models/
│   ├── controllers/
│   └── components/
│
├── clues/
│   ├── models/
│   └── systems/
│
├── systems/
│
└── components/

data/
│
├── datasources/
├── repositories/
└── models/

main.dart
```

---

# Responsabilidades por Carpeta

## core/

Contiene elementos reutilizables globales.

Ejemplos:

* Constantes
* Helpers
* Temas
* Utilidades
* Servicios compartidos

No debe contener lógica específica del gameplay.

---

## features/

Contiene pantallas de Flutter.

Ejemplos:

* Menú principal
* Configuración
* Estadísticas
* Tutoriales

No debe contener lógica interna del tablero.

---

## game/

Contiene toda la lógica del gameplay.

Ejemplos:

* Tablero
* Componentes interactivos
* Sistemas de validación
* Pistas
* Componentes Flame

Es el núcleo principal del juego.

---

## data/

Contiene persistencia local.

Ejemplos:

* Modelos de base de datos
* Repositorios
* Datasources
* Mapeadores

---

# Separación Obligatoria entre Flutter y Flame

Flutter y Flame tienen responsabilidades diferentes.

Flutter debe manejar:

* Pantallas
* Menús
* Navegación
* Configuración
* Estadísticas

Flame debe manejar:

* Tablero
* Gameplay
* Input táctil
* Componentes interactivos
* Lógica visual del juego

No mezclar responsabilidades.

---

# Principios de Código

Todo el código generado debe seguir:

* Clean Code
* KISS (Keep It Simple)
* DRY (Don't Repeat Yourself)
* SOLID cuando aporte valor real
* Composición sobre herencia
* Alta cohesión
* Bajo acoplamiento

Priorizar legibilidad sobre complejidad.

El código debe ser fácil de entender por otro desarrollador.

---

# Reglas de Generación de Código

Cuando generes código:

* Explica decisiones importantes.
* No agregues dependencias innecesarias.
* No implementes patrones complejos sin necesidad.
* No agregues abstracciones prematuras.
* No crear servicios vacíos.
* No crear interfaces sin uso real.
* No generar código muerto.
* No generar archivos de relleno.

Cada archivo debe tener una responsabilidad clara.

---

# Tamaño de Archivos

Como regla general:

* Preferir archivos pequeños.
* Preferir widgets pequeños.
* Preferir componentes pequeños.

Evitar archivos excesivamente largos.

Si un archivo supera aproximadamente 300 líneas, evaluar dividir responsabilidades.

---

# Convenciones de Nombres

## Archivos

Usar:

```text
snake_case.dart
```

Ejemplos:

```text
board_component.dart
cell_model.dart
game_controller.dart
```

---

## Clases

Usar:

```text
PascalCase
```

Ejemplos:

```dart
BoardComponent
CellData
GameController
```

---

## Variables

Usar:

```dart
camelCase
```

Ejemplos:

```dart
selectedCell
boardSize
currentCase
```

---

## Métodos

Usar:

```dart
camelCase
```

Ejemplos:

```dart
loadPuzzle()
validateBoard()
selectCell()
```

---

# Gestión del Estado

Por el momento:

Mantener el estado simple.

Evitar introducir soluciones complejas de gestión de estado prematuramente.

Antes de incorporar herramientas adicionales, justificar claramente su necesidad.

---

# Estrategia de Desarrollo

Implementar siempre de forma incremental.

Primero:

* Funcionalidad

Luego:

* Estabilidad

Luego:

* Optimización

Finalmente:

* Pulido visual

Nunca optimizar antes de que la funcionalidad exista.

---

# Roadmap Oficial

## Fase 1

Construir el núcleo del juego.

Objetivos:

* NexusGame
* BoardComponent
* Sistema de selección
* Sistema de pistas
* Sistema de reglas
* Resolver un caso completo

---

## Fase 2

Persistencia local.

Objetivos:

* Integrar Isar
* Guardar progreso
* Guardar configuraciones
* Guardar estadísticas

---

## Fase 3

UI completa.

Objetivos:

* Menú principal
* Selección de casos
* Configuración
* Estadísticas
* Tutorial

---

## Fase 4

Pulido.

Objetivos:

* Audio
* Animaciones
* Efectos visuales
* Feedback avanzado

---

# Estado Actual del Proyecto

Fase actual:

Fase 1 — Construcción del núcleo del gameplay.

Completado:

* Proyecto Flutter creado
* Dependencias instaladas
* Estructura de carpetas creada

Pendiente:

* NexusGame
* BoardComponent
* Sistema de interacción
* Sistema de pistas
* Sistema de reglas
* Primer caso jugable

---

# Objetivo Principal

La prioridad absoluta es crear una experiencia de deducción lógica elegante, fluida e inmersiva.

Todas las decisiones técnicas deben favorecer:

* Simplicidad
* Rendimiento
* Escalabilidad
* Mantenibilidad
* Calidad de experiencia del jugador

Evitar sobreingeniería.

Construir primero el juego.

Optimizar después.
