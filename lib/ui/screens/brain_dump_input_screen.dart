import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../../services/app_state_provider.dart';
import '../../theme/design_tokens.dart';
import '../../theme/theme.dart';

class BrainDumpInputScreen extends StatefulWidget {
  const BrainDumpInputScreen({super.key});

  @override
  State<BrainDumpInputScreen> createState() => _BrainDumpInputScreenState();
}

class _BrainDumpInputScreenState extends State<BrainDumpInputScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final SpeechToText _speech = SpeechToText();
  bool _saving = false;
  bool _isListening = false;
  bool _speechAvailable = false;
  late AnimationController _micPulse;

  @override
  void initState() {
    super.initState();
    _micPulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    _speechAvailable = await _speech.initialize();
    if (mounted) setState(() {});
  }

  Future<void> _toggleListening() async {
    if (_isListening) {
      await _speech.stop();
      _micPulse.stop();
      setState(() => _isListening = false);
    } else {
      if (!_speechAvailable) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Voice input not available on this device.')),
        );
        return;
      }
      HapticFeedback.mediumImpact();
      setState(() => _isListening = true);
      _micPulse.repeat(reverse: true);
      await _speech.listen(
        onResult: (result) {
          setState(() {
            _controller.text = result.recognizedWords;
            _controller.selection = TextSelection.fromPosition(
              TextPosition(offset: _controller.text.length),
            );
          });
        },
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 4),
      );
    }
  }

  Future<void> _submit() async {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Write or speak something first — even one sentence helps.'),
        ),
      );
      return;
    }
    HapticFeedback.lightImpact();
    setState(() => _saving = true);
    if (_isListening) {
      await _speech.stop();
      setState(() => _isListening = false);
    }
    final provider = context.read<AppStateProvider>();
    await provider.processBrainDump(text);
    if (!mounted) return;
    GoRouter.of(context).go('/reflect'); // safe: mounted check above
  }

  @override
  void dispose() {
    _controller.dispose();
    _micPulse.dispose();
    _speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EaseTheme.background,
      appBar: AppBar(
        backgroundColor: EaseTheme.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.x),
          onPressed: () => context.canPop() ? context.pop() : context.go('/home'),
        ),
        title: const Text('Brain Dump'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(EaseSpace.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'What\'s on your mind?',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: EaseSpace.xs),
              Text(
                'No judgment. Just unload it all here.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontSize: 14,
                      color: EaseTheme.secondary,
                    ),
              ),
              const SizedBox(height: EaseSpace.lg),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.78),
                    borderRadius: EaseRadius.lg,
                    border: Border.all(
                      color: _isListening
                          ? EaseTheme.primarySage
                          : EaseTheme.surfaceDim,
                      width: _isListening ? 1.5 : 1,
                    ),
                  ),
                  child: TextField(
                    controller: _controller,
                    maxLines: null,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top,
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(fontSize: 16),
                    decoration: InputDecoration(
                      hintText:
                          'Type freely... stress, work, money, relationships — anything.',
                      hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontSize: 15,
                            color: EaseTheme.secondary.withValues(alpha: 0.6),
                          ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: const EdgeInsets.all(EaseSpace.md),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: EaseSpace.md),
              Row(
                children: [
                  _VoiceButton(
                    isListening: _isListening,
                    pulseController: _micPulse,
                    onTap: _toggleListening,
                  ),
                  const SizedBox(width: EaseSpace.sm),
                  Expanded(
                    child: FilledButton(
                      onPressed: _saving ? null : _submit,
                      child: _saving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Submit & reflect'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VoiceButton extends StatelessWidget {
  final bool isListening;
  final AnimationController pulseController;
  final VoidCallback onTap;

  const _VoiceButton({
    required this.isListening,
    required this.pulseController,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pulseController,
      builder: (context, child) {
        final scale = isListening
            ? 1.0 + pulseController.value * 0.12
            : 1.0;
        return Transform.scale(
          scale: scale,
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: isListening
                    ? EaseTheme.tertiaryTerracotta
                    : Colors.white.withValues(alpha: 0.78),
                borderRadius: EaseRadius.md,
                border: Border.all(
                  color: isListening
                      ? EaseTheme.tertiaryTerracotta
                      : EaseTheme.surfaceDim,
                ),
              ),
              child: Icon(
                isListening ? LucideIcons.micOff : LucideIcons.mic,
                color: isListening ? Colors.white : EaseTheme.secondary,
                size: 22,
              ),
            ),
          ),
        );
      },
    );
  }
}
