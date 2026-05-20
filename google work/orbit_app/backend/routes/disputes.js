const express = require('express');
const router = express.Router();
const Dispute = require('../models/Dispute');
const Booking = require('../models/Booking');

// @route   POST api/disputes
// @desc    Create a dispute on a booking
router.post('/', async (req, res) => {
  const { bookingId, userId, providerId, issueType, description, evidenceUrls, antigravityTrace } = req.body;
  try {
    const dispute = new Dispute({
      bookingId,
      userId,
      providerId,
      issueType,
      description,
      evidenceUrls: evidenceUrls || [],
      antigravityTrace
    });

    await dispute.save();

    // Update booking status and save dispute reference
    await Booking.findByIdAndUpdate(bookingId, {
      status: 'disputed',
      disputeId: dispute._id.toString()
    });

    const obj = dispute.toObject();
    obj.disputeId = obj._id;
    res.status(201).json(obj);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// @route   PUT api/disputes/:id
// @desc    Update dispute status or resolution details
router.put('/:id', async (req, res) => {
  const { status, aiSuggestedResolution, refundAmount } = req.body;
  try {
    const dispute = await Dispute.findById(req.params.id);
    if (!dispute) {
      return res.status(404).json({ message: 'Dispute not found' });
    }

    if (status) dispute.status = status;
    if (aiSuggestedResolution) dispute.aiSuggestedResolution = aiSuggestedResolution;
    if (refundAmount !== undefined) dispute.refundAmount = refundAmount;
    if (status === 'resolved' || status === 'ai_resolved' || status === 'human_resolved') {
      dispute.resolvedAt = new Date();
    }

    await dispute.save();
    const obj = dispute.toObject();
    obj.disputeId = obj._id;
    res.json(obj);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

module.exports = router;
