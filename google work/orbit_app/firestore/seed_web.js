const { initializeApp } = require('firebase/app');
const { getFirestore, collection, doc, setDoc, writeBatch, GeoPoint, Timestamp } = require('firebase/firestore');

const firebaseConfig = {
  apiKey: "AIzaSyAw2gGsclzp4hrdp02FOqvhzpe8ZHJ1uPg",
  authDomain: "orbit-app-hosted.firebaseapp.com",
  projectId: "orbit-app-hosted",
  storageBucket: "orbit-app-hosted.firebasestorage.app",
  messagingSenderId: "973153006039",
  appId: "1:973153006039:web:4db69e0f95bea164069b92"
};

const app = initializeApp(firebaseConfig);
const db = getFirestore(app);

const now = Timestamp.now();
const tomorrow = new Date(); tomorrow.setDate(tomorrow.getDate() + 1);
const dayAfter = new Date(); dayAfter.setDate(dayAfter.getDate() + 2);

function slots(baseHour) {
  return [
    Timestamp.fromDate(new Date(tomorrow.setHours(baseHour, 0, 0, 0))),
    Timestamp.fromDate(new Date(tomorrow.setHours(baseHour + 2, 0, 0, 0))),
    Timestamp.fromDate(new Date(dayAfter.setHours(baseHour, 0, 0, 0))),
  ];
}

