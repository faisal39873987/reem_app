import 'package:flutter/material.dart';

class ChatInputBar extends StatefulWidget {
  final void Function(String) onSend;
  const ChatInputBar({super.key, required this.onSend});

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  final TextEditingController _controller = TextEditingController();
  bool _sending = false;

  void _handleSend() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _sending) return;
    setState(() => _sending = true);
    widget.onSend(text);
    _controller.clear();
    await Future.delayed(const Duration(milliseconds: 300));
    setState(() => _sending = false);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isRTL = Directionality.of(context) == TextDirection.rtl;
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        color: Colors.white,
        child: Row(
          children: [
            IconButton(
              icon: const Icon(
                Icons.camera_alt_outlined,
                color: Color(0xFF1877F2),
              ),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.attach_file, color: Color(0xFF1877F2)),
              onPressed: () {},
            ),
            Expanded(
              child: TextField(
                controller: _controller,
                minLines: 1,
                maxLines: 4,
                textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
                decoration: InputDecoration(
                  hintText: isRTL ? 'اكتب رسالة...' : 'Écrire un message...',
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                ),
                onSubmitted: (_) => _handleSend(),
              ),
            ),
            const SizedBox(width: 6),
            IconButton(
              icon:
                  _sending
                      ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                      : Icon(
                        Icons.send,
                        color:
                            _controller.text.trim().isEmpty
                                ? Colors.grey
                                : const Color(0xFF1877F2),
                      ),
              onPressed:
                  _controller.text.trim().isEmpty || _sending
                      ? null
                      : _handleSend,
            ),
          ],
        ),
      ),
    );
  }
}
