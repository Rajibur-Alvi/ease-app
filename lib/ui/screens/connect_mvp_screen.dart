import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../models/chat_models.dart';
import '../../models/models.dart';
import '../../services/app_state_provider.dart';
import '../../services/chat_provider.dart';
import '../../theme/design_tokens.dart';
import '../../theme/theme.dart';
import '../widgets/empty_state_card.dart';
import '../widgets/skeleton_loader.dart';

class ConnectMvpScreen extends StatefulWidget {
  const ConnectMvpScreen({super.key});

  @override
  State<ConnectMvpScreen> createState() => _ConnectMvpScreenState();
}

class _ConnectMvpScreenState extends State<ConnectMvpScreen> {
  CompanionMatch? _activeMatch;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppStateProvider>().buildMatches();
    });
  }

  @override
  Widget build(BuildContext context) {
    final chat = context.watch<ChatProvider>();

    return Scaffold(
      backgroundColor: EaseTheme.background,
      appBar: AppBar(
        backgroundColor: EaseTheme.background,
        elevation: 0,
        title: const Text('Connect'),
        leading: _activeMatch != null
            ? IconButton(
                icon: const Icon(LucideIcons.arrowLeft),
                onPressed: () {
                  chat.closeChat();
                  setState(() => _activeMatch = null);
                },
              )
            : null,
      ),
      body: SafeArea(
        child: _activeMatch != null
            ? _ChatView(match: _activeMatch!)
            : _MatchView(
                onOpenChat: (match) async {
                  HapticFeedback.lightImpact();
                  await chat.openChat(match);
                  setState(() => _activeMatch = match);
                },
              ),
      ),
    );
  }
}

// ── Match View ────────────────────────────────────────────────────────────────

class _MatchView extends StatelessWidget {
  final Future<void> Function(CompanionMatch) onOpenChat;

  const _MatchView({required this.onOpenChat});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateProvider>();
    final matches = appState.lastMatches;

    if (appState.isLoading) {
      return const Padding(
        padding: EdgeInsets.all(EaseSpace.lg),
        child: Column(
          children: [CardSkeleton(), CardSkeleton()],
        ),
      );
    }

    if (matches.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(EaseSpace.lg),
        child: EmptyStateCard(
          title: 'No matches yet',
          message:
              'Do a Brain Dump so we can find someone who understands you.',
          ctaLabel: 'Open Brain Dump',
          onTap: () => context.push('/brain-dump'),
        ),
      );
    }

    final top = matches.first;

    return ListView(
      padding: const EdgeInsets.all(EaseSpace.lg),
      children: [
        Text('Someone who gets it',
            style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: EaseSpace.xs),
        Text(
          'Based on your mood and interests.',
          style: Theme.of(context)
              .textTheme
              .bodyLarge
              ?.copyWith(fontSize: 14, color: EaseTheme.secondary),
        ),
        const SizedBox(height: EaseSpace.lg),
        _MatchCard(
          match: top,
          onChat: () => onOpenChat(top),
          onSkip: () => context.read<AppStateProvider>().skipMatch(top.id),
        ),
        if (matches.length > 1) ...[
          const SizedBox(height: EaseSpace.md),
          Text('OTHER SUGGESTIONS',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    letterSpacing: 1.4,
                    color: EaseTheme.secondary,
                  )),
          const SizedBox(height: EaseSpace.sm),
          ...matches.skip(1).map(
                (m) => Padding(
                  padding: const EdgeInsets.only(bottom: EaseSpace.sm),
                  child: _CompactMatchCard(
                    match: m,
                    onTap: () => onOpenChat(m),
                  ),
                ),
              ),
        ],
      ],
    );
  }
}

class _MatchCard extends StatelessWidget {
  final CompanionMatch match;
  final VoidCallback onChat;
  final VoidCallback onSkip;

