import 'package:flutter_test/flutter_test.dart';
import 'package:smarttear/infrastructure/assistant/chat_response_processor.dart';

void main() {
  test('splitChatSentences keeps decimal values intact', () {
    final parts = splitChatSentences(
      'Your tear glucose is 0.9 mmol/L. Sodium is 131 mEq/L.',
    );
    expect(parts.length, 2);
    expect(parts[0], contains('0.9'));
    expect(parts[1], contains('131'));
  });

  test('enforceShortResponse does not leave "is ." fragments', () {
    const raw =
        'Based on your reading, the most affected analyte is tear glucose. Your TG is 0.9 mmol/L.';
    final out = enforceShortResponse(raw);
    expect(out, isNot(contains('is .')));
    expect(out, contains('0.9'));
  });

  test('chatReplyLooksBroken detects empty analyte slot', () {
    expect(chatReplyLooksBroken('Your tear glucose is .'), isTrue);
    expect(
      chatReplyLooksBroken('TG is 0.9 mmol/L, which is high.'),
      isFalse,
    );
    expect(chatReplyLooksBroken(r'$1 $1 Tear Glucose'), isTrue);
  });

  test('cleanResponse preserves numbers instead of dollar-one placeholders', () {
    const raw =
        '**0.9 mmol/L** **Tear Glucose** — reading from **May 15** at **10:26 PM**.';
    final out = cleanResponse(raw);
    expect(out, isNot(contains(r'$1')));
    expect(out, contains('0.9'));
    expect(out, contains('Tear Glucose'));
    expect(out, contains('May 15'));
  });
}
