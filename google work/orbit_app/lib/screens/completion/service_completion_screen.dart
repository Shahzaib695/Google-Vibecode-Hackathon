import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../services/firestore_service.dart';

class ServiceCompletionScreen extends StatefulWidget {
  final String bookingId;
  const ServiceCompletionScreen({super.key, required this.bookingId});
  @override
  State<ServiceCompletionScreen> createState() => _ServiceCompletionScreenState();
}

class _ServiceCompletionScreenState extends State<ServiceCompletionScreen> {
  final _firestore = FirestoreService();
  double _rating = 0;
  double _punctuality = 0;
  double _quality = 0;
  double _professionalism = 0;
  bool _submitted = false;
  final _reviewController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Service Feedback')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: _submitted ? _buildThankYou() : _buildForm(),
      ),
    );
  }

  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: OrbitTheme.cardDecoration(gradient: OrbitColors.primaryGradient),
          child: const Row(
            children: [
              Text('⭐', style: TextStyle(fontSize: 36)),
              SizedBox(width: 16),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('How was your service?', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18)),
                  Text('Aapki feedback provider ki ranking ko improve karti hai', style: TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              )),
            ],
          ),
        ).animate().fadeIn(),
        const SizedBox(height: 24),
        _buildStarRating('Overall Rating', _rating, (v) => setState(() => _rating = v)),
        const SizedBox(height: 16),
        _buildStarRating('Punctuality', _punctuality, (v) => setState(() => _punctuality = v)),
        const SizedBox(height: 16),
        _buildStarRating('Work Quality', _quality, (v) => setState(() => _quality = v)),
        const SizedBox(height: 16),
        _buildStarRating('Professionalism', _professionalism, (v) => setState(() => _professionalism = v)),
        const SizedBox(height: 24),
        Text('Write a Review', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        TextField(
          controller: _reviewController,
          maxLines: 3,
          decoration: const InputDecoration(hintText: 'Kya acha laga? Kya improve ho sakta hai?'),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _rating == 0 ? null : _submitRating,
            child: const Text('Submit Feedback'),
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🎁', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
              Text('+10 Loyalty Points after submission', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: OrbitColors.coral, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStarRating(String label, double value, Function(double) onRate) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        Row(
          children: List.generate(5, (i) {
            return GestureDetector(
              onTap: () => onRate(i + 1.0),
              child: Icon(
                i < value ? Icons.star_rounded : Icons.star_outline_rounded,
                color: i < value ? const Color(0xFFFFB347) : OrbitColors.textHint,
                size: 36,
              ).animate(key: ValueKey('$label-$value')).scale(curve: Curves.elasticOut),
            );
          }),
        ),
      ],
    );
  }

  Future<void> _submitRating() async {
    await _firestore.submitRating(widget.bookingId, _rating, _reviewController.text);
    if (mounted) setState(() => _submitted = true);
  }

  Widget _buildThankYou() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 60),
        const Text('🎉', style: TextStyle(fontSize: 80)).animate().scale(curve: Curves.elasticOut),
        const SizedBox(height: 24),
        Text('Shukriya!', style: Theme.of(context).textTheme.displayMedium?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        const Text('Aapki feedback save ho gayi.\n+10 Loyalty Points aapke account mein add ho gaye! 🎁',
          textAlign: TextAlign.center, style: TextStyle(color: OrbitColors.textSecondary, fontSize: 16, height: 1.6)),
        const SizedBox(height: 32),
        ElevatedButton(onPressed: () => context.go('/home'), child: const Text('Back to Home')),
      ],
    );
  }
}
