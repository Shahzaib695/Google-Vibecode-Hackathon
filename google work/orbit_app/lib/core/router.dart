import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/auth/auth_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/auth/otp_verification_screen.dart';
import '../screens/auth/reset_password_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/chat/chat_screen.dart';
import '../screens/matching/matching_screen.dart';
import '../screens/pricing/pricing_screen.dart';
import '../screens/scheduling/scheduling_screen.dart';
import '../screens/tracking/tracking_screen.dart';
import '../screens/completion/completion_screen.dart';
import '../screens/dispute/dispute_screen.dart';
import '../screens/provider_dashboard/provider_dashboard_screen.dart';
import '../screens/trace_viewer/trace_viewer_screen.dart';
import '../screens/analytics/analytics_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/auth', builder: (_, __) => const AuthScreen()),
      GoRoute(path: '/forgot-password', builder: (_, __) => const ForgotPasswordScreen()),
      GoRoute(path: '/otp-verification', builder: (_, state) {
        return OtpVerificationScreen(email: state.extra as String);
      }),
      GoRoute(path: '/reset-password', builder: (_, state) {
        return ResetPasswordScreen(email: state.extra as String);
      }),
      GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
      GoRoute(path: '/chat', builder: (_, state) {
        final scenario = state.uri.queryParameters['scenario'];
        return ChatScreen(demoScenario: scenario);
      }),
      GoRoute(path: '/matching', builder: (_, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return MatchingScreen(intentData: extra ?? {});
      }),
      GoRoute(path: '/pricing', builder: (_, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return PricingScreen(data: extra ?? {});
      }),
      GoRoute(path: '/scheduling', builder: (_, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return SchedulingScreen(data: extra ?? {});
      }),
      GoRoute(path: '/tracking/:bookingId', builder: (_, state) {
        return TrackingScreen(bookingId: state.pathParameters['bookingId']!);
      }),
      GoRoute(path: '/completion/:bookingId', builder: (_, state) {
        return CompletionScreen(bookingId: state.pathParameters['bookingId']!);
      }),
      GoRoute(path: '/dispute/:bookingId', builder: (_, state) {
        return DisputeScreen(bookingId: state.pathParameters['bookingId']!);
      }),
      GoRoute(path: '/provider-dashboard', builder: (_, __) => const ProviderDashboardScreen()),
      GoRoute(path: '/trace-viewer', builder: (_, __) => const TraceViewerScreen()),
      GoRoute(path: '/analytics', builder: (_, __) => const AnalyticsScreen()),
    ],
  );
});
