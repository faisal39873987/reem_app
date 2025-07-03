import 'package:flutter/material.dart';

class LikeButton extends StatefulWidget {
  final bool isLiked;
  final int likeCount;
  final VoidCallback? onTap;
  const LikeButton({
    super.key,
    required this.isLiked,
    required this.likeCount,
    this.onTap,
  });

  @override
  State<LikeButton> createState() => _LikeButtonState();
}

class _LikeButtonState extends State<LikeButton>
    with SingleTickerProviderStateMixin {
  late bool _liked;
  late int _count;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _liked = widget.isLiked;
    _count = widget.likeCount;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
      lowerBound: 1.0,
      upperBound: 1.3,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleLike() async {
    setState(() {
      _liked = !_liked;
      _count += _liked ? 1 : -1;
    });
    _controller.forward(from: 1.0);
    await Future.delayed(const Duration(milliseconds: 250));
    _controller.reverse();
    if (widget.onTap != null) widget.onTap!();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleLike,
      child: Row(
        children: [
          ScaleTransition(
            scale: _controller.drive(Tween(begin: 1.0, end: 1.3)),
            child: Icon(
              _liked ? Icons.thumb_up : Icons.thumb_up_outlined,
              color: _liked ? const Color(0xFF1877F2) : Colors.grey[700],
              size: 20,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            'Like',
            style: TextStyle(
              color: _liked ? const Color(0xFF1877F2) : Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
          if (_count > 0) ...[
            const SizedBox(width: 2),
            Text(
              _count.toString(),
              style: TextStyle(
                color: _liked ? const Color(0xFF1877F2) : Colors.grey[700],
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
