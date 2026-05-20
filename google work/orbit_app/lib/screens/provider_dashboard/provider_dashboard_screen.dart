import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../services/firestore_service.dart';

class ProviderDashboardScreen extends StatefulWidget {
  const ProviderDashboardScreen({super.key});
  @override
  State<ProviderDashboardScreen> createState() => _ProviderDashboardScreenState();
}

class _ProviderDashboardScreenState extends State<ProviderDashboardScreen> {
  bool _isOnline = false;
  final _mockJobs = [
    {'service': 'AC Service', 'user': 'Ahmed K.', 'area': 'G-13', 'time': '09:00 AM', 'status': 'confirmed', 'amount': 2450},
    {'service': 'AC Repair', 'user': 'Sara M.', 'area': 'F-10', 'time': '02:00 PM', 'status': 'pending', 'amount': 3200},
    {'service': 'Gas Refill', 'user': 'Rizwan A.', 'area': 'I-8', 'time': 'Tomorrow 10AM', 'status': 'confirmed', 'amount': 1800},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OrbitColors.backgroundAlt,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader()),
            SliverToBoxAdapter(child: _buildEarningsCard()),
            SliverToBoxAdapter(child: _buildPerformance()),
            SliverToBoxAdapter(child: _buildJobsList()),
            SliverToBoxAdapter(child: _buildQuickActions()),
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(gradient: OrbitColors.primaryGradient),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: Colors.white.withOpacity(0.2),
                child: const Text('U', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Usman Tariq', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18)),
                    const Text('AC Technician • G-13', style: TextStyle(color: Colors.white70, fontSize: 13)),
                    Row(children: const [
                      Icon(Icons.star_rounded, color: Colors.amber, size: 14),
                      Text(' 4.9 • 98% on-time', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    ]),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => setState(() => _isOnline = !_isOnline),
                child: AnimatedContainer(
                  duration: 300.ms,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: _isOnline ? Colors.white : Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(_isOnline ? '🟢 Online' : '⚫ Offline',
                    style: TextStyle(color: _isOnline ? OrbitColors.coral : Colors.white70, fontWeight: FontWeight.w700, fontSize: 12)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEarningsCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: OrbitTheme.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Earnings', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
          Row(
            children: [
              _earningChip('Today', 'Rs. 4,250', OrbitColors.coral),
              const SizedBox(width: 12),
              _earningChip('This Week', 'Rs. 18,500', OrbitColors.skyBlue),
              const SizedBox(width: 12),
              _earningChip('This Month', 'Rs. 72,000', OrbitColors.mint),
            ],
          ),
          const SizedBox(height: 16),
          // Mock earnings bar chart
          Container(
            height: 60,
            decoration: BoxDecoration(
              color: OrbitColors.backgroundAlt,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [0.4, 0.7, 0.5, 0.9, 0.6, 0.8, 1.0].asMap().entries.map((e) {
                return Container(
                  width: 28,
                  height: 50 * e.value,
                  margin: const EdgeInsets.only(bottom: 4),
                  decoration: BoxDecoration(
                    gradient: OrbitColors.primaryGradient,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ).animate(delay: (e.key * 80).ms).slideY(begin: 1, curve: Curves.easeOut);
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'].map((d) =>
              SizedBox(width: 32, child: Text(d, style: TextStyle(fontSize: 10, color: OrbitColors.textHint), textAlign: TextAlign.center)),
            ).toList(),
          ),
        ],
      ),
    );
  }

  Widget _earningChip(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: OrbitColors.textPrimary)),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformance() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(20),
      decoration: OrbitTheme.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('AI Performance Insights', style: Theme.of(context).textTheme.titleMedium),
              const Spacer(),
              const Text('🤖', style: TextStyle(fontSize: 16)),
            ],
          ),
          const SizedBox(height: 16),
          _perfRow('On-Time Score', 0.98, '98%', OrbitColors.mint),
          const SizedBox(height: 10),
          _perfRow('Cancellation Rate', 0.02, '2%', OrbitColors.error, inverse: true),
          const SizedBox(height: 10),
          _perfRow('AI Match Score', 0.92, '92%', OrbitColors.coral),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: OrbitColors.mint.withOpacity(0.08), borderRadius: BorderRadius.circular(12)),
            child: const Text('🏆 Aap top 5% providers mein hain! Keep it up.',
              style: TextStyle(fontSize: 13, color: OrbitColors.mint, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _perfRow(String label, double value, String text, Color color, {bool inverse = false}) {
    final displayValue = inverse ? 1 - value : value;
    return Row(
      children: [
        SizedBox(width: 140, child: Text(label, style: const TextStyle(fontSize: 13))),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: LinearProgressIndicator(
              value: displayValue,
              minHeight: 8,
              backgroundColor: OrbitColors.backgroundAlt,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(text, style: TextStyle(fontWeight: FontWeight.w700, color: color, fontSize: 13)),
      ],
    );
  }

  Widget _buildJobsList() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Today\'s Jobs', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          ..._mockJobs.asMap().entries.map((e) {
            final job = e.value;
            final isConfirmed = job['status'] == 'confirmed';
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: OrbitTheme.cardDecoration(),
              child: Row(
                children: [
                  Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(color: OrbitColors.coral.withOpacity(0.1), borderRadius: BorderRadius.circular(14)),
                    child: const Center(child: Text('❄️', style: TextStyle(fontSize: 22))),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(job['service'] as String, style: Theme.of(context).textTheme.titleSmall),
                        Text('${job['user']} • ${job['area']} • ${job['time']}', style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isConfirmed ? OrbitColors.mint.withOpacity(0.1) : OrbitColors.amber.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(isConfirmed ? 'Confirmed' : 'Pending',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: isConfirmed ? OrbitColors.mint : OrbitColors.amber)),
                      ),
                      const SizedBox(height: 4),
                      Text('Rs. ${job['amount']}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: OrbitColors.coral)),
                    ],
                  ),
                ],
              ),
            ).animate(delay: (e.key * 80).ms).fadeIn().slideX(begin: 0.1);
          }),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => context.push('/trace-viewer'),
              icon: const Text('🧠'),
              label: const Text('View AI Traces'),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1A1A2E), padding: const EdgeInsets.symmetric(vertical: 14)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => context.push('/analytics'),
              icon: const Icon(Icons.analytics_rounded),
              label: const Text('Analytics'),
              style: OutlinedButton.styleFrom(
                foregroundColor: OrbitColors.coral,
                side: const BorderSide(color: OrbitColors.coral),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(OrbitTheme.radiusMedium)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
