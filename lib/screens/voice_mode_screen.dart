import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'dart:async';
import '../theme/theme.dart';
import '../services/app_state_provider.dart';
import '../theme/performance_helper.dart';

class VoiceModeScreen extends StatefulWidget {
  const VoiceModeScreen({Key? key}) : super(key: key);

  @override
  State<VoiceModeScreen> createState() => _VoiceModeScreenState();
}

class _VoiceModeScreenState extends State<VoiceModeScreen> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  String _transcription = "";
  String _aiResponse = "I'm listening. Tell me what's on your mind.";
  final List<String> _empathyChips = ["I understand", "Take your time", "That sounds heavy", "I'm here"];
  bool _isAvailable = false;
  bool _useKeyboard = false;
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  void _initSpeech() async {
    try {
      _isAvailable = await _speech.initialize(
        onStatus: (status) => debugPrint('STT Status: $status'),
        onError: (errorNotification) => debugPrint('STT Error: $errorNotification'),
      );
      if (mounted) setState(() {});
    } catch (e) {
      debugPrint('STT Init Exception: $e');
      _isAvailable = false;
      if (mounted) setState(() {});
    }
  }

  void _toggleListening() async {
    if (_isListening) {
      await _speech.stop();
      setState(() => _isListening = false);
    } else {
      if (_isAvailable && !_useKeyboard) {
        setState(() {
          _isListening = true;
          _transcription = "";
          _aiResponse = "Listening...";
        });
        await _speech.listen(
          onResult: (result) {
            setState(() {
              _transcription = result.recognizedWords;
              if (result.finalResult) {
                _isListening = false;
                _aiResponse = "I've noted that down. Anything else?";
              }
            });
          },
        );
      } else if (_useKeyboard) {
        // Just focus the text field (handled by UI)
      } else {
        _startSimulation();
      }
    }
  }

  void _startSimulation() {
    setState(() {
      _isListening = true;
      _transcription = "";
      _aiResponse = "Mic not available. Simulating transcription...";
    });
    
    Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isListening = false;
          _transcription = "I need to pay the electricity bill and call my sister.";
          _aiResponse = "Noted. You can edit this above if needed.";
        });
      }
    });
  }

  Future<void> _saveAndFinish() async {
    final text = _useKeyboard ? _textController.text.trim() : _transcription.trim();
    if (text.isNotEmpty) {
      await context.read<AppStateProvider>().addEntry(text);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Thought saved and categorized!')),
        );
      }
    }
    context.go('/dashboard');
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: SafeArea(
        child: SingleChildScrollView(
          child: SizedBox(
            height: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom,
            child: Column(
              children: [
                _buildHeader(context),
                const Spacer(),
                _buildAiResponseSection(),
                const SizedBox(height: 40),
                if (!_useKeyboard) _buildVisualizer(),
                const SizedBox(height: 40),
                _buildInputSection(),
                const Spacer(),
                if (!_useKeyboard) _buildEmpathyChips(),
                const SizedBox(height: 32),
                _buildControls(),
                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(LucideIcons.x, color: Colors.white70),
            onPressed: () => context.go('/dashboard'),
          ),
          Text(
            "OFFLOAD SESSION",
            style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.white54, letterSpacing: 2.0),
          ),
          IconButton(
            icon: Icon(_useKeyboard ? LucideIcons.mic : LucideIcons.keyboard, color: Colors.white70),
            onPressed: () => setState(() => _useKeyboard = !_useKeyboard),
          ),
        ],
      ),
    );
  }

  Widget _buildAiResponseSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Text(
        _aiResponse,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w300, height: 1.4),
      ),
    );
  }

  Widget _buildVisualizer() {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (_isListening) ...List.generate(3, (index) => _buildPulseCircle(index)),
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(color: EaseTheme.primaryContainer, shape: BoxShape.circle),
            child: Icon(_isListening ? LucideIcons.mic : LucideIcons.micOff, color: Colors.white, size: 32),
          ),
        ],
      ),
    );
  }

  Widget _buildPulseCircle(int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 1000 + (index * 500)),
      builder: (context, value, child) {
        return Container(
          width: 80 + (value * 100),
          height: 80 + (value * 100),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: EaseTheme.primaryContainer.withOpacity(1.0 - value), width: 2),
          ),
        );
      },
    );
  }

  Widget _buildInputSection() {
    if (_useKeyboard) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: TextField(
          controller: _textController,
          autofocus: true,
          style: const TextStyle(color: Colors.white, fontSize: 18),
          maxLines: 5,
          decoration: InputDecoration(
            hintText: "Type what's on your mind...",
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
            border: InputBorder.none,
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Text(
        _transcription.isEmpty ? "Tap the mic to speak" : _transcription,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.white70, fontSize: 16, fontStyle: FontStyle.italic),
      ),
    );
  }

  Widget _buildEmpathyChips() {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 500),
      opacity: _isListening ? 1.0 : 0.0,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          children: _empathyChips.map((chip) => Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white24),
            ),
            child: Text(chip, style: const TextStyle(color: Colors.white, fontSize: 12)),
          )).toList(),
        ),
      ),
    );
  }

  Widget _buildControls() {
    final hasText = _useKeyboard ? _textController.text.isNotEmpty : _transcription.isNotEmpty;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (!_isListening && hasText)
          _buildActionButton(LucideIcons.rotateCcw, "Clear", () {
            setState(() {
              _transcription = "";
              _textController.clear();
              _aiResponse = "I'm listening. Tell me what's on your mind.";
            });
          }),
        const SizedBox(width: 24),
        GestureDetector(
          onTap: _useKeyboard ? null : _toggleListening,
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: _useKeyboard ? Colors.white10 : (_isListening ? Colors.redAccent : EaseTheme.primaryContainer),
              shape: BoxShape.circle,
              boxShadow: _useKeyboard ? [] : [BoxShadow(color: (_isListening ? Colors.redAccent : EaseTheme.primaryContainer).withOpacity(0.4), blurRadius: 20)],
            ),
            child: Icon(_useKeyboard ? LucideIcons.keyboard : (_isListening ? LucideIcons.square : LucideIcons.mic), color: Colors.white, size: 28),
          ),
        ),
        const SizedBox(width: 24),
        if (!_isListening && hasText)
          _buildActionButton(LucideIcons.check, "Done", _saveAndFinish),
      ],
    );
  }

  Widget _buildActionButton(IconData icon, String label, VoidCallback onTap) {
    return Column(
      children: [
        IconButton(
          icon: Icon(icon, color: Colors.white70),
          onPressed: onTap,
        ),
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 10)),
      ],
    );
  }
}
