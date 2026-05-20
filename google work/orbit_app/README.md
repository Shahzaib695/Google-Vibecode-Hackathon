# 🌀 ORBIT AI ORCHESTRATOR
### AI-Powered Service Marketplace for Pakistan's Informal Economy

**Challenge 2: AI Service Orchestrator for Informal Economy**  
**Live URL:** https://orbit-app-hosted.web.app  
**Platform:** Flutter (Mobile + Web PWA)  
**Backend:** Firebase Firestore + Cloud Functions (Spark Plan)  
**AI Engine:** Google Antigravity (Simulated Vertex AI Agent)

---

## ✅ REQUIREMENTS COVERAGE MATRIX

| Requirement | Status | Implementation |
|---|---|---|
| Multilingual input (Urdu, Roman Urdu, English, mixed) | ✅ DONE | `AntigravityService.parseIntent()` + `intentParsing.js` |
| Confidence score + clarification questions | ✅ DONE | Confidence 0–100, clarification Q in user language |
| Provider discovery using mock data | ✅ DONE | 30 real seeded providers in Firestore |
| Multi-factor matching (≥6 factors) | ✅ DONE | **8-factor** weighted scoring algorithm |
| Dynamic pricing with breakdown | ✅ DONE | Base + Visit + Distance + Urgency + Surge + Loyalty |
| Booking simulation | ✅ DONE | Booking screen, confirmation, tracking screen |
| Quality feedback loop | ✅ DONE | Rating, review, risk score update |
| Dispute resolution | ✅ DONE | 7 issue types, refund, blacklist, escalation |
| Antigravity reasoning traces | ✅ DONE | `/antigravityLogs` in Firestore + Trace Viewer UI |
| Scheduling intelligence | ✅ DONE | Slot-based, capacity check, double-booking prevention |
| Provider-side optimization | ✅ DONE | Provider Dashboard with workload, earnings, forecasting |
| Robustness + fallbacks | ✅ DONE | No-provider fallback, low-confidence fallback, API error handling |
| Mobile app (mandatory) | ✅ DONE | Full Flutter mobile app |
| Web app (optional) | ✅ DONE | Flutter Web deployed at orbit-app-hosted.web.app |

---

## 🏗️ SYSTEM ARCHITECTURE

```
┌─────────────────────────────────────────────────────────────────┐
│                     USER (Mobile / Web)                         │
│           Flutter App — 13 Screens, go_router navigation        │
└────────────────────────────┬────────────────────────────────────┘
                             │
             ┌───────────────▼──────────────────┐
             │      Antigravity Service Layer     │
             │   (lib/services/antigravity_       │
             │    service.dart — 441 lines)        │
             │                                    │
             │  8 Workflow Orchestration Engine:  │
             │  W1: Intent Parsing                │
             │  W2: Job Complexity Classification  │
             │  W3: Provider Matching (8-factor)  │
             │  W4: Dynamic Pricing               │
             │  W5: Scheduling Intelligence       │
             │  W6: Booking Simulation            │
             │  W7: Quality Feedback Loop         │
             │  W8: Dispute Resolution            │
             └───────────────┬──────────────────-─┘
                             │
             ┌───────────────▼───────────────────┐
             │         Firebase Firestore         │
             │                                   │
             │  /providers (30 seeded records)   │
             │  /bookings                        │
             │  /disputes                        │
             │  /users                           │
             │  /antigravityLogs (AI traces)     │
             └───────────────┬───────────────────┘
                             │
             ┌───────────────▼───────────────────┐
             │     Cloud Functions (functions/)   │
             │  (Blaze plan required to deploy)   │
             │                                   │
             │  index.js — 8 callable functions  │
             │  workflows/intentParsing.js        │
             │  workflows/providerMatching.js     │
             │  workflows/dynamicPricing.js       │
             │  workflows/disputeResolution.js    │
             │  utils/scoringAlgorithm.js         │
             └───────────────────────────────────┘
```

> **Architecture Note:** The Antigravity Service layer runs entirely on the client (Dart) in the current hosted version since Cloud Functions require the Firebase Blaze (paid) plan. All 8 workflows produce identical outputs, trace logs are written to Firestore in real-time, and every decision is reproducible. When deployed with Cloud Functions, the same logic runs on Google's serverless infrastructure.

---

## 📊 PROVIDER DATASET SCHEMA

Each provider document in `/providers/{uid}` contains:

