import { formatPrice } from '../src/core/config';

describe('formatPrice', () => {
  it('formats amounts with the currency prefix and thousands separators', () => {
    expect(formatPrice(450000)).toBe('TND 450,000');
  });
});
