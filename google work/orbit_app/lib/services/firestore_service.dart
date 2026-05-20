import 'dart:async';
import '../models/booking_model.dart';
import '../models/provider_model.dart';
import '../models/dispute_model.dart';
import 'api_service.dart';

class FirestoreService {
  final ApiService _api = ApiService();

  // ── PROVIDERS ──
  Stream<List<ProviderModel>> streamProviders({String? serviceType, String? city}) async* {
    while (true) {
      try {
        final providers = await getProviders(serviceType: serviceType);
        if (city != null) {
          yield providers.where((p) => p.city.toLowerCase() == city.toLowerCase()).toList();
        } else {
          yield providers;
        }
      } catch (_) {
        // Emit empty list or handle error gracefully
        yield [];
      }
      await Future.delayed(const Duration(seconds: 4));
    }
  }

  Future<List<ProviderModel>> getProviders({String? serviceType}) async {
    try {
      final response = await _api.get('/providers', queryParameters: {
        if (serviceType != null) 'serviceType': serviceType,
        'onlyOnline': 'true',
      });
      if (response.statusCode == 200) {
        final List<dynamic> list = response.data;
        return list.map((json) => ProviderModel.fromJson(json)).toList();
      }
    } catch (_) {}
    return [];
  }

  Future<ProviderModel?> getProvider(String uid) async {
    try {
      final response = await _api.get('/providers/$uid');
      if (response.statusCode == 200) {
        return ProviderModel.fromJson(response.data);
      }
    } catch (_) {}
    return null;
  }

  Future<void> updateProviderStatus(String uid, bool isOnline, bool isAvailable) async {
    try {
      await _api.put('/providers/$uid/status', data: {
        'isOnline': isOnline,
        'isAvailable': isAvailable,
      });
    } catch (_) {}
  }

  // ── BOOKINGS ──
  Future<String> createBooking(BookingModel booking) async {
    try {
      final response = await _api.post('/bookings', data: booking.toJson());
      if (response.statusCode == 201 || response.statusCode == 200) {
        return response.data['bookingId'] ?? '';
      }
    } catch (_) {}
    return '';
  }

  Stream<List<BookingModel>> streamUserBookings(String userId) async* {
    while (true) {
      try {
        final response = await _api.get('/bookings/user/$userId');
        if (response.statusCode == 200) {
          final List<dynamic> list = response.data;
          yield list.map((json) => BookingModel.fromJson(json)).toList();
        }
      } catch (_) {
        yield [];
      }
      await Future.delayed(const Duration(seconds: 4));
    }
  }

  Stream<List<BookingModel>> streamProviderBookings(String providerId) async* {
    while (true) {
      try {
        final response = await _api.get('/bookings/provider/$providerId');
        if (response.statusCode == 200) {
          final List<dynamic> list = response.data;
          yield list.map((json) => BookingModel.fromJson(json)).toList();
        }
      } catch (_) {
        yield [];
      }
      await Future.delayed(const Duration(seconds: 4));
    }
  }

  Future<void> updateBookingStatus(String bookingId, String status) async {
    try {
      await _api.put('/bookings/$bookingId/status', data: {
        'status': status,
      });
    } catch (_) {}
  }

  Future<void> submitRating(String bookingId, double rating, String review) async {
    try {
      await _api.put('/bookings/$bookingId/rating', data: {
        'rating': rating,
        'review': review,
      });
    } catch (_) {}
  }

  // ── DISPUTES ──
  Future<String> createDispute(DisputeModel dispute) async {
    try {
      final response = await _api.post('/disputes', data: dispute.toJson());
      if (response.statusCode == 201 || response.statusCode == 200) {
        return response.data['disputeId'] ?? '';
      }
    } catch (_) {}
    return '';
  }

  Future<void> updateDisputeStatus(String disputeId, String status, String? resolution) async {
    try {
      await _api.put('/disputes/$disputeId', data: {
        'status': status,
        if (resolution != null) 'aiSuggestedResolution': resolution,
      });
    } catch (_) {}
  }

  // ── ANTIGRAVITY LOGS ──
  Stream<List<AntigravityLog>> streamLogs({String? stage}) async* {
    while (true) {
      try {
        final response = await _api.get('/logs', queryParameters: {
          if (stage != null) 'stage': stage,
        });
        if (response.statusCode == 200) {
          final List<dynamic> list = response.data;
          yield list.map((json) => AntigravityLog.fromJson(json)).toList();
        }
      } catch (_) {
        yield [];
      }
      await Future.delayed(const Duration(seconds: 4));
    }
  }

  // ── ANALYTICS ──
  Future<Map<String, dynamic>> getAnalytics() async {
    try {
      final response = await _api.get('/analytics');
      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(response.data);
      }
    } catch (_) {}
    return {
      'totalBookings': 0,
      'completedBookings': 0,
      'cancelledBookings': 0,
      'totalDisputes': 0,
      'avgConfidence': 0.0,
      'fallbackCount': 0,
      'aiSuccessRate': 0.0,
    };
  }
}
