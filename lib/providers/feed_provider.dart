import 'package:flutter/material.dart';
import '../models/post.dart';
import '../services/feed_service.dart';

class FeedProvider extends ChangeNotifier {
  final FeedService _feedService = FeedService();
  List<Post> _posts = [];
  bool _loading = false;
  String? _error;
  bool _initialized = false;

  List<Post> get posts => _posts;
  bool get loading => _loading;
  String? get error => _error;
  bool get initialized => _initialized;

  Future<void> fetchPosts({bool force = false}) async {
    if (_loading || (_initialized && !force)) return;
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _posts = await _feedService.fetchPosts();
      _initialized = true;
    } catch (e) {
      _error = e.toString();
    }
    _loading = false;
    notifyListeners();
  }

  void refresh() => fetchPosts(force: true);
}
