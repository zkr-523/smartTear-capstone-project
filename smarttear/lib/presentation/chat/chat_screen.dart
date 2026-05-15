import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../application/providers/auth_provider.dart';
import '../../application/providers/data_ingestor_provider.dart';
import '../../domain/entities/chat_message_view.dart';
import '../../domain/entities/conversation_turn.dart';
import '../../domain/entities/reading.dart';
import '../../infrastructure/assistant/chat_assistant_service.dart';
import '../widgets/design_system.dart';

/// Local-only welcome bubble; never persisted or sent to the API.
const int _welcomeLocalMessageId = -9000;

const String _kWelcomeAssistantMessage =
    'Hi — I\'m ZKR. Tap the book icon to attach a reading, then ask me anything. '
    'I\'ll keep answers short.';

const Color _contextBannerBg = Color(0xFF0D2235);

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen>
    with SingleTickerProviderStateMixin {
  final _assistant = ChatAssistantService();
  final _scroll = ScrollController();
  final _composer = TextEditingController();

  Reading? _activeReading;
  int? _activeReadingKey;
  List<Reading> _recentReadings = const <Reading>[];

  var _loadingMessages = true;
  var _typing = false;
  var _sending = false;
  var _localTempId = -1;

  List<ChatMessageView> _messages = const <ChatMessageView>[];

  late final AnimationController _dots;

  @override
  void initState() {
    super.initState();
    _dots = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat();
  }

  @override
  void dispose() {
    _dots.dispose();
    _scroll.dispose();
    _composer.dispose();
    super.dispose();
  }

  int _readingKey(Reading r) => r.id ?? (r.rawPackageRef.hashCode & 0x7fffffff);

  Future<void> _refreshRecentReadings() async {
    final repo = ref.read(readingRepositoryProvider);
    final list = await repo.latestReadings(limit: 12);
    if (!mounted) return;
    setState(() => _recentReadings = List<Reading>.from(list));
  }

  Future<void> _loadMessages() async {
    final auth = ref.read(authServiceProvider).currentUser;
    if (auth == null) return;

    setState(() => _loadingMessages = true);
    try {
      final repo = ref.read(readingRepositoryProvider);
      final list = await repo.loadChatMessages(
        userId: auth.uid,
        readingId: _activeReadingKey,
        limit: 200,
      );
      if (!mounted) return;
      setState(() {
        final mapped = list
            .map(
              (m) => ChatMessageView(
                id: m.id,
                role: m.role,
                text: cleanResponse(m.text),
                createdAt: m.createdAt,
              ),
            )
            .toList(growable: false);
        _messages = mapped.isEmpty
            ? <ChatMessageView>[
                ChatMessageView(
                  id: _welcomeLocalMessageId,
                  role: 'assistant',
                  text: _kWelcomeAssistantMessage,
                  createdAt: DateTime.now(),
                ),
              ]
            : mapped;
        _loadingMessages = false;
      });
      _scrollToBottom();
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingMessages = false);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    });
  }

  List<ConversationTurn> _toConversationHistory(List<ChatMessageView> msgs) {
    return msgs
        .where((m) => m.id != _welcomeLocalMessageId)
        .map(
          (m) => ConversationTurn(
            role: m.role == 'user' ? 'user' : 'model',
            content: m.text,
          ),
        )
        .toList(growable: false);
  }

  Future<void> _persistMessage({
    required String role,
    required String text,
    DateTime? createdAt,
  }) async {
    final auth = ref.read(authServiceProvider).currentUser;
    if (auth == null) return;
    final repo = ref.read(readingRepositoryProvider);
    await repo.saveChatMessage(
      userId: auth.uid,
      readingId: _activeReadingKey,
      role: role,
      text: text,
      createdAt: createdAt,
    );
  }

  Future<void> _send(String text) async {
    final auth = ref.read(authServiceProvider).currentUser;
    if (auth == null) return;
    final msg = cleanResponse(text.trim());
    if (msg.isEmpty) return;
    if (_sending) return;

    setState(() {
      _sending = true;
      _typing = true;
    });

    final now = DateTime.now();
    await _persistMessage(role: 'user', text: msg, createdAt: now);
    if (!mounted) return;
    setState(() {
      _messages = [
        ..._messages,
        ChatMessageView(
          id: _localTempId--,
          role: 'user',
          text: msg,
          createdAt: now,
        ),
      ];
    });
    _scrollToBottom();

    try {
      final response = await _assistant.respond(
        msg,
        _activeReading,
        _recentReadings,
        _toConversationHistory(_messages),
      );

      final reply = response.text;
      final at = DateTime.now();
      await _persistMessage(role: 'assistant', text: reply, createdAt: at);
      if (!mounted) return;
      setState(() {
        _messages = [
          ..._messages,
          ChatMessageView(
            id: _localTempId--,
            role: 'assistant',
            text: reply,
            createdAt: at,
          ),
        ];
      });
      _scrollToBottom();

      if (!mounted) return;
      setState(() {
        _typing = false;
        _sending = false;
      });

      if (!mounted) return;
      switch (response.navigationCommand) {
        case NavigationCommand.openHistory:
          context.go('/history');
        case NavigationCommand.openTrends:
          context.go('/trends');
        case null:
          break;
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _typing = false;
        _sending = false;
      });
    }
  }

  Future<void> _selectGeneral() async {
    setState(() {
      _activeReading = null;
      _activeReadingKey = null;
    });
    await _loadMessages();
  }

  Future<void> _applyReadingAndDiscuss(Reading r) async {
    setState(() {
      _activeReading = r;
      _activeReadingKey = _readingKey(r);
    });
    await _loadMessages();
    final when = DateFormat('MMM d, h:mm a').format(r.takenAt);
    await _send('Let us discuss my reading from $when');
  }

  String _tgLine(Reading r) {
    final g = r.glucose;
    if (g == null) return 'TG: — mmol/L';
    return 'TG: ${g.value.toStringAsFixed(1)} ${g.unit}';
  }

  String _contextSubtitle(Reading reading) {
    final date = DateFormat('MMM d, yyyy · h:mm a').format(reading.takenAt);
    final status = reading.isValid ? 'Valid' : 'Invalid';
    return '$date · $status · ${_tgLine(reading)}';
  }

  void _showReadingPickerSheet() {
    final h = MediaQuery.sizeOf(context).height * 0.72;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: SmartTearColors.bgCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          top: false,
          child: SizedBox(
            height: h,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 32,
                    height: 4,
                    margin: const EdgeInsets.only(top: 12),
                    decoration: BoxDecoration(
                      color: const Color(0x33FFFFFF),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Text(
                    'Select a Reading',
                    style: SmartTearText.title,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Divider(
                    height: 1,
                    thickness: 1,
                    color: SmartTearColors.divider,
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      ListTile(
                        tileColor: Colors.transparent,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 4,
                        ),
                        leading: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: SmartTearColors.tealLight,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: SmartTearColors.borderTeal,
                              width: 1,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.chat_outlined,
                            size: 18,
                            color: SmartTearColors.teal,
                          ),
                        ),
                        title: Text(
                          'General Question',
                          style: SmartTearText.body.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: Text(
                          'Ask anything about SmartTear',
                          style: SmartTearText.micro.copyWith(
                            color: SmartTearColors.textMuted,
                          ),
                        ),
                        onTap: () {
                          Navigator.pop(ctx);
                          unawaited(_selectGeneral());
                        },
                      ),
                      Divider(
                        height: 1,
                        thickness: 1,
                        color: SmartTearColors.divider,
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                        child: Text(
                          'READINGS',
                          style: SmartTearText.tag,
                        ),
                      ),
                      ..._recentReadings.expand((r) {
                        final ts =
                            DateFormat('MMM d, yyyy · h:mm a').format(r.takenAt);
                        return [
                          ListTile(
                            tileColor: Colors.transparent,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 4,
                            ),
                            leading: SizedBox(
                              width: 56,
                              height: 36,
                              child: Center(
                                child: StatusBadge(status: r.qcStatus),
                              ),
                            ),
                            title: Text(
                              ts,
                              style: SmartTearText.body.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            subtitle: Text(
                              _tgLine(r),
                              style: SmartTearText.micro,
                            ),
                            trailing: const Icon(
                              Icons.chevron_right,
                              size: 16,
                              color: SmartTearColors.textMuted,
                            ),
                            onTap: () {
                              Navigator.pop(ctx);
                              unawaited(_applyReadingAndDiscuss(r));
                            },
                          ),
                          Divider(
                            height: 1,
                            thickness: 1,
                            color: SmartTearColors.divider,
                          ),
                        ];
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authStateProvider).valueOrNull;
    final hasReading = _activeReading != null;

    if (auth != null && _recentReadings.isEmpty) {
      unawaited(_refreshRecentReadings());
    }
    if (auth != null && _loadingMessages && _messages.isEmpty) {
      unawaited(_loadMessages());
    }

    return Scaffold(
      backgroundColor: SmartTearColors.bgBase,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SafeArea(
            bottom: false,
            child: const _ChatAppBar(),
          ),
          if (hasReading)
            _ReadingContextBanner(
              subtitle: _contextSubtitle(_activeReading!),
              onClear: () => unawaited(_selectGeneral()),
            ),
          if (hasReading) _QuickChipsRow(onTap: (q) => unawaited(_send(q))),
          Expanded(
            child: _loadingMessages
                ? const Center(
                    child: CircularProgressIndicator(
                      color: SmartTearColors.teal,
                    ),
                  )
                : ListView.builder(
                    controller: _scroll,
                    reverse: false,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    itemCount: _messages.length + (_typing ? 1 : 0),
                    itemBuilder: (context, i) {
                      if (_typing && i == _messages.length) {
                        return _TypingAssistantRow(dots: _dots);
                      }
                      final m = _messages[i];
                      final isUser = m.role == 'user';
                      if (isUser) {
                        return _UserMessageRow(
                          text: m.text,
                          createdAt: m.createdAt,
                        );
                      }
                      return _AssistantMessageRow(
                        text: m.text,
                        createdAt: m.createdAt,
                      );
                    },
                  ),
          ),
          _InputRow(
            controller: _composer,
            enabled: auth != null,
            onOpenReadingPicker: _showReadingPickerSheet,
            onSend: () async {
              final text = _composer.text;
              _composer.clear();
              await _send(text);
            },
          ),
        ],
      ),
    );
  }
}

