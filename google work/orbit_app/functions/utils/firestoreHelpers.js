const admin = require('firebase-admin');

async function logToAntigravity({ stage, bookingId, inputData, reasoning, outputData, confidenceScore, fallbackTriggered = false, fallbackReason = null, latencyMs }) {
  const db = admin.firestore();
  const logId = db.collection('antigravityLogs').doc().id;
  await db.collection('antigravityLogs').doc(logId).set({
    logId, bookingId: bookingId || null, stage, inputData, reasoning, outputData,
    confidenceScore, fallbackTriggered, fallbackReason, latencyMs,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  });
  return logId;
}

module.exports = { logToAntigravity };
