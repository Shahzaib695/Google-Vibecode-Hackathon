import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'dart:math';
import '../../core/theme.dart';

class TrackingScreen extends StatefulWidget {
  final String bookingId;
  const TrackingScreen({super.key, required this.bookingId});
  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> with TickerProviderStateMixin {
  late AnimationController _dotController;
  int _eta = 24;
  String _status = 'en_route';

  @override
  void initState() {
    super.initState();
    _dotController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();
    _simulateMovement();
  }

  void _simulateMovement() {
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) setState(() { _eta = 18; });
      Future.delayed(const Duration(seconds: 5), () {
        if (mounted) setState(() { _eta = 12; });
        Future.delayed(const Duration(seconds: 5), () {
          if (mounted) setState(() { _eta = 5; });
          Future.delayed(const Duration(seconds: 5), () {
            if (mounted) setState(() { _status = 'in_progress'; _eta = 0; });
          });
        });
      });
    });
  }

  @override
  void dispose() {
    _dotController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildMapPlaceholder(),
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: _buildBottomPanel(),
          ),
          Positioned(
            top: 0, left: 0, right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: OrbitTheme.softShadow),
                        child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapPlaceholder() {
    return Container(
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFE8F4FD), Color(0xFFD4E9F7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          // Road simulation
          Center(
            child: Container(
              width: double.infinity, height: 4,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          Center(
            child: Container(
              width: 4, height: double.infinity,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          // Provider dot (animated position)
          AnimatedBuilder(
            animation: _dotController,
            builder: (_, __) {
              final progress = _dotController.value;
              return Positioned(
                left: 60 + progress * 200,
                top: 200 + sin(progress * pi) * 50,
                child: Column(
                  children: [
                    Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(
                        gradient: OrbitColors.primaryGradient,
                        shape: BoxShape.circle,
                        boxShadow: OrbitTheme.elevatedShadow,
                      ),
                      child: const Center(child: Text('🚗', style: TextStyle(fontSize: 20))),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(100),
                        boxShadow: OrbitTheme.softShadow,
                      ),
                      child: const Text('Usman', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
              );
            },
          ),
          // Destination pin
          const Positioned(
            right: 80, top: 220,
            child: Text('📍', style: TextStyle(fontSize: 32)),
          ),
          // Grid overlay to simulate map
          CustomPaint(painter: _MapGridPainter(), size: Size.infinite),
        ],
      ),
    );
  }

  Widget _buildBottomPanel() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 36),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(28), topRight: Radius.circular(28)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 30, offset: const Offset(0, -8))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 40, height: 4, decoration: BoxDecoration(color: OrbitColors.surfaceVariant, borderRadius: BorderRadius.circular(100))),
          const SizedBox(height: 20),
          if (_status == 'en_route') ...[
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(gradient: OrbitColors.primaryGradient, borderRadius: BorderRadius.circular(OrbitTheme.radiusMedium)),
                  child: Text('ETA: $_eta min', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18)),
                ).animate(key: ValueKey(_eta)).fadeIn(),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Usman Tariq', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                      const Text('On the way to your location', style: TextStyle(color: OrbitColors.textSecondary, fontSize: 13)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: OrbitColors.mint.withOpacity(0.1), shape: BoxShape.circle),
                  child: const Icon(Icons.phone_rounded, color: OrbitColors.mint),
                ),
              ],
            ),
          ] else ...[
            Row(
              children: [
                const Text('✅', style: TextStyle(fontSize: 36)),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Provider Arrived!', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
                      const Text('Service in progress...', style: TextStyle(color: OrbitColors.textSecondary)),
                    ],
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => context.push('/dispute/${widget.bookingId}'),
              style: OutlinedButton.styleFrom(
                foregroundColor: OrbitColors.error,
                side: const BorderSide(color: OrbitColors.error),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(OrbitTheme.radiusMedium)),
              ),
              child: const Text('Report Issue'),
            ),
          ),
        ],
      ),
    );
  }
}

class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..strokeWidth = 1;
    for (double x = 0; x < size.width; x += 60) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += 60) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}
