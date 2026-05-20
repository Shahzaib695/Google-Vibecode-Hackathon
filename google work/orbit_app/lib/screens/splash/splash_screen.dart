import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../core/theme.dart';
import '../../core/constants.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  final _pageController = PageController();
  int _currentPage = 0;
  bool _showOnboarding = false;
  late AnimationController _orbController;

  final _onboardingData = [
    {
      'emoji': '🤖',
      'title': 'AI ko batao,\nbaki humara kaam',
      'subtitle': 'Simply describe your need in Urdu, Roman Urdu, or English. Orbit\'s AI understands everything.',
      'color': OrbitColors.coral,
    },
    {
      'emoji': '⭐',
      'title': 'Best providers,\ninstantly matched',
      'subtitle': 'Our 8-factor AI algorithm finds the most reliable, nearest, and best-priced professional for you.',
      'color': OrbitColors.skyBlue,
    },
    {
      'emoji': '🛡️',
      'title': 'Guaranteed service,\nevery time',
      'subtitle': 'Full dispute protection, live tracking, and AI-powered quality assurance on every booking.',
      'color': OrbitColors.mint,
    },
  ];

  @override
  void initState() {
    super.initState();
    _orbController = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _showOnboarding = true);
    });
  }

  @override
  void dispose() {
    _orbController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 600),
        child: _showOnboarding ? _buildOnboarding() : _buildSplash(),
      ),
    );
  }

  Widget _buildSplash() {
    return Container(
      key: const ValueKey('splash'),
      decoration: const BoxDecoration(gradient: OrbitColors.primaryGradient),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _orbController,
              builder: (_, child) {
                return Transform.rotate(
                  angle: _orbController.value * 6.28,
                  child: child,
                );
              },
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.2),
                  border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
                ),
                child: const Center(
                  child: Text('🌐', style: TextStyle(fontSize: 48)),
                ),
              ),
            ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
            const SizedBox(height: 24),
            Text(
              'Orbit',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                letterSpacing: -2,
              ),
            ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.3),
            const SizedBox(height: 8),
            Text(
              AppConstants.appTagline,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.white.withOpacity(0.85),
              ),
            ).animate().fadeIn(delay: 500.ms),
          ],
        ),
      ),
    );
  }

  Widget _buildOnboarding() {
    return Scaffold(
      key: const ValueKey('onboarding'),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: () => context.go('/auth'),
                child: Text('Skip', style: TextStyle(color: OrbitColors.textSecondary)),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemCount: _onboardingData.length,
                itemBuilder: (_, i) => _buildOnboardingPage(_onboardingData[i]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  SmoothPageIndicator(
                    controller: _pageController,
                    count: _onboardingData.length,
                    effect: ExpandingDotsEffect(
                      activeDotColor: OrbitColors.coral,
                      dotColor: OrbitColors.surfaceVariant,
                      dotHeight: 8,
                      dotWidth: 8,
                      expansionFactor: 3,
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_currentPage < _onboardingData.length - 1) {
                          _pageController.nextPage(duration: 400.ms, curve: Curves.easeInOut);
                        } else {
                          context.go('/auth');
                        }
                      },
                      child: Text(_currentPage < _onboardingData.length - 1 ? 'Next' : 'Get Started'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOnboardingPage(Map<String, dynamic> data) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: (data['color'] as Color).withOpacity(0.1),
            ),
            child: Center(child: Text(data['emoji'] as String, style: const TextStyle(fontSize: 72))),
          ).animate().scale(curve: Curves.elasticOut),
          const SizedBox(height: 40),
          Text(
            data['title'] as String,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineLarge,
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
          const SizedBox(height: 16),
          Text(
            data['subtitle'] as String,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: OrbitColors.textSecondary, height: 1.6),
          ).animate().fadeIn(delay: 400.ms),
        ],
      ),
    );
  }
}
