import 'dart:io';

void main() {
  final file = File('test/game/generator/puzzle_generator_test.dart');
  var content = file.readAsStringSync();
  if (!content.contains("zone_data.dart")) {
    content = "import 'package:nexus_mortis/game/puzzles/models/zone_data.dart';\n" + content;
  }
  if (!content.contains("cell_position.dart")) {
    content = "import 'package:nexus_mortis/game/puzzles/models/cell_position.dart';\n" + content;
  }
  file.writeAsStringSync(content);
}