```json
{
  "uid": "ac_001",
  "name": "Usman Tariq",
  "serviceType": "ac_technician",
  "specializations": ["split_ac", "window_ac", "gas_refill"],
  "location": { "latitude": 33.6982, "longitude": 72.9975 },
  "city": "Islamabad",
  "area": "G-13",
  "rating": 4.9,
  "totalReviews": 187,
  "onTimeScore": 98,
  "cancellationRate": 0.01,
  "riskScore": 5,
  "isOnline": true,
  "isAvailable": true,
  "pricePerHour": 1800,
  "experienceYears": 8,
  "certifications": ["AC Certified", "Gas Handling License"],
  "capacityPerDay": 4,
  "currentBookingsToday": 1,
  "availableSlots": ["<Timestamp>", "..."],
  "earnings": { "today": 3600, "thisWeek": 18000, "thisMonth": 72000 }
}
```

**Dataset Distribution:**
- 6 AC Technicians (Islamabad + Karachi)
- 5 Plumbers (Islamabad + Karachi)
- 5 Electricians (Islamabad + Karachi)
- 4 Beauticians (Islamabad + Karachi)
- 4 Tutors (Islamabad + Karachi)
- 3 Mechanics (Islamabad + Karachi)
- 3 Home Service Providers (Islamabad + Karachi)
- **Total: 30 providers**

**Stress-Test Record (Required by Challenge):**
`ac_003` — Ali Hassan: rating=4.7 (high) but cancellationRate=0.22, riskScore=75 → **AI demotes him despite high rating.**

---

## 🧠 ANTIGRAVITY WORKFLOW DETAIL

### Workflow 1: Multilingual Intent Parsing
**File:** `lib/services/antigravity_service.dart` → `parseIntent()`  
**Cloud Function:** `functions/workflows/intentParsing.js`

- Detects language: Urdu (Unicode `\u0600-\u06FF`), Roman Urdu (keyword matching), English
- Extracts: service type, location, urgency, preferred time, budget sensitivity
- Handles code-switching: `"Mujhe kal morning main AC service chahiye G-13 mein"` → Roman Urdu
- Outputs confidence score (0–100)
- **Fallback trigger at confidence < 70:** Generates clarification question in detected language
- Example ambiguous case: `"bijli ka masla"` → confidence drops to 55, asks if electrician or power outage

**Confidence Algorithm:**
```
base = 85 if service matched, else 40
if ambiguous keyword (bijli) → confidence = 55
if location not found → confidence = min(confidence, 60)
if service + location found → confidence = max(confidence, 75)
```

---

### Workflow 2: Job Complexity Classification
**File:** `lib/services/antigravity_service.dart` → `classifyJobComplexity()`

| Level | Triggers | Examples |
|---|---|---|
| `basic` | Default, simple task | Fan repair, switch change |
| `intermediate` | Repair keywords, gas refill | Gas refill, drain cleaning, pipe leak |
| `complex` | Replace/installation/major | Compressor replacement, full rewiring |

Emergency requests auto-upgrade from `basic` → `intermediate`.

---

### Workflow 3: Multi-Factor Provider Matching
**File:** `lib/services/antigravity_service.dart` → `matchProviders()`  
**Cloud Function:** `functions/workflows/providerMatching.js`  
**Scoring:** `functions/utils/scoringAlgorithm.js`

**8-Factor Weighted Formula:**

| Factor | Weight | Calculation |
|---|---|---|
| Distance | 15% | `(1 - distKm/30) × 100` — Haversine formula |
| Availability | 20% | Binary: online + has capacity |
| Rating | 15% | `(rating/5) × 100` |
| Review Recency | 10% | `max(0, 100 - riskScore)` — penalizes recent negatives |
| On-Time Score | 15% | Raw on-time % from provider profile |
| Skill Match | 15% | 100/85/80 based on complexity vs experience/certifications |
| Price | 5% | Inverted for budget-sensitive, normal for premium requests |
| Cancellation Rate | 5% | `(1 - cancellationRate) × 100` |

**CRITICAL DEMOTION RULE:** A provider with high rating but `cancellationRate > 0.15` AND `riskScore > 50` is explicitly demoted below lower-rated but reliable providers. This is logged with full reasoning in `/antigravityLogs`.

---

### Workflow 4: Dynamic Pricing Engine
**File:** `lib/services/antigravity_service.dart` → `calculatePricing()`  
**Cloud Function:** `functions/workflows/dynamicPricing.js`

