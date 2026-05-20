class UserModel {
  final String uid;
  final String name;
  final String phone;
  final String preferredLanguage;
  final int loyaltyPoints;
  final List<String> bookingHistory;
  final DateTime createdAt;

  const UserModel({
    required this.uid,
    required this.name,
    required this.phone,
    this.preferredLanguage = 'english',
    this.loyaltyPoints = 0,
    this.bookingHistory = const [],
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> data) {
    return UserModel(
      uid: data['uid'] ?? data['_id'] ?? '',
      name: data['name'] ?? '',
      phone: data['phone'] ?? '',
      preferredLanguage: data['preferredLanguage'] ?? 'english',
      loyaltyPoints: data['loyaltyPoints'] ?? 0,
      bookingHistory: List<String>.from(data['bookingHistory'] ?? []),
      createdAt: data['createdAt'] != null
          ? DateTime.parse(data['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'phone': phone,
      'preferredLanguage': preferredLanguage,
      'loyaltyPoints': loyaltyPoints,
      'bookingHistory': bookingHistory,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? uid,
    String? name,
    String? phone,
    String? preferredLanguage,
    int? loyaltyPoints,
    List<String>? bookingHistory,
    DateTime? createdAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      loyaltyPoints: loyaltyPoints ?? this.loyaltyPoints,
      bookingHistory: bookingHistory ?? this.bookingHistory,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
