import sys

with open("test/game/hints/hint_economy_service_test.dart", "r", encoding="utf-8") as f:
    content = f.read()

old = "validationService = ValidationService(puzzleSolver: PuzzleSolver());"
new = "validationService = ValidationService(caseData: dummyCase, clueEvaluator: const ClueEvaluator(SpatialClueEvaluator()));"
content = content.replace(old, new)

with open("test/game/hints/hint_economy_service_test.dart", "w", encoding="utf-8") as f:
    f.write(content)
print("Done")
