export const theme = {
  colors: {
    primary: '#176AAB',
    navy: '#20394A',
    grey: '#6B777B',
    border: '#E5E5DF',
    sand: '#F0E7DA',
    terracotta: '#A65D42',
    white: '#FFFFFF',
    background: '#FAF8F4',
    error: '#A33B32',
  },
  fontSizes: { small: 14, body: 16, title: 24, heading: 30 },
  spacing: { xs: 4, sm: 8, md: 16, lg: 24, xl: 32 },
  radius: {
    sm: 6,
    md: 12,
    lg: 20,
    round: 999,
    // Same names and values as AppRadius in Flutter.
    card: 16,
    row: 14,
    thumb: 12,
    field: 10,
    pill: 999,
  },
} as const;