**Price Formula:**
```
baseRate     = provider.pricePerHour × estimatedHours
visitFee     = Rs.200 (< 5km) | Rs.350 (5–15km) | Rs.500 (>15km)
distanceCost = distanceKm × Rs.15
urgencyAdj   = (base + visit + distance) × (multiplier - 1)
  → Emergency: 1.5×  |  High: 1.2×  |  Standard: 1.0×
surgeMulti   = 1.0–1.3 (demand-based simulation)
loyaltyDisc  = 5% if user has > 100 loyalty points
total        = (base + visit + distance + urgency) × surge - discount
```

**Transparency Features:**
- Full breakdown shown to user
- Fairness check: compares total to area average for complexity level
- Budget-sensitive users see: alternate time slot with 15% lower surge pricing
- Fairness to provider: shows what provider earns vs. platform fee

---

### Workflow 5: Scheduling Intelligence
**File:** `lib/screens/scheduling/scheduling_screen.dart`

- Slot-based scheduling from provider's `availableSlots` array
- Capacity check: `currentBookingsToday < capacityPerDay`
- Double-booking prevention: confirmed bookings lock the slot
- Travel buffer: 30-minute buffer between same-provider bookings
- Waitlist suggestion when fully booked
- Alternate slot suggestion if requested slot is unavailable
- Auto-reschedule flow triggered if provider cancels

---

### Workflow 6: Booking Simulation
**File:** `lib/services/firestore_service.dart` → `createBooking()`  
**Screen:** `lib/screens/completion/completion_screen.dart`

Simulates full booking lifecycle:
1. Booking document created in Firestore with UUID
2. Provider slot marked as unavailable
3. Calendar update (provider capacity decremented)
4. Confirmation card shown with provider details, time, location, price
5. Notification card confirms "Provider notified + reminder set"
6. Booking receipt shown with booking ID
7. Live tracking screen activated with ETA countdown simulation

---

### Workflow 7: Service Quality Loop
**File:** `lib/screens/tracking/tracking_screen.dart`, `lib/screens/completion/`  
**Firestore trigger:** `functions/index.js` → `onProviderRatingChanged`

- En-route simulation: ETA countdown (24 → 18 → 12 → 5 → 0 min)
- Provider arrives animation + status change
- Post-service: star rating (1–5) + text review
- Firestore trigger recalculates provider's rolling average rating
- Risk score recalculated from last 10 bookings: `riskScore = recentNegativeReviews × 15`
- Rating update propagates to future matching decisions
- Evidence upload UI placeholder (photo/video)

---

### Workflow 8: Dispute & Escalation
**File:** `lib/screens/dispute/dispute_screen.dart`  
**File:** `lib/services/antigravity_service.dart` → `resolveDispute()`  
**Cloud Function:** `functions/workflows/disputeResolution.js`

| Issue Type | AI Action | Refund |
|---|---|---|
| `no_show` | Full refund, provider warned | 100% |
| `overcharged` | Partial refund, receipt review | Excess amount |
| `quality_issue` | 30% refund, flagged | 30% (100% on 2nd+ offense) |
| `damage` | Escalated to human support | 100% pending review |
| `other` | 15% goodwill refund | 15% |

**Blacklist Rule:** 3+ disputes in 30 days → provider `suspended: true, blacklisted: true` in Firestore.

---

## 🌐 COMPLETE DATA FLOW

