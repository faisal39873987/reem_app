import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../utils/constants.dart';
import '../models/notification.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/empty_state.dart';
import '../widgets/error_state.dart';
import '../widgets/skeleton_loader.dart';
import '../widgets/rv_bottom_nav_bar.dart';

class NotificationScreen extends StatefulWidget {
  final List<AppNotification>? testNotifications;
  const NotificationScreen({super.key, this.testNotifications});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  int unreadCount = 0;
  List<AppNotification> _notifications = [];
  bool _loading = true;
  String? _error;
  // TODO: Use Supabase real-time stream for notifications
  // TODO: Modularize notification tile, actions, and permissions
  // TODO: Add admin/moderator notification controls

  @override
  void initState() {
    super.initState();
    if (widget.testNotifications != null) {
      _notifications = widget.testNotifications!;
      _loading = false;
    } else {
      _fetchNotifications();
    }
  }

  Future<void> _fetchNotifications() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      // Replace with your Supabase notifications fetch logic
      final res = await Supabase.instance.client
          .from('notifications')
          .select()
          .order('created_at', ascending: false);
      if (!mounted) return;
      setState(() {
        _notifications =
            List<Map<String, dynamic>>.from(
              res,
            ).map((e) => AppNotification.fromMap(e)).toList();
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _refreshNotifications() async {
    await _fetchNotifications();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Notifications refreshed.')));
  }

  @override
  Widget build(BuildContext context) {
    const blue = kPrimaryColor;
    if (_loading) {
<<<<<<< HEAD
      return Scaffold(
        body: Center(child: SkeletonLoader(height: 64, count: 6)),
      );
=======
      return Scaffold(body: Center(child: CircularProgressIndicator()));
>>>>>>> 7376d04ed9157adca11b4d81bfec7683e877da79
    }
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 1,
          leading: BackButton(color: blue),
<<<<<<< HEAD
          title: Text(
            'Notifications',
            style: TextStyle(color: blue, fontFamily: 'SFPro'),
=======
          title: Text('Notifications', style: TextStyle(color: blue)),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red),
              SizedBox(height: 16),
              Text(
                _error!,
                style: TextStyle(fontSize: 18, color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ],
>>>>>>> 7376d04ed9157adca11b4d81bfec7683e877da79
          ),
        ),
        body: ErrorState(message: _error!, onRetry: _fetchNotifications),
      );
    }
    if (_notifications.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 1,
          leading: BackButton(color: blue),
<<<<<<< HEAD
          title: Text(
            'Notifications',
            style: TextStyle(color: blue, fontFamily: 'SFPro'),
          ),
        ),
        body: const EmptyState(
          message: 'No notifications found.',
          icon: Icons.notifications_none,
        ),
=======
          title: Text('Notifications', style: TextStyle(color: blue)),
        ),
        body: Center(child: Text('No notifications found.')),
>>>>>>> 7376d04ed9157adca11b4d81bfec7683e877da79
      );
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
<<<<<<< HEAD
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: blue),
          onPressed:
              () => Navigator.of(context).pushReplacementNamed('/landing'),
        ),
=======
        leading: BackButton(color: blue),
>>>>>>> 7376d04ed9157adca11b4d81bfec7683e877da79
        title: Row(
          children: [
            Text(
              "Notifications",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: blue,
              ),
            ),
            if (unreadCount > 0) ...[
              SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  unreadCount.toString(),
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ],
          ],
        ),
        actions: [
          if (unreadCount > 0)
            TextButton(
              onPressed: () {},
              child: Text("Mark all as read", style: TextStyle(color: blue)),
            ),
        ],
      ),
      backgroundColor: Colors.white,
      extendBody: true,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child:
                _loading
                    ? const Center(child: CircularProgressIndicator())
                    : _error != null
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(
                            Icons.notifications_off,
                            size: 64,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Notifications are currently unavailable.',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                    : _notifications.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(
                            Icons.notifications_none,
                            size: 64,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No notifications found.',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                    : RefreshIndicator(
                      onRefresh: _refreshNotifications,
                      child: ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        itemCount: _notifications.length,
                        separatorBuilder: (context, _) => const Divider(),
                        itemBuilder: (context, index) {
                          final notif = _notifications[index];
                          final title =
                              notif.title.isNotEmpty
                                  ? notif.title
                                  : 'Notification';
                          final subtitle = notif.body;
                          final createdAt = notif.createdAt;
                          final timeText = DateFormat.yMMMd().add_jm().format(
                            createdAt,
                          );
                          return ListTile(
                            leading: const Icon(
                              Icons.notifications,
                              color: kPrimaryColor,
                            ),
                            title: Text(title),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(subtitle),
                                if (timeText.isNotEmpty)
                                  Text(
                                    timeText,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
          ),
        ],
      ),
      floatingActionButton: Transform.translate(
        offset: const Offset(0, -8),
        child: FloatingActionButton(
          heroTag: 'fab_notification',
          onPressed: () => Navigator.of(context).pushNamed('/post'),
          backgroundColor: blue,
          shape: const CircleBorder(),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: const RVBottomNavBar(currentIndex: 3),
    );
  }
}
