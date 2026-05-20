const express = require('express');
const router = express.Router();
const Provider = require('../models/Provider');

// @route   GET api/providers
// @desc    Get all active/online providers with filters
router.get('/', async (req, res) => {
  const { serviceType, city } = req.query;
  const filter = {};
  
  // By default, match online ones unless checking all
  if (req.query.onlyOnline !== 'false') {
    filter.isOnline = true;
  }
  
  if (serviceType) filter.serviceType = serviceType;
  if (city) filter.city = city;

  try {
    const providers = await Provider.find(filter);
    // Convert _id to uid for frontend compatibility
    const formatted = providers.map(p => {
      const obj = p.toObject();
      obj.uid = obj._id;
      return obj;
    });
    res.json(formatted);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// @route   GET api/providers/:id
// @desc    Get specific provider details
router.get('/:id', async (req, res) => {
  try {
    const provider = await Provider.findById(req.params.id);
    if (!provider) {
      return res.status(404).json({ message: 'Provider not found' });
    }
    const obj = provider.toObject();
    obj.uid = obj._id;
    res.json(obj);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// @route   PUT api/providers/:id/status
// @desc    Update online and availability status
router.put('/:id/status', async (req, res) => {
  const { isOnline, isAvailable } = req.body;
  try {
    const provider = await Provider.findById(req.params.id);
    if (!provider) {
      return res.status(404).json({ message: 'Provider not found' });
    }

    if (isOnline !== undefined) provider.isOnline = isOnline;
    if (isAvailable !== undefined) provider.isAvailable = isAvailable;

    await provider.save();
    const obj = provider.toObject();
    obj.uid = obj._id;
    res.json(obj);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

module.exports = router;
