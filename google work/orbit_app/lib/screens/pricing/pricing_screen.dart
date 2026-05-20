import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../../core/theme.dart';
import '../../models/provider_model.dart';
import '../../models/booking_model.dart';
import '../../services/antigravity_service.dart';

class PricingScreen extends StatefulWidget {
  final Map<String, dynamic> data;
  const PricingScreen({super.key, required this.data});
  @override
  State<PricingScreen> createState() => _PricingScreenState();
}

class _PricingScreenState extends State<PricingScreen> {
  final _antigravity = AntigravityService();
  PricingBreakdown? _pricing;
  bool _loading = true;
  String _paymentMethod = 'cash';

  ProviderModel? get _provider => widget.data['provider'] as ProviderModel?;
  Map<String, dynamic> get _intent => widget.data['intent'] as Map<String, dynamic>? ?? {};

  @override
  void initState() {
    super.initState();
    _calculatePricing();
  }

  Future<void> _calculatePricing() async {
    if (_provider == null) { setState(() => _loading = false); return; }
    final pricing = await _antigravity.calculatePricing(
      provider: _provider!,
      intent: _intent,
      distanceKm: 8.5,
      userLoyaltyPoints: 50,
      complexity: _intent['complexity'] as String? ?? 'basic',
    );
    if (mounted) setState(() { _pricing = pricing; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pricing Breakdown'), leading: IconButton(onPressed: () => context.pop(), icon: const Icon(Icons.arrow_back_ios_new_rounded))),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: OrbitColors.coral))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildFairPriceCard(),
                  const SizedBox(height: 20),
                  _buildBreakdownCard(),
                  const SizedBox(height: 20),
                  _buildPaymentSelector(),
                  if (_pricing?.budgetAlternative != null) ...[
                    const SizedBox(height: 16),
                    _buildBudgetAlternative(),
                  ],
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => context.push('/scheduling', extra: {
                        'provider': _provider,
                        'intent': _intent,
                        'pricing': _pricing,
                        'paymentMethod': _paymentMethod,
                      }),
                      child: Text('Proceed — Rs. ${_pricing?.total.toStringAsFixed(0) ?? '0'}'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildFairPriceCard() {
    final isFair = _pricing?.isFairPrice ?? true;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: OrbitTheme.cardDecoration(gradient: isFair ? OrbitColors.mintGradient : null),
      child: Row(
        children: [
          Text(isFair ? '✅' : '⚠️', style: const TextStyle(fontSize: 36)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(isFair ? 'Fair Price' : 'Above Average',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18)),
                Text(isFair ? 'This price is within area average range' : 'Consider a later slot for lower surge pricing',
                  style: const TextStyle(color: Colors.white70, fontSize: 13)),
              ],
            ),
          ),
          Text('Rs.\n${_pricing?.total.toStringAsFixed(0) ?? '—'}',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 22),
            textAlign: TextAlign.right,
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: -0.1);
  }

  Widget _buildBreakdownCard() {
    final items = [
      {'label': 'Base Rate', 'value': _pricing?.baseRate ?? 0, 'icon': '🔧'},
      {'label': 'Visit Fee', 'value': _pricing?.visitFee ?? 0, 'icon': '🚗'},
      {'label': 'Distance Cost', 'value': _pricing?.distanceCost ?? 0, 'icon': '📍'},
      {'label': 'Urgency Adjustment', 'value': _pricing?.urgencyAdjustment ?? 0, 'icon': '⚡'},
      {'label': 'Surge Multiplier (×${_pricing?.surgeMultiplier.toStringAsFixed(2)})', 'value': 0, 'icon': '📈'},
      {'label': 'Loyalty Discount', 'value': -(_pricing?.loyaltyDiscount ?? 0), 'icon': '🎁'},
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: OrbitTheme.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Price Breakdown', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
          ...items.asMap().entries.map((e) {
            final item = e.value;
            final val = item['value'] as double;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Text(item['icon'] as String, style: const TextStyle(fontSize: 16)),
                  const SizedBox(width: 12),
                  Expanded(child: Text(item['label'] as String, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: OrbitColors.textPrimary))),
                  Text(
                    val == 0 ? '—' : 'Rs. ${val.abs().toStringAsFixed(0)}',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: val < 0 ? OrbitColors.mint : OrbitColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ).animate(delay: (e.key * 80).ms).fadeIn().slideX(begin: 0.1);
          }),
          const Divider(height: 24),
          Row(
            children: [
              Text('Total', style: Theme.of(context).textTheme.titleLarge),
              const Spacer(),
              Text('Rs. ${_pricing?.total.toStringAsFixed(0) ?? '0'}',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(color: OrbitColors.coral, fontWeight: FontWeight.w800)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSelector() {
    final methods = {'cash': '💵 Cash', 'jazzcash': '📱 JazzCash', 'easypaisa': '💳 EasyPaisa'};
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: OrbitTheme.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Payment Method', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          ...methods.entries.map((e) => RadioListTile<String>(
            value: e.key,
            groupValue: _paymentMethod,
            onChanged: (v) => setState(() => _paymentMethod = v!),
            title: Text(e.value),
            activeColor: OrbitColors.coral,
            contentPadding: EdgeInsets.zero,
          )),
        ],
      ),
    );
  }

  Widget _buildBudgetAlternative() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: OrbitColors.skyBlue.withOpacity(0.08),
        borderRadius: BorderRadius.circular(OrbitTheme.radiusMedium),
        border: Border.all(color: OrbitColors.skyBlue.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Text('💡', style: TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(_pricing!.budgetAlternative!,
              style: const TextStyle(fontSize: 13, color: OrbitColors.textPrimary, height: 1.4)),
          ),
        ],
      ),
    );
  }
}
