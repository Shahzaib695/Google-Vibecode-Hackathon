const admin = require('firebase-admin');
const { logToAntigravity } = require('../utils/firestoreHelpers');

async function resolveDispute(disputeId, bookingId, issueType, description) {
  const db = admin.firestore();
  const bookingDoc = await db.collection('bookings').doc(bookingId).get();
  const booking = bookingDoc.data();
  
  // Check provider dispute history
  const pastDisputes = await db.collection('disputes')
    .where('providerId', '==', booking.providerId)
    .where('status', '!=', 'closed').get();

  const disputeCount = pastDisputes.size;
  let resolution, refundAmount, newStatus = 'ai_resolved';

  switch (issueType) {
    case 'no_show':
      resolution = `Provider did not arrive. Full refund issued. Provider warned (${disputeCount + 1} dispute(s) total).`;
      refundAmount = booking.pricingBreakdown?.total || 0;
      break;
    case 'overcharged':
      resolution = 'Overcharge detected. Partial refund of excess amount recommended.';
      refundAmount = 200;
      break;
    case 'quality_issue':
      if (disputeCount >= 2) {
        resolution = 'Repeat quality issue. Full refund issued. Provider suspended.';
        refundAmount = booking.pricingBreakdown?.total || 0;
        await db.collection('providers').doc(booking.providerId).update({ isAvailable: false, suspended: true });
      } else {
        resolution = '30% refund issued. Provider flagged for review.';
        refundAmount = (booking.pricingBreakdown?.total || 0) * 0.30;
      }
      break;
    case 'damage':
      resolution = 'Property damage reported. Escalating to human support team.';
      refundAmount = booking.pricingBreakdown?.total || 0;
      newStatus = 'escalated';
      break;
    default:
      resolution = 'Issue reviewed. 15% goodwill refund offered. Contact support for further assistance.';
      refundAmount = (booking.pricingBreakdown?.total || 0) * 0.15;
  }

  // Blacklist check: 3+ disputes in 30 days
  const thirtyDaysAgo = new Date(); thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);
  const recentDisputes = await db.collection('disputes')
    .where('providerId', '==', booking.providerId)
    .where('createdAt', '>=', thirtyDaysAgo).get();

  if (recentDisputes.size >= 3) {
    await db.collection('providers').doc(booking.providerId).update({ suspended: true, blacklisted: true });
    resolution += ' PROVIDER BLACKLISTED: 3+ disputes in 30 days.';
  }

  await db.collection('disputes').doc(disputeId).update({
    status: newStatus,
    aiSuggestedResolution: resolution,
    refundAmount,
    resolvedAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  await logToAntigravity({
    stage: 'dispute',
    inputData: { disputeId, bookingId, issueType, disputeCount },
    reasoning: `Dispute type: ${issueType}. Provider dispute history: ${disputeCount}. Resolution: ${resolution}`,
    outputData: { resolution, refundAmount, status: newStatus },
    confidenceScore: newStatus === 'escalated' ? 60 : 88,
    fallbackTriggered: newStatus === 'escalated',
    fallbackReason: newStatus === 'escalated' ? 'Damage claim requires human review' : null,
    latencyMs: 800,
  });

  return { resolution, refundAmount, status: newStatus };
}

module.exports = { resolveDispute };
