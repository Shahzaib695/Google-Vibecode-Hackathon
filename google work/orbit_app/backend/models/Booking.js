const mongoose = require('mongoose');

const ExtractedIntentSchema = new mongoose.Schema({
  service: String,
  location: String,
  urgency: String,
  preferredTime: String,
  budgetSensitivity: String,
  jobDescription: String,
  confidence: Number,
  language: String,
  clarificationQuestion: String
}, { _id: false });

const PricingBreakdownSchema = new mongoose.Schema({
  baseRate: Number,
  visitFee: Number,
  distanceCost: Number,
  urgencyAdjustment: Number,
  surgeMultiplier: Number,
  loyaltyDiscount: Number,
  total: Number,
  isFairPrice: Boolean,
  budgetAlternative: String
}, { _id: false });

const BookingSchema = new mongoose.Schema({
  userId: { type: String, required: true },
  providerId: { type: String, required: true },
  serviceType: { type: String, required: true },
  jobComplexity: { type: String, default: 'basic' },
  status: { type: String, default: 'pending' }, // confirmed, completed, cancelled, disputed, etc.
  requestText: { type: String, required: true },
  extractedIntent: ExtractedIntentSchema,
  scheduledTime: { type: Date },
  address: { type: String, default: '' },
  pricingBreakdown: PricingBreakdownSchema,
  paymentMethod: { type: String, default: 'cash' },
  paymentStatus: { type: String, default: 'pending' },
  userRating: Number,
  userReview: String,
  providerRating: Number,
  disputeId: String,
  antigravityTrace: { type: mongoose.Schema.Types.Mixed },
  createdAt: { type: Date, default: Date.now },
  updatedAt: { type: Date, default: Date.now }
});

module.exports = mongoose.model('Booking', BookingSchema);
