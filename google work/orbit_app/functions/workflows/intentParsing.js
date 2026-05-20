const admin = require('firebase-admin');
const { logToAntigravity } = require('../utils/firestoreHelpers');

const KEYWORDS = {
  ac_technician: ['ac', 'air condition', 'cooling', 'thanda', 'ac service', 'ac wala', 'split ac'],
  plumber: ['plumb', 'pipe', 'leak', 'paani', 'nalka', 'drain', 'paipe'],
  electrician: ['electric', 'bijli', 'light', 'wiring', 'switch', 'electrisian', 'current'],
  beautician: ['beauty', 'salon', 'wax', 'facial', 'makeup', 'parlor'],
  tutor: ['tutor', 'teacher', 'ustaz', 'padhai', 'math', 'science'],
  mechanic: ['mechanic', 'car', 'gaari', 'engine', 'oil change'],
  home_service: ['clean', 'maid', 'cook', 'jadu', 'pochha'],
};

const PAKISTAN_AREAS = [
  'DHA', 'Gulshan', 'North Nazimabad', 'Saddar', 'Clifton',
  'G-13', 'F-10', 'Bahria Town', 'I-8', 'E-11', 'F-7', 'G-11',
  'Gulistan-e-Johar', 'DHA Karachi', 'DHA Islamabad',
];

/**
 * WORKFLOW 1: Multilingual Intent Parsing
 * Handles Urdu, Roman Urdu, English, mixed/code-switched
 */
async function parseIntent(rawText, userId) {
  const startTime = Date.now();
  const lower = rawText.toLowerCase();

  let language = 'english';
  if (/[\u0600-\u06FF]/.test(rawText)) {
    language = 'urdu';
  } else if (/\b(mujhe|chahiye|karo|hai|wala|kal|aaj|abhi|bijli|paani|jaldi)\b/.test(lower)) {
    language = 'roman_urdu';
  }

  // Extract service
  let service = '';
  for (const [svc, keywords] of Object.entries(KEYWORDS)) {
    if (keywords.some(k => lower.includes(k))) { service = svc; break; }
  }

  // Handle ambiguous "bijli"
  let confidence = service ? 85 : 40;
  let clarificationQuestion = null;

  if (lower.includes('bijli') && !lower.includes('wiring') && !lower.includes('switch')) {
    confidence = 55;
    clarificationQuestion = language === 'roman_urdu'
      ? 'Kya aapko electrician chahiye ya light gai hui hai?'
      : 'Do you need an electrician, or is this a power outage?';
  }

  // Extract location
  let location = '';
  for (const area of PAKISTAN_AREAS) {
    if (lower.includes(area.toLowerCase())) { location = area; break; }
  }
  if (!location) {
    if (lower.includes('karachi')) location = 'Karachi';
    else if (lower.includes('islamabad') || lower.includes('isb')) location = 'Islamabad';
    else if (lower.includes('lahore')) location = 'Lahore';
    else { confidence = Math.min(confidence, 60); clarificationQuestion = clarificationQuestion || 'Aapka area kaunsa hai?'; }
  }

  // Urgency
  let urgency = 'standard';
  if (/urgent|emergency|abhi|فوری|jaldi|turant/.test(lower)) urgency = 'emergency';
  else if (/aaj|today|same day/.test(lower)) urgency = 'high';

  // Time
  let preferredTime = 'as_soon_as_possible';
  if (/morning|subah|صبح/.test(lower)) preferredTime = 'tomorrow_morning';
  else if (/evening|sham|شام/.test(lower)) preferredTime = 'evening';
  else if (urgency === 'emergency') preferredTime = 'immediate';

  // Budget
  let budgetSensitivity = 'medium';
  if (/budget nahi|zyada nahi|cheap|sasta|سستا|kam budget/.test(lower)) budgetSensitivity = 'high';
  else if (/best|premium|expert/.test(lower)) budgetSensitivity = 'low';

  const latency = Date.now() - startTime;

  const reasoning = `
ANTIGRAVITY INTENT PARSING — Chain of Thought

Input: "${rawText}"
User ID: ${userId}

Step 1 — Language Detection:
  Detected: ${language}
  Method: Unicode range check + Roman Urdu keyword matching

Step 2 — Service Extraction:
  Service: ${service || 'UNKNOWN'}
  ${!service ? 'WARNING: No service matched. Confidence low.' : 'Matched via keyword analysis against 7 service categories.'}

Step 3 — Location Parsing:
  Location: ${location || 'NOT FOUND'}
  ${!location ? 'ACTION: Requesting clarification from user.' : 'Matched from Pakistan areas dataset.'}

Step 4 — Urgency Classification:
  Urgency: ${urgency}
  Time: ${preferredTime}

Step 5 — Budget Sensitivity:
  Budget: ${budgetSensitivity}

Step 6 — Confidence: ${confidence}/100
  ${confidence < 70 ? 'FALLBACK TRIGGERED: Generating clarification question in user language.' : 'Sufficient confidence to proceed to provider matching.'}

OUTPUT: Intent extraction complete.
`;

  const output = { service, location, urgency, preferredTime, budgetSensitivity, jobDescription: rawText, confidence, language, clarificationQuestion };

  await logToAntigravity({
    stage: 'intent_parsing',
    inputData: { rawText, userId },
    reasoning,
    outputData: output,
    confidenceScore: confidence,
    fallbackTriggered: confidence < 70,
    fallbackReason: confidence < 70 ? 'Low confidence — generating clarification' : null,
    latencyMs: latency,
  });

  return output;
}

module.exports = { parseIntent };
