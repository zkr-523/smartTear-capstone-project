import 'package:collection/collection.dart';

import '../../domain/entities/reading.dart';
import '../../domain/reference/analyte_reference_ranges.dart';

/// Short but readable — complete sentences with real numbers.
const int kChatMaxSentences = 3;
const int kChatMaxChars = 400;

final RegExp _brokenReplyPattern = RegExp(
  r'\bis\s+\.|'
  r'\bis\s+\*\*\s*\.|'
  r'\bare\s+\.|'
  r'\breading is\s+\.|'
  r'\bglucose is\s+\.|'
  r'\bTG is\s+\.|'
  r'\$1',
  caseSensitive: false,
);

bool chatReplyLooksBroken(String text) {
  final t = text.trim();
  if (t.isEmpty) return true;
  if (_brokenReplyPattern.hasMatch(t)) return true;
  if (t.contains('**') || t.contains('##')) return true;
  // Ends mid-word / no terminal punctuation on a long fragment
  if (t.length > 40 &&
      !t.endsWith('.') &&
      !t.endsWith('?') &&
      !t.endsWith('!') &&
      !t.endsWith('…')) {
    return true;
  }
  return false;
}

String _stripBoldMarkdown(String text) {
  return text.replaceAllMapped(
    RegExp(r'\*\*(.+?)\*\*'),
    (m) => m.group(1) ?? '',
  );
}

String _stripItalicMarkdown(String text) {
  return text.replaceAllMapped(
    RegExp(r'(?<!\*)\*(?!\*)(.+?)(?<!\*)\*(?!\*)'),
    (m) => m.group(1) ?? '',
  );
}

String cleanResponse(String text) {
  var result = text;
  result = _stripBoldMarkdown(result);
  result = _stripItalicMarkdown(result);
  result = result.replaceAll(RegExp(r'#{1,6}\s+'), '');
  result = result.replaceAll(RegExp(r'^\s*[-•*]\s+', multiLine: true), '');
  result = result.replaceAll(RegExp(r'^\s*\d+\.\s+', multiLine: true), '');
  result = result.replaceAll(RegExp(r'\n{3,}'), '\n\n');
  return result.trim();
}

/// Split on sentence boundaries, not decimal points (e.g. 0.9).
List<String> splitChatSentences(String text) {
  final parts = text.split(RegExp(r'(?<=[.!?])(?<!\d)\s+'));
  return parts.map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
}

String enforceShortResponse(
  String text, {
  int maxSentences = kChatMaxSentences,
  int maxChars = kChatMaxChars,
}) {
  text = cleanResponse(text);
  text = text.replaceAll(RegExp(r'\s+'), ' ').trim();

  final sentences = splitChatSentences(text);
  var out = sentences.length <= maxSentences
      ? sentences.join(' ')
      : sentences.take(maxSentences).join(' ');

  if (out.length <= maxChars) return _ensureTerminalPunctuation(out);

  // Prefer full sentences under the cap
  final kept = <String>[];
  for (final s in sentences) {
    final next = kept.isEmpty ? s : '${kept.join(' ')} $s';
    if (next.length > maxChars) break;
    kept.add(s);
  }
  if (kept.isNotEmpty) {
    return _ensureTerminalPunctuation(kept.join(' '));
  }

  // Last resort: word boundary trim (never mid-number if possible)
  out = out.substring(0, maxChars).trim();
  final lastSpace = out.lastIndexOf(' ');
  if (lastSpace > maxChars ~/ 2) {
    out = out.substring(0, lastSpace).trim();
  }
  return _ensureTerminalPunctuation(out);
}

String _ensureTerminalPunctuation(String text) {
  if (text.isEmpty) return text;
  if (text.endsWith('.') || text.endsWith('?') || text.endsWith('!')) {
    return text;
  }
  return '$text.';
}

String _fmt(double v) => v.abs() >= 10 ? v.toStringAsFixed(0) : v.toStringAsFixed(1);

String _bandLabel(double v, double min, double max) {
  if (v < min) return 'low';
  if (v > max) return 'high';
  return 'normal';
}

