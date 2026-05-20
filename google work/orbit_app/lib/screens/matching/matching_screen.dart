import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:math';
import '../../core/theme.dart';
import '../../core/constants.dart';
import '../../models/provider_model.dart';
import '../../services/antigravity_service.dart';
import '../../services/firestore_service.dart';
import '../../widgets/provider_card.dart';

class MatchingScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> intentData;
  const MatchingScreen({super.key, required this.intentData});
  @override
  ConsumerState<MatchingScreen> createState() => _MatchingScreenState();
}

class _MatchingScreenState extends ConsumerState<MatchingScreen> with TickerProviderStateMixin {
  final _antigravity = AntigravityService();
  final _firestore = FirestoreService();
  List<ProviderModel> _providers = [];
  bool _loading = true;
  String _stage = 'Fetching providers...';
  late AnimationController _pulseController;

  final _stages = [
    'Fetching providers...',
    'Calculating distances...',
    'Analyzing ratings & reliability...',
    'Applying 8-factor scoring...',
    'Selecting best matches...',
  ];
  int _stageIndex = 0;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat(reverse: true);
    _runMatching();
  }

  Future<void> _runMatching() async {
    for (int i = 0; i < _stages.length; i++) {
      await Future.delayed(const Duration(milliseconds: 700));
      if (mounted) setState(() { _stageIndex = i; _stage = _stages[i]; });
    }

    final serviceType = widget.intentData['service'] as String?;
    final complexity = widget.intentData['complexity'] as String? ?? 'basic';
    final candidates = await _firestore.getProviders(serviceType: serviceType);

    final r = Random();
    final userLat = 33.7 + r.nextDouble() * 0.1;
    final userLng = 73.0 + r.nextDouble() * 0.1;

    final matched = await _antigravity.matchProviders(
      candidates: candidates.isNotEmpty ? candidates : _getMockProviders(serviceType ?? 'ac_technician'),
      intent: widget.intentData,
      complexity: complexity,
      userLat: userLat,
      userLng: userLng,
    );

    if (mounted) setState(() { _providers = matched; _loading = false; });
  }

  List<ProviderModel> _getMockProviders(String serviceType) {
    // Fallback mock providers for demo
    final r = Random();
    return List.generate(5, (i) => ProviderModel(
      uid: 'mock_$i',
      name: ['Usman Tariq', 'Rafiq Ahmed', 'Hassan Ali', 'Bilal Khan', 'Imran Sheikh'][i],
      serviceType: serviceType,
      specializations: ['split_ac', 'window_ac'],
      location: GeoPoint(33.7 + r.nextDouble() * 0.05, 73.0 + r.nextDouble() * 0.05),
      city: 'Islamabad',
      area: ['G-13', 'F-10', 'I-8', 'E-11', 'Bahria Town'][i],
      rating: 3.5 + r.nextDouble() * 1.4,
      totalReviews: 20 + r.nextInt(200),
      onTimeScore: 60 + r.nextDouble() * 35,
      cancellationRate: r.nextDouble() * 0.2,
      riskScore: r.nextDouble() * 60,
      isOnline: true,
      isAvailable: true,
      pricePerHour: 800 + r.nextDouble() * 1200,
      experienceYears: 2 + r.nextInt(10),
      certifications: i % 2 == 0 ? ['AC Certified', 'Gas Handling'] : [],
      createdAt: DateTime.now(),
    ));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Provider Matching'),
        leading: IconButton(onPressed: () => context.pop(), icon: const Icon(Icons.arrow_back_ios_new_rounded)),
      ),
      body: _loading ? _buildLoading() : _buildResults(),
    );
  }

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _pulseController,
            builder: (_, __) => Container(
              width: 100 + _pulseController.value * 20,
              height: 100 + _pulseController.value * 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  OrbitColors.coral.withOpacity(0.3 + _pulseController.value * 0.3),
                  OrbitColors.coral.withOpacity(0.05),
                ]),
              ),
              child: Center(
                child: Container(
                  width: 70, height: 70,
                  decoration: const BoxDecoration(gradient: OrbitColors.primaryGradient, shape: BoxShape.circle),
                  child: const Icon(Icons.auto_awesome, color: Colors.white, size: 32),
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          Text('Antigravity AI', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          AnimatedSwitcher(
            duration: 400.ms,
            child: Text(_stage, key: ValueKey(_stageIndex),
              style: Theme.of(context).textTheme.bodyMedium,
            ).animate().fadeIn(),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: 200,
            child: LinearProgressIndicator(
              value: (_stageIndex + 1) / _stages.length,
              backgroundColor: OrbitColors.backgroundAlt,
              valueColor: const AlwaysStoppedAnimation(OrbitColors.coral),
              borderRadius: BorderRadius.circular(100),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResults() {
    return Column(
      children: [
        _buildWorkflowTimeline(),
        Expanded(
          child: _providers.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _providers.length,
                  itemBuilder: (_, i) => ProviderCard(
                    provider: _providers[i],
                    rank: i + 1,
                    onSelect: () => context.push('/pricing', extra: {
                      'provider': _providers[i],
                      'intent': widget.intentData,
                    }),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildWorkflowTimeline() {
    final stages = ['Input', 'Parse', 'Match', 'Price', 'Book'];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.white,
      child: Row(
        children: stages.asMap().entries.map((e) {
          final active = e.key <= 2;
          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        width: 28, height: 28,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: active ? OrbitColors.coral : OrbitColors.surfaceVariant,
                        ),
                        child: Icon(active ? Icons.check : Icons.circle_outlined, color: active ? Colors.white : OrbitColors.textHint, size: 14),
                      ),
                      const SizedBox(height: 4),
                      Text(e.value, style: TextStyle(fontSize: 9, color: active ? OrbitColors.coral : OrbitColors.textHint, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                if (e.key < stages.length - 1)
                  Expanded(child: Container(height: 2, color: e.key < 2 ? OrbitColors.coral : OrbitColors.surfaceVariant)),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('😔', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          Text('No providers available', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text('Koi provider available nahi hai is waqt.\nWaitlist mein add ho jao!',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          ElevatedButton(onPressed: () {}, child: const Text('Join Waitlist')),
          const SizedBox(height: 12),
          TextButton(onPressed: () => context.pop(), child: const Text('Try different time')),
        ],
      ),
    );
  }
}
