import React from 'react';
import { StyleSheet, Text, TextStyle } from 'react-native';
import { useTranslation } from 'react-i18next';
import { formatPrice } from '../config';
import { theme } from '../theme';
import { RentPeriod } from '../../data/models/listingCategory';
import { periodLabelKey } from '../../data/models/offerType';

type Props = {
  price: number;
  currency?: string;
  /** `rentPeriod` of the listing. Leave it null for a sale (no unit). */
  period?: RentPeriod | null;
  priceStyle?: TextStyle;
  unitStyle?: TextStyle;
};

/** Price with its unit, e.g. `TND 120 / night`. Always left-to-right, also in Arabic. */
export function PriceText({
  price,
  currency,
  period,
  priceStyle,
  unitStyle,
}: Props): React.JSX.Element {
  const { t } = useTranslation();
  const unitKey = periodLabelKey(period);
  return (
    <Text style={styles.line}>
      <Text style={[styles.price, priceStyle]}>
        {formatPrice(price, currency || undefined)}
      </Text>
      {unitKey ? (
        <Text style={[styles.unit, unitStyle]}>{` ${t(unitKey)}`}</Text>
      ) : null}
    </Text>
  );
}

const styles = StyleSheet.create({
  line: { writingDirection: 'ltr', alignSelf: 'flex-start' },
  price: {
    color: theme.colors.primary,
    fontSize: theme.fontSizes.body,
    fontWeight: '700',
  },
  unit: { color: theme.colors.grey, fontSize: theme.fontSizes.small },
});
