import React from 'react';
import { StyleSheet, ViewStyle } from 'react-native';
import { AppText } from '../components/AppText';
import { theme } from '../theme';
import { OfferType, offerLabelKey } from '../../data/models/offerType';

/** Color of an offer type: stay = blue, rent = navy, sale = terracotta. */
export function offerColor(type: OfferType): string {
  switch (type) {
    case 'stay':
      return theme.colors.primary;
    case 'rent':
      return theme.colors.navy;
    default:
      return theme.colors.terracotta;
  }
}

type Props = { type: OfferType; style?: ViewStyle };

/** Ribbon with the offer type, cream text (twin of OfferTypeBadge in Flutter). */
export function OfferTypeBadge({ type, style }: Props): React.JSX.Element {
  return (
    <AppText
      translationKey={offerLabelKey(type)}
      style={[styles.badge, { backgroundColor: offerColor(type) }, style]}
    />
  );
}

const styles = StyleSheet.create({
  badge: {
    alignSelf: 'flex-start',
    borderRadius: theme.radius.thumb,
    color: theme.colors.background,
    fontSize: theme.fontSizes.small,
    fontWeight: '600',
    overflow: 'hidden',
    paddingHorizontal: theme.spacing.sm,
    paddingVertical: theme.spacing.xs,
  },
});
