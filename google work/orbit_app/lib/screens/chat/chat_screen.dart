import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import '../../core/theme.dart';
import '../../core/constants.dart';
import '../../services/antigravity_service.dart';
import '../../widgets/ai_understanding_panel.dart';

enum ChatRole { user, ai }

class ChatMessage {
  final String text;
  final ChatRole role;
  final DateTime time;
  final bool isLoading;
  ChatMessage({required this.text, required this.role, required this.time, this.isLoading = false});
}

class ChatScreen extends StatefulWidget {
  final String? demoScenario;
  const ChatScreen({super.key, this.demoScenario});
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final _antigravity = AntigravityService();
  final List<ChatMessage> _messages = [];
  bool _isThinking = false;
  bool _panelVisible = false;
  Map<String, dynamic>? _intentData;
  String _selectedLanguage = 'EN';
  late AnimationController _orbController;

  @override
  void initState() {
    super.initState();
    _orbController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();
    _addAIGreeting();
    if (widget.demoScenario != null) {
      Future.delayed(const Duration(milliseconds: 800), () => _runDemoScenario(widget.demoScenario!));
    }
  }

  void _addAIGreeting() {
    _messages.add(ChatMessage(
      text: 'Assalam-o-Alaikum! 👋 Main Orbit AI hoon.\n\nMujhe batayein — kya service chahiye? Urdu, Roman Urdu, ya English mein likhein.\n\n*"Mujhe kal subah AC service chahiye G-13 mein"*',
      role: ChatRole.ai,
      time: DateTime.now(),
    ));
  }

  void _runDemoScenario(String scenario) {
    final input = DemoScenarios.scenarioInputs[scenario] ?? '';
    if (input.isNotEmpty) {
      _controller.text = input;
      _sendMessage();
    }
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    setState(() {
      _messages.add(ChatMessage(text: text, role: ChatRole.user, time: DateTime.now()));
      _messages.add(ChatMessage(text: '', role: ChatRole.ai, time: DateTime.now(), isLoading: true));
      _isThinking = true;
    });
    _scrollToBottom();

    try {
      final intent = await _antigravity.parseIntent(text);
      final complexity = await _antigravity.classifyJobComplexity(intent);
      intent['complexity'] = complexity;

      setState(() {
        _messages.removeLast();
        _isThinking = false;
        _intentData = intent;
        _panelVisible = true;
      });

      final confidence = (intent['confidence'] as double);
      String aiReply;
      if (confidence < 70) {
        aiReply = '🤔 ${intent['clarificationQuestion'] ?? 'Could you clarify your request?'}';
      } else {
        final service = intent['service'] as String;
        final location = intent['location'] as String;
        final urgency = intent['urgency'] as String;
        final serviceName = AppConstants.serviceNames[service] ?? service;
        aiReply = '✅ Samajh gaya!\n\n**${serviceName}** ki request — **$location** ke liye${urgency == 'emergency' ? ' (Emergency! 🚨)' : ''}.\n\nMain aapke liye best providers dhundh raha hoon... ⚡';
        
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            context.push('/matching', extra: intent);
          }
        });
      }

      setState(() {
        _messages.add(ChatMessage(text: aiReply, role: ChatRole.ai, time: DateTime.now()));
      });
    } catch (e) {
      setState(() {
        _messages.removeLast();
        _isThinking = false;
        _messages.add(ChatMessage(text: 'Maafi chahta hoon, koi masla hua. Dobara try karein.', role: ChatRole.ai, time: DateTime.now()));
      });
    }
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(100.ms, () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: 300.ms, curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _orbController.dispose();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OrbitColors.backgroundAlt,
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          Column(
            children: [
              if (_isThinking) _buildThinkingBanner(),
              Expanded(child: _buildMessageList()),
              if (_panelVisible && _intentData != null)
                AIUnderstandingPanel(intent: _intentData!, onClose: () => setState(() => _panelVisible = false)),
              _buildInputBar(),
            ],
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      leading: IconButton(onPressed: () => context.pop(), icon: const Icon(Icons.arrow_back_ios_new_rounded)),
      title: Row(
        children: [
          AnimatedBuilder(
            animation: _orbController,
            builder: (_, child) => Transform.rotate(angle: _orbController.value * 6.28, child: child),
            child: Container(
              width: 32, height: 32,
              decoration: const BoxDecoration(gradient: OrbitColors.primaryGradient, shape: BoxShape.circle),
              child: const Icon(Icons.auto_awesome, color: Colors.white, size: 14),
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Orbit AI', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              Text(_isThinking ? 'Soch raha hoon...' : 'Online',
                style: TextStyle(fontSize: 11, color: _isThinking ? OrbitColors.amber : OrbitColors.mint),
              ),
            ],
          ),
        ],
      ),
      actions: [
        GestureDetector(
          onTap: () => setState(() => _selectedLanguage = _selectedLanguage == 'EN' ? 'اردو' : 'EN'),
          child: Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: OrbitColors.backgroundAlt,
              borderRadius: BorderRadius.circular(100),
              border: Border.all(color: OrbitColors.surfaceVariant),
            ),
            child: Text(_selectedLanguage, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          ),
        ),
      ],
    );
  }

  Widget _buildThinkingBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      color: OrbitColors.coral.withOpacity(0.08),
      child: Row(
        children: [
          AnimatedBuilder(
            animation: _orbController,
            builder: (_, __) => Container(
              width: 8, height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: OrbitColors.coral.withOpacity(0.4 + _orbController.value * 0.6),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text('Antigravity AI analyzing your request...', style: TextStyle(color: OrbitColors.coral, fontSize: 13, fontWeight: FontWeight.w500)),
        ],
      ),
    ).animate().fadeIn();
  }

  Widget _buildMessageList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _messages.length,
      itemBuilder: (_, i) => _buildMessage(_messages[i], i),
    );
  }

  Widget _buildMessage(ChatMessage msg, int index) {
    final isUser = msg.role == ChatRole.user;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          gradient: isUser ? OrbitColors.primaryGradient : null,
          color: isUser ? null : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isUser ? 20 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 20),
          ),
          boxShadow: OrbitTheme.softShadow,
        ),
        child: msg.isLoading
            ? _buildTypingIndicator()
            : Text(
                msg.text,
                style: TextStyle(
                  color: isUser ? Colors.white : OrbitColors.textPrimary,
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
      ),
    ).animate(delay: (index * 30).ms).fadeIn().slideY(begin: 0.2);
  }

  Widget _buildTypingIndicator() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) =>
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: 8, height: 8,
          decoration: BoxDecoration(shape: BoxShape.circle, color: OrbitColors.coral.withOpacity(0.7)),
        ).animate(onPlay: (c) => c.repeat())
          .fadeIn(delay: (i * 200).ms)
          .then()
          .fadeOut(duration: 400.ms),
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 20, offset: const Offset(0, -4))],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              onSubmitted: (_) => _sendMessage(),
              maxLines: null,
              decoration: InputDecoration(
                hintText: 'Service request likhein...',
                hintStyle: const TextStyle(color: OrbitColors.textHint),
                fillColor: OrbitColors.backgroundAlt,
                suffixIcon: IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.mic_rounded, color: OrbitColors.textHint),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              width: 50, height: 50,
              decoration: const BoxDecoration(gradient: OrbitColors.primaryGradient, shape: BoxShape.circle),
              child: const Icon(Icons.send_rounded, color: Colors.white, size: 22),
            ),
          ),
        ],
      ),
    );
  }
}
