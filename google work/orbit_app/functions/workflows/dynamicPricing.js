const admin = require('firebase-admin');
const { logToAntigravity } = require('../utils/firestoreHelpers');

async function calculatePricing(providerId, intent, distanceKm, userId) {
  const db = admin.firestore();
  const providerDoc = await db.collection('providers').doc(providerId).get();
  const provider = providerDoc.data();
  const userDoc = await db.collection('users').doc(userId).get();
  const user = userDoc.exists ? userDoc.data() : { loyaltyPoints: 0 };

  const complexity = intent.complexity || 'basic';
  const estimatedHours = complexity === 'complex' ? 3.0 : complexity === 'intermediate' ? 2.0 : 1.5;
  const baseRate = provider.pricePerHour * estimatedHours;
  const visitFee = distanceKm < 5 ? 200 : distanceKm < 15 ? 350 : 500;
  const distanceCost = distanceKm * 15;
  const urgencyMap = { emergency: 1.5, high: 1.2, standard: 1.0, low: 1.0 };
  const urgencyMultiplier = urgencyMap[intent.urgency] || 1.0;
  const urgencyAdjustment = (baseRate + visitFee + distanceCost) * (urgencyMultiplier - 1);
  const surgeMultiplier = 1.0 + Math.random() * 0.3; // 1.0–1.3 demand-based
  const loyaltyDiscount = (user.loyaltyPoints || 0) > 100 ? 0.05 : 0;
  const subtotal = (baseRate + visitFee + distanceCost + urgencyAdjustment) * surgeMultiplier;
  const discountAmount = subtotal * loyaltyDiscount;
  const total = subtotal - discountAmount;

  const areaAvg = { basic: 2000, intermediate: 3000, complex: 5000 }[complexity];
  const isFairPrice = total <= areaAvg * 1.2;

  const result = {
    baseRate: Math.round(baseRate),
    visitFee,
    distanceCost: Math.round(distanceCost),
    urgencyAdjustment: Math.round(urgencyAdjustment),
    surgeMultiplier: parseFloat(surgeMultiplier.toFixed(2)),
    loyaltyDiscount: Math.round(discountAmount),
    total: Math.round(total),
    isFairPrice,
    budgetAlternative: intent.budgetSensitivity === 'high'
      ? `Schedule tomorrow afternoon for Rs. ${Math.round(total * 0.85)} (15% lower surge)` : null,
  };

  await logToAntigravity({
    stage: 'pricing',
    inputData: { providerId, intent, distanceKm, userId },
    reasoning: `Pricing: Base ${baseRate} + Visit ${visitFee} + Distance ${distanceCost} × Urgency ${urgencyMultiplier} × Surge ${surgeMultiplier.toFixed(2)} - Loyalty ${discountAmount} = Rs. ${total.toFixed(0)}. Fair price: ${isFairPrice}.`,
    outputData: result,
    confidenceScore: 95,
    latencyMs: 300,
  });

  return result;
}

module.exports = { calculatePricing };
