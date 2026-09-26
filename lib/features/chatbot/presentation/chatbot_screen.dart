import 'package:flutter/material.dart';
import '../data/chatbot_service.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key, required this.service});
  final ChatbotService service;

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final _controller = TextEditingController();
  final List<({bool user, String text})> _messages = [];
  bool _sending = false;

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _sending) return;
    setState(() {
      _sending = true;
      _messages.add((user: true, text: text));
      _controller.clear();
    });
    try {
      final reply = await widget.service.send(text);
      if (mounted) setState(() => _messages.add((user: false, text: reply)));
    } catch (e) {
      if (mounted)
        setState(
          () => _messages.add((
            user: false,
            text:
                'Our assistant is temporarily unavailable. Please try again later.',
          )),
        );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Youth Assistant')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (_, i) {
                final m = _messages[i];
                return Semantics(
                  label: m.user ? 'Your message' : 'Assistant message',
                  child: Align(
                    alignment: m.user
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(m.text),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      minLines: 1,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: 'Ask a question',
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Send message',
                    onPressed: _sending ? null : _send,
                    icon: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
