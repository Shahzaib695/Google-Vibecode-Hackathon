import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../core/constants.dart';
import '../../widgets/bottom_nav.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _logoTaps = 0;
  final _services = [
    {'type': 'ac_technician', 'label': 'AC Service', 'emoji': '❄️', 'color': const Color(0xFF4A9AF5)},
    {'type': 'plumber', 'label': 'Plumber', 'emoji': '🔧', 'color': const Color(0xFFFF6B6B)},
    {'type': 'electrician', 'label': 'Electrician', 'emoji': '⚡', 'color': const Color(0xFFFFB347)},
    {'type': 'beautician', 'label': 'Beautician', 'emoji': '💅', 'color': const Color(0xFFA78BFA)},
    {'type': 'tutor', 'label': 'Home Tutor', 'emoji': '📚', 'color': const Color(0xFF34D399)},
    {'type': 'mechanic', 'label': 'Mechanic', 'emoji': '🔩', 'color': const Color(0xFFFB7185)},
    {'type': 'home_service', 'label': 'Home Care', 'emoji': '🏠', 'color': const Color(0xFF6C63FF)},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OrbitColors.backgroundAlt,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader()),
            SliverToBoxAdapter(child: _buildAISearchBar()),
            SliverToBoxAdapter(child: _buildQuickScenarios()),
            SliverToBoxAdapter(child: _buildServicesGrid()),
            SliverToBoxAdapter(child: _buildTrendingProviders()),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
      bottomNavigationBar: const OrbitBottomNav(currentIndex: 0),
      floatingActionButton: _buildBookFAB(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      decoration: const BoxDecoration(color: Colors.white),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Good evening! 👋', style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: () {
                    _logoTaps++;
                    if (_logoTaps >= AppConstants.logoTapCountForTrace) {
                      _logoTaps = 0;
                      context.push('/trace-viewer');
                    }
                  },
                  child: Text('Orbit 🌐',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: OrbitColors.coral, fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => context.push('/analytics'),
            child: Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: OrbitColors.backgroundAlt,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.insights_rounded, color: OrbitColors.coral),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              gradient: OrbitColors.primaryGradient,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.person_rounded, color: Colors.white, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildAISearchBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
      child: GestureDetector(
        onTap: () => context.push('/chat'),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [OrbitColors.coral.withOpacity(0.08), OrbitColors.skyBlue.withOpacity(0.06)],
            ),
            borderRadius: BorderRadius.circular(OrbitTheme.radiusLarge),
            border: Border.all(color: OrbitColors.coral.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Container(
                width: 40, height: 40,
                decoration: const BoxDecoration(gradient: OrbitColors.primaryGradient, shape: BoxShape.circle),
                child: const Icon(Icons.auto_awesome, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Ask Orbit AI anything...', style: Theme.of(context).textTheme.titleSmall?.copyWith(color: OrbitColors.textSecondary)),
                    Text('"Mujhe kal AC service chahiye G-13 mein"',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: OrbitColors.textHint, fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.mic_rounded, color: OrbitColors.coral),
            ],
          ),
        ),
      ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
    );
  }

  Widget _buildQuickScenarios() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 0, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 24, bottom: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Demo Scenarios', style: Theme.of(context).textTheme.titleMedium),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: OrbitColors.coral.withOpacity(0.1), borderRadius: BorderRadius.circular(100)),
                  child: Text('LIVE DEMO', style: TextStyle(color: OrbitColors.coral, fontSize: 10, fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: DemoScenarios.scenarioLabels.entries.map((e) {
                return GestureDetector(
                  onTap: () => context.push('/chat?scenario=${e.key}'),
                  child: Container(
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(color: OrbitColors.surfaceVariant),
                      boxShadow: OrbitTheme.softShadow,
                    ),
                    child: Text(e.value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServicesGrid() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Services', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 0.85,
            ),
            itemCount: _services.length,
            itemBuilder: (_, i) {
              final s = _services[i];
              return GestureDetector(
                onTap: () => context.push('/chat'),
                child: Column(
                  children: [
                    Container(
                      width: 60, height: 60,
                      decoration: BoxDecoration(
                        color: (s['color'] as Color).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Center(child: Text(s['emoji'] as String, style: const TextStyle(fontSize: 28))),
                    ).animate(delay: (i * 50).ms).scale(curve: Curves.elasticOut),
                    const SizedBox(height: 8),
                    Text(s['label'] as String,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: OrbitColors.textPrimary),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTrendingProviders() {
    final providers = [
      {'name': 'Usman Tariq', 'service': 'AC Technician', 'rating': '4.9', 'area': 'G-13', 'badge': '🏆 Top Rated'},
      {'name': 'Rafiq Ahmed', 'service': 'Electrician', 'rating': '4.8', 'area': 'DHA', 'badge': '⚡ Fast'},
      {'name': 'Hassan Ali', 'service': 'Plumber', 'rating': '4.7', 'area': 'Gulshan', 'badge': '✅ Reliable'},
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 0, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 24, bottom: 16),
            child: Text('Trending Providers', style: Theme.of(context).textTheme.titleMedium),
          ),
          SizedBox(
            height: 160,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: providers.length,
              itemBuilder: (_, i) {
                final p = providers[i];
                return Container(
                  width: 180,
                  margin: const EdgeInsets.only(right: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: OrbitTheme.cardDecoration(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 22,
                            backgroundColor: OrbitColors.coral.withOpacity(0.15),
                            child: Text(p['name']![0], style: const TextStyle(color: OrbitColors.coral, fontWeight: FontWeight.bold)),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: OrbitColors.mint.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Text('⭐ ${p['rating']}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: OrbitColors.mint)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(p['name']!, style: Theme.of(context).textTheme.titleSmall),
                      Text(p['service']!, style: Theme.of(context).textTheme.bodySmall),
                      const Spacer(),
                      Text(p['badge']!, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: OrbitColors.coral)),
                    ],
                  ),
                ).animate(delay: (i * 100).ms).fadeIn().slideX(begin: 0.2);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookFAB() {
    return GestureDetector(
      onTap: () => context.push('/chat'),
      child: Container(
        width: 64, height: 64,
        decoration: const BoxDecoration(gradient: OrbitColors.primaryGradient, shape: BoxShape.circle),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 32),
      ),
    );
  }
}
