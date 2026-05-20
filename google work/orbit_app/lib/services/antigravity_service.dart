import 'dart:async';
import 'dart:math';
import '../models/booking_model.dart';
import '../models/provider_model.dart';
import '../models/dispute_model.dart';
import '../core/constants.dart';
import 'api_service.dart';

/// Antigravity Service — simulates all 8 AI workflows locally
/// In production, these call Node.js API -> Vertex AI Agent
class AntigravityService {
  final ApiService _api = ApiService();
  final _random = Random();

  // ─── WORKFLOW 1: MULTILINGUAL INTENT PARSING ───────────────────────────────
  Future<Map<String, dynamic>> parseIntent(String rawText) async {
    final start = DateTime.now();
    await Future.delayed(const Duration(milliseconds: 800));

    final lower = rawText.toLowerCase();
    String language = 'english';
    String service = '';
    String location = '';
    String urgency = 'standard';
    String preferredTime = 'as_soon_as_possible';
    String budgetSensitivity = 'medium';
    double confidence = 85.0;
    String? clarificationQuestion;

    // Language detection
    if (_containsUrdu(rawText)) {
      language = rawText.contains(RegExp(r'[\u0600-\u06FF]')) ? 'urdu' : 'roman_urdu';
    }

    // Service extraction
    if (_matchesAny(lower, ['ac', 'air condition', 'cooling', 'thanda', 'ٹھنڈا', 'ac service', 'ac wala'])) {
      service = 'ac_technician';
    } else if (_matchesAny(lower, ['plumb', 'pipe', 'leak', 'paani', 'پانی', 'nalka', 'drain'])) {
      service = 'plumber';
    } else if (_matchesAny(lower, ['electric', 'bijli', 'بجلی', 'light', 'wiring', 'electrisian', 'switch'])) {
      service = 'electrician';
    } else if (_matchesAny(lower, ['beauty', 'salon', 'wax', 'facial', 'makeup'])) {
      service = 'beautician';
    } else if (_matchesAny(lower, ['tutor', 'teacher', 'ustaz', 'padhai', 'پڑھائی'])) {
      service = 'tutor';
    } else if (_matchesAny(lower, ['mechanic', 'car', 'gaari', 'گاڑی', 'engine'])) {
      service = 'mechanic';
    } else if (_matchesAny(lower, ['clean', 'maid', 'cook', 'sahafi'])) {
      service = 'home_service';
    }

    // Handle ambiguous "bijli ka masla"
    if (lower.contains('bijli') && !lower.contains('wiring') && !lower.contains('switch')) {
      confidence = 55.0;
      clarificationQuestion = language == 'roman_urdu'
          ? 'Kya aapko electrician chahiye ya power outage ka masla hai?'
          : 'Do you need an electrician, or is this a power outage issue?';
    }

    // Location extraction
    for (final area in [...AppConstants.karachiAreas, ...AppConstants.islamabadAreas, ...AppConstants.lahoreAreas]) {
      if (lower.contains(area.toLowerCase())) {
        location = area;
        break;
      }
    }
    if (location.isEmpty && _matchesAny(lower, ['karachi', 'khi'])) location = 'Karachi';
    if (location.isEmpty && _matchesAny(lower, ['islamabad', 'isb'])) location = 'Islamabad';
    if (location.isEmpty) {
      confidence = min(confidence, 60.0);
      clarificationQuestion ??= language == 'roman_urdu'
          ? 'Aapka area kaunsa hai? (e.g. DHA, Gulshan, G-13)'
          : 'Which area are you located in?';
    }

    // Urgency
    if (_matchesAny(lower, ['urgent', 'emergency', 'abhi', 'فوری', 'jaldi', 'turant'])) {
      urgency = 'emergency';
    } else if (_matchesAny(lower, ['aaj', 'today', 'same day', 'آج'])) {
      urgency = 'high';
    } else if (_matchesAny(lower, ['kal', 'tomorrow', 'کل'])) {
      urgency = 'standard';
    }

    // Time
    if (_matchesAny(lower, ['morning', 'subah', 'صبح', 'suba'])) {
      preferredTime = 'tomorrow_morning';
    } else if (_matchesAny(lower, ['evening', 'sham', 'شام'])) {
      preferredTime = 'evening';
    } else if (urgency == 'emergency') {
      preferredTime = 'immediate';
    }

    // Budget
    if (_matchesAny(lower, ['budget nahi', 'zyada nahi', 'cheap', 'sasta', 'سستا', 'kam budget'])) {
      budgetSensitivity = 'high';
    } else if (_matchesAny(lower, ['best', 'premium', 'expert'])) {
      budgetSensitivity = 'low';
    }

    if (service.isNotEmpty && confidence > 60) confidence = max(confidence, 75.0);

    final latency = DateTime.now().difference(start).inMilliseconds;
    final reasoning = '''
ANTIGRAVITY INTENT PARSING — Chain of Thought:

Input: "$rawText"

Step 1 — Language Detection:
  Detected: $language
  Rationale: ${_containsUrdu(rawText) ? 'Contains Urdu/Roman Urdu patterns' : 'Standard English detected'}

Step 2 — Service Extraction:
  Service: ${service.isEmpty ? 'UNKNOWN' : service}
  ${service.isEmpty ? 'WARNING: No service matched. Requesting clarification.' : 'Matched based on keyword analysis.'}

Step 3 — Location Parsing:
  Location: ${location.isEmpty ? 'NOT FOUND' : location}
  ${location.isEmpty ? 'ACTION: Will ask user for area.' : 'Extracted from known Pakistan areas list.'}

Step 4 — Urgency Classification:
  Urgency: $urgency
  Time Preference: $preferredTime

Step 5 — Budget Sensitivity:
  Budget: $budgetSensitivity

Step 6 — Confidence Score: $confidence / 100
  ${confidence < 70 ? 'FALLBACK: Generating clarification question.' : 'Confidence sufficient to proceed.'}

OUTPUT: Intent extracted successfully.
''';

    final output = {
      'service': service,
      'location': location,
      'urgency': urgency,
      'preferredTime': preferredTime,
      'budgetSensitivity': budgetSensitivity,
      'jobDescription': rawText,
      'confidence': confidence,
      'language': language,
      'clarificationQuestion': clarificationQuestion,
    };

    await _logToFirestore(
      stage: 'intent_parsing',
      inputData: {'rawText': rawText},
      reasoning: reasoning,
      outputData: output,
      confidenceScore: confidence,
      fallbackTriggered: confidence < 70,
      fallbackReason: confidence < 70 ? 'Low confidence — generating clarification' : null,
      latencyMs: latency,
    );

    return output;
  }

