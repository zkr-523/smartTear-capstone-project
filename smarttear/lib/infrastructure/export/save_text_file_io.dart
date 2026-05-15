import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

Future<String?> saveTextFileImpl({
  required String fileName,
  required String contents,
}) async {
  try {
    Directory? dir = await getDownloadsDirectory();
    dir ??= await getApplicationDocumentsDirectory();
    final path = p.join(dir.path, fileName);
    final file = File(path);
    await file.writeAsString(contents);
    return null;
  } catch (e) {
    return 'Could not save file: $e';
  }
}
