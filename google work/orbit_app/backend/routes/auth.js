const express = require('express');
const router = express.Router();
const jwt = require('jsonwebtoken');
const User = require('../models/User');
const PasswordReset = require('../models/PasswordReset');
const { sendOTP } = require('../utils/brevoEmail');
const authMiddleware = require('../middleware/auth');

// Helper to generate JWT
const generateToken = (user) => {
  return jwt.sign(
    { id: user._id, email: user.email },
    process.env.JWT_SECRET || 'orbit_super_secret_jwt_key_12345',
    { expiresIn: '30d' }
  );
};

// @route   POST api/auth/signup
router.post('/signup', async (req, res) => {
  const { email, password, name, phone, preferredLanguage } = req.body;
  try {
    let user = await User.findOne({ email });
    if (user) {
      return res.status(400).json({ message: 'User already exists' });
    }

    user = new User({
      email,
      password,
      name: name || '',
      phone: phone || '',
      preferredLanguage: preferredLanguage || 'english'
    });

    await user.save();
    const token = generateToken(user);
    res.status(201).json({
      token,
      user: {
        uid: user._id,
        email: user.email,
        name: user.name,
        phone: user.phone,
        preferredLanguage: user.preferredLanguage,
        loyaltyPoints: user.loyaltyPoints,
        bookingHistory: user.bookingHistory,
        createdAt: user.createdAt
      }
    });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// @route   POST api/auth/login
router.post('/login', async (req, res) => {
  const { email, password } = req.body;
  try {
    const user = await User.findOne({ email });
    if (!user) {
      return res.status(400).json({ message: 'Invalid credentials' });
    }

    const isMatch = await user.comparePassword(password);
    if (!isMatch) {
      return res.status(400).json({ message: 'Invalid credentials' });
    }

    const token = generateToken(user);
    res.json({
      token,
      user: {
        uid: user._id,
        email: user.email,
        name: user.name,
        phone: user.phone,
        preferredLanguage: user.preferredLanguage,
        loyaltyPoints: user.loyaltyPoints,
        bookingHistory: user.bookingHistory,
        createdAt: user.createdAt
      }
    });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// @route   POST api/auth/forgot-password
router.post('/forgot-password', async (req, res) => {
  const { email } = req.body;
  try {
    const user = await User.findOne({ email });
    if (!user) {
      return res.status(400).json({ message: 'No user registered with this email address' });
    }

    const otp = Math.floor(100000 + Math.random() * 900000).toString();
    const expiresAt = new Date(Date.now() + 10 * 60 * 1000); // 10 mins

    // Upsert PasswordReset document
    await PasswordReset.findOneAndUpdate(
      { email },
      { otp, expiresAt },
      { upsert: true, new: true }
    );

    // Send email using Brevo Helper with local console fallback
    let emailSent = true;
    try {
      await sendOTP(email, otp);
      console.log(`✉️ OTP sent successfully to ${email}`);
    } catch (emailError) {
      emailSent = false;
      console.error("⚠️ SMTP email sending failed, using console fallback:", emailError.message);
      console.log('\n================================================');
      console.log(`🔑 [DEVELOPMENT FALLBACK] OTP CODE FOR ${email}:`);
      console.log(`👉 CODE: ${otp}`);
      console.log('================================================\n');
    }

    res.json({
      message: 'OTP sent to your email successfully.'
    });
  } catch (err) {
    console.error("❌ Error in forgot-password path:", err);
    res.status(500).json({ message: err.message });
  }
});

// @route   POST api/auth/verify-otp
router.post('/verify-otp', async (req, res) => {
  const { email, otp } = req.body;
  try {
    const record = await PasswordReset.findOne({ email });
    if (!record) {
      return res.status(400).json({ message: 'Invalid or expired OTP request.' });
    }

    if (record.otp !== otp) {
      return res.status(400).json({ message: 'Incorrect OTP code.' });
    }

    if (new Date() > record.expiresAt) {
      return res.status(400).json({ message: 'OTP code has expired.' });
    }

    res.json({ message: 'OTP verified successfully.' });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// @route   POST api/auth/reset-password
router.post('/reset-password', async (req, res) => {
  const { email, otp, password } = req.body;
  try {
    const record = await PasswordReset.findOne({ email });
    if (!record) {
      return res.status(400).json({ message: 'Invalid or expired OTP verification.' });
    }

    if (record.otp !== otp || new Date() > record.expiresAt) {
      return res.status(400).json({ message: 'Verification code has expired or is invalid.' });
    }

    const user = await User.findOne({ email });
    if (!user) {
      return res.status(404).json({ message: 'User not found.' });
    }

    // Set new password (the pre-save middleware will hash it)
    user.password = password;
    await user.save();

    // Clean up reset token
    await PasswordReset.deleteOne({ email });

    res.json({ message: 'Password has been reset successfully.' });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// @route   GET api/auth/me
router.get('/me', authMiddleware, async (req, res) => {
  try {
    const user = await User.findById(req.user.id).select('-password');
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }
    res.json({
      uid: user._id,
      email: user.email,
      name: user.name,
      phone: user.phone,
      preferredLanguage: user.preferredLanguage,
      loyaltyPoints: user.loyaltyPoints,
      bookingHistory: user.bookingHistory,
      createdAt: user.createdAt
    });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

module.exports = router;
