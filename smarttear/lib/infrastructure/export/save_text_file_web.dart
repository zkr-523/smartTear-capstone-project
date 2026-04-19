// Browser download via Blob + anchor; only compiled for web (see save_text_file.dart).
// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:convert';
import 'dart:html' as html;

Future<String?> saveTextFileImpl({
  required String fileName,
  required String contents,
}) async {
  try {
    final bytes = utf8.encode(contents);
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', fileName)
      ..style.display = 'none';
    html.document.body!.children.add(anchor);
    anchor.click();
    anchor.remove();
    html.Url.revokeObjectUrl(url);
    return null;
  } catch (e) {
    return 'Could not download: $e';
  }
}
