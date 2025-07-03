import 'package:flutter/material.dart';

class StoriesRow extends StatelessWidget {
  const StoriesRow({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy stories data
    final stories = List.generate(
      8,
      (i) => {
        'name': i == 0 ? 'Create a story' : 'User $i',
        'image': 'assets/images/default_user.png',
        'isNew': i != 0 && i % 2 == 0,
        'isCreate': i == 0,
      },
    );
    return SizedBox(
      height: 110,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        itemCount: stories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final s = stories[i];
          return Column(
            children: [
              Stack(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color:
                            (s['isNew'] as bool? ?? false)
                                ? const Color(0xFF1877F2)
                                : Colors.transparent,
                        width: 3,
                      ),
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        s['image'] as String,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  if ((s['isCreate'] as bool? ?? false))
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1877F2),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              SizedBox(
                width: 70,
                child: Text(
                  s['name'] as String,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
