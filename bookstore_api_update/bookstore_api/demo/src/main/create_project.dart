
import 'dart:io';

Future<void> main() async {
  // Thư mục gốc của dự án
  final projectDir = Directory('store-api');

  // Danh sách thư mục cần tạo
  final directories = [
    '.mvn/wrapper',
    'src/main/java/com/example/store',
    'src/main/resources',
    'src/test/java/com/example/store',
  ];

  // Tạo các thư mục
  for (final path in directories) {
    final directory = Directory('${projectDir.path}/$path');

    await directory.create(recursive: true);

    print('Created directory: ${directory.path}');
  }

  

    // Tạo thư mục cha nếu cần
    
  }

 // print('\nProject created at: ${projectDir.absolute.path}');