  const _MatchCard(
      {required this.match, required this.onChat, required this.onSkip});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(EaseSpace.lg),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.78),
        borderRadius: EaseRadius.xl,
        border: Border.all(color: EaseTheme.surfaceDim),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor:
                EaseTheme.primaryContainer.withValues(alpha: 0.2),
            child: Text(
              match.name[0].toUpperCase(),
              style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: EaseTheme.primarySage),
            ),
          ),
          const SizedBox(height: EaseSpace.sm),
          Text(match.name,
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium
                  ?.copyWith(fontSize: 20)),
          const SizedBox(height: EaseSpace.xs),
          _MoodBadge(mood: match.mood),
          const SizedBox(height: EaseSpace.sm),
          Wrap(
            spacing: EaseSpace.xs,
            runSpacing: EaseSpace.xs,
            alignment: WrapAlignment.center,
            children: match.interests
                .map((i) => _InterestChip(label: i))
                .toList(),
          ),
          const SizedBox(height: EaseSpace.xs),
          Text(
            'Prefers ${match.style.name} · Introvert ${match.introvertLevel}',
            style: Theme.of(context)
                .textTheme
                .labelSmall
                ?.copyWith(color: EaseTheme.secondary),
          ),
          const SizedBox(height: EaseSpace.lg),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onSkip,
                  icon: const Icon(LucideIcons.skipForward, size: 16),
                  label: const Text('Skip'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    foregroundColor: EaseTheme.secondary,
                    side: const BorderSide(color: EaseTheme.surfaceDim),
                  ),
                ),
              ),
              const SizedBox(width: EaseSpace.sm),
              Expanded(
                flex: 2,
                child: FilledButton.icon(
                  onPressed: onChat,
                  icon: const Icon(LucideIcons.messageCircle, size: 16),
                  label: const Text('Start chat'),
                  style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(48)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CompactMatchCard extends StatelessWidget {
  final CompanionMatch match;
  final VoidCallback onTap;

  const _CompactMatchCard({required this.match, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(EaseSpace.md),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.72),
          borderRadius: EaseRadius.md,
          border: Border.all(color: EaseTheme.surfaceDim),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor:
                  EaseTheme.primaryContainer.withValues(alpha: 0.2),
              child: Text(match.name[0].toUpperCase(),
                  style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: EaseTheme.primarySage)),
            ),
            const SizedBox(width: EaseSpace.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(match.name,
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(
                              fontSize: 15, fontWeight: FontWeight.w600)),
                  Text(match.interests.take(2).join(', '),
                      style: Theme.of(context)
                          .textTheme
                          .labelSmall
                          ?.copyWith(color: EaseTheme.secondary)),
                ],
              ),
            ),
            const Icon(LucideIcons.chevronRight,
                size: 16, color: EaseTheme.secondary),
          ],
        ),
      ),
    );
  }
}

// ── Chat View ─────────────────────────────────────────────────────────────────

class _ChatView extends StatefulWidget {
  final CompanionMatch match;

  const _ChatView({required this.match});

  @override
  State<_ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<_ChatView> {
  final _inputController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: EaseMotion.standard,
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final chat = context.watch<ChatProvider>();

    // Auto-scroll when messages change
    if (chat.activeMessages.isNotEmpty) _scrollToBottom();

    return Column(
      children: [
        // Match header
        Container(
          padding: const EdgeInsets.symmetric(
              horizontal: EaseSpace.md, vertical: EaseSpace.sm),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.78),
            border:
                Border(bottom: BorderSide(color: EaseTheme.surfaceDim)),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor:
                    EaseTheme.primaryContainer.withValues(alpha: 0.2),
                child: Text(widget.match.name[0].toUpperCase(),
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: EaseTheme.primarySage)),
              ),
              const SizedBox(width: EaseSpace.sm),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.match.name,
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium
                          ?.copyWith(fontSize: 16)),
                  Text(
                    chat.isTyping ? 'typing...' : 'Here to listen',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: chat.isTyping
                              ? EaseTheme.primarySage
                              : EaseTheme.secondary,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Messages
        Expanded(
          child: chat.isLoading
              ? const Center(child: CircularProgressIndicator())
              : chat.activeMessages.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(EaseSpace.lg),
                        child: Text(
                          'Say hello — no pressure, just a gentle opener.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(
                                  fontSize: 14,
                                  color: EaseTheme.secondary),
                        ),
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(EaseSpace.md),
                      itemCount: chat.activeMessages.length +
                          (chat.isTyping ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == chat.activeMessages.length &&
                            chat.isTyping) {
                          return const _TypingIndicator();
                        }
                        return _Bubble(
                            message: chat.activeMessages[index]);
                      },
                    ),
        ),

        // Input
        Container(
          padding: EdgeInsets.only(
            left: EaseSpace.md,
            right: EaseSpace.md,
            top: EaseSpace.sm,
            bottom:
                MediaQuery.of(context).viewInsets.bottom + EaseSpace.sm,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.78),
            border:
                Border(top: BorderSide(color: EaseTheme.surfaceDim)),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _inputController,
                  decoration: const InputDecoration(
                    hintText: 'Write a gentle message...',
                    isDense: true,
                  ),
                  onSubmitted: _send,
                  textInputAction: TextInputAction.send,
                ),
              ),
              const SizedBox(width: EaseSpace.xs),
              IconButton(
                onPressed: () => _send(_inputController.text),
                icon: const Icon(LucideIcons.send, size: 20),
                color: EaseTheme.primarySage,
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _send(String text) {
    if (text.trim().isEmpty) return;
    HapticFeedback.selectionClick();
    context.read<ChatProvider>().sendMessage(text, widget.match);
    _inputController.clear();
  }
}

