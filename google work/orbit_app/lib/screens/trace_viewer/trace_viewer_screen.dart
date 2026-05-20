import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../models/dispute_model.dart';
import '../../services/firestore_service.dart';

class TraceViewerScreen extends StatefulWidget {
  const TraceViewerScreen({super.key});
  @override
  State<TraceViewerScreen> createState() => _TraceViewerScreenState();
}

class _TraceViewerScreenState extends State<TraceViewerScreen> {
  final _firestore = FirestoreService();
  String? _filterStage;
  Set<String> _expanded = {};

  final _stageFilters = [null, 'intent_parsing', 'provider_matching', 'pricing', 'scheduling', 'booking', 'dispute'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1117),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F1117),
        title: const Text('🧠 Antigravity Trace Viewer', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(onPressed: () => context.pop(), icon: const Icon(Icons.arrow_back_ios_new_rounded)),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              gradient: OrbitColors.primaryGradient,
              borderRadius: BorderRadius.circular(100),
            ),
            child: const Text('JUDGE PANEL', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800)),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: StreamBuilder<List<AntigravityLog>>(
              stream: _firestore.streamLogs(stage: _filterStage),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: OrbitColors.coral));
                }
                final logs = snap.data ?? _getMockLogs();
                if (logs.isEmpty) return _buildEmptyState();
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: logs.length,
                  itemBuilder: (_, i) => _buildLogCard(logs[i], i),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    final labels = {
      null: 'All',
      'intent_parsing': 'Intent',
      'provider_matching': 'Matching',
      'pricing': 'Pricing',
      'scheduling': 'Schedule',
      'booking': 'Booking',
      'dispute': 'Dispute',
    };
    return Container(
      color: const Color(0xFF1A1A2E),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _stageFilters.map((f) {
            final selected = _filterStage == f;
            return GestureDetector(
              onTap: () => setState(() => _filterStage = f),
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: selected ? OrbitColors.coral : Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(labels[f] ?? f ?? 'All',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: selected ? Colors.white : Colors.white60)),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildLogCard(AntigravityLog log, int index) {
    final isExpanded = _expanded.contains(log.logId);
    final confidenceColor = log.isHighConfidence ? OrbitColors.mint : log.isMediumConfidence ? OrbitColors.amber : OrbitColors.error;
    final borderColor = log.fallbackTriggered ? OrbitColors.error : log.isHighConfidence ? OrbitColors.mint : OrbitColors.amber;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(OrbitTheme.radiusMedium),
        border: Border.all(color: borderColor.withOpacity(0.4)),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => setState(() {
              if (isExpanded) _expanded.remove(log.logId); else _expanded.add(log.logId);
            }),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 8, height: 8,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: confidenceColor),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(log.stageLabel, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
                        Text('${log.latencyMs}ms • ${log.createdAt.toString().substring(0, 16)}',
                          style: const TextStyle(color: Colors.white38, fontSize: 11)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: confidenceColor.withOpacity(0.15), borderRadius: BorderRadius.circular(100)),
                    child: Text('${log.confidenceScore.toStringAsFixed(0)}%',
                      style: TextStyle(color: confidenceColor, fontWeight: FontWeight.w800, fontSize: 12)),
                  ),
                  const SizedBox(width: 8),
                  Icon(isExpanded ? Icons.expand_less : Icons.expand_more, color: Colors.white38),
                ],
              ),
            ),
          ),
          if (isExpanded) ...[
            const Divider(color: Colors.white10, height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (log.fallbackTriggered) ...[
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: OrbitColors.error.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                      child: Row(
                        children: [
                          const Icon(Icons.warning_rounded, color: OrbitColors.error, size: 16),
                          const SizedBox(width: 8),
                          Expanded(child: Text('FALLBACK: ${log.fallbackReason}', style: const TextStyle(color: OrbitColors.error, fontSize: 12))),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  _codeBlock('📥 Input', log.inputData.toString()),
                  const SizedBox(height: 12),
                  _codeBlock('🧠 Reasoning', log.reasoning),
                  const SizedBox(height: 12),
                  _codeBlock('📤 Output', log.outputData.toString()),
                ],
              ),
            ),
          ],
        ],
      ),
    ).animate(delay: (index * 50).ms).fadeIn();
  }

  Widget _codeBlock(String label, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 11, fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.4),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(content,
            style: const TextStyle(color: Color(0xFF34D399), fontSize: 11, fontFamily: 'monospace', height: 1.5)),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🧠', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          const Text('No logs yet', style: TextStyle(color: Colors.white60, fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          const Text('Make an AI booking request to generate Antigravity traces.',
            style: TextStyle(color: Colors.white38, fontSize: 13), textAlign: TextAlign.center),
          const SizedBox(height: 24),
          ElevatedButton(onPressed: () => context.push('/chat'), child: const Text('Try AI Chat')),
        ],
      ),
    );
  }

  List<AntigravityLog> _getMockLogs() {
    return [
      AntigravityLog(
        logId: 'mock1',
        bookingId: 'booking123',
        stage: 'intent_parsing',
        inputData: {'rawText': 'Mujhe kal AC service chahiye G-13 mein'},
        reasoning: '''ANTIGRAVITY INTENT PARSING — Chain of Thought:
Step 1 — Language: roman_urdu detected
Step 2 — Service: ac_technician (keyword: AC)
Step 3 — Location: G-13 (Islamabad area matched)
Step 4 — Urgency: standard (kal = tomorrow)
Step 5 — Budget: medium (no budget keywords)
Step 6 — Confidence: 88/100 → sufficient to proceed''',
        outputData: {'service': 'ac_technician', 'location': 'G-13', 'confidence': 88},
        confidenceScore: 88,
        latencyMs: 823,
        createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
      AntigravityLog(
        logId: 'mock2',
        stage: 'provider_matching',
        inputData: {'serviceType': 'ac_technician', 'candidates': 6},
        reasoning: '''ANTIGRAVITY PROVIDER MATCHING:
Scored 6 providers using 8-factor weighted algorithm.
DEMOTION: Ali Khan (4.7★) demoted because cancellationRate=0.22 and riskScore=71.
PROMOTED: Usman Tariq (4.5★) selected — onTimeScore=98, zero recent cancellations.
Plain reasoning: Usman is more reliable despite slightly lower rating.''',
        outputData: {'topMatch': 'Usman Tariq', 'score': 87.3},
        confidenceScore: 87,
        latencyMs: 1240,
        createdAt: DateTime.now().subtract(const Duration(minutes: 4)),
      ),
      AntigravityLog(
        logId: 'mock3',
        stage: 'pricing',
        inputData: {'provider': 'Usman Tariq', 'urgency': 'standard'},
        reasoning: 'Base: 2800, Visit: 350, Distance: 127.5, Surge: 1.12x, Total: 3673',
        outputData: {'total': 3673, 'isFairPrice': true},
        confidenceScore: 95,
        fallbackTriggered: false,
        latencyMs: 612,
        createdAt: DateTime.now().subtract(const Duration(minutes: 3)),
      ),
      AntigravityLog(
        logId: 'mock4',
        stage: 'intent_parsing',
        inputData: {'rawText': 'bijli ka masla hai urgent'},
        reasoning: 'FALLBACK: bijli could be electrician OR power outage. Confidence: 55. Generating clarification question.',
        outputData: {'service': 'electrician', 'confidence': 55, 'clarificationQuestion': 'Do you need an electrician or is this a power outage?'},
        confidenceScore: 55,
        fallbackTriggered: true,
        fallbackReason: 'Ambiguous input — bijli could be electrician or power outage',
        latencyMs: 934,
        createdAt: DateTime.now().subtract(const Duration(minutes: 2)),
      ),
    ];
  }
}
