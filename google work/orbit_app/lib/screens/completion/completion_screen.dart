import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:confetti/confetti.dart';
import '../../core/theme.dart';
import '../../services/firestore_service.dart';
import '../../models/booking_model.dart';

class CompletionScreen extends StatefulWidget {
  final String bookingId;
  const CompletionScreen({super.key, required this.bookingId});
  @override
  State<CompletionScreen> createState() => _CompletionScreenState();
}

class _CompletionScreenState extends State<CompletionScreen> {
  late ConfettiController _confetti;
  BookingModel? _booking;

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 4))..play();
    _loadBooking();
  }

  Future<void> _loadBooking() async {
    // For demo, show mock booking data
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OrbitColors.backgroundAlt,
      body: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confetti,
              blastDirectionality: BlastDirectionality.explosive,
              colors: const [OrbitColors.coral, OrbitColors.skyBlue, OrbitColors.mint, OrbitColors.amber],
              numberOfParticles: 30,
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  Container(
                    width: 100, height: 100,
                    decoration: const BoxDecoration(gradient: OrbitColors.mintGradient, shape: BoxShape.circle),
                    child: const Icon(Icons.check_rounded, color: Colors.white, size: 52),
                  ).animate().scale(curve: Curves.elasticOut),
                  const SizedBox(height: 24),
                  Text('Booking Confirmed! 🎉',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
                    textAlign: TextAlign.center,
                  ).animate().fadeIn(delay: 300.ms),
                  const SizedBox(height: 8),
                  Text('Aapki booking successful ho gayi.\nProvider rast mein hai.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: OrbitColors.textSecondary),
                    textAlign: TextAlign.center,
                  ).animate().fadeIn(delay: 500.ms),
                  const SizedBox(height: 32),
                  _buildProviderCard(),
                  const SizedBox(height: 20),
                  _buildNotificationCard(),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => context.push('/tracking/${widget.bookingId}'),
                          icon: const Icon(Icons.map_rounded),
                          label: const Text('Track Live'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: OrbitColors.coral,
                            side: const BorderSide(color: OrbitColors.coral),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(OrbitTheme.radiusMedium)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => context.go('/home'),
                          icon: const Icon(Icons.home_rounded),
                          label: const Text('Go Home'),
                        ),
                      ),
                    ],
                  ).animate().fadeIn(delay: 700.ms),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProviderCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: OrbitTheme.cardDecoration(),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: OrbitColors.coral.withOpacity(0.15),
                child: const Text('U', style: TextStyle(color: OrbitColors.coral, fontWeight: FontWeight.bold, fontSize: 22)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Usman Tariq', style: Theme.of(context).textTheme.titleMedium),
                    const Text('AC Technician • G-13', style: TextStyle(color: OrbitColors.textSecondary, fontSize: 13)),
                    const SizedBox(height: 4),
                    Row(children: [
                      const Icon(Icons.star_rounded, color: Color(0xFFFFB347), size: 14),
                      const Text(' 4.9', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                      const Text(' • ETA: 25 min', style: TextStyle(color: OrbitColors.textSecondary, fontSize: 12)),
                    ]),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: OrbitColors.mint.withOpacity(0.15), shape: BoxShape.circle),
                child: const Icon(Icons.phone_rounded, color: OrbitColors.mint, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 12),
          _infoRow(Icons.calendar_today_rounded, 'Tomorrow, 09:00 AM'),
          const SizedBox(height: 8),
          _infoRow(Icons.location_on_rounded, 'G-13, Islamabad'),
          const SizedBox(height: 8),
          _infoRow(Icons.payments_rounded, 'Cash • Rs. 2,450'),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2);
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: OrbitColors.coral),
        const SizedBox(width: 10),
        Text(text, style: const TextStyle(fontSize: 14, color: OrbitColors.textPrimary)),
      ],
    );
  }

  Widget _buildNotificationCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: OrbitColors.skyBlue.withOpacity(0.08),
        borderRadius: BorderRadius.circular(OrbitTheme.radiusMedium),
        border: Border.all(color: OrbitColors.skyBlue.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          const Text('🔔', style: TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Notification Sent!', style: TextStyle(fontWeight: FontWeight.w700, color: OrbitColors.skyBlue)),
                const Text('Reminder set for 1 hour before your booking. Provider has been notified.', 
                  style: TextStyle(fontSize: 12, color: OrbitColors.textSecondary, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 600.ms);
  }
}