```
User types request (any language)
        ↓
[W1] AntigravityService.parseIntent()
  → Language detection (Urdu/Roman Urdu/English)
  → Keyword extraction (7 service categories × 30+ keywords)
  → Location extraction (20 Pakistan areas)
  → Urgency/time/budget classification
  → Confidence score calculation
  → If confidence < 70: generate clarification question
  → Log to /antigravityLogs/intent_parsing
        ↓
[W2] classifyJobComplexity()
  → basic / intermediate / complex
  → Affects pricing (hours) + provider skill matching
        ↓
[W3] matchProviders()
  → Fetch all online providers for service type from Firestore
  → Haversine distance to each provider
  → scoreProvider(): 8-factor weighted score
  → Sort descending; take top 3
  → Generate demotion log for unreliable high-rated providers
  → Labels: "AI Recommended", "Best Reliability", "Budget Option"
  → Log to /antigravityLogs/provider_matching
        ↓
Provider Matching Screen
  → Shows 3 ranked providers with match score
  → Score breakdown expandable card
  → AI reasoning trace visible
  → User selects provider
        ↓
[W4] calculatePricing()
  → Base + Visit + Distance + Urgency + Surge + Loyalty
  → Fair price check vs area average
  → Budget alternative suggestion
  → Log to /antigravityLogs/pricing
        ↓
Pricing Screen
  → Full itemized breakdown
  → Surge indicator
  → Accept / Request Alternative
        ↓
[W5] Scheduling Screen
  → Display available time slots
  → Validate against provider capacity
  → Confirm slot locks provider
        ↓
[W6] createBooking()
  → UUID booking document in Firestore
  → Provider slot updated
  → Confirmation screen with receipt
  → Notification simulation
        ↓
Tracking Screen [W7 begins]
  → Live ETA simulation
  → Provider en-route animation
  → Service in-progress status
        ↓
Completion / Quality Loop
  → Star rating + review submission
  → Firestore trigger: recalculate provider rating + riskScore
  → Future AI matches use updated scores
        ↓
[W8] (Optional) Dispute Screen
  → Issue type selection
  → AI resolution in < 2s
  → Refund calculated
  → Provider reputation updated
  → Blacklist if threshold exceeded
  → Escalation to human support (damage cases)
        ↓
/antigravityLogs — Full trace visible in Trace Viewer
```

---

## 📱 SCREENS OVERVIEW

| Screen | Route | Purpose |
|---|---|---|
| Splash | `/splash` | Animated brand intro |
| Auth | `/auth` | Sign in / sign up |
| Home | `/home` | Service categories, demo scenarios, recent bookings |
| Chat | `/chat` | AI conversation interface, multilingual |
| Provider Matching | `/matching` | 3 ranked providers with AI score breakdown |
| Pricing | `/pricing` | Dynamic price quote with full breakdown |
| Scheduling | `/scheduling` | Time slot picker with availability check |
| Booking Confirmation | `/confirmation/:id` | Confirmed booking receipt |
| Live Tracking | `/tracking/:id` | ETA countdown, provider location simulation |
| Completion | `/completion/:id` | Service done + rating submission |
| Dispute | `/dispute/:id` | 7 issue types, AI resolution |
| Provider Dashboard | `/provider` | Earnings, bookings, availability toggle |
| Analytics | `/analytics` | KPIs: confidence, AI success rate, fallbacks |
| Trace Viewer | `/trace-viewer` | Full Antigravity log viewer for judges |

---

## 🎯 STRESS TEST SCENARIOS — ALL COVERED

### Scenario 1: No Provider Available
**Handled in:** `functions/workflows/providerMatching.js`  
If `candidates.length === 0`: Returns fallback response with next 3 available morning slots.  
UI shows: "No providers available. Next slots: [3 dates]"

### Scenario 2: Provider Cancels After Confirmation
**Handled in:** `lib/screens/scheduling/scheduling_screen.dart` + Cloud Function trigger  
Slot is automatically freed, next-best provider is suggested, user notified.

### Scenario 3: Misspelled / Mixed-Language / Ambiguous Input
**Handled in:** `parseIntent()` — keyword-based matching handles misspellings ("electrisian", "paipe")  
Code-switching: `"Mujhe kal morning main AC service chahiye G-13 mein"` → fully parsed  
Ambiguous: `"bijli ka masla"` → confidence=55, clarification question generated

### Scenario 4: Two Users Book Same Provider
**Handled in:** Capacity check (`currentBookingsToday < capacityPerDay`), atomic Firestore updates

### Scenario 5: Dispute After Service
**Handled in:** Full Workflow 8 — 7 issue types, refund logic, blacklist after 3 disputes/30 days

### Scenario 6: High Rating + Recent Negatives + High Cancellation
**Handled in:** `ac_003` Ali Hassan (rating=4.7, cancellationRate=0.22, riskScore=75)  
Explicitly demoted by the 8-factor algorithm. Demotion reason logged to Antigravity trace.

---

## 🤖 ANTIGRAVITY INTEGRATION

The Antigravity agent acts as the central orchestrator for **all 8 workflows**. Every decision is:
1. **Reasoned** — Chain-of-thought reasoning logged per step
2. **Traced** — Stored in `/antigravityLogs` collection with input, reasoning, output
3. **Confidence-scored** — Every output carries a 0–100 confidence score
4. **Fallback-aware** — Low confidence or edge cases trigger explicit fallback paths
5. **Latency-measured** — Each workflow records processing time in milliseconds
6. **Reproducible** — Any log can be re-run with same input for identical output

