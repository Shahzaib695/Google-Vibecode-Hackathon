class DisputeModel {
  final String disputeId;
  final String bookingId;
  final String userId;
  final String providerId;
  final String issueType;
  final String description;
  final List<String> evidenceUrls;
  String status;
  final String? aiSuggestedResolution;
  final double? refundAmount;
  final DateTime? resolvedAt;
  final Map<String, dynamic>? antigravityTrace;
  final DateTime createdAt;

  DisputeModel({
    required this.disputeId,
    required this.bookingId,
    required this.userId,
    required this.providerId,
    required this.issueType,
    required this.description,
    this.evidenceUrls = const [],
    this.status = 'open',
    this.aiSuggestedResolution,
    this.refundAmount,
    this.resolvedAt,
    this.antigravityTrace,
    required this.createdAt,
  });

  factory DisputeModel.fromJson(Map<String, dynamic> data) {
    return DisputeModel(
      disputeId: data['disputeId'] ?? data['_id'] ?? '',
      bookingId: data['bookingId'] ?? '',
      userId: data['userId'] ?? '',
      providerId: data['providerId'] ?? '',
      issueType: data['issueType'] ?? 'other',
      description: data['description'] ?? '',
      evidenceUrls: List<String>.from(data['evidenceUrls'] ?? []),
      status: data['status'] ?? 'open',
      aiSuggestedResolution: data['aiSuggestedResolution'],
      refundAmount: (data['refundAmount'] as num?)?.toDouble(),
      resolvedAt: data['resolvedAt'] != null
          ? DateTime.parse(data['resolvedAt'] as String)
          : null,
      antigravityTrace: data['antigravityTrace'] != null
          ? Map<String, dynamic>.from(data['antigravityTrace'])
          : null,
      createdAt: data['createdAt'] != null
          ? DateTime.parse(data['createdAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'disputeId': disputeId,
      'bookingId': bookingId,
      'userId': userId,
      'providerId': providerId,
      'issueType': issueType,
      'description': description,
      'evidenceUrls': evidenceUrls,
      'status': status,
      'aiSuggestedResolution': aiSuggestedResolution,
      'refundAmount': refundAmount,
      'resolvedAt': resolvedAt?.toIso8601String(),
      'antigravityTrace': antigravityTrace,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  String get issueLabel {
    const labels = {
      'no_show': 'Provider No-Show',
      'overcharged': 'Overcharged',
      'incomplete_work': 'Incomplete Work',
      'quality_issue': 'Quality Issue',
      'unprofessional': 'Unprofessional Behavior',
      'damage': 'Property Damage',
      'other': 'Other Issue',
    };
    return labels[issueType] ?? issueType;
  }

  String get statusLabel {
    const labels = {
      'open': 'Open',
      'ai_reviewing': 'AI Reviewing',
      'ai_resolved': 'AI Resolved',
      'escalated': 'Escalated to Human',
      'human_resolved': 'Resolved',
      'closed': 'Closed',
    };
    return labels[status] ?? status;
  }
}

class AntigravityLog {
  final String logId;
  final String? bookingId;
  final String stage;
  final Map<String, dynamic> inputData;
  final String reasoning;
  final Map<String, dynamic> outputData;
  final double confidenceScore;
  final bool fallbackTriggered;
  final String? fallbackReason;
  final int latencyMs;
  final DateTime createdAt;

  const AntigravityLog({
    required this.logId,
    this.bookingId,
    required this.stage,
    required this.inputData,
    required this.reasoning,
    required this.outputData,
    required this.confidenceScore,
    this.fallbackTriggered = false,
    this.fallbackReason,
    required this.latencyMs,
    required this.createdAt,
  });

  factory AntigravityLog.fromJson(Map<String, dynamic> data) {
    return AntigravityLog(
      logId: data['logId'] ?? data['_id'] ?? '',
      bookingId: data['bookingId'],
      stage: data['stage'] ?? '',
      inputData: Map<String, dynamic>.from(data['inputData'] ?? {}),
      reasoning: data['reasoning'] ?? '',
      outputData: Map<String, dynamic>.from(data['outputData'] ?? {}),
      confidenceScore: (data['confidenceScore'] ?? 0.0).toDouble(),
      fallbackTriggered: data['fallbackTriggered'] ?? false,
      fallbackReason: data['fallbackReason'],
      latencyMs: data['latencyMs'] ?? 0,
      createdAt: data['createdAt'] != null
          ? DateTime.parse(data['createdAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'logId': logId,
      'bookingId': bookingId,
      'stage': stage,
      'inputData': inputData,
      'reasoning': reasoning,
      'outputData': outputData,
      'confidenceScore': confidenceScore,
      'fallbackTriggered': fallbackTriggered,
      'fallbackReason': fallbackReason,
      'latencyMs': latencyMs,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  String get stageLabel {
    const labels = {
      'intent_parsing': 'Intent Parsing',
      'job_complexity': 'Job Complexity',
      'provider_matching': 'Provider Matching',
      'pricing': 'Dynamic Pricing',
      'scheduling': 'Scheduling',
      'booking': 'Booking Creation',
      'dispute': 'Dispute Resolution',
      'quality_loop': 'Quality Loop',
    };
    return labels[stage] ?? stage;
  }

  bool get isHighConfidence => confidenceScore >= 85;
  bool get isMediumConfidence => confidenceScore >= 70 && confidenceScore < 85;
  bool get isLowConfidence => confidenceScore < 70;
}
