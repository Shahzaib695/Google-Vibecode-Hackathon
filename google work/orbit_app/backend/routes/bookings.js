const express = require('express');
const router = express.Router();
const Booking = require('../models/Booking');
const Provider = require('../models/Provider');
const User = require('../models/User');

// Helper function to populate provider details
const populateProviderInfo = async (bookingObj) => {
  try {
    const provider = await Provider.findById(bookingObj.providerId);
    if (provider) {
      bookingObj.providerName = provider.name;
      bookingObj.providerPhone = provider.phone || '';
      bookingObj.providerRatingValue = provider.rating;
    }
  } catch (_) {}
  bookingObj.bookingId = bookingObj._id;
  return bookingObj;
};

// @route   POST api/bookings
// @desc    Create a new service booking
router.post('/', async (req, res) => {
  const {
    userId, providerId, serviceType, jobComplexity, requestText,
    extractedIntent, scheduledTime, address, pricingBreakdown, paymentMethod
  } = req.body;

  try {
    const booking = new Booking({
      userId,
      providerId,
      serviceType,
      jobComplexity: jobComplexity || 'basic',
      status: 'confirmed',
      requestText,
      extractedIntent,
      scheduledTime: scheduledTime ? new Date(scheduledTime) : undefined,
      address: address || '',
      pricingBreakdown,
      paymentMethod: paymentMethod || 'cash',
      paymentStatus: 'pending'
    });

    await booking.save();

    // Update user history
    await User.findByIdAndUpdate(userId, {
      $push: { bookingHistory: booking._id.toString() }
    });

    const obj = booking.toObject();
    const populated = await populateProviderInfo(obj);
    res.status(201).json(populated);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// @route   GET api/bookings/user/:userId
// @desc    Get bookings for a specific user
router.get('/user/:userId', async (req, res) => {
  try {
    const bookings = await Booking.find({ userId: req.params.userId }).sort({ createdAt: -1 });
    const formatted = await Promise.all(bookings.map(async (b) => {
      const obj = b.toObject();
      return await populateProviderInfo(obj);
    }));
    res.json(formatted);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// @route   GET api/bookings/provider/:providerId
// @desc    Get bookings for a specific provider
router.get('/provider/:providerId', async (req, res) => {
  try {
    const bookings = await Booking.find({ providerId: req.params.providerId }).sort({ createdAt: -1 });
    const formatted = await Promise.all(bookings.map(async (b) => {
      const obj = b.toObject();
      return await populateProviderInfo(obj);
    }));
    res.json(formatted);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// @route   PUT api/bookings/:id/status
// @desc    Update the status of a booking
router.put('/:id/status', async (req, res) => {
  const { status } = req.body;
  try {
    const booking = await Booking.findById(req.params.id);
    if (!booking) {
      return res.status(404).json({ message: 'Booking not found' });
    }

    booking.status = status;
    booking.updatedAt = new Date();
    await booking.save();

    const obj = booking.toObject();
    const populated = await populateProviderInfo(obj);
    res.json(populated);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// @route   PUT api/bookings/:id/rating
// @desc    Submit rating and review, complete the booking
router.put('/:id/rating', async (req, res) => {
  const { rating, review } = req.body;
  try {
    const booking = await Booking.findById(req.params.id);
    if (!booking) {
      return res.status(404).json({ message: 'Booking not found' });
    }

    booking.userRating = rating;
    booking.userReview = review;
    booking.status = 'completed';
    booking.updatedAt = new Date();
    await booking.save();

    // Recalculate provider overall rating
    try {
      const allRatings = await Booking.find({ providerId: booking.providerId, userRating: { $exists: true } });
      if (allRatings.length > 0) {
        const avg = allRatings.reduce((sum, b) => sum + b.userRating, 0) / allRatings.length;
        await Provider.findByIdAndUpdate(booking.providerId, {
          rating: parseFloat(avg.toFixed(1)),
          $inc: { totalReviews: 1 }
        });
      }
    } catch (_) {}

    const obj = booking.toObject();
    const populated = await populateProviderInfo(obj);
    res.json(populated);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

module.exports = router;
