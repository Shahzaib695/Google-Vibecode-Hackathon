const mongoose = require('mongoose');

const ProviderSchema = new mongoose.Schema({
  name: { type: String, required: true },
  serviceType: { type: String, required: true }, // e.g., ac_technician, plumber, electrician
  specializations: [{ type: String }],
  location: {
    latitude: { type: Number, required: true },
    longitude: { type: Number, required: true }
  },
  city: { type: String, required: true },
  area: { type: String, required: true },
  rating: { type: Number, default: 0.0 },
  totalReviews: { type: Number, default: 0 },
  onTimeScore: { type: Number, default: 0.0 },
  cancellationRate: { type: Number, default: 0.0 },
  riskScore: { type: Number, default: 0.0 },
  isOnline: { type: Boolean, default: false },
  isAvailable: { type: Boolean, default: false },
  pricePerHour: { type: Number, required: true },
  experienceYears: { type: Number, default: 0 },
  certifications: [{ type: String }],
  capacityPerDay: { type: Number, default: 5 },
  currentBookingsToday: { type: Number, default: 0 },
  availableSlots: [{ type: Date }],
  earnings: {
    type: Map,
    of: Number,
    default: {}
  },
  profileImageUrl: { type: String },
  phone: { type: String },
  createdAt: { type: Date, default: Date.now }
});

module.exports = mongoose.model('Provider', ProviderSchema);
