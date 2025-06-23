import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

class IntroOverlay extends StatefulWidget {
  final List<GlobalKey> animatedKeys;
  final VoidCallback onFinish;

  const IntroOverlay({
    super.key,
    required this.animatedKeys,
    required this.onFinish,
  });

  @override
  State<IntroOverlay> createState() => _IntroOverlayState();
}

class _IntroOverlayState extends State<IntroOverlay> {
  int _currentStep = 0;
  final List<String> _instructions = [
    'This is the Home button. Tap to view the feed.',
    'This is Reem Youth section. Discover nearby highlights.',
    'This is the Market. Explore items & services.',
    'Tap here to add your own post!',
  ];

  void _nextStep() async {
    if (_currentStep < widget.animatedKeys.length - 1) {
      setState(() => _currentStep++);
    } else {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('intro_done', true);
      widget.onFinish();
    }
  }

  @override
  Widget build(BuildContext context) {
    final RenderBox? targetBox =
        widget.animatedKeys[_currentStep].currentContext?.findRenderObject()
            as RenderBox?;
    final Offset targetOffset =
        targetBox?.localToGlobal(Offset.zero) ?? Offset.zero;
    final Size targetSize = targetBox?.size ?? Size.zero;

    final bool showAbove =
        targetOffset.dy > MediaQuery.of(context).size.height / 2;

    return Stack(
      children: [
        Positioned.fill(
          child: Container(color: Colors.black.withAlpha((0.7 * 255).toInt())),
        ),
        if (targetSize != Size.zero)
          Positioned(
            top: targetOffset.dy - 12,
            left: targetOffset.dx - 12,
            child: Container(
              width: targetSize.width + 24,
              height: targetSize.height + 24,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: kPrimaryColor, width: 4),
              ),
            ),
          ),
        if (targetSize != Size.zero)
          Positioned(
            top:
                showAbove
                    ? targetOffset.dy - targetSize.height - 140
                    : targetOffset.dy + targetSize.height + 24,
            left: 24,
            right: 24,
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: kPrimaryColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      _instructions[_currentStep],
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: kPrimaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: _nextStep,
                      child: Text(
                        _currentStep == widget.animatedKeys.length - 1
                            ? 'Finish'
                            : 'Next',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
