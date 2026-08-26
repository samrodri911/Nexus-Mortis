import 'dart:io';

void main() {
  final files = [
    'lib/features/case_selection/case_selection_page.dart',
    'test/features/case_selection/case_selection_page_test.dart'
  ];

  for (final path in files) {
    final file = File(path);
    if (!file.existsSync()) continue;
    var content = file.readAsStringSync();
    
    // Replace the corrupted string
    content = content.replaceAll(RegExp(r'Tienes una investigaci.*n en curso'), 'Tienes una investigación en curso');
    content = content.replaceAll(RegExp(r'Investigaci.*n Infinita'), 'Investigación Infinita');
    
    file.writeAsStringSync(content);
    print('Fixed $path');
  }
}