const providers = [
  // ── AC TECHNICIANS ──────────────────────────────────────────────────────────
  {
    uid: 'ac_001', name: 'Usman Tariq', serviceType: 'ac_technician',
    specializations: ['split_ac', 'window_ac', 'gas_refill'],
    location: new GeoPoint(33.6982, 72.9975), city: 'Islamabad', area: 'G-13',
    rating: 4.9, totalReviews: 187, onTimeScore: 98, cancellationRate: 0.01,
    riskScore: 5, isOnline: true, isAvailable: true, pricePerHour: 1800,
    experienceYears: 8, certifications: ['AC Certified', 'Gas Handling License'],
    capacityPerDay: 4, currentBookingsToday: 1,
    availableSlots: slots(9), earnings: { today: 3600, thisWeek: 18000, thisMonth: 72000 },
  },
  {
    uid: 'ac_002', name: 'Faisal Khan', serviceType: 'ac_technician',
    specializations: ['split_ac', 'central_ac'],
    location: new GeoPoint(24.8107, 67.0655), city: 'Karachi', area: 'DHA Karachi',
    rating: 4.7, totalReviews: 212, onTimeScore: 91, cancellationRate: 0.04,
    riskScore: 15, isOnline: true, isAvailable: true, pricePerHour: 2000,
    experienceYears: 6, certifications: ['AC Certified'],
    capacityPerDay: 5, currentBookingsToday: 2,
    availableSlots: slots(10), earnings: { today: 4000, thisWeek: 20000, thisMonth: 80000 },
  },
  {
    uid: 'ac_003', name: 'Ali Hassan', serviceType: 'ac_technician',
    specializations: ['window_ac', 'gas_refill'],
    location: new GeoPoint(24.9295, 67.0970), city: 'Karachi', area: 'Gulshan',
    rating: 4.7, totalReviews: 95, onTimeScore: 62, cancellationRate: 0.22,
    riskScore: 75, isOnline: true, isAvailable: true, pricePerHour: 1600,
    experienceYears: 4, certifications: [],
    capacityPerDay: 3, currentBookingsToday: 1,
    availableSlots: slots(11), earnings: { today: 1600, thisWeek: 8000, thisMonth: 32000 },
  },
  {
    uid: 'ac_004', name: 'Hamid Raza', serviceType: 'ac_technician',
    specializations: ['split_ac', 'installation'],
    location: new GeoPoint(33.7150, 73.0170), city: 'Islamabad', area: 'F-10',
    rating: 4.5, totalReviews: 143, onTimeScore: 95, cancellationRate: 0.02,
    riskScore: 10, isOnline: true, isAvailable: true, pricePerHour: 1900,
    experienceYears: 7, certifications: ['AC Certified', 'Electrical Safety'],
    capacityPerDay: 4, currentBookingsToday: 2,
    availableSlots: slots(9), earnings: { today: 3800, thisWeek: 19000, thisMonth: 76000 },
  },
  {
    uid: 'ac_005', name: 'Shahid Mehmood', serviceType: 'ac_technician',
    specializations: ['commercial_ac', 'split_ac'],
    location: new GeoPoint(24.8607, 67.0104), city: 'Karachi', area: 'Saddar',
    rating: 4.2, totalReviews: 78, onTimeScore: 78, cancellationRate: 0.08,
    riskScore: 30, isOnline: false, isAvailable: false, pricePerHour: 1500,
    experienceYears: 3, certifications: [],
    capacityPerDay: 5, currentBookingsToday: 0,
    availableSlots: slots(14), earnings: { today: 0, thisWeek: 7500, thisMonth: 30000 },
  },
  {
    uid: 'ac_006', name: 'Tariq Mahmood', serviceType: 'ac_technician',
    specializations: ['split_ac', 'compressor_replacement'],
    location: new GeoPoint(33.5498, 73.1946), city: 'Islamabad', area: 'Bahria Town',
    rating: 4.8, totalReviews: 231, onTimeScore: 97, cancellationRate: 0.01,
    riskScore: 8, isOnline: true, isAvailable: true, pricePerHour: 2200,
    experienceYears: 10, certifications: ['Master AC Tech', 'Gas License'],
    capacityPerDay: 3, currentBookingsToday: 1,
    availableSlots: slots(9), earnings: { today: 4400, thisWeek: 22000, thisMonth: 88000 },
  },

  // ── PLUMBERS ─────────────────────────────────────────────────────────────────
  {
    uid: 'pl_001', name: 'Ghulam Abbas', serviceType: 'plumber',
    specializations: ['pipe_repair', 'drain_cleaning', 'installation'],
    location: new GeoPoint(24.9478, 67.0529), city: 'Karachi', area: 'North Nazimabad',
    rating: 4.6, totalReviews: 156, onTimeScore: 88, cancellationRate: 0.05,
    riskScore: 20, isOnline: true, isAvailable: true, pricePerHour: 1200,
    experienceYears: 9, certifications: ['Plumbing License'],
    capacityPerDay: 6, currentBookingsToday: 2,
    availableSlots: slots(9), earnings: { today: 2400, thisWeek: 12000, thisMonth: 48000 },
  },
  {
    uid: 'pl_002', name: 'Muhammad Akram', serviceType: 'plumber',
    specializations: ['bathroom_fitting', 'pipe_leak'],
    location: new GeoPoint(24.8117, 67.0300), city: 'Karachi', area: 'Clifton',
    rating: 4.4, totalReviews: 92, onTimeScore: 82, cancellationRate: 0.07,
    riskScore: 25, isOnline: true, isAvailable: true, pricePerHour: 1000,
    experienceYears: 5, certifications: [],
    capacityPerDay: 5, currentBookingsToday: 1,
    availableSlots: slots(10), earnings: { today: 2000, thisWeek: 10000, thisMonth: 40000 },
  },
  {
    uid: 'pl_003', name: 'Zulfiqar Ahmed', serviceType: 'plumber',
    specializations: ['drain_cleaning', 'water_pump'],
    location: new GeoPoint(33.6823, 73.0594), city: 'Islamabad', area: 'I-8',
    rating: 4.3, totalReviews: 67, onTimeScore: 85, cancellationRate: 0.06,
    riskScore: 22, isOnline: true, isAvailable: true, pricePerHour: 900,
    experienceYears: 4, certifications: [],
    capacityPerDay: 6, currentBookingsToday: 3,
    availableSlots: slots(11), earnings: { today: 2700, thisWeek: 13500, thisMonth: 54000 },
  },
  {
    uid: 'pl_004', name: 'Pervez Akhtar', serviceType: 'plumber',
    specializations: ['pipe_installation', 'boiler_repair'],
    location: new GeoPoint(33.7251, 73.0062), city: 'Islamabad', area: 'E-11',
    rating: 3.8, totalReviews: 41, onTimeScore: 70, cancellationRate: 0.15,
    riskScore: 45, isOnline: false, isAvailable: false, pricePerHour: 800,
    experienceYears: 2, certifications: [],
    capacityPerDay: 4, currentBookingsToday: 0,
    availableSlots: slots(14), earnings: { today: 0, thisWeek: 4000, thisMonth: 16000 },
  },
  {
    uid: 'pl_005', name: 'Riaz Hussain', serviceType: 'plumber',
    specializations: ['pipe_repair', 'drain_cleaning'],
    location: new GeoPoint(24.9295, 67.0970), city: 'Karachi', area: 'Gulshan',
    rating: 4.7, totalReviews: 189, onTimeScore: 93, cancellationRate: 0.03,
    riskScore: 12, isOnline: true, isAvailable: true, pricePerHour: 1100,
    experienceYears: 8, certifications: ['Master Plumber'],
    capacityPerDay: 5, currentBookingsToday: 2,
    availableSlots: slots(9), earnings: { today: 2200, thisWeek: 11000, thisMonth: 44000 },
  },

  // ── ELECTRICIANS ─────────────────────────────────────────────────────────────
  {
    uid: 'el_001', name: 'Rafiq Ahmed', serviceType: 'electrician',
    specializations: ['wiring', 'panel_upgrade', 'solar'],
    location: new GeoPoint(24.8107, 67.0655), city: 'Karachi', area: 'DHA Karachi',
    rating: 4.8, totalReviews: 203, onTimeScore: 96, cancellationRate: 0.02,
    riskScore: 8, isOnline: true, isAvailable: true, pricePerHour: 1400,
    experienceYears: 10, certifications: ['WAPDA Certified', 'Solar Installation'],
    capacityPerDay: 5, currentBookingsToday: 1,
    availableSlots: slots(9), earnings: { today: 2800, thisWeek: 14000, thisMonth: 56000 },
  },
  {
    uid: 'el_002', name: 'Nasir Iqbal', serviceType: 'electrician',
    specializations: ['wiring', 'switch_repair'],
    location: new GeoPoint(33.6982, 72.9975), city: 'Islamabad', area: 'G-13',
    rating: 4.3, totalReviews: 88, onTimeScore: 80, cancellationRate: 0.09,
    riskScore: 35, isOnline: true, isAvailable: true, pricePerHour: 1100,
    experienceYears: 5, certifications: [],
    capacityPerDay: 6, currentBookingsToday: 2,
    availableSlots: slots(10), earnings: { today: 2200, thisWeek: 11000, thisMonth: 44000 },
  },
  {
    uid: 'el_003', name: 'Asif Mehmood', serviceType: 'electrician',
    specializations: ['panel_repair', 'generator'],
    location: new GeoPoint(24.9478, 67.0529), city: 'Karachi', area: 'North Nazimabad',
    rating: 4.5, totalReviews: 112, onTimeScore: 88, cancellationRate: 0.04,
    riskScore: 18, isOnline: true, isAvailable: true, pricePerHour: 1300,
    experienceYears: 7, certifications: ['WAPDA Certified'],
    capacityPerDay: 4, currentBookingsToday: 1,
    availableSlots: slots(11), earnings: { today: 2600, thisWeek: 13000, thisMonth: 52000 },
  },
  {
    uid: 'el_004', name: 'Khalid Pervaiz', serviceType: 'electrician',
    specializations: ['wiring', 'fan_repair'],
    location: new GeoPoint(33.7150, 73.0170), city: 'Islamabad', area: 'F-10',
    rating: 3.5, totalReviews: 29, onTimeScore: 58, cancellationRate: 0.22,
    riskScore: 80, isOnline: true, isAvailable: true, pricePerHour: 900,
    experienceYears: 2, certifications: [],
    capacityPerDay: 5, currentBookingsToday: 0,
    availableSlots: slots(12), earnings: { today: 0, thisWeek: 4500, thisMonth: 18000 },
  },
  {
    uid: 'el_005', name: 'Sohail Anwar', serviceType: 'electrician',
    specializations: ['solar', 'inverter', 'wiring'],
    location: new GeoPoint(33.5498, 73.1946), city: 'Islamabad', area: 'Bahria Town',
    rating: 4.9, totalReviews: 276, onTimeScore: 99, cancellationRate: 0.01,
    riskScore: 3, isOnline: true, isAvailable: true, pricePerHour: 1600,
    experienceYears: 12, certifications: ['WAPDA Certified', 'Solar Expert', 'Safety License'],
    capacityPerDay: 4, currentBookingsToday: 2,
    availableSlots: slots(9), earnings: { today: 3200, thisWeek: 16000, thisMonth: 64000 },
  },

  // ── BEAUTICIANS ──────────────────────────────────────────────────────────────
  {
    uid: 'be_001', name: 'Sana Malik', serviceType: 'beautician',
    specializations: ['bridal', 'facial', 'waxing'],
    location: new GeoPoint(24.8107, 67.0655), city: 'Karachi', area: 'DHA Karachi',
    rating: 4.9, totalReviews: 341, onTimeScore: 97, cancellationRate: 0.02,
    riskScore: 6, isOnline: true, isAvailable: true, pricePerHour: 2500,
    experienceYears: 8, certifications: ['Makeup Artist Cert'],
    capacityPerDay: 3, currentBookingsToday: 1,
    availableSlots: slots(10), earnings: { today: 5000, thisWeek: 25000, thisMonth: 100000 },
  },
  {
    uid: 'be_002', name: 'Farah Naz', serviceType: 'beautician',
    specializations: ['mehndi', 'facial', 'threading'],
    location: new GeoPoint(24.9295, 67.0970), city: 'Karachi', area: 'Gulshan',
    rating: 4.6, totalReviews: 178, onTimeScore: 90, cancellationRate: 0.04,
    riskScore: 15, isOnline: true, isAvailable: true, pricePerHour: 2000,
    experienceYears: 6, certifications: [],
    capacityPerDay: 4, currentBookingsToday: 2,
    availableSlots: slots(11), earnings: { today: 4000, thisWeek: 20000, thisMonth: 80000 },
  },
  {
    uid: 'be_003', name: 'Nadia Iqbal', serviceType: 'beautician',
    specializations: ['hair', 'facial', 'pedicure'],
    location: new GeoPoint(33.6982, 72.9975), city: 'Islamabad', area: 'G-13',
    rating: 4.4, totalReviews: 95, onTimeScore: 85, cancellationRate: 0.06,
    riskScore: 22, isOnline: true, isAvailable: true, pricePerHour: 1800,
    experienceYears: 4, certifications: [],
    capacityPerDay: 4, currentBookingsToday: 1,
    availableSlots: slots(10), earnings: { today: 3600, thisWeek: 18000, thisMonth: 72000 },
  },
  {
    uid: 'be_004', name: 'Zara Ahmed', serviceType: 'beautician',
    specializations: ['bridal', 'photoshoot_makeup'],
    location: new GeoPoint(33.5498, 73.1946), city: 'Islamabad', area: 'Bahria Town',
    rating: 4.8, totalReviews: 267, onTimeScore: 95, cancellationRate: 0.02,
    riskScore: 9, isOnline: true, isAvailable: true, pricePerHour: 3000,
    experienceYears: 9, certifications: ['Certified Makeup Artist'],
    capacityPerDay: 2, currentBookingsToday: 0,
    availableSlots: slots(9), earnings: { today: 6000, thisWeek: 30000, thisMonth: 120000 },
  },

  // ── TUTORS ───────────────────────────────────────────────────────────────────
  {
    uid: 'tu_001', name: 'Dr. Wasim Shah', serviceType: 'tutor',
    specializations: ['math', 'physics', 'O_level'],
    location: new GeoPoint(24.8107, 67.0655), city: 'Karachi', area: 'DHA Karachi',
    rating: 4.9, totalReviews: 198, onTimeScore: 99, cancellationRate: 0.01,
    riskScore: 2, isOnline: true, isAvailable: true, pricePerHour: 1500,
    experienceYears: 15, certifications: ['PhD Mathematics', 'Teaching Certificate'],
    capacityPerDay: 6, currentBookingsToday: 3,
    availableSlots: slots(14), earnings: { today: 4500, thisWeek: 22500, thisMonth: 90000 },
  },
  {
    uid: 'tu_002', name: 'Sara Fatima', serviceType: 'tutor',
    specializations: ['english', 'urdu', 'A_level'],
    location: new GeoPoint(24.9295, 67.0970), city: 'Karachi', area: 'Gulshan',
    rating: 4.7, totalReviews: 134, onTimeScore: 94, cancellationRate: 0.03,
    riskScore: 10, isOnline: true, isAvailable: true, pricePerHour: 1200,
    experienceYears: 8, certifications: ['MA English'],
    capacityPerDay: 5, currentBookingsToday: 2,
    availableSlots: slots(15), earnings: { today: 3600, thisWeek: 18000, thisMonth: 72000 },
  },
  {
    uid: 'tu_003', name: 'Hassan Mirza', serviceType: 'tutor',
    specializations: ['chemistry', 'biology', 'MDCAT'],
    location: new GeoPoint(33.7150, 73.0170), city: 'Islamabad', area: 'F-10',
    rating: 4.6, totalReviews: 89, onTimeScore: 91, cancellationRate: 0.04,
    riskScore: 14, isOnline: true, isAvailable: true, pricePerHour: 1300,
    experienceYears: 6, certifications: ['MSc Chemistry'],
    capacityPerDay: 5, currentBookingsToday: 1,
    availableSlots: slots(14), earnings: { today: 2600, thisWeek: 13000, thisMonth: 52000 },
  },
  {
    uid: 'tu_004', name: 'Amina Baig', serviceType: 'tutor',
    specializations: ['primary', 'urdu', 'islamiat'],
    location: new GeoPoint(33.6982, 72.9975), city: 'Islamabad', area: 'G-13',
    rating: 4.3, totalReviews: 56, onTimeScore: 87, cancellationRate: 0.05,
    riskScore: 18, isOnline: false, isAvailable: false, pricePerHour: 900,
    experienceYears: 4, certifications: ['B.Ed'],
    capacityPerDay: 6, currentBookingsToday: 0,
    availableSlots: slots(16), earnings: { today: 0, thisWeek: 5400, thisMonth: 21600 },
  },

  // ── MECHANICS ────────────────────────────────────────────────────────────────
  {
    uid: 'me_001', name: 'Aslam Butt', serviceType: 'mechanic',
    specializations: ['car_service', 'oil_change', 'brake_repair'],
    location: new GeoPoint(24.8607, 67.0104), city: 'Karachi', area: 'Saddar',
    rating: 4.5, totalReviews: 167, onTimeScore: 85, cancellationRate: 0.06,
    riskScore: 22, isOnline: true, isAvailable: true, pricePerHour: 1500,
    experienceYears: 12, certifications: ['Auto Mechanic License'],
    capacityPerDay: 4, currentBookingsToday: 2,
    availableSlots: slots(9), earnings: { today: 3000, thisWeek: 15000, thisMonth: 60000 },
  },
  {
    uid: 'me_002', name: 'Tariq Butt', serviceType: 'mechanic',
    specializations: ['engine_repair', 'transmission', 'diagnostic'],
    location: new GeoPoint(33.6823, 73.0594), city: 'Islamabad', area: 'I-8',
    rating: 4.7, totalReviews: 123, onTimeScore: 92, cancellationRate: 0.03,
    riskScore: 11, isOnline: true, isAvailable: true, pricePerHour: 1800,
    experienceYears: 10, certifications: ['Engine Specialist', 'Diagnostic License'],
    capacityPerDay: 3, currentBookingsToday: 1,
    availableSlots: slots(10), earnings: { today: 3600, thisWeek: 18000, thisMonth: 72000 },
  },
  {
    uid: 'me_003', name: 'Shahbaz Khan', serviceType: 'mechanic',
    specializations: ['body_work', 'paint', 'denting'],
    location: new GeoPoint(24.8117, 67.0300), city: 'Karachi', area: 'Clifton',
    rating: 4.2, totalReviews: 78, onTimeScore: 75, cancellationRate: 0.12,
    riskScore: 40, isOnline: true, isAvailable: true, pricePerHour: 1200,
    experienceYears: 5, certifications: [],
    capacityPerDay: 4, currentBookingsToday: 0,
    availableSlots: slots(11), earnings: { today: 0, thisWeek: 7200, thisMonth: 28800 },
  },

  // ── HOME SERVICES ─────────────────────────────────────────────────────────────
  {
    uid: 'hs_001', name: 'Rukhsana Bibi', serviceType: 'home_service',
    specializations: ['cleaning', 'cooking', 'laundry'],
    location: new GeoPoint(24.9295, 67.0970), city: 'Karachi', area: 'Gulshan',
    rating: 4.8, totalReviews: 312, onTimeScore: 96, cancellationRate: 0.02,
    riskScore: 7, isOnline: true, isAvailable: true, pricePerHour: 800,
    experienceYears: 10, certifications: [],
    capacityPerDay: 3, currentBookingsToday: 1,
    availableSlots: slots(9), earnings: { today: 2400, thisWeek: 12000, thisMonth: 48000 },
  },
  {
    uid: 'hs_002', name: 'Shanaz Akhtar', serviceType: 'home_service',
    specializations: ['deep_cleaning', 'kitchen_cleaning'],
    location: new GeoPoint(33.7150, 73.0170), city: 'Islamabad', area: 'F-10',
    rating: 4.5, totalReviews: 144, onTimeScore: 89, cancellationRate: 0.04,
    riskScore: 16, isOnline: true, isAvailable: true, pricePerHour: 700,
    experienceYears: 6, certifications: [],
    capacityPerDay: 4, currentBookingsToday: 2,
    availableSlots: slots(10), earnings: { today: 2100, thisWeek: 10500, thisMonth: 42000 },
  },
  {
    uid: 'hs_003', name: 'Parveen Nawaz', serviceType: 'home_service',
    specializations: ['cleaning', 'ironing'],
    location: new GeoPoint(33.5498, 73.1946), city: 'Islamabad', area: 'Bahria Town',
    rating: 4.3, totalReviews: 67, onTimeScore: 82, cancellationRate: 0.07,
    riskScore: 24, isOnline: true, isAvailable: true, pricePerHour: 650,
    experienceYears: 4, certifications: [],
    capacityPerDay: 4, currentBookingsToday: 0,
    availableSlots: slots(11), earnings: { today: 0, thisWeek: 5200, thisMonth: 20800 },
  },
];

async function seed() {
  console.log('🌱 Seeding 30 providers to Firestore...');
  const batch = writeBatch(db);
  for (const provider of providers) {
    const ref = doc(db, 'providers', provider.uid);
    batch.set(ref, { ...provider, createdAt: now });
  }
  await batch.commit();
  console.log(`✅ Seeded ${providers.length} providers successfully!`);
  process.exit(0);
}

seed().catch(e => { console.error('❌ Seed failed:', e); process.exit(1); });
