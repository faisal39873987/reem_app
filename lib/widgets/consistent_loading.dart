import 'package:flutter/material.dart';
import '../utils/constants.dart';

/// Consistent loading widget used throughout the app
class ConsistentLoading extends StatelessWidget {
  final String? message;
  final double size;

  const ConsistentLoading({super.key, this.message, this.size = 40.0});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: const CircularProgressIndicator(
              color: kPrimaryColor,
              strokeWidth: 3.0,
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: const TextStyle(
                color: kTextLight,
                fontSize: 14,
                fontFamily: 'SFPro',
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Consistent empty state widget
class ConsistentEmptyState extends StatelessWidget {
  final String message;
  final IconData icon;
  final VoidCallback? onRetry;

  const ConsistentEmptyState({
    super.key,
    required this.message,
    this.icon = Icons.inbox,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: kTextLight),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: kTextLight,
                fontSize: 16,
                fontFamily: 'SFPro',
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
            ],
          ],
        ),
      ),
    );
  }
}
