const express = require('express');
const router = express.Router();
const AntigravityLog = require('../models/AntigravityLog');

// @route   GET api/logs
// @desc    Get recent Antigravity trace logs
router.get('/', async (req, res) => {
  const { stage, limit } = req.query;
  const filter = {};
  if (stage) filter.stage = stage;
  const maxLimit = parseInt(limit) || 50;

  try {
    const logs = await AntigravityLog.find(filter).sort({ createdAt: -1 }).limit(maxLimit);
    const formatted = logs.map(l => {
      const obj = l.toObject();
      obj.logId = obj._id;
      return obj;
    });
    res.json(formatted);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// @route   POST api/logs
// @desc    Create a new Antigravity log trace
router.post('/', async (req, res) => {
  const { bookingId, stage, inputData, reasoning, outputData, confidenceScore, fallbackTriggered, fallbackReason, latencyMs } = req.body;
  try {
    const log = new AntigravityLog({
      bookingId,
      stage,
      inputData,
      reasoning,
      outputData,
      confidenceScore,
      fallbackTriggered,
      fallbackReason,
      latencyMs
    });

    await log.save();
    const obj = log.toObject();
    obj.logId = obj._id;
    res.status(201).json(obj);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

module.exports = router;
