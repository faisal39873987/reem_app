import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../widgets/feed_app_bar.dart';
import '../models/post.dart';
import '../models/product.dart';
import '../services/marketplace_service.dart';
import '../services/likes_service.dart';
import '../widgets/rv_bottom_nav_bar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<List<Post>> fetchFeedPosts() async {
  final client = Supabase.instance.client;
  final currentUser = client.auth.currentUser;

  // Fetch posts with user profile data and like information
  final postsRes = await client
      .from('posts')
      .select('''
        *,
        profiles!posts_user_id_fkey (
          full_name,
          avatar_url
        )
      ''')
      .order('created_at', ascending: false);

  final posts = <Post>[];

  for (final postData in postsRes) {
    final postMap = Map<String, dynamic>.from(postData);
    final profile = postMap['profiles'];

    // Add profile data to post data for easier access
    if (profile != null) {
      postMap['user_name'] = profile['full_name'];
      postMap['user_avatar_url'] = profile['avatar_url'];
    }

    // Get like count for this post
    final likesRes = await client
        .from('post_likes')
        .select()
        .eq('post_id', postMap['id']);
    postMap['like_count'] = likesRes.length;

    // Check if current user liked this post
    if (currentUser != null) {
      final userLikeRes =
          await client
              .from('post_likes')
              .select()
              .eq('post_id', postMap['id'])
              .eq('user_id', currentUser.id)
              .maybeSingle();
      postMap['is_liked'] = userLikeRes != null;
    } else {
      postMap['is_liked'] = false;
    }

    posts.add(Post.fromMap(postMap['id'] ?? '', postMap));
  }

  return posts;
}

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: const FeedAppBar(),
      body: const _LandingBody(),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: RVBottomNavBar(currentIndex: 0),
      ),
    );
  }
}

class _LandingBody extends StatelessWidget {
  const _LandingBody();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 18),
          _MarketplaceForYouSection(),
          const SizedBox(height: 18),
          _TimelinePostsSection(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _TimelinePostsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Post>>(
      future: fetchFeedPosts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.only(top: 32),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return const Padding(
            padding: EdgeInsets.only(top: 32),
            child: Center(child: Text('Error loading posts')),
          );
        }
        final posts = snapshot.data ?? [];
        if (posts.isEmpty) {
          return const Padding(
            padding: EdgeInsets.only(top: 32),
            child: Center(child: Text('No posts found.')),
          );
        }
        return Column(
          children: List.generate(
            posts.length,
            (i) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 6),
              child: FbHomePostCard(post: posts[i]),
            ),
          ),
        );
      },
    );
  }
}

// ENHANCED FACEBOOK-STYLE POST CARD WITH LIKE FUNCTIONALITY
class FbHomePostCard extends StatefulWidget {
  final Post post;
  const FbHomePostCard({required this.post, super.key});

  @override
  State<FbHomePostCard> createState() => _FbHomePostCardState();
}

