import 'dart:developer' as developer;

import 'package:dio/dio.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../../core/constants/api_constants.dart';
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

const String _kFallbackText =
    'I can help with your readings, history, and trends. Try: Explain my result, Show last 3 readings.';

const String _kSystemPrompt =
    'You are ZKR, the SmartTear assistant. In SmartTear, "TG" means tear glucose (not triglycerides); the other analyte codes are Na (sodium), K (potassium), Cl (chloride), and Chol (cholesterol). Be a friendly conversational assistant first and a tear-biomarker specialist second. Answer any question — greetings, the day of the week, small talk, unrelated questions — and gently bring the conversation back to the user\'s tear readings when relevant. Never give a medical diagnosis. Always suggest consulting a doctor for medical concerns. Keep every reply under 3 complete sentences. Use plain text — no markdown, no bullets, no headers. Answer only using the SmartTear knowledge below and the user\'s reading data. If the answer is not covered by either, say you do not have that information in the app. Do not fill gaps from outside knowledge.';

const Map<String, String> _kAnalyteDisplayNames = <String, String>{
  'TG': 'Tear glucose',
  'Na': 'Sodium',
  'K': 'Potassium',
  'Cl': 'Chloride',
  'Chol': 'Cholesterol',
};

const String _kKnowledgeAssetPath = 'assets/chat/knowledge.md';
const String _kKnowledgeDelimiter = '=== SmartTear knowledge ===';

class ChatAssistantService {
  ChatAssistantService({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                connectTimeout: const Duration(seconds: 10),
                receiveTimeout: const Duration(seconds: 10),
                sendTimeout: const Duration(seconds: 10),
              ),
            );

  final Dio _dio;
  String? _knowledge;

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
    if (lower.contains('open trends') ||
        lower.contains('show trends') ||
        lower.contains('show graph')) {
      return const AssistantResponse(
        text: 'Opening your trends.',
        navigationCommand: NavigationCommand.openTrends,
      );
    }

    if (kAnthropicApiKey.isEmpty) {
      return const AssistantResponse(text: _kFallbackText);
    }

    try {
      final knowledge = await _loadKnowledge();
      final readingContext = _buildReadingContext(currentReading, recentReadings);
      final knowledgeBit =
          knowledge.isEmpty ? '' : '\n\n$_kKnowledgeDelimiter\n$knowledge';
      final system = '$_kSystemPrompt\n\n$readingContext$knowledgeBit';
      final messages = _buildMessages(message, conversationHistory);

      final resp = await _dio.post<Object>(
        kAnthropicEndpoint,
        data: <String, dynamic>{
          'model': kAnthropicModel,
          'max_tokens': kAnthropicMaxTokens,
          'system': system,
          'messages': messages,
        },
        options: Options(
          headers: <String, String>{
            'x-api-key': kAnthropicApiKey,
            'anthropic-version': kAnthropicVersion,
            'anthropic-dangerous-direct-browser-access': 'true',
            'content-type': 'application/json',
          },
        ),
      );

      final data = resp.data;
      final Map<String, dynamic> map = switch (data) {
        final Map<String, dynamic> m => m,
        final Map m => Map<String, dynamic>.from(m),
        _ => throw StateError('Unexpected response shape'),
      };

      final content = map['content'];
      if (content is! List || content.isEmpty) {
        throw StateError('Missing "content" array');
      }
      final first = content.first;
      final Map<String, dynamic> block = switch (first) {
        final Map<String, dynamic> m => m,
        final Map m => Map<String, dynamic>.from(m),
        _ => throw StateError('Unexpected content block shape'),
      };
      final text = block['text'];
      if (text is! String || text.trim().isEmpty) {
        throw StateError('Missing "text" field');
      }

      final cleaned = enforceShortResponse(cleanResponse(text));
      return AssistantResponse(text: cleaned);
    } catch (_) {
      return const AssistantResponse(text: _kFallbackText);
    }
  }

  Future<String> _loadKnowledge() async {
    final cached = _knowledge;
    if (cached != null) return cached;
    try {
      final loaded = await rootBundle.loadString(_kKnowledgeAssetPath);
      _knowledge = loaded;
      return loaded;
    } catch (e) {
      developer.log(
        'Failed to load SmartTear knowledge asset: $e',
        name: 'ChatAssistantService',
      );
      _knowledge = '';
      return '';
    }
  }

  String _buildReadingContext(Reading? r, List<Reading> recent) {
    if (r == null) return 'No reading currently selected.';
    final statusStr = r.isValid ? 'valid' : 'invalid';
    final lines = <String>[
      '${recent.length} readings total. Latest ${r.takenAt.toIso8601String()}: status $statusStr.',
    ];
    if (!r.isValid && (r.invalidReason ?? '').isNotEmpty) {
      lines.add('Reason: ${r.invalidReason}');
    }
    for (final a in r.analytes) {
      final v = a.value;
      if (v.isNaN || v.isInfinite) continue;
      final name = _kAnalyteDisplayNames[a.analyteCode] ?? a.analyteCode;
      lines.add('$name (${a.analyteCode}): ${v.toStringAsFixed(1)} ${a.unit}');
      final estBg = a.estimatedBG;
      if (a.analyteCode == 'TG' &&
          estBg != null &&
          !estBg.isNaN &&
          !estBg.isInfinite) {
        lines.add('Estimated blood glucose (BG): ${estBg.toStringAsFixed(1)} mmol/L');
      }
    }
    return lines.join('\n');
  }

  List<Map<String, String>> _buildMessages(
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

    final last6 = turns.length <= 6 ? turns : turns.sublist(turns.length - 6);

    final out = <Map<String, String>>[];
    for (final t in last6) {
      final role = t.role.toLowerCase().trim() == 'user' ? 'user' : 'assistant';
      final plain = cleanResponse(t.content);
      if (plain.isEmpty) continue;
      out.add(<String, String>{'role': role, 'content': plain});
    }
    out.add(<String, String>{'role': 'user', 'content': currentMessage});
    return out;
  }
}
