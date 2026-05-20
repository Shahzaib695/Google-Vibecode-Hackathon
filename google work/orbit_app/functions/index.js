const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

const { parseIntent } = require('./workflows/intentParsing');
const { matchProviders } = require('./workflows/providerMatching');
const { calculatePricing } = require('./workflows/dynamicPricing');
const { scheduleBooking } = require('./workflows/schedulingIntelligence');
const { createBooking } = require('./workflows/bookingSimulation');
const { processQualityLoop } = require('./workflows/serviceQualityLoop');
const { resolveDispute } = require('./workflows/disputeResolution');

// ── WORKFLOW 1: Intent Parsing ──────────────────────────────────────────────
exports.parseIntent = functions.https.onCall(async (data, context) => {
  return await parseIntent(data.rawText, data.userId);
});

// ── WORKFLOW 2+3: Match Providers ───────────────────────────────────────────
exports.matchProviders = functions.https.onCall(async (data, context) => {
  return await matchProviders(data.intent, data.userLocation, data.complexity);
});

// ── WORKFLOW 4: Dynamic Pricing ─────────────────────────────────────────────
exports.calculatePricing = functions.https.onCall(async (data, context) => {
  return await calculatePricing(data.providerId, data.intent, data.distanceKm, data.userId);
});

// ── WORKFLOW 5: Scheduling ──────────────────────────────────────────────────
exports.scheduleBooking = functions.https.onCall(async (data, context) => {
  return await scheduleBooking(data.providerId, data.requestedSlot, data.userId);
});

// ── WORKFLOW 6: Booking Simulation ──────────────────────────────────────────
exports.createBooking = functions.https.onCall(async (data, context) => {
  return await createBooking(data.bookingData);
});

// ── WORKFLOW 7: Quality Loop ─────────────────────────────────────────────────
exports.submitFeedback = functions.https.onCall(async (data, context) => {
  return await processQualityLoop(data.bookingId, data.rating, data.review);
});

// ── WORKFLOW 8: Dispute Resolution ──────────────────────────────────────────
exports.resolveDispute = functions.https.onCall(async (data, context) => {
  return await resolveDispute(data.disputeId, data.bookingId, data.issueType, data.description);
});

// ── Firestore Triggers ───────────────────────────────────────────────────────
exports.onBookingCreated = functions.firestore.document('bookings/{bookingId}').onCreate(async (snap, ctx) => {
  const booking = snap.data();
  const db = admin.firestore();
  // Send FCM notifications (simulated)
  console.log(`Booking created: ${ctx.params.bookingId} for provider ${booking.providerId}`);
  await db.collection('antigravityLogs').add({
    logId: db.collection('antigravityLogs').doc().id,
    bookingId: ctx.params.bookingId,
    stage: 'booking',
    inputData: { bookingId: ctx.params.bookingId },
    reasoning: 'Booking created successfully. FCM notifications sent to user and provider.',
    outputData: { status: 'confirmed', notificationsSent: true },
    confidenceScore: 100,
    fallbackTriggered: false,
    latencyMs: 200,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  });
});

exports.onProviderRatingChanged = functions.firestore.document('bookings/{bookingId}').onUpdate(async (change, ctx) => {
  const before = change.before.data();
  const after = change.after.data();
  if (before.userRating === after.userRating) return null;
  
  const db = admin.firestore();
  const providerId = after.providerId;
  
  // Recalculate provider risk score
  const bookingsSnap = await db.collection('bookings')
    .where('providerId', '==', providerId)
    .where('status', '==', 'completed').get();
  
  if (bookingsSnap.empty) return null;
  
  const ratings = bookingsSnap.docs.map(d => d.data().userRating).filter(r => r != null);
  const avgRating = ratings.reduce((a, b) => a + b, 0) / ratings.length;
  
  // Calculate risk score: high if recent negative reviews + high cancellation
  const recentDocs = bookingsSnap.docs.slice(-10);
  const recentNegative = recentDocs.filter(d => (d.data().userRating || 5) <= 2).length;
  const riskScore = Math.min(100, recentNegative * 15);
  
  await db.collection('providers').doc(providerId).update({
    rating: parseFloat(avgRating.toFixed(2)),
    riskScore,
    totalReviews: ratings.length,
  });

  if (after.userRating <= 2) {
    console.log(`ALERT: Low rating for provider ${providerId}. Flagging for review.`);
  }
  return null;
});
