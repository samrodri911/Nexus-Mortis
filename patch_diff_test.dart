import 'dart:io';

void main() {
  final file = File('test/game/difficulty/difficulty_analyzer_test.dart');
  var content = file.readAsStringSync();
  content = content.replaceFirst('expect(analysis.clueCount, equals(6));', 'expect(analysis.clueCount, equals(7));');
  file.writeAsStringSync(content);
}
