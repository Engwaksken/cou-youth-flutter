import 'package:flutter/material.dart';

import '../core/api/api_client.dart';
import '../core/theme/app_colors.dart';
import '../services/chatbot_service.dart';
import '../widgets/youth_screen_scaffold.dart';
import 'accessibility_screen.dart';
import 'church_locator_screen.dart';
import 'courses_screen.dart';
import 'events_screen.dart';
import 'prayer_screen.dart';
import 'safety_center_screen.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key, this.service});

  final ChatbotService? service;

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  late final ChatbotService _service;
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final List<_ChatMessage> _messages = [
    const _ChatMessage(
      text:
          'Hello! I am the COU Youth Assistant. I can help you find events, courses, churches, prayer support, accessibility help and other youth resources.',
      fromUser: false,
    ),
  ];

  bool _busy = false;

  static const _quickPrompts = <String>[
    'Find an event',
    'Show available courses',
    'Find a church',
    'Prayer support',
    'Accessibility help',
    'How do I donate?',
  ];

  @override
  void initState() {
    super.initState();
    _service = widget.service ?? ChatbotService();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _send([String? preset]) async {
    final message = (preset ?? _messageController.text).trim();
    if (message.isEmpty || _busy) return;

    setState(() {
      _messages.add(_ChatMessage(text: message, fromUser: true));
      _messageController.clear();
      _busy = true;
    });
    _scrollToBottom();

    try {
      final reply = await _service.ask(message);
      if (!mounted) return;
      setState(() {
        _messages.add(_ChatMessage(text: reply, fromUser: false));
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _messages.add(
          _ChatMessage(text: e.message, fromUser: false, isError: true),
        );
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _messages.add(
          const _ChatMessage(
            text:
                'The assistant is temporarily unavailable. You can still use the quick support actions below.',
            fromUser: false,
            isError: true,
          ),
        );
      });
    } finally {
      if (mounted) {
        setState(() => _busy = false);
        _scrollToBottom();
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            : const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  void _open(Widget screen) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    return YouthScreenScaffold(
      title: 'Youth Assistant',
      subtitle: 'Ask about events, courses, churches, prayer and youth support.',
      leading: IconButton(
        tooltip: 'Back',
        onPressed: () => Navigator.of(context).maybePop(),
        icon: const Icon(Icons.arrow_back_rounded),
      ),
      actions: [
        IconButton(
          tooltip: 'Accessibility settings',
          onPressed: () => _open(const AccessibilityScreen()),
          icon: const Icon(Icons.accessibility_new_outlined, color: Colors.white),
        ),
      ],
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
              color: AppColors.surfaceSoft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quick help',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        for (final prompt in _quickPrompts) ...[
                          ActionChip(
                            label: Text(prompt),
                            onPressed: _busy ? null : () => _send(prompt),
                          ),
                          const SizedBox(width: 8),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _SupportAction(
                        icon: Icons.volunteer_activism_outlined,
                        label: 'Prayer',
                        onPressed: () => _open(const PrayerScreen()),
                      ),
                      _SupportAction(
                        icon: Icons.shield_outlined,
                        label: 'Safety',
                        onPressed: () => _open(const SafetyCenterScreen()),
                      ),
                      _SupportAction(
                        icon: Icons.event_outlined,
                        label: 'Events',
                        onPressed: () => _open(const EventsScreen()),
                      ),
                      _SupportAction(
                        icon: Icons.menu_book_outlined,
                        label: 'Courses',
                        onPressed: () => _open(const CoursesScreen()),
                      ),
                      _SupportAction(
                        icon: Icons.location_on_outlined,
                        label: 'Churches',
                        onPressed: () => _open(const ChurchLocatorScreen()),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  return Semantics(
                    label: message.fromUser
                        ? 'Your message: ${message.text}'
                        : 'Youth Assistant: ${message.text}',
                    child: Align(
                      alignment: message.fromUser
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 520),
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 11,
                        ),
                        decoration: BoxDecoration(
                          color: message.fromUser
                              ? AppColors.primary
                              : message.isError
                                  ? Theme.of(context).colorScheme.errorContainer
                                  : AppColors.primaryLight,
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(16),
                            topRight: const Radius.circular(16),
                            bottomLeft: Radius.circular(message.fromUser ? 16 : 4),
                            bottomRight: Radius.circular(message.fromUser ? 4 : 16),
                          ),
                          border: message.fromUser
                              ? null
                              : Border.all(color: AppColors.border),
                        ),
                        child: Text(
                          message.text,
                          style: TextStyle(
                            color: message.fromUser
                                ? Colors.white
                                : message.isError
                                    ? Theme.of(context).colorScheme.onErrorContainer
                                    : AppColors.textPrimary,
                            height: 1.45,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            if (_busy)
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary,
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Youth Assistant is preparing a response…',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ),
            Container(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      minLines: 1,
                      maxLines: 5,
                      textInputAction: TextInputAction.newline,
                      decoration: const InputDecoration(
                        hintText: 'Ask the Youth Assistant…',
                        prefixIcon: Icon(Icons.chat_bubble_outline_rounded),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    tooltip: 'Send message',
                    onPressed: _busy ? null : () => _send(),
                    icon: const Icon(Icons.send_rounded),
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

class _SupportAction extends StatelessWidget {
  const _SupportAction({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '$label support shortcut',
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(label),
      ),
    );
  }
}

class _ChatMessage {
  const _ChatMessage({
    required this.text,
    required this.fromUser,
    this.isError = false,
  });

  final String text;
  final bool fromUser;
  final bool isError;
}
