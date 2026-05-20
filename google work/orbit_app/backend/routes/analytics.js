const express = require('express');
const router = express.Router();
const Booking = require('../models/Booking');
const Dispute = require('../models/Dispute');
const AntigravityLog = require('../models/AntigravityLog');

// @route   GET api/analytics
// @desc    Get dashboard metrics and AI performance metrics
router.get('/', async (req, res) => {
  try {
    const totalBookings = await Booking.countDocuments();
    const completedBookings = await Booking.countDocuments({ status: 'completed' });
    const cancelledBookings = await Booking.countDocuments({ status: 'cancelled' });
    const totalDisputes = await Dispute.countDocuments();
    
    const logs = await AntigravityLog.find({});
    
    let avgConfidence = 0.0;
    let fallbackCount = 0;
    
    if (logs.length > 0) {
      const sumConfidence = logs.reduce((sum, log) => sum + (log.confidenceScore || 0), 0);
      avgConfidence = sumConfidence / logs.length;
      fallbackCount = logs.filter(log => log.fallbackTriggered === true).length;
    }

    const aiSuccessRate = logs.length > 0 ? ((logs.length - fallbackCount) / logs.length * 100) : 0;

    res.json({
      totalBookings,
      completedBookings,
      cancelledBookings,
      totalDisputes,
      avgConfidence,
      fallbackCount,
      aiSuccessRate
    });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

module.exports = router;
