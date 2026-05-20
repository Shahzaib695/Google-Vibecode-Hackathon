import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../models/dispute_model.dart';
import '../../services/antigravity_service.dart';
import '../../services/firestore_service.dart';

class DisputeScreen extends StatefulWidget {
  final String bookingId;
  const DisputeScreen({super.key, required this.bookingId});
  @override
  State<DisputeScreen> createState() => _DisputeScreenState();
}

class _DisputeScreenState extends State<DisputeScreen> {
  final _antigravity = AntigravityService();
  final _firestore = FirestoreService();
  final _descController = TextEditingController();
  String? _selectedIssue;
  bool _loading = false;
  Map<String, dynamic>? _resolution;

  final _issues = {
    'no_show': '🚫 Provider No-Show',
    'overcharged': '💰 Overcharged',
    'incomplete_work': '🔧 Incomplete Work',
    'quality_issue': '⭐ Quality Issue',
    'unprofessional': '😡 Unprofessional',
    'damage': '💥 Property Damage',
    'other': '❓ Other',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dispute Resolution'),
        leading: IconButton(onPressed: () => context.pop(), icon: const Icon(Icons.arrow_back_ios_new_rounded)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: _resolution != null ? _buildResolution() : _buildForm(),
      ),
    );
  }

  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: OrbitColors.error.withOpacity(0.08), borderRadius: BorderRadius.circular(OrbitTheme.radiusMedium)),
          child: const Row(
            children: [
              Text('🛡️', style: TextStyle(fontSize: 24)),
              SizedBox(width: 12),
              Expanded(child: Text('Aapki shikayat ahamm hai. Orbit AI aapki madad karega.',
                style: TextStyle(fontSize: 14, color: OrbitColors.textPrimary, height: 1.4))),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text('Issue Select Karen', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10, runSpacing: 10,
          children: _issues.entries.map((e) {
            final selected = _selectedIssue == e.key;
            return GestureDetector(
              onTap: () => setState(() => _selectedIssue = e.key),
              child: AnimatedContainer(
                duration: 200.ms,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: selected ? OrbitColors.coral : Colors.white,
                  borderRadius: BorderRadius.circular(OrbitTheme.radiusMedium),
                  border: Border.all(color: selected ? OrbitColors.coral : OrbitColors.surfaceVariant),
                  boxShadow: OrbitTheme.softShadow,
                ),
                child: Text(e.value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: selected ? Colors.white : OrbitColors.textPrimary)),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),
        Text('Describe karo (optional)', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        TextField(
          controller: _descController,
          maxLines: 4,
          decoration: const InputDecoration(hintText: 'Kya hua? Details batao...'),
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.attach_file_rounded),
          label: const Text('Evidence Upload (optional)'),
          style: OutlinedButton.styleFrom(
            foregroundColor: OrbitColors.textSecondary,
            side: const BorderSide(color: OrbitColors.surfaceVariant),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(OrbitTheme.radiusMedium)),
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _selectedIssue == null || _loading ? null : _submitDispute,
            icon: const Text('🤖'),
            label: _loading
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('Submit to Orbit AI'),
          ),
        ),
      ],
    );
  }

  Future<void> _submitDispute() async {
    setState(() => _loading = true);
    final dispute = DisputeModel(
      disputeId: '',
      bookingId: widget.bookingId,
      userId: 'demo_user',
      providerId: 'mock_provider',
      issueType: _selectedIssue!,
      description: _descController.text,
      createdAt: DateTime.now(),
    );
    final result = await _antigravity.resolveDispute(dispute);
    await _firestore.createDispute(dispute);
    if (mounted) setState(() { _resolution = result; _loading = false; });
  }

  Widget _buildResolution() {
    final status = _resolution!['status'] as String;
    final isEscalated = status == 'escalated';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: OrbitTheme.cardDecoration(
            gradient: isEscalated ? OrbitColors.purpleGradient : OrbitColors.mintGradient,
          ),
          child: Column(
            children: [
              Text(isEscalated ? '🔺' : '✅', style: const TextStyle(fontSize: 48)),
              const SizedBox(height: 12),
              Text(isEscalated ? 'Escalated to Human Support' : 'AI Resolution Ready',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 20)),
            ],
          ),
        ).animate().scale(curve: Curves.elasticOut),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: OrbitTheme.cardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('🤖 AI Resolution', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              Text(_resolution!['resolution'] as String,
                style: const TextStyle(fontSize: 14, height: 1.6, color: OrbitColors.textPrimary)),
              if ((_resolution!['refundAmount'] as double) > 0) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: OrbitColors.mint.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    children: [
                      const Text('💚', style: TextStyle(fontSize: 20)),
                      const SizedBox(width: 10),
                      Text('Refund: Rs. ${(_resolution!['refundAmount'] as double).toStringAsFixed(0)}',
                        style: const TextStyle(fontWeight: FontWeight.w700, color: OrbitColors.mint, fontSize: 16)),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ).animate().fadeIn(delay: 300.ms),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () => context.go('/home'),
                child: const Text('Accept Resolution'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  foregroundColor: OrbitColors.purple,
                  side: const BorderSide(color: OrbitColors.purple),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(OrbitTheme.radiusMedium)),
                ),
                child: const Text('Escalate'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