class _PulsingLiveDot extends StatefulWidget {
  const _PulsingLiveDot();

  @override
  State<_PulsingLiveDot> createState() => _PulsingLiveDotState();
}

class _PulsingLiveDotState extends State<_PulsingLiveDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.45, end: 1).animate(
        CurvedAnimation(parent: _c, curve: Curves.easeInOut),
      ),
      child: Container(
        width: 8,
        height: 8,
        decoration: const BoxDecoration(
          color: SmartTearColors.valid,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

class _ChatAppBar extends StatelessWidget {
  const _ChatAppBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: SmartTearColors.bgCard,
        border: Border(
          bottom: BorderSide(
            color: SmartTearColors.divider,
            width: 1,
          ),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const _PulsingLiveDot(),
                    const SizedBox(width: 6),
                    Text('ZKR', style: SmartTearText.title),
                  ],
                ),
                Text(
                  'SmartTear AI Assistant',
                  style: SmartTearText.micro.copyWith(
                    fontSize: 11,
                    color: SmartTearColors.teal,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: SmartTearColors.tealLight,
              shape: BoxShape.circle,
              border: Border.all(
                color: SmartTearColors.borderTeal,
                width: 1,
              ),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.psychology_outlined,
              size: 18,
              color: SmartTearColors.teal,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReadingContextBanner extends StatelessWidget {
  const _ReadingContextBanner({
    required this.subtitle,
    required this.onClear,
  });

  final String subtitle;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        color: _contextBannerBg,
        border: Border(
          bottom: BorderSide(
            color: SmartTearColors.borderTeal,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 32,
            decoration: BoxDecoration(
              color: SmartTearColors.teal,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Discussing reading',
                  style: SmartTearText.micro.copyWith(
                    color: SmartTearColors.teal,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: SmartTearText.label.copyWith(
                    color: SmartTearColors.textPrimary,
                    letterSpacing: 0,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onClear,
            behavior: HitTestBehavior.opaque,
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(
                Icons.close_outlined,
                size: 16,
                color: SmartTearColors.textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickChipsRow extends StatelessWidget {
  const _QuickChipsRow({required this.onTap});

  final ValueChanged<String> onTap;

  static const _chips = <String>[
    'What does this mean?',
    'Do I need a doctor?',
    'Which analyte is most affected?',
    'How was this collected?',
    'Compare to my history',
    'What affects my glucose?',
    'How to improve my levels?',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: SmartTearColors.bgCard,
        border: Border(
          bottom: BorderSide(
            color: SmartTearColors.divider,
            width: 1,
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (var i = 0; i < _chips.length; i++) ...[
              if (i > 0) const SizedBox(width: 8),
              Material(
                color: SmartTearColors.transparent,
                child: InkWell(
                  onTap: () => onTap(_chips[i]),
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      color: SmartTearColors.tealLight,
                      border: Border.all(
                        color: SmartTearColors.borderTeal,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      _chips[i],
                      style: SmartTearText.body.copyWith(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: SmartTearColors.teal,
                        height: 1.2,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _UserMessageRow extends StatelessWidget {
  const _UserMessageRow({
    required this.text,
    required this.createdAt,
  });

  final String text;
  final DateTime createdAt;

  @override
  Widget build(BuildContext context) {
    final ts = DateFormat('h:mm a').format(createdAt);
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.only(left: 60, bottom: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    SmartTearColors.teal,
                    SmartTearColors.tealDim,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(4),
                ),
              ),
              child: Text(
                text,
                style: SmartTearText.body.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: SmartTearColors.bgDeep,
                  height: 1.4,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                ts,
                textAlign: TextAlign.right,
                style: SmartTearText.micro.copyWith(
                  color: SmartTearColors.textMuted,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AssistantMessageRow extends StatefulWidget {
  const _AssistantMessageRow({
    required this.text,
    required this.createdAt,
  });

  final String text;
  final DateTime createdAt;

  @override
  State<_AssistantMessageRow> createState() => _AssistantMessageRowState();
}

class _AssistantMessageRowState extends State<_AssistantMessageRow> {
  static const int _collapseLen = 400;
  var _expanded = false;

  @override
  Widget build(BuildContext context) {
    final text = widget.text;
    final long = text.length > _collapseLen;
    final collapsed = long && !_expanded;
    final bodyText = collapsed ? text.substring(0, _collapseLen) : text;
    final ts = DateFormat('h:mm a').format(widget.createdAt);

    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(right: 60, bottom: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 32,
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: SmartTearColors.bgCard,
                shape: BoxShape.circle,
                border: Border.all(
                  color: SmartTearColors.borderTeal,
                  width: 1,
                ),
              ),
              child: Text(
                'Z',
                style: SmartTearText.body.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: SmartTearColors.teal,
                  height: 1,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: SmartTearColors.bgCard,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(4),
                        topRight: Radius.circular(16),
                        bottomLeft: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      ),
                      border: Border.all(
                        color: const Color(0x33FFFFFF),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          bodyText,
                          style: SmartTearText.body.copyWith(height: 1.5),
                        ),
                        if (collapsed)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: GestureDetector(
                              onTap: () => setState(() => _expanded = true),
                              child: Text(
                                'Read more',
                                style: SmartTearText.body.copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                  color: SmartTearColors.teal,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 4, top: 2),
                    child: Text(
                      ts,
                      style: SmartTearText.micro.copyWith(
                        color: SmartTearColors.textMuted,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TypingAssistantRow extends StatelessWidget {
  const _TypingAssistantRow({required this.dots});

  final AnimationController dots;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(right: 60, bottom: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 32,
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: SmartTearColors.bgCard,
                shape: BoxShape.circle,
                border: Border.all(
                  color: SmartTearColors.borderTeal,
                  width: 1,
                ),
              ),
              child: Text(
                'Z',
                style: SmartTearText.body.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: SmartTearColors.teal,
                  height: 1,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: SmartTearColors.bgCard,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(4),
                        topRight: Radius.circular(16),
                        bottomLeft: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      ),
                      border: Border.all(
                        color: const Color(0x33FFFFFF),
                        width: 1,
                      ),
                    ),
                    child: AnimatedBuilder(
                      animation: dots,
                      builder: (context, _) {
                        final t = dots.value;
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(3, (i) {
                            final phase = i * (2 * math.pi / 3);
                            final y = math.sin(2 * math.pi * t + phase) * 5.0;
                            return Padding(
                              padding: EdgeInsets.only(right: i < 2 ? 6 : 0),
                              child: Transform.translate(
                                offset: Offset(0, y),
                                child: Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    color: SmartTearColors.teal,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            );
                          }),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InputRow extends StatelessWidget {
  const _InputRow({
    required this.controller,
    required this.enabled,
    required this.onOpenReadingPicker,
    required this.onSend,
  });

  final TextEditingController controller;
  final bool enabled;
  final VoidCallback onOpenReadingPicker;
  final Future<void> Function() onSend;

  static const _sendGradient = LinearGradient(
    colors: [Color(0xFF00D4C8), Color(0xFF00897B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final viewInsetBottom = MediaQuery.viewInsetsOf(context).bottom;

    return Container(
      constraints: const BoxConstraints(minHeight: 64),
      decoration: const BoxDecoration(
        color: SmartTearColors.bgCard,
        border: Border(
          top: BorderSide(
            color: Color(0x33FFFFFF),
            width: 1,
          ),
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        12,
        8,
        12,
        8 + bottomInset + viewInsetBottom,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Material(
            color: SmartTearColors.bgCard,
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: enabled ? onOpenReadingPicker : null,
              customBorder: const CircleBorder(),
              child: Ink(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: SmartTearColors.bgCard,
                  border: Border.all(
                    color: SmartTearColors.borderTeal,
                    width: 1,
                  ),
                ),
                child: Icon(
                  Icons.menu_book_outlined,
                  size: 18,
                  color: enabled
                      ? SmartTearColors.teal
                      : SmartTearColors.textMuted,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 48, maxHeight: 160),
              child: TextField(
                controller: controller,
                enabled: enabled,
                minLines: 1,
                maxLines: 5,
                textAlignVertical: TextAlignVertical.center,
                cursorColor: SmartTearColors.teal,
                style: SmartTearText.body,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: SmartTearColors.bgBase,
                  hintText: 'Message ZKR...',
                  hintStyle: SmartTearText.micro.copyWith(
                    color: SmartTearColors.textMuted,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: const BorderSide(
                      color: Color(0x33FFFFFF),
                      width: 1,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: const BorderSide(
                      color: Color(0x33FFFFFF),
                      width: 1,
                    ),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(
                      color: const Color(0x33FFFFFF).withOpacity(0.4),
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(
                      color: SmartTearColors.teal.withOpacity(0.55),
                      width: 1,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: const BorderSide(
                      color: Color(0x33FFFFFF),
                      width: 1,
                    ),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(
                      color: SmartTearColors.teal.withOpacity(0.55),
                      width: 1,
                    ),
                  ),
                  isDense: true,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (context, v, _) {
              final hasText = v.text.trim().isNotEmpty;
              final canSend = enabled && hasText;
              return GestureDetector(
                onTap: canSend ? () => unawaited(onSend()) : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: hasText && enabled ? _sendGradient : null,
                    color: hasText && enabled ? null : SmartTearColors.bgCard,
                    border: Border.all(
                      color: hasText && enabled
                          ? SmartTearColors.borderTeal
                          : const Color(0x33FFFFFF),
                      width: 1,
                    ),
                    boxShadow: hasText && enabled
                        ? [
                            BoxShadow(
                              color: SmartTearColors.teal.withOpacity(0.35),
                              blurRadius: 12,
                              spreadRadius: 0,
                            ),
                          ]
                        : null,
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.send_rounded,
                    size: 18,
                    color: hasText && enabled
                        ? SmartTearColors.bgDeep
                        : SmartTearColors.textMuted,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
