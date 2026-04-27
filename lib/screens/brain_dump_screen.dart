import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../theme/theme.dart';
import '../services/app_state_provider.dart';
import '../services/ai_service.dart';

class BrainDumpScreen extends StatefulWidget {
  const BrainDumpScreen({Key? key}) : super(key: key);

  @override
  State<BrainDumpScreen> createState() => _BrainDumpScreenState();
}

class _BrainDumpScreenState extends State<BrainDumpScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _cursorController;
  final TextEditingController _textController = TextEditingController();
  final AiService _aiService = AiService();
  String? _detectedCategory;

  @override
  void initState() {
    super.initState();
    _cursorController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);

    _textController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    setState(() {
      _detectedCategory = _aiService.categorizeThought(_textController.text).name;
    });
  }

  @override
  void dispose() {
    _cursorController.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _saveAndFinish() {
    final text = _textController.text.trim();
    if (text.isNotEmpty) {
      context.read<AppStateProvider>().addEntry(text);
    }
    context.go('/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EaseTheme.surfaceContainerLow,
      body: SafeArea(
        child: Stack(
          children: [
            // Header
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: EaseTheme.surface,
                        boxShadow: EaseTheme.neumorphicShadows,
                      ),
                      child: IconButton(
                        icon: const Icon(LucideIcons.x, color: EaseTheme.onSurfaceVariant),
                        onPressed: () => context.go('/dashboard'),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: EaseTheme.primaryContainer.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(40),
                        border: Border.all(color: Colors.white.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: EaseTheme.primaryContainer,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "FLOWING",
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: EaseTheme.onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Main Content
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // AI Prompt
                    RichText(
                      text: TextSpan(
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontSize: 28,
                              color: EaseTheme.secondary.withOpacity(0.8),
                              fontStyle: FontStyle.italic,
                              fontFamily: 'Noto Serif',
                            ),
                        children: [
                          const TextSpan(text: "What's on your mind? \n"),
                          TextSpan(
                            text: "Anything. Everything.",
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  fontSize: 28,
                                  color: EaseTheme.onSurface,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 48),

                    // Input Section
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _textController,
                            autofocus: true,
                            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                  fontSize: 32,
                                ),
                            decoration: InputDecoration(
                              hintText: "Start anywhere...",
                              hintStyle: Theme.of(context).textTheme.displayLarge?.copyWith(
                                    fontSize: 32,
                                    color: EaseTheme.onSurface.withOpacity(0.2),
                                  ),
                              border: InputBorder.none,
                            ),
                            maxLines: null,
                          ),
                        ),
                        if (_textController.text.isNotEmpty)
                          AnimatedBuilder(
                            animation: _cursorController,
                            builder: (context, child) {
                              return Opacity(
                                opacity: _cursorController.value,
                                child: Container(
                                  width: 3,
                                  height: 40,
                                  color: EaseTheme.primarySage,
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Categorization Tag (Visible only when category detected)
                    if (_detectedCategory != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: EaseTheme.primarySage,
                          borderRadius: BorderRadius.circular(40),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(LucideIcons.sparkles, color: Colors.white, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              _detectedCategory!,
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: Colors.white,
                                  ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Bottom Toolbar
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(60),
                    border: Border.all(color: Colors.white.withOpacity(0.5)),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 20,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: () => context.go('/voice-mode'),
                        child: Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: EaseTheme.surface,
                            boxShadow: EaseTheme.neumorphicShadows,
                          ),
                          child: const Icon(LucideIcons.mic, color: EaseTheme.primarySage, size: 28),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        width: 1,
                        height: 32,
                        color: EaseTheme.outline.withOpacity(0.3),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: _saveAndFinish,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: EaseTheme.primarySage,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(40),
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(
                              "Done",
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                    fontSize: 18,
                                    color: Colors.white,
                                  ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(LucideIcons.arrowRight, size: 20),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
