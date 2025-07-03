import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'notification_screen.dart';
import 'post_creation_screen.dart';
import '../utils/constants.dart';
import '../widgets/empty_state.dart';
import '../widgets/error_state.dart';
import '../widgets/skeleton_loader.dart';
import '../widgets/rv_bottom_nav_bar.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchTerm = '';
  // TODO: Modularize search result widget (post, user, marketplace, etc)
  // TODO: Add advanced filter/sort modal
  // TODO: Add permissions for search visibility (admin/mod/user/guest)

  @override
  Widget build(BuildContext context) {
    const blueColor = kPrimaryColor;
    return Scaffold(
      backgroundColor: Colors.white,
      extendBody: true,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ الشريط العلوي مع سهم الرجوع
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: blueColor),
                    onPressed:
                        () => Navigator.of(
                          context,
                        ).pushReplacementNamed('/landing'),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "Search",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: blueColor,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(
                      Icons.notifications_none,
                      color: blueColor,
                    ),
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (_) => const NotificationScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  if (!mounted) return;
                  setState(() => _searchTerm = value.trim());
                },
                decoration: const InputDecoration(
                  labelText: "Search posts and services",
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            Expanded(
              child:
                  _searchTerm.isEmpty
                      ? const Center(
                        child: Text(
                          "Enter a keyword to search",
                          style: TextStyle(fontFamily: 'SFPro'),
                        ),
                      )
                      : FutureBuilder<List<dynamic>>(
                        // TODO: Replace dynamic with proper model
                        future: _performSearch(_searchTerm),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return SkeletonLoader(height: 64, count: 6);
                          }
                          if (snapshot.hasError) {
                            return ErrorState(
                              message: 'Error: \\${snapshot.error}',
                              onRetry: () => setState(() {}),
                            );
                          }
                          final results = snapshot.data ?? [];
                          if (results.isEmpty) {
                            return const EmptyState(
                              message: 'No results found.',
                              icon: Icons.search,
                            );
                          }
                          return ListView.builder(
                            itemCount: results.length,
                            itemBuilder: (context, i) {
                              final result = results[i];
                              final isPost = result.containsKey('content');

                              return Card(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 4,
                                ),
                                child: ListTile(
                                  leading:
                                      result['image_url'] != null &&
                                              result['image_url'].isNotEmpty
                                          ? ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            child: Image.network(
                                              result['image_url'],
                                              width: 50,
                                              height: 50,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (
                                                    context,
                                                    error,
                                                    stackTrace,
                                                  ) => const Icon(
                                                    Icons.image_not_supported,
                                                  ),
                                            ),
                                          )
                                          : Icon(
                                            isPost
                                                ? Icons.article
                                                : Icons.store,
                                          ),
                                  title: Text(
                                    result['title'] ?? 'No title',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'SFPro',
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        isPost
                                            ? (result['content'] ?? '')
                                                    .toString()
                                                    .substring(
                                                      0,
                                                      ((result['content'] ?? '')
                                                                  .toString()
                                                                  .length >
                                                              100
                                                          ? 100
                                                          : (result['content'] ??
                                                                  '')
                                                              .toString()
                                                              .length),
                                                    ) +
                                                ((result['content'] ?? '')
                                                            .toString()
                                                            .length >
                                                        100
                                                    ? '...'
                                                    : '')
                                            : result['description'] ?? '',
                                        style: const TextStyle(
                                          fontFamily: 'SFPro',
                                        ),
                                      ),
                                      if (!isPost && result['price'] != null)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            top: 4,
                                          ),
                                          child: Text(
                                            '\$${result['price']}',
                                            style: const TextStyle(
                                              color: Colors.green,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: 'SFPro',
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  trailing: Chip(
                                    label: Text(
                                      isPost ? 'Post' : 'Product',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontFamily: 'SFPro',
                                      ),
                                    ),
                                    backgroundColor:
                                        isPost
                                            ? Colors.blue.shade100
                                            : Colors.green.shade100,
                                  ),
                                  onTap: () {
                                    if (isPost) {
                                      Navigator.pushNamed(
                                        context,
                                        '/post-details',
                                        arguments: {'postId': result['id']},
                                      );
                                    } else {
                                      // Navigate to product details
                                      Navigator.of(
                                        context,
                                      ).pushNamed('/marketplace');
                                    }
                                  },
                                ),
                              );
                            },
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
      floatingActionButton: Transform.translate(
        offset: const Offset(0, -8),
        child: FloatingActionButton(
          heroTag: 'fab_search',
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const PostCreationScreen()),
            );
          },
          backgroundColor: blueColor,
          shape: const CircleBorder(),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: const RVBottomNavBar(
        currentIndex: -1,
      ), // Search doesn't have index in main nav
    );
  }

  Future<List<dynamic>> _performSearch(String term) async {
    final supabase = Supabase.instance.client;
    // بحث في جدول المنشورات
    final posts = await supabase
        .from('posts')
        .select('id, title, content, image_url')
        .ilike('title', '%$term%');
    // بحث في جدول الماركت بليس
    final products = await supabase
        .from('marketplace')
        .select('id, title, description, price, image_url')
        .ilike('title', '%$term%');
    // دمج النتائج
    final results = <Map<String, dynamic>>[];
    results.addAll(List<Map<String, dynamic>>.from(posts));
    results.addAll(List<Map<String, dynamic>>.from(products));
    return results;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
