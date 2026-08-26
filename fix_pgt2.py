import sys

with open("test/game/generator/puzzle_generator_test.dart", "r", encoding="utf-8") as f:
    content = f.read()

# Replace first call
old_call_1 = """      final result = generator.generateSolution(
        rows: 2,
        columns: 2,
        suspects: suspects,
        objects: objects,
        victimId: 'dummy_victim',
        killerId: suspects.first.id,
        zones: const [
          ZoneData(id: 'z1', name: 'Z1', cells: [CellPosition(0,0), CellPosition(1,1)]),
          ZoneData(id: 'z2', name: 'Z2', cells: [CellPosition(0,1), CellPosition(1,0)]),
        ],
      );"""

new_call_1 = """      final result = generator.generateSolution(
        rows: 2,
        columns: 2,
        suspects: suspects,
        objects: objects,
        victimId: suspects[1].id,
        killerId: suspects.first.id,
        zones: const [
          ZoneData(id: 'z1', name: 'Z1', cells: [CellPosition(0,0), CellPosition(1,1)]),
          ZoneData(id: 'z2', name: 'Z2', cells: [CellPosition(0,1), CellPosition(1,0)]),
        ],
      );"""

content = content.replace(old_call_1, new_call_1)

# Replace second call
old_call_2 = """        () => generator.generateSolution(
          rows: 2,
          columns: 2, // Solo caben 4 celdas en total
          suspects: suspects,
          objects: objects,
          victimId: 'dummy_victim',
          killerId: suspects.first.id,
          zones: const [
            ZoneData(id: 'z1', name: 'Z1', cells: [CellPosition(0,0), CellPosition(1,1)]),
            ZoneData(id: 'z2', name: 'Z2', cells: [CellPosition(0,1), CellPosition(1,0)]),
          ],
        ),"""

new_call_2 = """        () => generator.generateSolution(
          rows: 2,
          columns: 2, // Solo caben 4 celdas en total
          suspects: suspects,
          objects: objects,
          victimId: suspects[1].id,
          killerId: suspects.first.id,
          zones: const [
            ZoneData(id: 'z1', name: 'Z1', cells: [CellPosition(0,0), CellPosition(1,1)]),
            ZoneData(id: 'z2', name: 'Z2', cells: [CellPosition(0,1), CellPosition(1,0)]),
          ],
        ),"""

content = content.replace(old_call_2, new_call_2)

with open("test/game/generator/puzzle_generator_test.dart", "w", encoding="utf-8") as f:
    f.write(content)
print("Done")
