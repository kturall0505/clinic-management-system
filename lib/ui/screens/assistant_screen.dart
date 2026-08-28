import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/services/ai_service.dart';

class _ChatMessage {
  const _ChatMessage(this.text, {required this.fromUser});
  final String text;
  final bool fromUser;
}

class AssistantScreen extends StatefulWidget {
  const AssistantScreen({super.key});
  @override State<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends State<AssistantScreen> {
  final _controller = TextEditingController();
  final _messages = [_ChatMessage('Salam!', fromUser: false)];
  bool _thinking = false;

  @override void dispose() { _controller.dispose(); super.dispose(); }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _thinking) return;
    setState(() { _messages.add(_ChatMessage(text, fromUser: true)); _controller.clear(); _thinking = true; });
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() { _messages.add(_ChatMessage('Cavab hazirdir.', fromUser: false)); _thinking = false; });
  }

  @override Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              return Align(
                alignment: _messages[index].fromUser ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  padding: const EdgeInsets.all(12),
                  constraints: const BoxConstraints(maxWidth: 480),
                  decoration: BoxDecoration(
                    color: _messages[index].fromUser ? scheme.primaryContainer : scheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(_messages[index].text),
                ),
              );
            },
          ),
        ),
        if (_thinking) const LinearProgressIndicator(),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(child: TextField(controller: _controller, decoration: const InputDecoration(hintText: 'Sualinizi yazin...'), onSubmitted: (_) => _send())),
                const SizedBox(width: 8),
                IconButton.filled(onPressed: _send, icon: const Icon(Icons.send), tooltip: 'Gonder'),
              ],
            ),
          ),
        ),
      ],
    );
  }
}