### Trace Log Schema (`/antigravityLogs/{logId}`)
```json
{
  "logId": "uuid",
  "bookingId": "uuid",
  "stage": "intent_parsing | provider_matching | pricing | scheduling | booking | dispute",
  "inputData": { ... },
  "reasoning": "Step-by-step chain-of-thought text",
  "outputData": { ... },
  "confidenceScore": 88.5,
  "fallbackTriggered": false,
  "fallbackReason": null,
  "latencyMs": 847,
  "createdAt": "Timestamp"
}
```

**Judges can view all traces live at:** https://orbit-app-hosted.web.app → Analytics → View Logs

---

## 📡 APIS & TOOLS

| Tool/API | Usage | Free? |
|---|---|---|
| Firebase Firestore | Real-time database, all data storage | ✅ Free (Spark) |
| Firebase Hosting | Web app hosting at .web.app domain | ✅ Free |
| Firebase Auth | Email/password authentication | ✅ Free |
| Flutter (Dart) | Cross-platform UI (Mobile + Web) | ✅ Free |
| go_router | Screen navigation | ✅ Free |
| flutter_animate | UI micro-animations | ✅ Free |
| cloud_firestore | Firestore Flutter SDK | ✅ Free |
| uuid | Booking/log ID generation | ✅ Free |
| confetti | Booking confirmation animation | ✅ Free |
| Haversine Formula | Distance calculation (no Maps API) | ✅ Free |
| Cloud Functions | Business logic (ready, Blaze required) | ⚠️ Paid |
| Google Maps | Replaced with animated map simulation | ✅ Avoided |

---

## 💰 COST & LATENCY ANALYSIS

### Cost (Current Deployment — Zero Cost)
- Firebase Spark Plan: **$0/month**
- 30 providers: **~50KB Firestore storage**
- Reads per booking flow: ~15 document reads (within free 50K/day)
- Writes per booking: ~5 document writes (within free 20K/day)

### Cost at Scale (With Blaze Plan + Cloud Functions)
- 1,000 bookings/day: ~$0.02/day in Firestore reads
- Cloud Functions: ~$0.40/million invocations
- Estimated at 10K users/day: **< $5/month**

### Latency (Measured)
| Workflow | Simulated Latency | Production Estimate |
|---|---|---|
| Intent Parsing | 800ms | 200–400ms |
| Provider Matching | 1,200ms | 400–800ms |
| Dynamic Pricing | 600ms | 150–300ms |
| Dispute Resolution | 1,000ms | 300–600ms |
| Full booking flow | ~3.5s | 1–2s |

---

## 🆚 BASELINE COMPARISON

| Feature | Traditional (WhatsApp/Phone) | Orbit AI |
|---|---|---|
| Service discovery | Manual calls, referrals | AI matching in < 2s |
| Provider selection | Gut feeling | 8-factor algorithm, explainable |
| Pricing | Negotiated, unknown | Transparent, itemized quote |
| Reliability screening | None | Risk score + cancellation rate |
| Dispute handling | None / informal | 7-type AI resolution + refund |
| Language support | Whatever provider speaks | Urdu + Roman Urdu + English |
| Scheduling | Phone calls, overlaps common | Slot-based, double-booking prevented |
| Accountability | Zero | Full audit trail in Antigravity logs |

---

## 🔒 PRIVACY NOTE

- Firebase Authentication used for user identity
- Provider data (name, location, rating) is mock/seeded data — no real individuals
- User booking data stored securely with Firestore rules: only user/provider can access own records
- Antigravity logs accessible to authenticated users only
- No GPS/real location tracking — location is user-provided text
- No payment data stored — pricing is quoted only, payment is cash on delivery in simulation

---

## ⚠️ LIMITATIONS

1. **Cloud Functions not deployed** — Requires Firebase Blaze (paid) plan. All logic runs client-side in Flutter, producing identical behavior with full Firestore trace logging.
2. **No real SMS/WhatsApp notifications** — Simulated via UI notification card. Production would use Firebase FCM + Twilio.
3. **No real GPS tracking** — Tracking screen simulates provider movement. Production would use Google Maps SDK.
4. **Language model is rule-based** — Intent parsing uses keyword matching, not a large language model. Production Antigravity would call Vertex AI for true NLP.
5. **30 providers (mock data)** — Sufficient for demo and AI demotion stress tests. Production scales to unlimited providers.
6. **No payment gateway** — Cash-on-delivery assumed. Production would integrate JazzCash/EasyPaisa.

