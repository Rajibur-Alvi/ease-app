import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/theme.dart';

class ChatScreen extends StatefulWidget {
  final String partnerName;
  const ChatScreen({Key? key, required this.partnerName}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [
    {"text": "Hi! I saw we both like reading. What are you reading right now?", "isUser": false},
  ];

  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;
    setState(() {
      _messages.add({"text": _controller.text, "isUser": true});
      _controller.clear();
    });
    
    // Simulate response
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _messages.add({"text": "That sounds interesting! I've been meaning to check that out.", "isUser": false});
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EaseTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: Colors.black),
          onPressed: () => context.go('/connections'),
        ),
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(color: EaseTheme.primarySage, shape: BoxShape.circle),
              child: const Icon(LucideIcons.user, size: 16, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Text(widget.partnerName, style: const TextStyle(color: Colors.black, fontSize: 16)),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return Align(
                  alignment: msg['isUser'] ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: msg['isUser'] ? EaseTheme.primaryContainer : Colors.white,
                      borderRadius: BorderRadius.circular(20).copyWith(
                        bottomRight: msg['isUser'] ? const Radius.circular(0) : const Radius.circular(20),
                        bottomLeft: msg['isUser'] ? const Radius.circular(20) : const Radius.circular(0),
                      ),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                    ),
                    child: Text(
                      msg['text'],
                      style: TextStyle(color: msg['isUser'] ? Colors.white : Colors.black87),
                    ),
                  ),
                );
              },
            ),
          ),
          _buildInput(),
        ],
      ),
    );
  }

  Widget _buildInput() {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: "Send a message...",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                  filled: true,
                  fillColor: EaseTheme.background,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                ),
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: _sendMessage,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(color: EaseTheme.primaryContainer, shape: BoxShape.circle),
                child: const Icon(LucideIcons.send, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
