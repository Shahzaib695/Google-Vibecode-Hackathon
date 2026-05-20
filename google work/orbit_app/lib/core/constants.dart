class AppConstants {
  // App Info
  static const String appName = 'Orbit';
  static const String appTagline = 'Your city, intelligently served.';
  static const String appVersion = '1.0.0';

  // Google Maps API Key
  static const String googleMapsApiKey = 'YOUR_GOOGLE_MAPS_API_KEY';

  // Firebase Cloud Functions base URL
  static const String functionsBaseUrl =
      'https://us-central1-orbit-pakistan.cloudfunctions.net';

  // Antigravity / Vertex AI
  static const String vertexAiProjectId = 'orbit-pakistan';
  static const String vertexAiLocation = 'us-central1';
  static const String antigravityAgentId = 'YOUR_AGENT_ID';

  // Demo mode
  static const bool isDemoMode = true;
  static const int logoTapCountForTrace = 3;

  // Pricing Constants (PKR)
  static const double visitFeeNear = 200.0;
  static const double visitFeeMid = 350.0;
  static const double visitFeeFar = 500.0;
  static const double distanceCostPerKm = 15.0;
  static const double loyaltyDiscountThreshold = 100.0;
  static const double loyaltyDiscountRate = 0.05;
  static const int loyaltyPointsPerBooking = 10;

  // Urgency Multipliers
  static const double urgencyStandard = 1.0;
  static const double urgencySameDay = 1.2;
  static const double urgencyEmergency = 1.5;

  // Confidence Thresholds
  static const double confidenceLowThreshold = 70.0;
  static const double confidenceMediumThreshold = 85.0;

  // Provider Matching Weights
  static const double weightDistance = 0.15;
  static const double weightAvailability = 0.20;
  static const double weightRating = 0.15;
  static const double weightReviewRecency = 0.10;
  static const double weightOnTime = 0.15;
  static const double weightSkill = 0.15;
  static const double weightPrice = 0.05;
  static const double weightCancellation = 0.05;

  // Dispute Thresholds
  static const int blacklistDisputeThreshold = 3;
  static const int blacklistDisputeDays = 30;

  // Pakistan Areas
  static const List<String> karachiAreas = [
    'DHA', 'Gulshan', 'North Nazimabad', 'Saddar', 'Clifton',
    'Gulistan-e-Johar', 'Liaquatabad', 'Korangi', 'Malir', 'Landhi',
  ];

  static const List<String> islamabadAreas = [
    'G-13', 'F-10', 'Bahria Town', 'I-8', 'E-11',
    'DHA Islamabad', 'F-7', 'G-11', 'Blue Area', 'I-10',
  ];

  static const List<String> lahoreAreas = [
    'DHA Lahore', 'Gulberg', 'Model Town', 'Johar Town',
    'Bahria Town Lahore', 'Township', 'Cantt', 'Garden Town',
  ];

  // Service Types
  static const Map<String, String> serviceIcons = {
    'ac_technician': '❄️',
    'plumber': '🔧',
    'electrician': '⚡',
    'beautician': '💅',
    'tutor': '📚',
    'mechanic': '🔩',
    'home_service': '🏠',
  };

  static const Map<String, String> serviceNames = {
    'ac_technician': 'AC Service',
    'plumber': 'Plumber',
    'electrician': 'Electrician',
    'beautician': 'Beautician',
    'tutor': 'Home Tutor',
    'mechanic': 'Mechanic',
    'home_service': 'Home Service',
  };

  // Payment Methods
  static const Map<String, String> paymentMethods = {
    'cash': 'Cash on Delivery',
    'jazzcash': 'JazzCash',
    'easypaisa': 'EasyPaisa',
  };

  // Status Labels
  static const Map<String, String> bookingStatusLabels = {
    'pending': 'Pending',
    'confirmed': 'Confirmed',
    'en_route': 'On the Way',
    'in_progress': 'In Progress',
    'completed': 'Completed',
    'disputed': 'Disputed',
    'cancelled': 'Cancelled',
  };

  // Language Options
  static const Map<String, String> languages = {
    'english': 'English',
    'urdu': 'اردو',
    'roman_urdu': 'Roman Urdu',
  };

  // Mock Coordinates (Pakistan)
  static const Map<String, Map<String, double>> areaCoordinates = {
    'DHA Karachi': {'lat': 24.8107, 'lng': 67.0655},
    'Gulshan': {'lat': 24.9295, 'lng': 67.0970},
    'North Nazimabad': {'lat': 24.9478, 'lng': 67.0529},
    'Saddar': {'lat': 24.8607, 'lng': 67.0104},
    'Clifton': {'lat': 24.8117, 'lng': 67.0300},
    'G-13': {'lat': 33.6982, 'lng': 72.9975},
    'F-10': {'lat': 33.7150, 'lng': 73.0170},
    'Bahria Town': {'lat': 33.5498, 'lng': 73.1946},
    'I-8': {'lat': 33.6823, 'lng': 73.0594},
    'E-11': {'lat': 33.7251, 'lng': 73.0062},
  };
}

class DemoScenarios {
  static const String emergencyAC = 'emergency_ac';
  static const String noProvider = 'no_provider';
  static const String providerCancellation = 'provider_cancellation';
  static const String priceDispute = 'price_dispute';
  static const String unreliableProvider = 'unreliable_provider';
  static const String ambiguousInput = 'ambiguous_input';

  static const Map<String, String> scenarioLabels = {
    emergencyAC: '🔴 Emergency AC Repair',
    noProvider: '⚠️ No Provider Available',
    providerCancellation: '🔄 Provider Cancellation',
    priceDispute: '💰 Price Dispute',
    unreliableProvider: '⭐ High-Rated Unreliable Provider',
    ambiguousInput: '🌐 Ambiguous Urdu Input',
  };

  static const Map<String, String> scenarioInputs = {
    emergencyAC: 'AC bilkul kaam nahi kar raha, kal subah G-13 mein technician chahiye, budget zyada nahi hai',
    noProvider: 'Mujhe abhi ek plumber chahiye Clifton mein, bohot urgent hai',
    providerCancellation: 'Mujhe kal AC service chahiye DHA Karachi',
    priceDispute: 'AC service karwai lekin unhon ne zyada paise liye',
    unreliableProvider: 'Gulshan mein best AC technician chahiye',
    ambiguousInput: 'bijli ka masla hai urgent fix karo',
  };
}
