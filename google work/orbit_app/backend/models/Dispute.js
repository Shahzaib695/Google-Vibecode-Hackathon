const mongoose = require('mongoose');

const DisputeSchema = new mongoose.Schema({
  bookingId: { type: String, required: true },
  userId: { type: String, required: true },
  providerId: { type: String, required: true },
  issueType: { type: String, required: true }, // e.g., no_show, overcharged, quality_issue, etc.
  description: { type: String, required: true },
  evidenceUrls: [{ type: String }],
  status: { type: String, default: 'open' }, // open, ai_reviewing, ai_resolved, closed
  aiSuggestedResolution: String,
  refundAmount: Number,
  resolvedAt: Date,
  antigravityTrace: { type: mongoose.Schema.Types.Mixed },
  createdAt: { type: Date, default: Date.now }
});

module.exports = mongoose.model('Dispute', DisputeSchema);