/// Grounded reply when the model output was truncated or empty.
String? localReadingFallback(String message, Reading? reading) {
  if (reading == null) return null;
  final q = message.toLowerCase();

  final tg = reading.glucose;
  if (tg == null && reading.analytes.isEmpty) {
    return null;
  }

  double? v(String code) =>
      reading.analytes.where((a) => a.analyteCode == code).firstOrNull?.value;

  final tgVal = tg?.value ?? v('TG');
  final na = v('Na');
  final k = v('K');
  final cl = v('Cl');
  final chol = v('Chol');
  final estBg = tg?.estimatedBG;

  if (q.contains('most affected') ||
      q.contains('which analyte') ||
      q.contains('biggest issue') ||
      q.contains('stand out')) {
    final flags = <String>[];
    if (tgVal != null) {
      final b = _bandLabel(
        tgVal,
        AnalyteReferenceRanges.tearGlucoseMinMmolL,
        AnalyteReferenceRanges.tearGlucoseMaxMmolL,
      );
      if (b != 'normal') {
        flags.add('tear glucose (TG) ${_fmt(tgVal)} mmol/L ($b)');
      }
    }
    if (na != null) {
      final b = _bandLabel(
        na,
        AnalyteReferenceRanges.sodiumMin,
        AnalyteReferenceRanges.sodiumMax,
      );
      if (b != 'normal') flags.add('sodium ${_fmt(na)} mEq/L ($b)');
    }
    if (chol != null) {
      final b = _bandLabel(
        chol,
        AnalyteReferenceRanges.cholesterolMinMmolL,
        AnalyteReferenceRanges.cholesterolMaxMmolL,
      );
      if (b != 'normal') flags.add('cholesterol ${_fmt(chol)} mmol/L ($b)');
    }
    if (flags.isEmpty && tgVal != null) {
      return 'For this reading, tear glucose (TG) at ${_fmt(tgVal)} mmol/L is in the usual band (about ${AnalyteReferenceRanges.tearGlucoseRangeLabel()} mmol/L). Nothing else looks clearly off — want me to walk through Na or Chol?';
    }
    if (flags.isNotEmpty) {
      final top = flags.first;
      return 'The clearest flag is $top. TG normal is about ${AnalyteReferenceRanges.tearGlucoseRangeLabel()} mmol/L. Want tips for a cleaner retake?';
    }
  }

  if (q.contains('tg') ||
      q.contains('tear glucose') ||
      q.contains('glucose')) {
    if (tgVal != null) {
      final b = _bandLabel(
        tgVal,
        AnalyteReferenceRanges.tearGlucoseMinMmolL,
        AnalyteReferenceRanges.tearGlucoseMaxMmolL,
      );
      return 'Tear glucose (TG) is ${_fmt(tgVal)} mmol/L — that is $b for this app (normal about ${AnalyteReferenceRanges.tearGlucoseRangeLabel()}).';
    }
  }

  if (q.contains('est') && q.contains('bg') && estBg != null) {
    final mg = (estBg * 18).round();
    return 'Estimated blood glucose is ${_fmt(estBg)} mmol/L (about $mg mg/dL) from your TG using our Park-trained model. That is an estimate, not a lab draw.';
  }

  if ((q.contains('invalid') || q.contains('why')) &&
      (reading.invalidReason ?? '').isNotEmpty) {
    final reason = reading.invalidReason!;
    return 'This reading was marked invalid: $reason Try a longer contact (about 1–2 seconds) and a full tear sample, then retake.';
  }

  if (q.contains('summar') ||
      q.contains('explain') ||
      q.contains('this reading') ||
      q.contains('what does this mean') ||
      q.contains('need a doctor') ||
      q.contains('doctor')) {
    return _formatFullReadingSummary(reading, tgVal, na, k, cl, chol, estBg);
  }

  if (q.contains('biomarker') ||
      q.contains('measurement') ||
      q.contains('musur') ||
      q.contains('full reading') ||
      q.contains('all analyte') ||
      q.contains('all reding') ||
      q.contains('all reading')) {
    return _formatFullReadingSummary(reading, tgVal, na, k, cl, chol, estBg);
  }

  return null;
}

String _formatFullReadingSummary(
  Reading reading,
  double? tgVal,
  double? na,
  double? k,
  double? cl,
  double? chol,
  double? estBg,
) {
  final parts = <String>[];
  if (tgVal != null) {
    final b = _bandLabel(
      tgVal,
      AnalyteReferenceRanges.tearGlucoseMinMmolL,
      AnalyteReferenceRanges.tearGlucoseMaxMmolL,
    );
    parts.add('TG ${_fmt(tgVal)} mmol/L ($b)');
  }
  if (na != null) parts.add('Na ${_fmt(na)} mEq/L');
  if (k != null) parts.add('K ${_fmt(k)} mEq/L');
  if (cl != null) parts.add('Cl ${_fmt(cl)} mEq/L');
  if (chol != null) parts.add('Chol ${_fmt(chol)} mmol/L');
  final status = reading.isValid ? 'Valid' : 'Invalid';
  final line = parts.isEmpty ? 'no analyte values stored' : parts.join(', ');
  final contact = reading.contactDurationMs;
  final contactBit = contact != null ? ' Contact ${contact}ms.' : '';
  final estBit =
      estBg != null ? ' Est. BG ${_fmt(estBg)} mmol/L (${(estBg * 18).round()} mg/dL).' : '';
  return 'This reading is $status: $line.$contactBit$estBit Not a diagnosis — ask about any one value for more detail.';
}
