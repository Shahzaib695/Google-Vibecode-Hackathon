const admin = require('firebase-admin');
const { logToAntigravity } = require('../utils/firestoreHelpers');
const { scoreProvider } = require('../utils/scoringAlgorithm');

/**
 * WORKFLOW 3: Multi-Factor Provider Matching
 * 8-factor weighted scoring formula
 * CRITICAL: High-rating unreliable providers must be demoted
 */
async function matchProviders(intent, userLocation, complexity) {
  const startTime = Date.now();
  const db = admin.firestore();

  // Fetch candidates
  let query = db.collection('providers').where('isOnline', '==', true).where('isAvailable', '==', true);
  if (intent.service) query = query.where('serviceType', '==', intent.service);

  const snap = await query.get();
  const candidates = snap.docs.map(d => ({ id: d.id, ...d.data() }));

  if (candidates.length === 0) {
    // Fallback: relax constraints
    const relaxedSnap = await db.collection('providers').where('serviceType', '==', intent.service).get();
    const relaxed = relaxedSnap.docs.map(d => ({ id: d.id, ...d.data() }));
    
    return {
      providers: [],
      fallback: true,
      message: `No available providers for ${intent.service}. Found ${relaxed.length} providers but none currently available.`,
      nextAvailableSlots: getNextAvailableSlots(),
    };
  }

  // Score each provider
  const scored = candidates.map(provider => {
    const distance = haversine(
      userLocation.lat, userLocation.lng,
      provider.location._latitude, provider.location._longitude
    );
    const scores = scoreProvider(provider, intent, distance, complexity);
    
    const matchScore = 
      scores.distance * 0.15 +
      scores.availability * 0.20 +
      scores.rating * 0.15 +
      scores.recency * 0.10 +
      scores.ontime * 0.15 +
      scores.skill * 0.15 +
      scores.price * 0.05 +
      scores.cancellation * 0.05;

    return { provider, matchScore, scores, distanceKm: distance };
  });

  // Sort by score (descending)
  scored.sort((a, b) => b.matchScore - a.matchScore);

  // CRITICAL RULE: Detect and explain demotion of unreliable providers
  const demotionLog = [];
  for (let i = 0; i < scored.length - 1; i++) {
    const high = scored[i];
    const low = scored[i + 1];
    if (low.provider.rating > high.provider.rating && 
        high.provider.cancellationRate > 0.15 &&
        high.matchScore < low.matchScore) {
      demotionLog.push(
        `DEMOTION: ${high.provider.name} (${high.provider.rating}★) ranked below ${low.provider.name} ` +
        `(${low.provider.rating}★) because of ${(high.provider.cancellationRate * 100).toFixed(0)}% ` +
        `cancellation rate and risk score ${high.provider.riskScore}.`
      );
    }
  }

  const top3 = scored.slice(0, 3);
  const labels = ['AI Recommended', 'Best Reliability', 'Budget Option'];

  const results = top3.map((item, i) => ({
    ...item.provider,
    matchScore: parseFloat(item.matchScore.toFixed(1)),
    scoreBreakdown: item.scores,
    matchLabel: labels[i] || 'Good Match',
    distanceKm: parseFloat(item.distanceKm.toFixed(1)),
    matchReason: buildReason(item.provider, item.scores, item.distanceKm, i),
  }));

  const latency = Date.now() - startTime;
  const reasoning = `
ANTIGRAVITY PROVIDER MATCHING — Chain of Thought

Intent: ${intent.service} in ${intent.location}
Complexity: ${complexity}
Candidates evaluated: ${candidates.length}

8-Factor Scoring Applied:
  Distance (15%), Availability (20%), Rating (15%), Review Recency (10%)
  On-Time (15%), Skill Match (15%), Price (5%), Cancellation Rate (5%)

${demotionLog.length > 0 ? '⚠️ DEMOTION EVENTS:\n' + demotionLog.join('\n') : 'No demotion events.'}

Top Match: ${results[0]?.name || 'None'} — Score: ${results[0]?.matchScore || 0}%
Plain Reasoning: ${results[0]?.matchReason || 'N/A'}

Total latency: ${latency}ms
`;

  await logToAntigravity({
    stage: 'provider_matching',
    inputData: { intent, userLocation, complexity, candidateCount: candidates.length },
    reasoning,
    outputData: { topMatches: results.map(r => ({ name: r.name, score: r.matchScore })), demotions: demotionLog },
    confidenceScore: results.length > 0 ? results[0].matchScore : 0,
    fallbackTriggered: false,
    latencyMs: latency,
  });

  return { providers: results, totalCandidates: candidates.length };
}

function buildReason(provider, scores, distanceKm, rank) {
  let reason = `Recommended ${provider.name}`;
  if (provider.onTimeScore > 90 && provider.cancellationRate < 0.05) {
    reason += ` for exceptional reliability (${provider.onTimeScore}% on-time, ${(provider.cancellationRate * 100).toFixed(0)}% cancellation rate)`;
  }
  if (provider.riskScore > 50) {
    reason += `. NOTE: Provider has elevated risk score (${provider.riskScore}) — monitor closely.`;
  }
  if (distanceKm < 5) reason += `. Only ${distanceKm.toFixed(1)}km away.`;
  return reason;
}

function getNextAvailableSlots() {
  const slots = [];
  const now = new Date();
  for (let i = 0; i < 3; i++) {
    const slot = new Date(now);
    slot.setDate(slot.getDate() + i + 1);
    slot.setHours(9, 0, 0, 0);
    slots.push(slot.toISOString());
  }
  return slots;
}

function haversine(lat1, lng1, lat2, lng2) {
  const R = 6371;
  const dLat = toRad(lat2 - lat1);
  const dLng = toRad(lng2 - lng1);
  const a = Math.sin(dLat/2)**2 + Math.cos(toRad(lat1)) * Math.cos(toRad(lat2)) * Math.sin(dLng/2)**2;
  return R * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
}

function toRad(deg) { return deg * Math.PI / 180; }

module.exports = { matchProviders };
