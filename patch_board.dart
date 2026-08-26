import 'dart:io';

void main() {
  final file = File('lib/game/board/components/board_component.dart');
  var content = file.readAsStringSync();
  
  content = "import 'package:nexus_mortis/game/board/components/zone_border_component.dart';\n" + content;
  
  content = content.replaceFirst(
'''      }
    }
  }''',
'''      }
    }

    // Agregar el componente de bordes de zona que se dibujará SOBRE las celdas
    await add(ZoneBorderComponent(
      controller: controller,
      size: boardSize,
    ));
  }'''
  );

  file.writeAsStringSync(content);
}