  // ─── WORKFLOW 2: JOB COMPLEXITY CLASSIFICATION ─────────────────────────────
  Future<String> classifyJobComplexity(Map<String, dynamic> intent) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final service = intent['service'] as String;
    final description = (intent['jobDescription'] as String).toLowerCase();
    final urgency = intent['urgency'] as String;

    String complexity = 'basic';
    if (_matchesAny(description, ['compressor', 'rewiring', 'major', 'replace', 'installation', 'badi problem'])) {
      complexity = 'complex';
    } else if (_matchesAny(description, ['gas refill', 'gas bharwana', 'parts', 'repair', 'fix', 'toota'])) {
      complexity = 'intermediate';
    }
    if (urgency == 'emergency' && complexity == 'basic') complexity = 'intermediate';

    return complexity;
  }

  // ─── WORKFLOW 3: PROVIDER MATCHING ─────────────────────────────────────────
  Future<List<ProviderModel>> matchProviders({
    required List<ProviderModel> candidates,
    required Map<String, dynamic> intent,
    required String complexity,
    required double userLat,
    required double userLng,
  }) async {
    final start = DateTime.now();
    await Future.delayed(const Duration(milliseconds: 1200));

    if (candidates.isEmpty) return [];

    final budgetSensitivity = intent['budgetSensitivity'] as String;
    final List<Map<String, dynamic>> scored = [];

    for (final p in candidates) {
      // Distance score
      final dist = _haversine(userLat, userLng, p.location.latitude, p.location.longitude);
      final distScore = (1 - min(dist / 30.0, 1.0)) * 100;

      // Availability score
      final availScore = p.isAvailable && p.hasCapacity ? 100.0 : 0.0;

      // Rating score
      final ratingScore = (p.rating / 5.0) * 100;

      // Review recency — penalize high raters with recent negatives (riskScore)
      final recencyScore = max(0.0, 100.0 - p.riskScore);

      // On-time score
      final ontimeScore = p.onTimeScore;

      // Skill score
      double skillScore = 70.0;
      if (complexity == 'complex' && p.experienceYears >= 5 && p.certifications.isNotEmpty) {
        skillScore = 100.0;
      } else if (complexity == 'intermediate' && p.specializations.isNotEmpty) {
        skillScore = 85.0;
      } else if (complexity == 'basic') {
        skillScore = 80.0;
      }

      // Price score
      double priceScore = 50.0;
      if (budgetSensitivity == 'high') {
        priceScore = max(0, (1 - (p.pricePerHour / 5000)) * 100);
      } else if (budgetSensitivity == 'low') {
        priceScore = min(100, (p.pricePerHour / 5000) * 100 + 50);
      }

      // Cancellation score (lower rate = higher score)
      final cancelScore = (1 - p.cancellationRate) * 100;

      final match = (distScore * 0.15) +
          (availScore * 0.20) +
          (ratingScore * 0.15) +
          (recencyScore * 0.10) +
          (ontimeScore * 0.15) +
          (skillScore * 0.15) +
          (priceScore * 0.05) +
          (cancelScore * 0.05);

      scored.add({
        'provider': p,
        'score': match,
        'breakdown': {
          'distance': distScore,
          'availability': availScore,
          'rating': ratingScore,
          'recency': recencyScore,
          'ontime': ontimeScore,
          'skill': skillScore,
          'price': priceScore,
          'cancellation': cancelScore,
        },
        'distanceKm': dist,
      });
    }

    scored.sort((a, b) => (b['score'] as double).compareTo(a['score'] as double));
    final top3 = scored.take(3).toList();

    final List<ProviderModel> result = [];
    final labels = ['AI Recommended', 'Best Reliability', 'Budget Option'];

    for (int i = 0; i < top3.length; i++) {
      final item = top3[i];
      final p = item['provider'] as ProviderModel;
      final breakdown = item['breakdown'] as Map<String, double>;
      final score = item['score'] as double;
      final dist = item['distanceKm'] as double;

      String reason = 'Recommended ${p.name}';
      if (p.cancellationRate < 0.05 && p.onTimeScore > 90) {
        reason += ' for exceptional reliability (${p.onTimeScore.toStringAsFixed(0)}% on-time, zero recent cancellations)';
      } else if (p.riskScore > 50) {
        reason += ' despite lower risk score — best available for this slot';
      }
      if (dist < 5) reason += ', only ${dist.toStringAsFixed(1)}km away';

      result.add(p.copyWith(
        matchScore: score,
        scoreBreakdown: breakdown,
        matchLabel: i < labels.length ? labels[i] : 'Good Match',
        matchReason: reason,
      ));
    }

    final latency = DateTime.now().difference(start).inMilliseconds;
    await _logToFirestore(
      stage: 'provider_matching',
      inputData: {'intent': intent, 'complexity': complexity, 'candidateCount': candidates.length},
      reasoning: 'Scored ${candidates.length} providers using 8-factor weighted algorithm. Top match: ${result.isNotEmpty ? result.first.name : "none"}.',
      outputData: {'topMatches': result.map((p) => {'name': p.name, 'score': p.matchScore}).toList()},
      confidenceScore: result.isNotEmpty ? (result.first.matchScore ?? 0) : 0,
      fallbackTriggered: result.isEmpty,
      latencyMs: latency,
    );

    return result;
  }

  // ─── WORKFLOW 4: DYNAMIC PRICING ───────────────────────────────────────────
  Future<PricingBreakdown> calculatePricing({
    required ProviderModel provider,
    required Map<String, dynamic> intent,
    required double distanceKm,
    required int userLoyaltyPoints,
    required String complexity,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));

    final urgency = intent['urgency'] as String;
    final estimatedHours = complexity == 'complex' ? 3.0 : complexity == 'intermediate' ? 2.0 : 1.5;

    final baseRate = provider.pricePerHour * estimatedHours;
    final visitFee = distanceKm < 5 ? 200.0 : distanceKm < 15 ? 350.0 : 500.0;
    final distanceCost = distanceKm * 15.0;

    final urgencyMultiplier = urgency == 'emergency' ? 1.5 : urgency == 'high' ? 1.2 : 1.0;
    final urgencyAdjustment = (baseRate + visitFee + distanceCost) * (urgencyMultiplier - 1);

    // Surge (random 1.0–1.3 based on demand simulation)
    final surgeMultiplier = 1.0 + (_random.nextDouble() * 0.3);
    final loyaltyDiscount = userLoyaltyPoints > 100 ? 0.05 : 0.0;

    final subtotal = (baseRate + visitFee + distanceCost + urgencyAdjustment) * surgeMultiplier;
    final discountAmount = subtotal * loyaltyDiscount;
    final total = subtotal - discountAmount;

    return PricingBreakdown(
      baseRate: baseRate,
      visitFee: visitFee,
      distanceCost: distanceCost,
      urgencyAdjustment: urgencyAdjustment,
      surgeMultiplier: surgeMultiplier,
      loyaltyDiscount: discountAmount,
      total: total,
      isFairPrice: total < 4000,
      budgetAlternative: intent['budgetSensitivity'] == 'high'
          ? 'Schedule for tomorrow afternoon for Rs. ${(total * 0.85).toStringAsFixed(0)} (15% lower surge)'
          : null,
    );
  }

  // ─── WORKFLOW 8: DISPUTE RESOLUTION ────────────────────────────────────────
  Future<Map<String, dynamic>> resolveDispute(DisputeModel dispute) async {
    await Future.delayed(const Duration(milliseconds: 1000));

    String resolution = '';
    double refundAmount = 0;
    String newStatus = 'ai_resolved';

    switch (dispute.issueType) {
      case 'no_show':
        resolution = 'Provider did not show up. Full refund of booking amount issued. Provider has been warned. Three such incidents will result in suspension.';
        refundAmount = 100.0;
        break;
      case 'overcharged':
        resolution = 'AI reviewed booking receipt vs. stated rates. Partial refund of overcharged amount recommended.';
        refundAmount = 200.0;
        break;
      case 'quality_issue':
        resolution = 'Quality issue reported. 30% refund issued and provider flagged for review.';
        refundAmount = 30.0;
        break;
      case 'damage':
        resolution = 'Property damage reported. This requires human review. Escalating to support team.';
        newStatus = 'escalated';
        break;
      default:
        resolution = 'Issue reviewed by AI. Partial refund recommended. Escalate if unsatisfied.';
        refundAmount = 15.0;
    }

    await _logToFirestore(
      stage: 'dispute',
      inputData: {'disputeId': dispute.disputeId, 'issueType': dispute.issueType},
      reasoning: 'Dispute resolution: ${dispute.issueType} → $resolution',
      outputData: {'resolution': resolution, 'refund': refundAmount, 'status': newStatus},
      confidenceScore: 88.0,
      fallbackTriggered: newStatus == 'escalated',
      fallbackReason: newStatus == 'escalated' ? 'Damage claim requires human review' : null,
      latencyMs: 1000,
    );

    return {'resolution': resolution, 'refundAmount': refundAmount, 'status': newStatus};
  }

  // ─── HELPERS ───────────────────────────────────────────────────────────────
  bool _matchesAny(String text, List<String> keywords) {
    return keywords.any((k) => text.contains(k));
  }

  bool _containsUrdu(String text) {
    return text.contains(RegExp(r'[\u0600-\u06FF]')) ||
        _matchesAny(text.toLowerCase(), ['mujhe', 'chahiye', 'karo', 'hai', 'wala', 'kal', 'aaj', 'abhi', 'bijli', 'paani']);
  }

  double _haversine(double lat1, double lng1, double lat2, double lng2) {
    const R = 6371.0;
    final dLat = _toRad(lat2 - lat1);
    final dLng = _toRad(lng2 - lng1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRad(lat1)) * cos(_toRad(lat2)) * sin(dLng / 2) * sin(dLng / 2);
    return R * 2 * atan2(sqrt(a), sqrt(1 - a));
  }

  double _toRad(double deg) => deg * pi / 180;

  Future<void> _logToFirestore({
    required String stage,
    String? bookingId,
    required Map<String, dynamic> inputData,
    required String reasoning,
    required Map<String, dynamic> outputData,
    required double confidenceScore,
    bool fallbackTriggered = false,
    String? fallbackReason,
    required int latencyMs,
  }) async {
    try {
      await _api.post('/logs', data: {
        'bookingId': bookingId,
        'stage': stage,
        'inputData': inputData,
        'reasoning': reasoning,
        'outputData': outputData,
        'confidenceScore': confidenceScore,
        'fallbackTriggered': fallbackTriggered,
        'fallbackReason': fallbackReason,
        'latencyMs': latencyMs,
      });
    } catch (_) {}
  }
}
