/**
 * Provider Scoring Algorithm — 8 factors
 */
function scoreProvider(provider, intent, distanceKm, complexity) {
  // Distance score (0–100, 0km=100, 30+km=0)
  const distance = Math.max(0, (1 - distanceKm / 30)) * 100;

  // Availability (binary)
  const availability = (provider.isAvailable && provider.currentBookingsToday < provider.capacityPerDay) ? 100 : 0;

  // Rating score
  const rating = (provider.rating / 5) * 100;

  // Review recency — penalize by riskScore
  const recency = Math.max(0, 100 - (provider.riskScore || 0));

  // On-time score
  const ontime = provider.onTimeScore || 0;

  // Skill specialization
  let skill = 70;
  if (complexity === 'complex' && provider.experienceYears >= 5 && (provider.certifications || []).length > 0) skill = 100;
  else if (complexity === 'intermediate' && (provider.specializations || []).length > 0) skill = 85;
  else if (complexity === 'basic') skill = 80;

  // Price score — depends on budget sensitivity
  let price = 50;
  if (intent.budgetSensitivity === 'high') price = Math.max(0, (1 - provider.pricePerHour / 5000) * 100);
  else if (intent.budgetSensitivity === 'low') price = Math.min(100, (provider.pricePerHour / 5000) * 100 + 50);

  // Cancellation score
  const cancellation = (1 - (provider.cancellationRate || 0)) * 100;

  return { distance, availability, rating, recency, ontime, skill, price, cancellation };
}

module.exports = { scoreProvider };
