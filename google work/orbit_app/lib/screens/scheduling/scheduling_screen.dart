import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../core/theme.dart';
import '../../models/provider_model.dart';
import '../../models/booking_model.dart';
import '../../services/firestore_service.dart';

class SchedulingScreen extends StatefulWidget {
  final Map<String, dynamic> data;
  const SchedulingScreen({super.key, required this.data});
  @override
  State<SchedulingScreen> createState() => _SchedulingScreenState();
}

class _SchedulingScreenState extends State<SchedulingScreen> {
  final _firestore = FirestoreService();
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  String? _selectedSlot;
  bool _booking = false;

  ProviderModel? get _provider => widget.data['provider'] as ProviderModel?;
  PricingBreakdown? get _pricing => widget.data['pricing'] as PricingBreakdown?;
  Map<String, dynamic> get _intent => widget.data['intent'] as Map<String, dynamic>? ?? {};
  String get _paymentMethod => widget.data['paymentMethod'] as String? ?? 'cash';

  final _slots = ['09:00 AM', '10:30 AM', '12:00 PM', '02:00 PM', '04:00 PM', '06:00 PM'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Schedule Booking'), leading: IconButton(onPressed: () => context.pop(), icon: const Icon(Icons.arrow_back_ios_new_rounded))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProviderSummary(),
            const SizedBox(height: 20),
            _buildDateStrip(),
            const SizedBox(height: 20),
            _buildTimeSlots(),
            const SizedBox(height: 20),
            _buildBookingSummary(),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedSlot == null || _booking ? null : _confirmBooking,
                child: _booking
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Confirm Booking'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProviderSummary() {
    if (_provider == null) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: OrbitTheme.cardDecoration(),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: OrbitColors.coral.withOpacity(0.15),
            child: Text(_provider!.name[0], style: const TextStyle(color: OrbitColors.coral, fontWeight: FontWeight.bold, fontSize: 18)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_provider!.name, style: Theme.of(context).textTheme.titleMedium),
                Text('${_provider!.serviceName} • ${_provider!.area}', style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          Text(_provider!.priceDisplay, style: Theme.of(context).textTheme.titleSmall?.copyWith(color: OrbitColors.coral)),
        ],
      ),
    );
  }

  Widget _buildDateStrip() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Select Date', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 7,
            itemBuilder: (_, i) {
              final date = DateTime.now().add(Duration(days: i));
              final isSelected = date.day == _selectedDate.day && date.month == _selectedDate.month;
              return GestureDetector(
                onTap: () => setState(() { _selectedDate = date; _selectedSlot = null; }),
                child: AnimatedContainer(
                  duration: 200.ms,
                  margin: const EdgeInsets.only(right: 10),
                  width: 58,
                  decoration: BoxDecoration(
                    gradient: isSelected ? OrbitColors.primaryGradient : null,
                    color: isSelected ? null : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: OrbitTheme.softShadow,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(['Mon','Tue','Wed','Thu','Fri','Sat','Sun'][date.weekday - 1],
                        style: TextStyle(fontSize: 11, color: isSelected ? Colors.white70 : OrbitColors.textHint, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text('${date.day}',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: isSelected ? Colors.white : OrbitColors.textPrimary)),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSlots() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Available Slots', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, childAspectRatio: 2.5, crossAxisSpacing: 10, mainAxisSpacing: 10,
          ),
          itemCount: _slots.length,
          itemBuilder: (_, i) {
            final slot = _slots[i];
            final isSelected = slot == _selectedSlot;
            return GestureDetector(
              onTap: () => setState(() => _selectedSlot = slot),
              child: AnimatedContainer(
                duration: 200.ms,
                decoration: BoxDecoration(
                  color: isSelected ? OrbitColors.coral : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isSelected ? OrbitColors.coral : OrbitColors.surfaceVariant),
                  boxShadow: OrbitTheme.softShadow,
                ),
                child: Center(
                  child: Text(slot,
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isSelected ? Colors.white : OrbitColors.textPrimary),
                  ),
                ),
              ),
            ).animate(delay: (i * 50).ms).fadeIn();
          },
        ),
      ],
    );
  }

  Widget _buildBookingSummary() {
    if (_selectedSlot == null) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: OrbitTheme.cardDecoration(gradient: LinearGradient(
        colors: [OrbitColors.coral.withOpacity(0.06), OrbitColors.skyBlue.withOpacity(0.04)],
      )),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Booking Summary', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          _row('Provider', _provider?.name ?? '—'),
          _row('Date', '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}'),
          _row('Time', _selectedSlot!),
          _row('Payment', _paymentMethod.toUpperCase()),
          _row('Total', 'Rs. ${_pricing?.total.toStringAsFixed(0) ?? '—'}', bold: true),
        ],
      ),
    ).animate().fadeIn();
  }

  Widget _row(String label, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          Text(value, style: TextStyle(fontWeight: bold ? FontWeight.w800 : FontWeight.w600, color: bold ? OrbitColors.coral : OrbitColors.textPrimary)),
        ],
      ),
    );
  }

  Future<void> _confirmBooking() async {
    if (_provider == null || _selectedSlot == null) return;
    setState(() => _booking = true);
    try {
      final bookingId = await _firestore.createBooking(BookingModel(
        bookingId: '',
        userId: 'demo_user',
        providerId: _provider!.uid,
        serviceType: _provider!.serviceType,
        jobComplexity: _intent['complexity'] as String? ?? 'basic',
        status: 'confirmed',
        requestText: _intent['jobDescription'] as String? ?? '',
        extractedIntent: ExtractedIntent(
          service: _intent['service'] as String? ?? '',
          location: _intent['location'] as String? ?? '',
          urgency: _intent['urgency'] as String? ?? 'standard',
          preferredTime: _intent['preferredTime'] as String? ?? 'asap',
          budgetSensitivity: _intent['budgetSensitivity'] as String? ?? 'medium',
          jobDescription: _intent['jobDescription'] as String? ?? '',
          confidence: (_intent['confidence'] as double? ?? 0),
          language: _intent['language'] as String? ?? 'english',
        ),
        scheduledTime: _selectedDate,
        address: _provider!.area,
        pricingBreakdown: _pricing,
        paymentMethod: _paymentMethod,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));
      if (mounted) context.pushReplacement('/completion/$bookingId');
    } catch (e) {
      setState(() => _booking = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Booking failed: $e')));
    }
  }
}
