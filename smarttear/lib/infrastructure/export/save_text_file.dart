import 'save_text_file_stub.dart'
    if (dart.library.html) 'save_text_file_web.dart'
    if (dart.library.io) 'save_text_file_io.dart' as impl;

Future<String?> saveTextFile({
  required String fileName,
  required String contents,
}) =>
    impl.saveTextFileImpl(fileName: fileName, contents: contents);
