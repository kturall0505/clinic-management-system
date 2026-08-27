import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/ai_service.dart';

class AssistantScreen extends StatefulWidget {
  const AssistantScreen({super.key});

  @override
  State<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends State<AssistantScreen> {
  final _controller = TextEditingController();
  final List<_Message> _messages = [];
  bool _isLoading = false;
  final ScrollController _scrollController = ScrollController();

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(_Message(text: text, isUser: true));
      _isLoading = true;
    });
    _controller.clear();
    _scrollToBottom();

    final ai = context.read<AiService>();
    try {
      final answer = await ai.ask(text);

      if (mounted) {
        setState(() {
          _messages.add(_Message(text: answer, isUser: false));
          _isLoading = false;
        });
        _scrollToBottom();
      }
    } on Exception catch (e) {
      if (mounted) {
        setState(() {
          _messages.add(_Message(text: 'Xəta baş verdi: $e', isUser: false, isError: true));
          _isLoading = false;
        });
        _scrollToBottom();
      }
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Expanded(
          child: _messages.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.smart_toy_rounded, size: 64, color: theme.colorScheme.primary.withValues(alpha: 0.6)),
                      const SizedBox(height: AppTheme.spacing4),
                      Text(
                        'AI Asistente xoş gəlmisiniz',
                        style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: AppTheme.spacing2),
                      Text(
                        'Sualınızı yazın, kömək edəcəm',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppTheme.spacing4),
                      Wrap(
                        spacing: AppTheme.spacing2,
                        runSpacing: AppTheme.spacing2,
                        children: [
                          _SuggestionChip(
                            label: 'Randevu necə yaradılır?',
                            onTap: () {
                              _controller.text = 'Randevu necə yaradılır?';
                              _send();
                            },
                          ),
                          _SuggestionChip(
                            label: 'Pasient əlavə et',
                            onTap: () {
                              _controller.text = 'Pasient necə əlavə edilir?';
                              _send();
                            },
                          ),
                          _SuggestionChip(
                            label: 'Həkim idarəetməsi',
                            onTap: () {
                              _controller.text = 'Həkimlər necə idarə olunur?';
                              _send();
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(AppTheme.spacing4),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final msg = _messages[index];
                    return Align(
                      alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: AppTheme.spacing1),
                        padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing4, vertical: AppTheme.spacing3),
                        decoration: BoxDecoration(
                          color: msg.isError
                              ? AppTheme.errorContainer
                              : msg.isUser
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(AppTheme.spacing3).copyWith(
                            bottomRight: msg.isUser ? Radius.zero : null,
                            bottomLeft: msg.isUser ? null : Radius.zero,
                          ),
                        ),
                        child: Text(
                          msg.text,
                          style: TextStyle(
                            color: msg.isUser && !msg.isError
                                ? theme.colorScheme.onPrimary
                                : theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                    );
                  },
                ),
      ),
      if (_isLoading)
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: AppTheme.spacing4),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: AppTheme.spacing2),
              child: SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ),
        ),
      Padding(
        padding: const EdgeInsets.all(AppTheme.spacing4),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: 'Sualınızı yazın...',
                  suffixIcon: _controller.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded),
                          onPressed: () => _controller.clear(),
                        )
                      : null,
                ),
                onSubmitted: (_) => _send(),
              ),
            ),
            const SizedBox(width: AppTheme.spacing2),
            IconButton.filled(
              onPressed: _isLoading ? null : _send,
              icon: const Icon(Icons.send_rounded),
            ),
          ],
        ),
      ),
    );
  }
}

class _Message {
  final String text;
  final bool isUser;
  final bool isError;

  _Message({required this.text, required this.isUser, this.isError = false});
}

class _SuggestionChip extends StatelessWidget {
  const _SuggestionChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ActionChip(
      label: Text(label, style: const TextStyle(fontSize: 13)),
      onPressed: onTap,
      backgroundColor: theme.colorScheme.surfaceContainerHighest,
      side: BorderSide(color: theme.colorScheme.outline),
    );
  }
}
