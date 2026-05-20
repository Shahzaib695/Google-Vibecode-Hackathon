# ORBIT AI ORCHESTRATOR — FINAL ARCHITECTURE

## 1. System Overview

Orbit is an AI-powered service orchestration platform for Pakistan’s informal economy.

It consists of:
* **Flutter** → UI layer
* **Firebase** → backend + storage
* **Cloud Functions** → business logic execution
* **Antigravity (Vertex AI)** → decision-making engine

---

## 2. AI Orchestration Flow

```text
User Input (Urdu/English/Roman Urdu)
        ↓
Antigravity Intent Parser
        ↓
Provider Matching Engine
        ↓
Dynamic Pricing Engine
        ↓
Scheduling Engine
        ↓
Booking Execution (Firebase)
        ↓
Lifecycle Tracking + Feedback Loop
```

---

## 3. Stitch Role (IMPORTANT CLARIFICATION)

Stitch is used ONLY for:
* UI layout generation
* design system extraction
* screen structuring reference

It is NOT part of runtime execution. UI assets and design tokens were mapped from Stitch output and implemented into the Flutter theme system.

---

## 4. Backend Communication Model

**Flutter → Firebase Cloud Functions → Antigravity Agent**

### Example flow:

```text
Flutter Chat Screen
    ↓
/intent/extract (Cloud Function)
    ↓
Antigravity reasoning engine
    ↓
Firestore logs + response
    ↓
UI updates (Provider Matching Screen)
```

---

## 5. Antigravity Logging System

Every AI decision stores:
* input query
* extracted intent
* provider ranking scores
* pricing breakdown
* fallback decisions
* latency

Stored in:
```text
/antigravityLogs
```
*All AI decisions are traceable and reproducible via Antigravity logs for evaluation transparency.*

---

## 6. Deployment Steps

### Mobile
```bash
flutter pub get
flutter run
```

### Web
```bash
flutter build web --release
firebase deploy
```
