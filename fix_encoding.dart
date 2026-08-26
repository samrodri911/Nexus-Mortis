import 'dart:io';

void main() {
  final file = File('lib/features/case_selection/case_selection_page.dart');
  var content = file.readAsStringSync();
  content = content.replaceAll('Tienes una investigacin en curso', 'Tienes una investigación en curso');
  content = content.replaceAll('Investigacin Infinita', 'Investigación Infinita');
  content = content.replaceAll('EXPEDIENTES', 'EXPEDIENTES'); // was already correct
  file.writeAsStringSync(content);
}
