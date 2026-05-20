import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme.dart';
import '../../core/constants.dart';

class AIUnderstandingPanel extends StatelessWidget {
  final Map<String, dynamic> intent;
  final VoidCallback onClose;
  const AIUnderstandingPanel({super.key, required this.intent, required this.onClose});

  @override
  Widget build(BuildContext context) {
    final confidence = (intent['confidence'] as double? ?? 0);
    final service = intent['service'] as String? ?? '';
    final location = intent['location'] as String? ?? 'Not detected';
    final urgency = intent['urgency'] as String? ?? 'standard';
    final time = intent['preferredTime'] as String? ?? 'ASAP';
    final budget = intent['budgetSensitivity'] as String? ?? 'medium';
    final language = intent['language'] as String? ?? 'english';

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(OrbitTheme.radiusLarge),
        border: Border.all(color: OrbitColors.coral.withOpacity(0.2)),
        boxShadow: OrbitTheme.elevatedShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  gradient: OrbitColors.primaryGradient,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: const Text('🧠 AI Understanding', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
              ),
              const Spacer(),
              GestureDetector(onTap: onClose, child: const Icon(Icons.close, size: 18, color: OrbitColors.textHint)),
            ],
          ),
          const SizedBox(height: 16),
          // Fields grid
          Wrap(
            spacing: 8, runSpacing: 8,
            children: [
              _field(context, '🔧 Service', AppConstants.serviceNames[service] ?? service, delay: 0),
              _field(context, '📍 Location', location, delay: 100),
              _field(context, '⚡ Urgency', urgency.toUpperCase(), delay: 200,
                color: urgency == 'emergency' ? OrbitColors.error : urgency == 'high' ? OrbitColors.amber : OrbitColors.mint),
              _field(context, '🕐 Time', _timeLabel(time), delay: 300),
              _field(context, '💰 Budget', budget.toUpperCase(), delay: 400),
              _field(context, '🌐 Language', language, delay: 500),
            ],
          ),
          const SizedBox(height: 16),
          // Confidence bar
          Row(
            children: [
              Text('AI Confidence', style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
              const Spacer(),
              Text('${confidence.toStringAsFixed(0)}%',
                style: TextStyle(
                  fontWeight: FontWeight.w800, fontSize: 13,
                  color: confidence >= 85 ? OrbitColors.mint : confidence >= 70 ? OrbitColors.amber : OrbitColors.error,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: LinearProgressIndicator(
              value: confidence / 100,
              minHeight: 8,
              backgroundColor: OrbitColors.backgroundAlt,
              valueColor: AlwaysStoppedAnimation(
                confidence >= 85 ? OrbitColors.mint : confidence >= 70 ? OrbitColors.amber : OrbitColors.error,
              ),
            ),
          ).animate().scaleX(begin: 0, curve: Curves.easeOut, duration: 800.ms),
          if (confidence < 70 && intent['clarificationQuestion'] != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: OrbitColors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: OrbitColors.amber.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Text('💬', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(intent['clarificationQuestion'] as String,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: OrbitColors.textPrimary),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 600.ms),
          ],
        ],
      ),
    ).animate().slideY(begin: 1, curve: Curves.easeOut);
  }

  Widget _field(BuildContext context, String label, String value, {int delay = 0, Color? color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: (color ?? OrbitColors.coral).withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: OrbitColors.textHint)),
          const SizedBox(height: 2),
          Text(value.isEmpty ? '—' : value,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: color ?? OrbitColors.textPrimary),
          ),
        ],
      ),
    ).animate(delay: delay.ms).fadeIn().slideX(begin: 0.2);
  }

  String _timeLabel(String time) {
    switch (time) {
      case 'tomorrow_morning': return 'Kal Subah (9–12)';
      case 'evening': return 'Sham (5–8pm)';
      case 'immediate': return 'Abhi (Immediate)';
      default: return 'ASAP';
    }
  }
}
