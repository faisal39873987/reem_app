import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/consistent_loading.dart';

class MarketplaceDetailsScreen extends StatefulWidget {
  final String productId;

  const MarketplaceDetailsScreen({super.key, required this.productId});

  @override
  State<MarketplaceDetailsScreen> createState() =>
      _MarketplaceDetailsScreenState();
}

class _MarketplaceDetailsScreenState extends State<MarketplaceDetailsScreen> {
  final _supabase = Supabase.instance.client;

  Map<String, dynamic>? _product;
  Map<String, dynamic>? _productDetails;
  Map<String, dynamic>? _seller;
  bool _isLoading = true;
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadProductDetails();
  }

  Future<void> _loadProductDetails() async {
    try {
      setState(() => _isLoading = true);

      // Load product data with seller info
      final productResponse =
          await _supabase
              .from('marketplace')
              .select('''
            *,
            profiles!marketplace_user_id_fkey (
              id,
              full_name,
              avatar_url,
              bio,
              phone
            )
          ''')
              .eq('id', widget.productId)
              .single();

      // Load product details
      final detailsResponse =
          await _supabase
              .from('marketplace_details')
              .select('*')
              .eq('product_id', widget.productId)
              .maybeSingle();

      setState(() {
        _product = productResponse;
        _seller = productResponse['profiles'] as Map<String, dynamic>?;
        _productDetails = detailsResponse;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading product: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: ConsistentLoading()));
    }

    if (_product == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Product Details')),
        body: const Center(child: Text('Product not found')),
      );
    }

    final allImages = <String>[];
    if (_product!['image_url'] != null) {
      allImages.add(_product!['image_url']);
    }
    if (_productDetails?['additional_images'] != null) {
      final additionalImages = List<String>.from(
        _productDetails!['additional_images'],
      );
      allImages.addAll(additionalImages);
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(_product!['title'] ?? 'Product Details'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // Implement share functionality
            },
          ),
          IconButton(
            icon: const Icon(Icons.favorite_border),
            onPressed: () {
              // Implement favorite functionality
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Images
                  _buildImageCarousel(allImages),

                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Price and Title
                        _buildProductHeader(),

                        const SizedBox(height: 16),

                        // Seller Information
                        _buildSellerInfo(),

                        const SizedBox(height: 16),

                        // Product Description
                        _buildDescription(),

                        const SizedBox(height: 16),

                        // Seller Notes (if available)
                        if (_productDetails?['seller_notes'] != null)
                          _buildSellerNotes(),

                        const SizedBox(height: 100), // Space for bottom bar
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Message Seller Bar
          _buildMessageSellerBar(),
        ],
      ),
    );
  }

  Widget _buildImageCarousel(List<String> images) {
    if (images.isEmpty) {
      return Container(
        height: 300,
        color: Colors.grey.shade200,
        child: const Center(
          child: Icon(Icons.image, size: 80, color: Colors.grey),
        ),
      );
    }

    return SizedBox(
      height: 300,
      child: Stack(
        children: [
          PageView.builder(
            itemCount: images.length,
            onPageChanged: (index) {
              setState(() => _currentImageIndex = index);
            },
            itemBuilder: (context, index) {
              return CachedNetworkImage(
                imageUrl: images[index],
                fit: BoxFit.cover,
                placeholder:
                    (context, url) => Container(
                      color: Colors.grey.shade200,
                      child: const Center(child: ConsistentLoading()),
                    ),
                errorWidget:
                    (context, url, error) => Container(
                      color: Colors.grey.shade200,
                      child: const Center(
                        child: Icon(Icons.error, size: 50, color: Colors.grey),
                      ),
                    ),
              );
            },
          ),

          // Image indicators
          if (images.length > 1)
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children:
                    images.asMap().entries.map((entry) {
                      return Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color:
                              _currentImageIndex == entry.key
                                  ? Colors.white
                                  : Colors.white.withValues(alpha: 0.5),
                        ),
                      );
                    }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProductHeader() {
    final price = _product!['price']?.toString() ?? '0';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '\$${double.tryParse(price)?.toStringAsFixed(2) ?? price}',
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _product!['title'] ?? 'Untitled Product',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.access_time, size: 16, color: Colors.grey.shade600),
            const SizedBox(width: 4),
            Text(
              _formatTimeAgo(DateTime.parse(_product!['created_at'])),
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSellerInfo() {
    if (_seller == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundImage:
                _seller!['avatar_url'] != null
                    ? NetworkImage(_seller!['avatar_url'])
                    : null,
            backgroundColor: Colors.grey.shade300,
            child:
                _seller!['avatar_url'] == null
                    ? Icon(Icons.person, color: Colors.grey.shade600)
                    : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _seller!['full_name'] ?? 'Anonymous Seller',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                if (_seller!['bio'] != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    _seller!['bio'],
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: Colors.grey.shade400),
        ],
      ),
    );
  }

  Widget _buildDescription() {
    final description =
        _product!['description'] ??
        _productDetails?['description'] ??
        'No description available.';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Description',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Text(description, style: const TextStyle(fontSize: 16, height: 1.5)),
      ],
    );
  }

  Widget _buildSellerNotes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Seller Notes',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: Text(
            _productDetails!['seller_notes'],
            style: TextStyle(
              fontSize: 14,
              color: Colors.blue.shade800,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildMessageSellerBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _messageSellerHandler(),
                icon: const Icon(Icons.message),
                label: const Text('Message Seller'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: () => _callSellerHandler(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Icon(Icons.phone),
            ),
          ],
        ),
      ),
    );
  }

  void _messageSellerHandler() {
    if (_seller == null) return;

    // Navigate to messages screen with seller info in the state
    // You can enhance this to open a chat directly with the seller
    Navigator.pushNamed(context, '/messages');

    // Show a snackbar indicating which seller to message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Contact ${_seller!['full_name'] ?? 'Seller'} through messages',
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _callSellerHandler() {
    if (_seller?['phone'] != null) {
      // Implement phone call functionality
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Call: ${_seller!['phone']}')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Phone number not available')),
      );
    }
  }

  String _formatTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${difference.inDays ~/ 7}w ago';
    }
  }
}
