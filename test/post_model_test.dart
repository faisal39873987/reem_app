import 'package:flutter_test/flutter_test.dart';
import 'package:reem_verse_rebuild/models/post.dart';

void main() {
  group('Post.fromMap', () {
    test('parses all types robustly', () {
      final now = DateTime.now();
      final post = Post.fromMap('123', {
        'imageUrl': 456, // int
        'description': null,
        'price': '99.5',
        'creatorId': 789,
        'category': null,
        'isAnonymous': 1,
        'latitude': '24.5',
        'longitude': 55,
        'timestamp': now.toIso8601String(),
      });
      expect(post.id, '123');
      expect(post.imageUrl, '456');
      expect(post.description, '');
      expect(post.price, 99.5);
      expect(post.creatorId, '789');
      expect(post.category, 'Services');
      expect(post.isAnonymous, true);
      expect(post.latitude, 24.5);
      expect(post.longitude, 55.0);
      expect(post.timestamp.difference(now).inSeconds.abs() < 2, true);
    });

    test('handles nulls and missing fields', () {
      final post = Post.fromMap('id', {});
      expect(post.id, 'id');
      expect(post.imageUrl, '');
      expect(post.description, '');
      expect(post.price, 0.0);
      expect(post.creatorId, '');
      expect(post.category, 'Services');
      expect(post.isAnonymous, false);
      expect(post.latitude, 0.0);
      expect(post.longitude, 0.0);
      expect(post.timestamp, isA<DateTime>());
    });

    test('parses int/double/string timestamps', () {
      final post1 = Post.fromMap('id', {'timestamp': 1650000000}); // seconds
      final post2 = Post.fromMap('id', {'timestamp': 1650000000000}); // ms
      final post3 = Post.fromMap('id', {'timestamp': '2022-04-15T12:00:00Z'});
      expect(post1.timestamp.year, greaterThan(2000));
      expect(post2.timestamp.year, greaterThan(2000));
      expect(post3.timestamp.year, 2022);
    });
  });
}
