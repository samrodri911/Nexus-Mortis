import sys

with open("test/game/hints/hint_economy_service_test.dart", "r", encoding="utf-8") as f:
    content = f.read()

content = content.replace("solver: PuzzleSolver()", "puzzleSolver: PuzzleSolver()")

with open("test/game/hints/hint_economy_service_test.dart", "w", encoding="utf-8") as f:
    f.write(content)
print("Done")
