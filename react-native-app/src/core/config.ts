export const appConfig = {
  currency: 'TND',
  defaultMapCenter: { latitude: 36.8065, longitude: 10.1815 },
  supportedLanguages: ['en', 'fr', 'ar'] as const,
  defaultLanguage: 'ar' as const,
  areaUnit: 'm²',
};

export function formatPrice(
  amount: number,
  currency = appConfig.currency,
): string {
  const formatted = new Intl.NumberFormat('en-US', {
    maximumFractionDigits: 0,
  }).format(amount);
  return `${currency} ${formatted}`;
}
