class ExtractedIntent {
  final String service;
  final String location;
  final String urgency;
  final String preferredTime;
  final String budgetSensitivity;
  final String jobDescription;
  final double confidence;
  final String language;
  final String? clarificationQuestion;

  const ExtractedIntent({
    required this.service,
    required this.location,
    required this.urgency,
    required this.preferredTime,
    required this.budgetSensitivity,
    required this.jobDescription,
    required this.confidence,
    required this.language,
    this.clarificationQuestion,
  });

  factory ExtractedIntent.fromMap(Map<String, dynamic> map) {
    return ExtractedIntent(
      service: map['service'] ?? '',
      location: map['location'] ?? '',
      urgency: map['urgency'] ?? 'standard',
      preferredTime: map['preferredTime'] ?? 'as_soon_as_possible',
      budgetSensitivity: map['budgetSensitivity'] ?? 'medium',
      jobDescription: map['jobDescription'] ?? '',
      confidence: (map['confidence'] ?? 0.0).toDouble(),
      language: map['language'] ?? 'english',
      clarificationQuestion: map['clarificationQuestion'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'service': service,
      'location': location,
      'urgency': urgency,
      'preferredTime': preferredTime,
      'budgetSensitivity': budgetSensitivity,
      'jobDescription': jobDescription,
      'confidence': confidence,
      'language': language,
      'clarificationQuestion': clarificationQuestion,
    };
  }
}

class PricingBreakdown {
  final double baseRate;
  final double visitFee;
  final double distanceCost;
  final double urgencyAdjustment;
  final double surgeMultiplier;
  final double loyaltyDiscount;
  final double total;
  final bool isFairPrice;
  final String? budgetAlternative;

  const PricingBreakdown({
    required this.baseRate,
    required this.visitFee,
    required this.distanceCost,
    required this.urgencyAdjustment,
    required this.surgeMultiplier,
    required this.loyaltyDiscount,
    required this.total,
    this.isFairPrice = true,
    this.budgetAlternative,
  });

  factory PricingBreakdown.fromMap(Map<String, dynamic> map) {
    return PricingBreakdown(
      baseRate: (map['baseRate'] ?? 0.0).toDouble(),
      visitFee: (map['visitFee'] ?? 0.0).toDouble(),
      distanceCost: (map['distanceCost'] ?? 0.0).toDouble(),
      urgencyAdjustment: (map['urgencyAdjustment'] ?? 0.0).toDouble(),
      surgeMultiplier: (map['surgeMultiplier'] ?? 1.0).toDouble(),
      loyaltyDiscount: (map['loyaltyDiscount'] ?? 0.0).toDouble(),
      total: (map['total'] ?? 0.0).toDouble(),
      isFairPrice: map['isFairPrice'] ?? true,
      budgetAlternative: map['budgetAlternative'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'baseRate': baseRate,
      'visitFee': visitFee,
      'distanceCost': distanceCost,
      'urgencyAdjustment': urgencyAdjustment,
      'surgeMultiplier': surgeMultiplier,
      'loyaltyDiscount': loyaltyDiscount,
      'total': total,
      'isFairPrice': isFairPrice,
      'budgetAlternative': budgetAlternative,
    };
  }

  String get totalDisplay => 'Rs. ${total.toStringAsFixed(0)}';
}

class BookingModel {
  final String bookingId;
  final String userId;
  final String providerId;
  final String serviceType;
  final String jobComplexity;
  String status;
  final String requestText;
  final ExtractedIntent? extractedIntent;
  final DateTime? scheduledTime;
  final String address;
  final PricingBreakdown? pricingBreakdown;
  final String paymentMethod;
  String paymentStatus;
  double? userRating;
  String? userReview;
  double? providerRating;
  String? disputeId;
  final Map<String, dynamic>? antigravityTrace;
  final DateTime createdAt;
  DateTime updatedAt;

  // Provider info (joined)
  String? providerName;
  String? providerPhone;
  double? providerRatingValue;

  BookingModel({
    required this.bookingId,
    required this.userId,
    required this.providerId,
    required this.serviceType,
    this.jobComplexity = 'basic',
    this.status = 'pending',
    required this.requestText,
    this.extractedIntent,
    this.scheduledTime,
    this.address = '',
    this.pricingBreakdown,
    this.paymentMethod = 'cash',
    this.paymentStatus = 'pending',
    this.userRating,
    this.userReview,
    this.providerRating,
    this.disputeId,
    this.antigravityTrace,
    required this.createdAt,
    required this.updatedAt,
    this.providerName,
    this.providerPhone,
    this.providerRatingValue,
  });

  factory BookingModel.fromJson(Map<String, dynamic> data) {
    return BookingModel(
      bookingId: data['bookingId'] ?? data['_id'] ?? '',
      userId: data['userId'] ?? '',
      providerId: data['providerId'] ?? '',
      serviceType: data['serviceType'] ?? '',
      jobComplexity: data['jobComplexity'] ?? 'basic',
      status: data['status'] ?? 'pending',
      requestText: data['requestText'] ?? '',
      extractedIntent: data['extractedIntent'] != null
          ? ExtractedIntent.fromMap(
              Map<String, dynamic>.from(data['extractedIntent']))
          : null,
      scheduledTime: data['scheduledTime'] != null
          ? DateTime.parse(data['scheduledTime'] as String)
          : null,
      address: data['address'] ?? '',
      pricingBreakdown: data['pricingBreakdown'] != null
          ? PricingBreakdown.fromMap(
              Map<String, dynamic>.from(data['pricingBreakdown']))
          : null,
      paymentMethod: data['paymentMethod'] ?? 'cash',
      paymentStatus: data['paymentStatus'] ?? 'pending',
      userRating: (data['userRating'] as num?)?.toDouble(),
      userReview: data['userReview'],
      providerRating: (data['providerRating'] as num?)?.toDouble(),
      disputeId: data['disputeId'],
      antigravityTrace: data['antigravityTrace'] != null
          ? Map<String, dynamic>.from(data['antigravityTrace'])
          : null,
      createdAt: data['createdAt'] != null
          ? DateTime.parse(data['createdAt'] as String)
          : DateTime.now(),
      updatedAt: data['updatedAt'] != null
          ? DateTime.parse(data['updatedAt'] as String)
          : DateTime.now(),
      providerName: data['providerName'],
      providerPhone: data['providerPhone'],
      providerRatingValue: (data['providerRatingValue'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bookingId': bookingId,
      'userId': userId,
      'providerId': providerId,
      'serviceType': serviceType,
      'jobComplexity': jobComplexity,
      'status': status,
      'requestText': requestText,
      'extractedIntent': extractedIntent?.toMap(),
      'scheduledTime': scheduledTime?.toIso8601String(),
      'address': address,
      'pricingBreakdown': pricingBreakdown?.toMap(),
      'paymentMethod': paymentMethod,
      'paymentStatus': paymentStatus,
      'userRating': userRating,
      'userReview': userReview,
      'providerRating': providerRating,
      'disputeId': disputeId,
      'antigravityTrace': antigravityTrace,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'providerName': providerName,
      'providerPhone': providerPhone,
      'providerRatingValue': providerRatingValue,
    };
  }

  String get statusLabel {
    const labels = {
      'pending': 'Pending',
      'confirmed': 'Confirmed',
      'en_route': 'On the Way',
      'in_progress': 'In Progress',
      'completed': 'Completed',
      'disputed': 'Disputed',
      'cancelled': 'Cancelled',
    };
    return labels[status] ?? status;
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
}
