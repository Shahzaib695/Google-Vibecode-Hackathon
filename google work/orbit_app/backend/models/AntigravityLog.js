const mongoose = require('mongoose');

const AntigravityLogSchema = new mongoose.Schema({
  bookingId: String,
  stage: { type: String, required: true }, // e.g., intent_parsing, provider_matching, pricing, etc.
  inputData: { type: mongoose.Schema.Types.Mixed, required: true },
  reasoning: { type: String, required: true },
  outputData: { type: mongoose.Schema.Types.Mixed, required: true },
  confidenceScore: { type: Number, required: true },
  fallbackTriggered: { type: Boolean, default: false },
  fallbackReason: String,
  latencyMs: { type: Number, required: true },
  createdAt: { type: Date, default: Date.now }
});

module.exports = mongoose.model('AntigravityLog', AntigravityLogSchema);
