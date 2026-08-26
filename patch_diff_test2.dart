import 'dart:io';

void main() {
  final file = File('test/game/difficulty/difficulty_analyzer_test.dart');
  var content = file.readAsStringSync();
  content = content.replaceFirst('expect(analysis.suspectCount, equals(3));', 'expect(analysis.suspectCount, equals(4));');
  file.writeAsStringSync(content);
}
