class Seller {
  final String id;
  final String name;
  final String avatarUrl;
  final String info;
  final bool isFollowing;
  final bool isRTL;

  Seller({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.info,
    this.isFollowing = false,
    this.isRTL = false,
  });

  factory Seller.empty() => Seller(id: '', name: '', avatarUrl: '', info: '');
}
