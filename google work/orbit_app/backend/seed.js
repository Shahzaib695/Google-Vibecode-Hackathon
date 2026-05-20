const mongoose = require('mongoose');
const Provider = require('./models/Provider');
require('dotenv').config();

const providersData = [
  // AC Technicians
  {
    name: 'Muhammad Yasir',
    serviceType: 'ac_technician',
    specializations: ['split_ac', 'inverter_ac', 'gas_refill'],
    location: { latitude: 33.6844, longitude: 73.0479 },
    city: 'Islamabad',
    area: 'F-8',
    rating: 4.8,
    totalReviews: 120,
    onTimeScore: 95.0,
    cancellationRate: 0.02,
    riskScore: 5.0,
    isOnline: true,
    isAvailable: true,
    pricePerHour: 1500,
    experienceYears: 6,
    certifications: ['DAE HVAC', 'National Safety Certificate'],
    capacityPerDay: 5,
    phone: '+923001234567'
  },
  {
    name: 'Tariq Mehmood',
    serviceType: 'ac_technician',
    specializations: ['split_ac', 'window_ac', 'leakage_repair'],
    location: { latitude: 33.6982, longitude: 72.9975 },
    city: 'Islamabad',
    area: 'G-13',
    rating: 4.9,
    totalReviews: 187,
    onTimeScore: 98.0,
    cancellationRate: 0.01,
    riskScore: 3.0,
    isOnline: true,
    isAvailable: true,
    pricePerHour: 1800,
    experienceYears: 8,
    certifications: ['AC Certified', 'Gas Handling License'],
    capacityPerDay: 4,
    phone: '+923009876543'
  },
  {
    name: 'Kamran Ali',
    serviceType: 'ac_technician',
    specializations: ['central_ac', 'inverter_ac', 'installation'],
    location: { latitude: 33.6518, longitude: 73.0819 },
    city: 'Islamabad',
    area: 'I-8',
    rating: 4.2,
    totalReviews: 45,
    onTimeScore: 88.0,
    cancellationRate: 0.08,
    riskScore: 15.0,
    isOnline: true,
    isAvailable: true,
    pricePerHour: 2000,
    experienceYears: 4,
    certifications: ['Votech AC Tech Course'],
    capacityPerDay: 6,
    phone: '+923123456789'
  },
  {
    name: 'Zahid Khan',
    serviceType: 'ac_technician',
    specializations: ['split_ac', 'cleaning', 'compressor_repair'],
    location: { latitude: 33.6923, longitude: 73.0223 },
    city: 'Islamabad',
    area: 'G-11',
    rating: 4.6,
    totalReviews: 89,
    onTimeScore: 92.0,
    cancellationRate: 0.04,
    riskScore: 8.0,
    isOnline: true,
    isAvailable: false,
    pricePerHour: 1400,
    experienceYears: 5,
    certifications: [],
    capacityPerDay: 5,
    phone: '+923334567890'
  },

  // Plumbers
  {
    name: 'Sajid Mahmood',
    serviceType: 'plumber',
    specializations: ['leakage_repair', 'pipe_fitting', 'drain_cleaning'],
    location: { latitude: 33.6684, longitude: 73.0745 },
    city: 'Islamabad',
    area: 'G-9',
    rating: 4.7,
    totalReviews: 142,
    onTimeScore: 96.0,
    cancellationRate: 0.01,
    riskScore: 4.0,
    isOnline: true,
    isAvailable: true,
    pricePerHour: 800,
    experienceYears: 10,
    certifications: ['Wasa Plumber License'],
    capacityPerDay: 6,
    phone: '+923211234567'
  },
  {
    name: 'Nadeem Abbas',
    serviceType: 'plumber',
    specializations: ['geyser_installation', 'bathroom_fitting'],
    location: { latitude: 33.7011, longitude: 73.0455 },
    city: 'Islamabad',
    area: 'F-7',
    rating: 4.9,
    totalReviews: 95,
    onTimeScore: 99.0,
    cancellationRate: 0.0,
    riskScore: 2.0,
    isOnline: true,
    isAvailable: true,
    pricePerHour: 1200,
    experienceYears: 7,
    certifications: ['Govt Technical Board Certified'],
    capacityPerDay: 5,
    phone: '+923451234567'
  },
  {
    name: 'Irshad Ahmed',
    serviceType: 'plumber',
    specializations: ['leakage_repair', 'water_pump_repair'],
    location: { latitude: 33.6455, longitude: 73.0125 },
    city: 'Islamabad',
    area: 'I-9',
    rating: 4.4,
    totalReviews: 67,
    onTimeScore: 90.0,
    cancellationRate: 0.05,
    riskScore: 10.0,
    isOnline: true,
    isAvailable: true,
    pricePerHour: 900,
    experienceYears: 5,
    certifications: [],
    capacityPerDay: 5,
    phone: '+923151234567'
  },

  // Electricians
  {
    name: 'Waseem Akram',
    serviceType: 'electrician',
    specializations: ['wiring', 'db_box_repair', 'appliance_repair'],
    location: { latitude: 33.6811, longitude: 73.0366 },
    city: 'Islamabad',
    area: 'F-10',
    rating: 4.8,
    totalReviews: 165,
    onTimeScore: 97.0,
    cancellationRate: 0.02,
    riskScore: 5.0,
    isOnline: true,
    isAvailable: true,
    pricePerHour: 1000,
    experienceYears: 9,
    certifications: ['IESCO Electrician License', 'DAE Electrical'],
    capacityPerDay: 5,
    phone: '+923011234567'
  },
  {
    name: 'Asif Ali',
    serviceType: 'electrician',
    specializations: ['short_circuit_repair', 'ups_inverter_installation'],
    location: { latitude: 33.6702, longitude: 73.0112 },
    city: 'Islamabad',
    area: 'G-10',
    rating: 4.5,
    totalReviews: 78,
    onTimeScore: 91.0,
    cancellationRate: 0.06,
    riskScore: 9.0,
    isOnline: true,
    isAvailable: true,
    pricePerHour: 900,
    experienceYears: 4,
    certifications: [],
    capacityPerDay: 6,
    phone: '+923021234567'
  },
  {
    name: 'Farooq Shah',
    serviceType: 'electrician',
    specializations: ['wiring', 'generator_installation'],
    location: { latitude: 33.6125, longitude: 73.1255 },
    city: 'Islamabad',
    area: 'Khanna Pul',
    rating: 4.6,
    totalReviews: 112,
    onTimeScore: 94.0,
    cancellationRate: 0.03,
    riskScore: 7.0,
    isOnline: true,
    isAvailable: false,
    pricePerHour: 950,
    experienceYears: 6,
    certifications: ['Safety First Electric Board'],
    capacityPerDay: 5,
    phone: '+923031234567'
  },

  // Beauticians
  {
    name: 'Ayesha Khan',
    serviceType: 'beautician',
    specializations: ['makeup', 'facial_treatment', 'hair_styling'],
    location: { latitude: 33.7022, longitude: 73.0388 },
    city: 'Islamabad',
    area: 'E-11',
    rating: 4.9,
    totalReviews: 230,
    onTimeScore: 99.0,
    cancellationRate: 0.01,
    riskScore: 2.0,
    isOnline: true,
    isAvailable: true,
    pricePerHour: 2500,
    experienceYears: 10,
    certifications: ['Depilex Gold Diploma', 'International Makeup Artist'],
    capacityPerDay: 3,
    phone: '+923041234567'
  },
  {
    name: 'Sara Butt',
    serviceType: 'beautician',
    specializations: ['manicure_pedicure', 'threading_waxing'],
    location: { latitude: 33.6899, longitude: 73.0555 },
    city: 'Islamabad',
    area: 'F-6',
    rating: 4.7,
    totalReviews: 94,
    onTimeScore: 94.0,
    cancellationRate: 0.03,
    riskScore: 6.0,
    isOnline: true,
    isAvailable: true,
    pricePerHour: 1500,
    experienceYears: 5,
    certifications: ['Loreal Hair Care Academy'],
    capacityPerDay: 4,
    phone: '+923051234567'
  },

  // Tutors
  {
    name: 'Dr. Sofia Rehman',
    serviceType: 'tutor',
    specializations: ['mathematics', 'physics', 'o_levels'],
    location: { latitude: 33.6933, longitude: 73.0299 },
    city: 'Islamabad',
    area: 'F-11',
    rating: 4.9,
    totalReviews: 110,
    onTimeScore: 98.0,
    cancellationRate: 0.01,
    riskScore: 2.0,
    isOnline: true,
    isAvailable: true,
    pricePerHour: 2200,
    experienceYears: 12,
    certifications: ['PhD in Mathematics (QAU)', 'Best Teacher Award 2024'],
    capacityPerDay: 4,
    phone: '+923061234567'
  },
  {
    name: 'Zainab Qazi',
    serviceType: 'tutor',
    specializations: ['english_literature', 'urdu_grammar'],
    location: { latitude: 33.6599, longitude: 73.0899 },
    city: 'Islamabad',
    area: 'I-8',
    rating: 4.8,
    totalReviews: 76,
    onTimeScore: 96.0,
    cancellationRate: 0.02,
    riskScore: 4.0,
    isOnline: true,
    isAvailable: true,
    pricePerHour: 1500,
    experienceYears: 6,
    certifications: ['M.Phil English (NUML)'],
    capacityPerDay: 5,
    phone: '+923071234567'
  },

  // Mechanics
  {
    name: 'Sher Khan',
    serviceType: 'mechanic',
    specializations: ['car_engine_repair', 'brake_repair', 'tuning'],
    location: { latitude: 33.6422, longitude: 72.9811 },
    city: 'Islamabad',
    area: 'G-15',
    rating: 4.8,
    totalReviews: 310,
    onTimeScore: 97.0,
    cancellationRate: 0.02,
    riskScore: 3.0,
    isOnline: true,
    isAvailable: true,
    pricePerHour: 1200,
    experienceYears: 15,
    certifications: ['Toyota Master Technician Certification'],
    capacityPerDay: 5,
    phone: '+923081234567'
  },
  {
    name: 'Bilal Warraich',
    serviceType: 'mechanic',
    specializations: ['bike_repair', 'engine_overhauling'],
    location: { latitude: 33.6399, longitude: 73.0677 },
    city: 'Islamabad',
    area: 'Rawalpindi Road',
    rating: 4.5,
    totalReviews: 89,
    onTimeScore: 90.0,
    cancellationRate: 0.05,
    riskScore: 9.0,
    isOnline: true,
    isAvailable: true,
    pricePerHour: 600,
    experienceYears: 7,
    certifications: [],
    capacityPerDay: 6,
    phone: '+923091234567'
  }
];

