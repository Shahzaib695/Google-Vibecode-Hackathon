class GeoPoint {
  final double latitude;
  final double longitude;
  const GeoPoint(this.latitude, this.longitude);
}

class ProviderModel {
  final String uid;
  final String name;
  final String serviceType;
  final List<String> specializations;
  final GeoPoint location;
  final String city;
  final String area;
  final double rating;
  final int totalReviews;
  final double onTimeScore;
  final double cancellationRate;
  final double riskScore;
  final bool isOnline;
  final bool isAvailable;
  final double pricePerHour;
  final int experienceYears;
  final List<String> certifications;
  final int capacityPerDay;
  final int currentBookingsToday;
  final List<DateTime> availableSlots;
  final Map<String, double> earnings;
  final String? profileImageUrl;
  final String? phone;
  final DateTime createdAt;

  // Computed: match score from AI
  double? matchScore;
  Map<String, double>? scoreBreakdown;
  String? matchLabel;
  String? matchReason;

  ProviderModel({
    required this.uid,
    required this.name,
    required this.serviceType,
    this.specializations = const [],
    required this.location,
    required this.city,
    required this.area,
    this.rating = 0.0,
    this.totalReviews = 0,
    this.onTimeScore = 0.0,
    this.cancellationRate = 0.0,
    this.riskScore = 0.0,
    this.isOnline = false,
    this.isAvailable = false,
    required this.pricePerHour,
    this.experienceYears = 0,
    this.certifications = const [],
    this.capacityPerDay = 5,
    this.currentBookingsToday = 0,
    this.availableSlots = const [],
    this.earnings = const {},
    this.profileImageUrl,
    this.phone,
    required this.createdAt,
    this.matchScore,
    this.scoreBreakdown,
    this.matchLabel,
    this.matchReason,
  });

  factory ProviderModel.fromJson(Map<String, dynamic> data) {
    GeoPoint loc = const GeoPoint(0, 0);
    if (data['location'] != null) {
      final locData = data['location'];
      loc = GeoPoint(
        (locData['latitude'] ?? locData['lat'] ?? 0.0).toDouble(),
        (locData['longitude'] ?? locData['lng'] ?? 0.0).toDouble(),
      );
    }

    return ProviderModel(
      uid: data['uid'] ?? data['_id'] ?? '',
      name: data['name'] ?? '',
      serviceType: data['serviceType'] ?? '',
      specializations: List<String>.from(data['specializations'] ?? []),
      location: loc,
      city: data['city'] ?? '',
      area: data['area'] ?? '',
      rating: (data['rating'] ?? 0.0).toDouble(),
      totalReviews: data['totalReviews'] ?? 0,
      onTimeScore: (data['onTimeScore'] ?? 0.0).toDouble(),
      cancellationRate: (data['cancellationRate'] ?? 0.0).toDouble(),
      riskScore: (data['riskScore'] ?? 0.0).toDouble(),
      isOnline: data['isOnline'] ?? false,
      isAvailable: data['isAvailable'] ?? false,
      pricePerHour: (data['pricePerHour'] ?? 0.0).toDouble(),
      experienceYears: data['experienceYears'] ?? 0,
      certifications: List<String>.from(data['certifications'] ?? []),
      capacityPerDay: data['capacityPerDay'] ?? 5,
      currentBookingsToday: data['currentBookingsToday'] ?? 0,
      availableSlots: (data['availableSlots'] as List<dynamic>? ?? [])
          .map((e) => DateTime.parse(e as String))
          .toList(),
      earnings: Map<String, double>.from(
        (data['earnings'] as Map<String, dynamic>? ?? {})
            .map((k, v) => MapEntry(k, (v ?? 0.0).toDouble())),
      ),
      profileImageUrl: data['profileImageUrl'],
      phone: data['phone'],
      createdAt: data['createdAt'] != null
          ? DateTime.parse(data['createdAt'])
          : DateTime.now(),
      matchScore: data['matchScore'] != null ? (data['matchScore'] as num).toDouble() : null,
      scoreBreakdown: data['scoreBreakdown'] != null
          ? Map<String, double>.from((data['scoreBreakdown'] as Map).map((k, v) => MapEntry(k.toString(), (v as num).toDouble())))
          : null,
      matchLabel: data['matchLabel'],
      matchReason: data['matchReason'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'serviceType': serviceType,
      'specializations': specializations,
      'location': {
        'latitude': location.latitude,
        'longitude': location.longitude,
      },
      'city': city,
      'area': area,
      'rating': rating,
      'totalReviews': totalReviews,
      'onTimeScore': onTimeScore,
      'cancellationRate': cancellationRate,
      'riskScore': riskScore,
      'isOnline': isOnline,
      'isAvailable': isAvailable,
      'pricePerHour': pricePerHour,
      'experienceYears': experienceYears,
      'certifications': certifications,
      'capacityPerDay': capacityPerDay,
      'currentBookingsToday': currentBookingsToday,
      'availableSlots': availableSlots.map((e) => e.toIso8601String()).toList(),
      'earnings': earnings,
      'profileImageUrl': profileImageUrl,
      'phone': phone,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  String get serviceIcon {
    const icons = {
      'ac_technician': '❄️',
      'plumber': '🔧',
      'electrician': '⚡',
      'beautician': '💅',
      'tutor': '📚',
      'mechanic': '🔩',
      'home_service': '🏠',
    };
    return icons[serviceType] ?? '🔧';
  }

  String get serviceName {
    const names = {
      'ac_technician': 'AC Technician',
      'plumber': 'Plumber',
      'electrician': 'Electrician',
      'beautician': 'Beautician',
      'tutor': 'Home Tutor',
      'mechanic': 'Mechanic',
      'home_service': 'Home Service',
    };
    return names[serviceType] ?? serviceType;
  }

  String get priceDisplay => 'Rs. ${pricePerHour.toStringAsFixed(0)}/hr';
  
  String get onTimeDisplay => '${onTimeScore.toStringAsFixed(0)}%';

  bool get isHighRisk => riskScore > 65;
  bool get isReliable => cancellationRate < 0.05 && onTimeScore > 85;
  bool get hasCapacity => currentBookingsToday < capacityPerDay;

  ProviderModel copyWith({
    bool? isOnline,
    bool? isAvailable,
    double? rating,
    double? riskScore,
    double? matchScore,
    Map<String, double>? scoreBreakdown,
    String? matchLabel,
    String? matchReason,
    int? currentBookingsToday,
    List<DateTime>? availableSlots,
  }) {
    return ProviderModel(
      uid: uid,
      name: name,
      serviceType: serviceType,
      specializations: specializations,
      location: location,
      city: city,
      area: area,
      rating: rating ?? this.rating,
      totalReviews: totalReviews,
      onTimeScore: onTimeScore,
      cancellationRate: cancellationRate,
      riskScore: riskScore ?? this.riskScore,
      isOnline: isOnline ?? this.isOnline,
      isAvailable: isAvailable ?? this.isAvailable,
      pricePerHour: pricePerHour,
      experienceYears: experienceYears,
      certifications: certifications,
      capacityPerDay: capacityPerDay,
      currentBookingsToday: currentBookingsToday ?? this.currentBookingsToday,
      availableSlots: availableSlots ?? this.availableSlots,
      earnings: earnings,
      profileImageUrl: profileImageUrl,
      phone: phone,
      createdAt: createdAt,
      matchScore: matchScore ?? this.matchScore,
      scoreBreakdown: scoreBreakdown ?? this.scoreBreakdown,
      matchLabel: matchLabel ?? this.matchLabel,
      matchReason: matchReason ?? this.matchReason,
    );
  }
}
