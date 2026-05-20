import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../services/auth_service.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _auth = AuthService();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLogin = true;
  bool _loading = false;
  String _error = '';
  bool _isProvider = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submitAuth() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || !email.contains('@') || password.length < 6) {
      setState(() => _error = 'Please enter a valid email and a password (min 6 chars).');
      return;
    }

    setState(() { _loading = true; _error = ''; });

    try {
      if (_isLogin) {
        await _auth.signInWithEmailPassword(email, password);
      } else {
        await _auth.signUpWithEmailPassword(email, password);
      }
      if (mounted) context.go(_isProvider ? '/provider-dashboard' : '/home');
    } catch (e) {
      String msg = e.toString();
        msg = msg.replaceAll('Exception: ', '');
        msg = msg.replaceAll('DioException [bad response]: ', '');
        if (msg.length > 120) msg = msg.substring(0, 120);
        setState(() { _error = msg; });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _demoLogin() async {
    setState(() => _loading = true);
    await _auth.demoLogin();
    if (mounted) context.go(_isProvider ? '/provider-dashboard' : '/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(gradient: OrbitColors.primaryGradient),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Text('Orbit 🌐',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.w800),
                  ).animate().fadeIn().slideX(begin: -0.2),
                  Text('Your city, intelligently served.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white.withOpacity(0.85)),
                  ).animate().fadeIn(delay: 200.ms),
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            _roleButton('User', false),
                            const SizedBox(width: 12),
                            _roleButton('Provider', true),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Text(_isLogin ? 'Sign In' : 'Create Account',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text('Use your email and password to continue',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 20),
                        
                        TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            hintText: 'Email address',
                            prefixIcon: Icon(Icons.email_outlined, color: OrbitColors.textSecondary),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            hintText: 'Password',
                            prefixIcon: Icon(Icons.lock_outline, color: OrbitColors.textSecondary),
                          ),
                        ),
                        
                        if (_error.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(_error, style: TextStyle(color: OrbitColors.error, fontSize: 13)),
                          ),
                        const SizedBox(height: 20),
                        
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _loading ? null : _submitAuth,
                            child: _loading
                                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : Text(_isLogin ? 'Sign In' : 'Sign Up'),
                          ),
                        ),
                        
                        if (_isLogin) ...[
                          const SizedBox(height: 8),
                          Center(
                            child: TextButton(
                              onPressed: () => context.push('/forgot-password'),
                              child: const Text('Forgot Password? (Email OTP)', style: TextStyle(color: OrbitColors.coral)),
                            ),
                          ),
                        ],
                        
                        const SizedBox(height: 16),
                        Center(
                          child: TextButton(
                            onPressed: () {
                              setState(() {
                                _isLogin = !_isLogin;
                                _error = '';
                              });
                            },
                            child: Text(
                              _isLogin ? 'Don\'t have an account? Sign Up' : 'Already have an account? Sign In',
                              style: const TextStyle(color: OrbitColors.textSecondary),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: _loading ? null : _demoLogin,
                            icon: const Text('🚀'),
                            label: const Text('Demo Mode — Skip Login'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: OrbitColors.coral,
                              side: const BorderSide(color: OrbitColors.coral),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(OrbitTheme.radiusMedium)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1, curve: Curves.easeOutCubic),
                ],
              ),
            ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _roleButton(String label, bool isProvider) {
    final selected = _isProvider == isProvider;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _isProvider = isProvider),
        child: AnimatedContainer(
          duration: 200.ms,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? OrbitColors.coral : OrbitColors.backgroundAlt,
            borderRadius: BorderRadius.circular(OrbitTheme.radiusMedium),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: selected ? Colors.white : OrbitColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