// Add 14 more random providers to make it exactly 30
const serviceTypes = ['ac_technician', 'plumber', 'electrician', 'beautician', 'tutor', 'mechanic', 'home_service'];
const areas = ['G-11', 'F-8', 'G-13', 'I-8', 'E-11', 'F-10', 'G-9', 'F-7', 'G-10', 'I-9', 'F-11', 'G-15'];
const firstNames = ['Muhammad', 'Ali', 'Zain', 'Bilal', 'Usman', 'Hamza', 'Saad', 'Farhan', 'Rizwan', 'Noman', 'Ayesha', 'Fatima', 'Sana', 'Maria'];
const lastNames = ['Khan', 'Ahmed', 'Awan', 'Raza', 'Shah', 'Mahmood', 'Abbas', 'Ali', 'Qureshi', 'Malik', 'Rehman', 'Butt', 'Siddiqui'];

for (let i = 0; i < 14; i++) {
  const serviceType = serviceTypes[Math.floor(Math.random() * serviceTypes.length)];
  const name = firstNames[Math.floor(Math.random() * firstNames.length)] + ' ' + lastNames[Math.floor(Math.random() * lastNames.length)];
  const area = areas[Math.floor(Math.random() * areas.length)];
  
  // Random coordinates near Islamabad
  const latitude = 33.6 + Math.random() * 0.15;
  const longitude = 72.9 + Math.random() * 0.2;

  providersData.push({
    name,
    serviceType,
    specializations: [serviceType + '_general', serviceType + '_premium'],
    location: { latitude, longitude },
    city: 'Islamabad',
    area,
    rating: parseFloat((4.0 + Math.random() * 1.0).toFixed(1)),
    totalReviews: Math.floor(10 + Math.random() * 100),
    onTimeScore: parseFloat((85 + Math.random() * 15).toFixed(1)),
    cancellationRate: parseFloat((Math.random() * 0.1).toFixed(2)),
    riskScore: parseFloat((Math.random() * 15).toFixed(1)),
    isOnline: true,
    isAvailable: Math.random() > 0.3,
    pricePerHour: 500 + Math.floor(Math.random() * 2000),
    experienceYears: 2 + Math.floor(Math.random() * 10),
    certifications: Math.random() > 0.5 ? ['Technical Certified Pro'] : [],
    capacityPerDay: 3 + Math.floor(Math.random() * 4),
    phone: '+923' + Math.floor(100000000 + Math.random() * 900000000)
  });
}

const seedDB = async () => {
  try {
    const mongoURI = process.env.MONGODB_URI || 'mongodb://localhost:27017/orbit';
    await mongoose.connect(mongoURI);
    console.log('✅ Connected to MongoDB for seeding.');

    await Provider.deleteMany({});
    console.log('🗑️ Deleted existing providers.');

    await Provider.insertMany(providersData);
    console.log('🌱 Successfully seeded 30 providers.');

    mongoose.connection.close();
    console.log('🔌 Connection closed.');
  } catch (error) {
    console.error('❌ Seeding failed:', error);
    process.exit(1);
  }
};

seedDB();
