import sys

with open("test/game/hints/hint_economy_service_test.dart", "r", encoding="utf-8") as f:
    lines = f.readlines()

new_lines = []
skip = False
for line in lines:
    if "validationService = ValidationService(" in line:
        new_lines.append("      validationService = ValidationService(solver: PuzzleSolver());\n")
        skip = True
    elif skip and ");" in line:
        skip = False
    elif not skip:
        new_lines.append(line)

content = "".join(new_lines)
if "puzzle_solver.dart" not in content:
    content = "import 'package:nexus_mortis/game/solver/puzzle_solver.dart';\n" + content

with open("test/game/hints/hint_economy_service_test.dart", "w", encoding="utf-8") as f:
    f.write(content)
print("Done")
