const nodemailer = require('nodemailer');

const sendOTP = (recipientEmail, otp) => {
  return new Promise((resolve, reject) => {
    const smtpUser = process.env.BREVO_SMTP_USER || '981c2e001@smtp-brevo.com';
    const smtpPass = process.env.BREVO_API_KEY || 'xsmtpsib-1134de3da0153c261d21cd25930454716a9ab51af0dc56ca1e7fc40e683823ca-scfmkqf4HyabRaFH';
    const senderEmail = process.env.BREVO_SENDER || 'moin69603@gmail.com';

    const transporter = nodemailer.createTransport({
      host: 'smtp-relay.brevo.com',
      port: 587,
      secure: false, // Upgrade later with STARTTLS
      auth: {
        user: smtpUser,
        pass: smtpPass
      }
    });

    const mailOptions = {
      from: `"Orbit AI Support" <${senderEmail}>`,
      to: recipientEmail,
      subject: "Your Orbit Password Reset Code",
      html: `
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: auto; padding: 20px; border: 1px solid #e0e0e0; border-radius: 12px; background-color: #ffffff;">
          <h2 style="color: #FF6B6B; text-align: center; margin-top: 0;">Orbit App Password Reset</h2>
          <p style="font-size: 16px; color: #333; line-height: 1.5;">Hello,</p>
          <p style="font-size: 16px; color: #333; line-height: 1.5;">We received a request to reset the password for your Orbit account. Please use the 6-digit verification code below to proceed:</p>
          <div style="text-align: center; margin: 30px 0;">
            <div style="display: inline-block; font-size: 32px; font-weight: bold; color: #FF6B6B; letter-spacing: 4px; padding: 12px 24px; background-color: #fff0f0; border-radius: 8px; border: 1px dashed #FF6B6B; white-space: nowrap;">${otp}</div>
          </div>
          <p style="font-size: 14px; color: #666; line-height: 1.5;">This code is valid for 10 minutes. If you did not request a password reset, please ignore this email.</p>
          <hr style="border: 0; border-top: 1px solid #eee; margin: 30px 0;" />
          <p style="font-size: 12px; color: #aaa; text-align: center; line-height: 1.5;">Orbit &mdash; Your city, intelligently served.<br>Google Cloud AI Challenge 2026</p>
        </div>
      `
    };

    transporter.sendMail(mailOptions, (error, info) => {
      if (error) {
        return reject(error);
      }
      resolve(info.response);
    });
  });
};

module.exports = { sendOTP };
