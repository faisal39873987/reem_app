class Profile {
  final String id;
  final String fullName;
  final String bio;
  final String phone;
  final String note;
  final String avatarUrl;
  final bool showInReemYouth;

  Profile({
    required this.id,
    required this.fullName,
    required this.bio,
    required this.phone,
    required this.note,
    required this.avatarUrl,
    required this.showInReemYouth,
  });

  factory Profile.fromMap(Map<String, dynamic> data) {
    String parseString(dynamic value) {
      if (value == null) return '';
      if (value is String) return value;
      if (value is int || value is double) return value.toString();
      return value.toString();
    }

    bool parseBool(dynamic value) {
      if (value == null) return true;
      if (value is bool) return value;
      if (value is int) return value == 1;
      if (value is String) return value == 'true' || value == '1';
      return true;
    }

    return Profile(
      id: parseString(data['id']),
      fullName: parseString(data['full_name']),
      bio: parseString(data['bio']),
      phone: parseString(data['phone']),
      note: parseString(data['note']),
      avatarUrl: parseString(data['avatar_url']),
      showInReemYouth: parseBool(data['show_in_reem_youth']),
    );
  }
}