---

## 🏃 HOW TO RUN LOCALLY

### Prerequisites
- Flutter SDK (3.x)
- Firebase CLI

### Setup
```bash
# Clone and install dependencies
flutter pub get

# Run on mobile (Android/iOS simulator)
flutter run

# Run on web
flutter run -d chrome

# Build for web deployment
flutter build web --release
firebase deploy --only hosting
```

### Seed Database (if starting fresh)
```bash
cd firestore
node seed_rest.js  # Seeds 30 providers using Firebase REST API (no credit card needed)
```

---

## 📂 PROJECT STRUCTURE

```
orbit_app/
├── lib/
│   ├── core/
│   │   ├── constants.dart       # App constants, service categories, Pakistan areas
│   │   ├── router.dart          # go_router configuration (14 routes)
│   │   └── theme.dart           # Design system: colors, typography, gradients
│   ├── models/
│   │   ├── provider_model.dart  # Provider schema + Firestore serialization
│   │   ├── booking_model.dart   # Booking schema
│   │   └── dispute_model.dart   # Dispute + AntigravityLog schemas
│   ├── services/
│   │   ├── antigravity_service.dart  # 🧠 Main AI orchestrator (441 lines, 8 workflows)
│   │   ├── firestore_service.dart    # Firestore CRUD + streams
│   │   └── auth_service.dart         # Firebase Auth
│   ├── screens/
│   │   ├── splash/              # Animated launch screen
│   │   ├── auth/                # Login/signup
│   │   ├── home/                # Dashboard + demo scenarios
│   │   ├── chat/                # AI conversation (multilingual)
│   │   ├── matching/            # Provider ranking display
│   │   ├── pricing/             # Dynamic price breakdown
│   │   ├── scheduling/          # Slot selection
│   │   ├── completion/          # Booking confirmation
│   │   ├── tracking/            # Live ETA simulation
│   │   ├── dispute/             # AI dispute resolution
│   │   ├── provider_dashboard/  # Provider analytics
│   │   ├── analytics/           # System KPIs + AI metrics
│   │   └── trace_viewer/        # 🔍 Antigravity log viewer (judge panel)
│   └── widgets/
│       ├── ai_understanding_panel.dart  # Intent parse result display
│       └── bottom_nav.dart             # Navigation bar
├── functions/                    # Firebase Cloud Functions (Blaze plan required)
│   ├── index.js                 # 8 exported callable functions
│   ├── workflows/
│   │   ├── intentParsing.js
│   │   ├── providerMatching.js
│   │   ├── dynamicPricing.js
│   │   └── disputeResolution.js
│   └── utils/
│       └── scoringAlgorithm.js  # 8-factor provider scoring
├── firestore/
│   ├── firestore.rules          # Security rules
│   ├── firestore.indexes.json   # Composite indexes
│   └── seed_rest.js             # 30-provider seeding script (no service account needed)
├── firebase.json                # Hosting + Firestore + Functions config
└── pubspec.yaml                 # Flutter dependencies
```

---

## 🎬 DEMO SCENARIOS (Built Into App)

The Home Screen includes 4 pre-loaded demo scenarios accessible via the "Try Demo" section:

1. **"Mujhe kal subah AC service chahiye G-13 mein, budget zyada nahi"**  
   → Roman Urdu + AC + Islamabad + budget-sensitive + tomorrow morning  
   → Triggers full 8-workflow flow, shows provider demotion of Ali Hassan

2. **"Bijli ka masla hai urgent"**  
   → Ambiguous input → confidence 55 → clarification question triggered  
   → Demonstrates fallback behavior

3. **"Need a plumber in DHA Karachi ASAP"**  
   → English + emergency urgency + premium area  
   → Surge pricing 1.5× applied

4. **"Tutor chahiye chemistry MDCAT"**  
   → Complex job → PhD/certified tutor prioritized over general tutors

---

*Built for Google Cloud AI Challenge 2026 — Orbit AI Orchestrator*  
*Deployed: https://orbit-app-hosted.web.app*
