import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../services/auth_service.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String email;
  const OtpVerificationScreen({super.key, required this.email});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final _auth = AuthService();
  bool _loading = false;
  String _error = '';

  Future<void> _verifyOTP(String otp) async {
    setState(() { _loading = true; _error = ''; });

    try {
      final isValid = await _auth.verifyPasswordResetOTP(widget.email, otp);
      if (isValid) {
        if (mounted) context.pushReplacement('/reset-password', extra: widget.email);
      } else {
        setState(() { _error = 'Invalid or expired OTP. Please try again.'; });
      }
    } catch (e) {
      String msg = e.toString().replaceAll('Exception: ', '');
      if (msg.length > 120) msg = msg.substring(0, 120);
      setState(() { _error = msg; });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(gradient: OrbitColors.primaryGradient),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => context.pop(),
                  ).animate().fadeIn(),
                  const SizedBox(height: 16),
                  Text('Verify Email',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.w800),
                  ).animate().fadeIn().slideX(begin: -0.2),
                  Text('A 6-digit code was sent to ${widget.email}',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white.withOpacity(0.85)),
                  ).animate().fadeIn(delay: 200.ms),
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Enter OTP', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 16),
                        PinCodeTextField(
                          appContext: context,
                          length: 6,
                          keyboardType: TextInputType.number,
                          pinTheme: PinTheme(
                            shape: PinCodeFieldShape.box,
                            borderRadius: BorderRadius.circular(12),
                            activeFillColor: OrbitColors.backgroundAlt,
                            selectedFillColor: OrbitColors.coral.withOpacity(0.1),
                            inactiveFillColor: OrbitColors.backgroundAlt,
                            activeColor: OrbitColors.coral,
                            selectedColor: OrbitColors.coral,
                            inactiveColor: OrbitColors.surfaceVariant,
                          ),
                          enableActiveFill: true,
                          onCompleted: _verifyOTP,
                          onChanged: (_) {},
                        ),
                        if (_error.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(_error, style: TextStyle(color: OrbitColors.error, fontSize: 13)),
                          ),
                        const SizedBox(height: 24),
                        if (_loading)
                          const Center(child: CircularProgressIndicator(color: OrbitColors.coral)),
                      ],
                    ),
                  ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1, curve: Curves.easeOutCubic),
                ],
              ),
            ),
            ),
          ),
        ],
      ),
    );
  }
}
