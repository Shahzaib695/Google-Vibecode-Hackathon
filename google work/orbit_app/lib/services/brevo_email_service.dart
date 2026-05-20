import 'dart:convert';
import 'package:http/http.dart' as http;

class BrevoEmailService {
  static const String apiKey = 'xsmtpsib-1134de3da0153c261d21cd25930454716a9ab51af0dc56ca1e7fc40e683823ca-scfmkqf4HyabRaFH';
  static const String apiUrl = 'https://api.brevo.com/v3/smtp/email';

  Future<void> sendOTP(String recipientEmail, String otp) async {
    final Map<String, dynamic> data = {
      "sender": {"name": "Orbit AI Support", "email": "support@orbitapp.com"},
      "to": [{"email": recipientEmail}],
      "subject": "Your Orbit Password Reset Code",
      "htmlContent": """
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: auto; padding: 30px; border: 1px solid #e0e0e0; border-radius: 12px; background-color: #ffffff;">
          <h2 style="color: #FF6B6B; text-align: center;">Orbit App Password Reset</h2>
          <p style="font-size: 16px; color: #333;">Hello,</p>
          <p style="font-size: 16px; color: #333;">We received a request to reset the password for your Orbit account. Please use the 6-digit verification code below to proceed:</p>
          <div style="text-align: center; margin: 40px 0;">
            <span style="font-size: 36px; font-weight: bold; color: #FF6B6B; letter-spacing: 8px; padding: 15px 30px; background-color: #fff0f0; border-radius: 8px; border: 1px dashed #FF6B6B;">$otp</span>
          </div>
          <p style="font-size: 14px; color: #666;">This code is valid for 10 minutes. If you did not request a password reset, please ignore this email.</p>
          <hr style="border: 0; border-top: 1px solid #eee; margin: 30px 0;" />
          <p style="font-size: 12px; color: #aaa; text-align: center;">Orbit &mdash; Your city, intelligently served.<br>Google Cloud AI Challenge 2026</p>
        </div>
      """
    };

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'accept': 'application/json',
        'api-key': apiKey,
        'content-type': 'application/json',
      },
      body: jsonEncode(data),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to send email: ${response.body}');
    }
  }
}