class _FbHomePostCardState extends State<FbHomePostCard> {
  bool isLiked = false;
  int likeCount = 0;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
<<<<<<< HEAD
    _loadLikeStatus();
  }

  Future<void> _loadLikeStatus() async {
    try {
      final liked = await LikesService.isPostLikedByUser(widget.post.id);
      final count = await LikesService.getPostLikeCount(widget.post.id);
      if (mounted) {
        setState(() {
          isLiked = liked;
          likeCount = count;
        });
      }
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> _toggleLike() async {
    if (isLoading) return;

    setState(() => isLoading = true);

    try {
      final newLikedState = await LikesService.togglePostLike(widget.post.id);
      if (mounted) {
        setState(() {
          isLiked = newLikedState;
          likeCount += newLikedState ? 1 : -1;
          isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(newLikedState ? 'Post liked!' : 'Post unliked!'),
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to update like')));
      }
    }
  }

  void _openPostDetails({bool openComments = false}) {
    Navigator.pushNamed(
      context,
      '/post-details',
      arguments: {'postId': widget.post.id, 'openComments': openComments},
    );
  }

  void _sharePost() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Shared post: ${widget.post.title}')),
    );
=======
    Future.microtask(() {
      if (!mounted) return;
      Provider.of<FeedProvider>(context, listen: false).fetchPosts();
    });
>>>>>>> 7376d04ed9157adca11b4d81bfec7683e877da79
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openPostDetails(),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User info header
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundImage:
                      widget.post.userAvatarUrl != null &&
                              widget.post.userAvatarUrl!.isNotEmpty
                          ? NetworkImage(widget.post.userAvatarUrl!)
                          : null,
                  backgroundColor: Colors.grey.shade300,
                  child:
                      (widget.post.userAvatarUrl == null ||
                              widget.post.userAvatarUrl!.isEmpty)
                          ? const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 28,
                          )
                          : null,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.post.userName ?? 'User',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15.5,
                          color: Colors.black,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Row(
                        children: [
                          Text(
                            widget.post.timeAgo,
                            style: TextStyle(
                              fontSize: 12.5,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.public,
                            size: 13,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.more_horiz,
                    color: Colors.grey,
                    size: 22,
                  ),
                  onPressed: () {},
                  splashRadius: 20,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),

            // Post content
            if (widget.post.description.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                widget.post.description,
                style: const TextStyle(fontSize: 15.5, color: Colors.black),
                maxLines: 6,
                overflow: TextOverflow.ellipsis,
              ),
            ],

            // Post images
            if ((widget.post.images.isNotEmpty) ||
                (widget.post.imageUrl.isNotEmpty)) ...[
              const SizedBox(height: 10),
              FbPostImagesGrid(
                images:
                    widget.post.images.isNotEmpty
                        ? widget.post.images
                        : [widget.post.imageUrl],
              ),
            ],

            const SizedBox(height: 10),

            // Action buttons with like functionality
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                FbActionButton(
                  icon: isLiked ? Icons.thumb_up : Icons.thumb_up_alt_outlined,
                  label: likeCount > 0 ? 'Like ($likeCount)' : 'Like',
                  onPressed: _toggleLike,
                  color: isLiked ? const Color(0xFF1877F2) : null,
                ),
                FbActionButton(
                  icon: Icons.mode_comment_outlined,
                  label: 'Comment',
                  onPressed: () => _openPostDetails(openComments: true),
                ),
                FbActionButton(
                  icon: Icons.reply,
                  label: 'Share',
                  onPressed: _sharePost,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Facebook-style action button
class FbActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final Color? color;

  const FbActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.color,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final buttonColor = color ?? Colors.grey.shade600;
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: buttonColor),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: buttonColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Images grid for posts
class FbPostImagesGrid extends StatelessWidget {
  final List<String> images;
  const FbPostImagesGrid({required this.images, super.key});

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(10);
    if (images.length == 1) {
      return ClipRRect(
        borderRadius: borderRadius,
        child: AspectRatio(
          aspectRatio: 1.5,
          child: CachedNetworkImage(
            imageUrl: images[0],
            fit: BoxFit.cover,
            placeholder:
                (context, url) => Container(color: Colors.grey.shade200),
            errorWidget:
                (context, url, error) => Container(
                  color: Colors.grey.shade200,
                  child: const Icon(
                    Icons.broken_image,
                    color: Colors.grey,
                    size: 48,
                  ),
                ),
          ),
        ),
      );
    } else if (images.length == 2) {
      return Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 2),
              child: ClipRRect(
                borderRadius: borderRadius,
                child: AspectRatio(
                  aspectRatio: 1,
                  child: CachedNetworkImage(
                    imageUrl: images[0],
                    fit: BoxFit.cover,
                    placeholder:
                        (context, url) =>
                            Container(color: Colors.grey.shade200),
                    errorWidget:
                        (context, url, error) => Container(
                          color: Colors.grey.shade200,
                          child: const Icon(
                            Icons.broken_image,
                            color: Colors.grey,
                          ),
                        ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 2),
              child: ClipRRect(
                borderRadius: borderRadius,
                child: AspectRatio(
                  aspectRatio: 1,
                  child: CachedNetworkImage(
                    imageUrl: images[1],
                    fit: BoxFit.cover,
                    placeholder:
                        (context, url) =>
                            Container(color: Colors.grey.shade200),
                    errorWidget:
                        (context, url, error) => Container(
                          color: Colors.grey.shade200,
                          child: const Icon(
                            Icons.broken_image,
                            color: Colors.grey,
                          ),
                        ),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    } else {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 4,
          crossAxisSpacing: 4,
        ),
        itemCount: images.length > 4 ? 4 : images.length,
        itemBuilder: (context, index) {
          final isLast = index == 3 && images.length > 4;
          return ClipRRect(
            borderRadius: borderRadius,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CachedNetworkImage(
                  imageUrl: images[index],
                  fit: BoxFit.cover,
                  placeholder:
                      (context, url) => Container(color: Colors.grey.shade200),
                  errorWidget:
                      (context, url, error) => Container(
                        color: Colors.grey.shade200,
                        child: const Icon(
                          Icons.broken_image,
                          color: Colors.grey,
                        ),
                      ),
                ),
                if (isLast)
                  Container(
                    color: Colors.black.withValues(alpha: 0.45),
                    child: Center(
                      child: Text(
                        '+${images.length - 3}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      );
    }
  }
}

// MARKETPLACE PREVIEW SECTION (NOT FULL MARKETPLACE)
class _MarketplaceForYouSection extends StatelessWidget {
  const _MarketplaceForYouSection();

  @override
  Widget build(BuildContext context) {
    final width = (MediaQuery.of(context).size.width - 24) / 2;
    final height = width + 62;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Marketplace For You',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black.withValues(alpha: 0.85),
                  letterSpacing: -0.2,
                ),
              ),
              TextButton(
                onPressed:
                    () => Navigator.of(context).pushNamed('/marketplace'),
                child: const Text(
                  'See All',
                  style: TextStyle(
                    color: Color(0xFF1877F2),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: height + 16,
          child: FutureBuilder<List<Product>>(
            future: fetchProducts(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return const Center(child: Text('Error loading products'));
              }
              final products = snapshot.data ?? [];
              if (products.isEmpty) {
                return const Center(child: Text('No products found.'));
              }
              return ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                itemCount: products.length,
                separatorBuilder: (context, i) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final p = products[i];
                  return MarketplacePreviewCard(
                    product: p,
                    width: width,
                    height: height,
                    onTap:
                        () => Navigator.of(context).pushNamed('/marketplace'),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

// MARKETPLACE PREVIEW CARD (NOT FULL PRODUCT CARD)
class MarketplacePreviewCard extends StatelessWidget {
  final Product product;
  final double width;
  final double height;
  final VoidCallback? onTap;

  const MarketplacePreviewCard({
    required this.product,
    required this.width,
    required this.height,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
              child: SizedBox(
                width: width,
                height: width,
                child:
                    product.imageUrl.isNotEmpty
                        ? CachedNetworkImage(
                          imageUrl: product.imageUrl,
                          fit: BoxFit.cover,
                          placeholder:
                              (context, url) => Container(
                                color: Colors.grey.shade200,
                                child: Center(
                                  child: Icon(
                                    Icons.image,
                                    color: Colors.grey,
                                    size: width * 0.4,
                                  ),
                                ),
                              ),
                          errorWidget:
                              (context, url, error) => Container(
                                color: Colors.grey.shade200,
                                child: Center(
                                  child: Icon(
                                    Icons.broken_image,
                                    color: Colors.grey,
                                    size: width * 0.4,
                                  ),
                                ),
                              ),
                        )
                        : Container(
                          color: Colors.grey.shade200,
                          child: Center(
                            child: Icon(
                              Icons.image,
                              color: Colors.grey,
                              size: width * 0.4,
                            ),
                          ),
                        ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '\$${product.price.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Expanded(
                      child: Text(
                        product.title,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade700,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