class _Bubble extends StatelessWidget {
  final ChatMessage message;

  const _Bubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final fromMatch = message.senderId.startsWith('m');

    return Align(
      alignment:
          fromMatch ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: EaseSpace.xs),
        padding: const EdgeInsets.symmetric(
            horizontal: EaseSpace.md, vertical: EaseSpace.sm),
        constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.72),
        decoration: BoxDecoration(
          color: fromMatch
              ? Colors.white.withValues(alpha: 0.85)
              : EaseTheme.primarySage,
          borderRadius: EaseRadius.lg,
          border: fromMatch
              ? Border.all(color: EaseTheme.surfaceDim)
              : null,
        ),
        child: Column(
          crossAxisAlignment: fromMatch
              ? CrossAxisAlignment.start
              : CrossAxisAlignment.end,
          children: [
            Text(
              message.text,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontSize: 14,
                    color: fromMatch
                        ? EaseTheme.onSurface
                        : Colors.white,
                  ),
            ),
            const SizedBox(height: 2),
            Text(
              _formatTime(message.timestamp),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontSize: 10,
                    color: fromMatch
                        ? EaseTheme.secondary
                        : Colors.white.withValues(alpha: 0.7),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator();

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600))
      ..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.4, end: 1.0).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: EaseSpace.xs),
        padding: const EdgeInsets.symmetric(
            horizontal: EaseSpace.md, vertical: EaseSpace.sm),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.85),
          borderRadius: EaseRadius.lg,
          border: Border.all(color: EaseTheme.surfaceDim),
        ),
        child: FadeTransition(
          opacity: _anim,
          child: Text('typing...',
              style: Theme.of(context)
                  .textTheme
                  .labelSmall
                  ?.copyWith(color: EaseTheme.secondary)),
        ),
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

class _MoodBadge extends StatelessWidget {
  final MoodState mood;
  const _MoodBadge({required this.mood});

  @override
  Widget build(BuildContext context) {
    final label = switch (mood) {
      MoodState.calm => '😌 Calm',
      MoodState.overwhelmed => '😤 Overwhelmed',
      MoodState.lowEnergy => '😴 Low Energy',
    };
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: EaseSpace.sm, vertical: 4),
      decoration: BoxDecoration(
        color: EaseTheme.primarySage.withValues(alpha: 0.08),
        borderRadius: EaseRadius.pill,
      ),
      child: Text(label,
          style: Theme.of(context)
              .textTheme
              .labelSmall
              ?.copyWith(color: EaseTheme.primarySage)),
    );
  }
}

class _InterestChip extends StatelessWidget {
  final String label;
  const _InterestChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: EaseSpace.sm, vertical: 4),
      decoration: BoxDecoration(
        color: EaseTheme.primarySage.withValues(alpha: 0.08),
        borderRadius: EaseRadius.pill,
      ),
      child: Text(label,
          style: Theme.of(context)
              .textTheme
              .labelSmall
              ?.copyWith(color: EaseTheme.primarySage)),
    );
  }
}
