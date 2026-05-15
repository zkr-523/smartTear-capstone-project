import 'package:collection/collection.dart';
import 'package:dio/dio.dart';

import '../../domain/entities/conversation_turn.dart';
import '../../domain/entities/reading.dart';
import 'chat_response_processor.dart';

export 'chat_response_processor.dart' show cleanResponse, enforceShortResponse;

enum NavigationCommand { openHistory, openTrends }

class AssistantResponse {
  const AssistantResponse({
    required this.text,
    this.navigationCommand,
  });

  final String text;
  final NavigationCommand? navigationCommand;
}

/// Sent to Replit /chat — must stay aligned with server length limits.
const String _chatBehaviorSystemPromptAddendum = '''
You are ZKR in SmartTear. Reply in 2–3 complete sentences (under 400 characters).
Every answer must name the analyte and give the actual number with units (e.g. TG 0.9 mmol/L).
Never leave a blank after "is" or "are" — if you mention a value, write the full value.
Be direct and human, like texting a knowledgeable friend.
Use TG, Na, K, Cl, Chol and QC from the reading. Use conversation history for follow-ups.
No markdown, bullets, or "As an AI". Not a diagnosis.''';

class ChatAssistantService {
  ChatAssistantService({
    Dio? dio,
    String baseUrl = 'https://smart-tear-simulation--zkrST.replit.app',
  }) : _dio = dio ??
            Dio(
              BaseOptions(
                connectTimeout: const Duration(seconds: 20),
                receiveTimeout: const Duration(seconds: 25),
                sendTimeout: const Duration(seconds: 20),
              ),
            ),
        _baseUrl = baseUrl;

  final Dio _dio;
  final String _baseUrl;

  Future<AssistantResponse> respond(
    String message,
    Reading? currentReading,
    List<Reading> recentReadings,
    List<ConversationTurn> conversationHistory,
  ) async {
    final lower = message.toLowerCase();
    if (lower.contains('open history')) {
      return const AssistantResponse(
        text: 'Opening your reading history.',
        navigationCommand: NavigationCommand.openHistory,
      );
    }
    if (lower.contains('open trends')) {
      return const AssistantResponse(
        text: 'Opening your trends.',
        navigationCommand: NavigationCommand.openTrends,
      );
    }

    final turns = _historyTurnsPayload(message, conversationHistory);
    final body = <String, dynamic>{
      'message': message,
      'systemPrompt': _chatBehaviorSystemPromptAddendum,
      'currentReading': currentReading == null ? null : _readingPayload(currentReading),
      'history': _historyPayload(recentReadings),
      if (turns.isNotEmpty) 'conversationHistory': turns,
    };

    try {
      final resp = await _dio.post<Object>(
        '$_baseUrl/chat',
        data: body,
      );

      final data = resp.data;
      final Map<String, dynamic> map = switch (data) {
        final Map<String, dynamic> m => m,
        final Map m => Map<String, dynamic>.from(m),
        _ => throw StateError('Unexpected response shape from /chat'),
      };

      final text = map['response'];
      if (text is! String || text.trim().isEmpty) {
        throw StateError('Missing "response" field');
      }

      return AssistantResponse(
        text: _finalizeReply(message, currentReading, text),
      );
    } on DioException {
      final fallback = localReadingFallback(message, currentReading);
      if (fallback != null) {
        return AssistantResponse(text: fallback);
      }
      return const AssistantResponse(
        text: 'Having trouble connecting right now. Please try again.',
      );
    } catch (_) {
      final fallback = localReadingFallback(message, currentReading);
      if (fallback != null) {
        return AssistantResponse(text: fallback);
      }
      return const AssistantResponse(
        text: 'Having trouble connecting right now. Please try again.',
      );
    }
  }

  String _finalizeReply(String message, Reading? reading, String raw) {
    final cleaned = cleanResponse(raw);
    var out = enforceShortResponse(cleaned);
    if (chatReplyLooksBroken(out)) {
      final local = localReadingFallback(message, reading);
      if (local != null) {
        out = local;
      }
    }
    return out;
  }

  Map<String, dynamic> _readingPayload(Reading r) {
    final analytes = r.analytes
        .where((a) {
          final v = a.value;
          if (v.isNaN || v.isInfinite) return false;
          return true;
        })
        .map(
          (a) => <String, dynamic>{
            'code': a.analyteCode,
            'value': a.value.toDouble(),
            'unit': a.unit,
            if (a.estimatedBG != null) 'estimatedBG': a.estimatedBG,
          },
        )
        .toList(growable: false);

    return <String, dynamic>{
      'readingId': r.id ?? 0,
      'takenAt': r.takenAt.toIso8601String(),
      'qcStatus': r.qcStatus.name,
      'invalidReason': r.invalidReason,
      'analytes': analytes,
      'contactDurationMs': r.contactDurationMs,
    };
  }

  Map<String, dynamic> _historyPayload(List<Reading> recentReadings) {
    final valid = recentReadings.where((r) => r.isValid).toList(growable: false);

    double? avgGlucose;
    if (valid.isNotEmpty) {
      final values = <double>[];
      for (final r in valid) {
        final g = r.glucose;
        if (g != null) values.add(g.value);
      }
      if (values.isNotEmpty) {
        avgGlucose = values.reduce((a, b) => a + b) / values.length;
      }
    }

    final lastReadingAt = recentReadings.isNotEmpty
        ? recentReadings.first.takenAt.toIso8601String()
        : null;

    return <String, dynamic>{
      'totalReadings': recentReadings.length,
      'validReadings': valid.length,
      'avgGlucose': avgGlucose,
      'lastReadingAt': lastReadingAt,
    };
  }

  List<Map<String, dynamic>> _historyTurnsPayload(
    String currentMessage,
    List<ConversationTurn> history,
  ) {
    final trimmedCurrent = currentMessage.trim();
    var turns = List<ConversationTurn>.from(history);

    if (turns.isNotEmpty) {
      final last = turns.last;
      if (last.role.toLowerCase().trim() == 'user' &&
          last.content.trim() == trimmedCurrent) {
        turns = turns.sublist(0, turns.length - 1);
      }
    }

    final last6 =
        turns.length <= 6 ? turns : turns.sublist(turns.length - 6);

    final out = <Map<String, dynamic>>[];
    for (final t in last6) {
      final role = _apiChatRole(t.role);
      final plain = cleanResponse(t.content);
      if (plain.isEmpty) continue;
      out.add(<String, dynamic>{'role': role, 'content': plain});
    }
    return out;
  }

  static String _apiChatRole(String role) {
    final r = role.toLowerCase().trim();
    if (r == 'user') return 'user';
    return 'model';
  }
}
