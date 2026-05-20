import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme.dart';
import '../../models/provider_model.dart';

class ProviderCard extends StatelessWidget {
  final ProviderModel provider;
  final int rank;
  final VoidCallback onSelect;
  const ProviderCard({super.key, required this.provider, required this.rank, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final matchPct = provider.matchScore?.toStringAsFixed(0) ?? '0';
    final isTop = rank == 1;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: OrbitTheme.cardDecoration(
        gradient: isTop ? LinearGradient(
          colors: [OrbitColors.coral.withOpacity(0.05), OrbitColors.skyBlue.withOpacity(0.03)],
        ) : null,
        shadows: isTop ? OrbitTheme.elevatedShadow : OrbitTheme.softShadow,
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: OrbitColors.coral.withOpacity(0.15),
                  child: Text(provider.name[0], style: const TextStyle(color: OrbitColors.coral, fontWeight: FontWeight.bold, fontSize: 22)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(provider.name, style: Theme.of(context).textTheme.titleMedium),
                      Text('${provider.serviceName} • ${provider.area}', style: Theme.of(context).textTheme.bodySmall),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded, color: Color(0xFFFFB347), size: 14),
                          Text(' ${provider.rating.toStringAsFixed(1)} (${provider.totalReviews})',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                          const SizedBox(width: 8),
                          Text('⏱ ${provider.onTimeDisplay} on-time',
                            style: const TextStyle(fontSize: 11, color: OrbitColors.textSecondary)),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: isTop ? OrbitColors.primaryGradient : const LinearGradient(colors: [Color(0xFF4A9AF5), Color(0xFF6C63FF)]),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Text('$matchPct%', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13)),
                    ),
                    const SizedBox(height: 4),
                    Text('match', style: TextStyle(fontSize: 10, color: OrbitColors.textHint)),
                  ],
                ),
              ],
            ),
            if (provider.matchLabel != null) ...[
              const SizedBox(height: 12),
              _badges(provider),
            ],
            if (provider.matchReason != null) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: OrbitColors.backgroundAlt,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Text('🤖', style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(provider.matchReason!,
                        style: const TextStyle(fontSize: 12, color: OrbitColors.textSecondary, height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Rs. ${provider.pricePerHour.toStringAsFixed(0)}/hr',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(color: OrbitColors.coral)),
                      if (provider.isHighRisk)
                        Text('⚠️ High risk score', style: const TextStyle(fontSize: 11, color: OrbitColors.warning)),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: onSelect,
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
                  child: const Text('Select'),
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate(delay: (rank * 150).ms).fadeIn().slideY(begin: 0.2);
  }

  Widget _badges(ProviderModel provider) {
    final badges = <String>[];
    if (provider.matchLabel != null) badges.add(provider.matchLabel!);
    if (provider.isReliable) badges.add('✅ Reliable');
    if (provider.cancellationRate < 0.03) badges.add('🎯 Zero Cancellations');
    if (provider.experienceYears >= 5) badges.add('${provider.experienceYears}yr exp');

    return Wrap(
      spacing: 8, runSpacing: 6,
      children: badges.map((b) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: OrbitColors.coral.withOpacity(0.1),
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: OrbitColors.coral.withOpacity(0.25)),
        ),
        child: Text(b, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: OrbitColors.coral)),
      )).toList(),
    );
  }
}
