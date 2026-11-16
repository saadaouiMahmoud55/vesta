import React from 'react';
import {
  Image,
  Pressable,
  StyleSheet,
  Text,
  View,
} from 'react-native';
import { AppText } from '../components/AppText';
import { theme } from '../theme';
import { OfferType } from '../../data/models/offerType';
import { RentPeriod } from '../../data/models/listingCategory';
import { OfferTypeBadge } from './OfferTypeBadge';
import { PriceText } from './PriceText';

type Props = {
  title: string;
  city: string;
  price: number;
  currency?: string;
  offerType: OfferType;
  /** Used only for rent and stay. */
  period?: RentPeriod | null;
  /** Cover photo as base64 (JPEG). A placeholder is shown when empty. */
  coverBase64?: string | null;
  unavailable?: boolean;
  onPress?: () => void;
  /** Top corner at the end of the photo (the heart of Favorites). */
  topEnd?: React.ReactNode;
};

/**
 * Twin of ListingCard in Flutter: photo with the offer ribbon, title, city and
 * price with its unit. It only draws: it reads nothing from Firestore.
 */
export function ListingCard({
  title,
  city,
  price,
  currency,
  offerType,
  period,
  coverBase64,
  unavailable,
  onPress,
  topEnd,
}: Props): React.JSX.Element {
  return (
    <Pressable
      accessibilityRole={onPress ? 'button' : undefined}
      onPress={onPress}
      style={styles.card}
    >
      <View style={styles.photo}>
        {coverBase64 ? (
          <Image
            source={{ uri: `data:image/jpeg;base64,${coverBase64}` }}
            style={styles.image}
          />
        ) : null}
        {unavailable ? (
          <>
            <View style={styles.veil} />
            <View style={styles.unavailableWrap}>
              <AppText
                translationKey="favoritesUnavailable"
                style={styles.unavailable}
              />
            </View>
          </>
        ) : null}
        <View style={styles.topStart}>
          <OfferTypeBadge type={offerType} />
        </View>
        {topEnd ? <View style={styles.topEnd}>{topEnd}</View> : null}
      </View>
      <View style={styles.body}>
        <Text numberOfLines={1} style={styles.title}>
          {title}
        </Text>
        <Text numberOfLines={1} style={styles.city}>
          {city}
        </Text>
        <PriceText
          price={price}
          currency={currency}
          period={offerType === 'sale' ? null : period}
        />
      </View>
    </Pressable>
  );
}

const styles = StyleSheet.create({
  card: {
    backgroundColor: theme.colors.white,
    borderColor: theme.colors.border,
    borderRadius: theme.radius.card,
    borderWidth: 1,
    overflow: 'hidden',
  },
  photo: { aspectRatio: 16 / 10, backgroundColor: theme.colors.sand },
  image: { height: '100%', width: '100%' },
  veil: {
    ...StyleSheet.absoluteFill,
    backgroundColor: theme.colors.navy,
    opacity: 0.45,
  },
  unavailableWrap: {
    ...StyleSheet.absoluteFill,
    justifyContent: 'flex-end',
    padding: theme.spacing.sm,
  },
  unavailable: {
    alignSelf: 'flex-start',
    backgroundColor: theme.colors.grey,
    borderRadius: theme.radius.thumb,
    color: theme.colors.white,
    fontSize: theme.fontSizes.small,
    overflow: 'hidden',
    paddingHorizontal: 10,
    paddingVertical: theme.spacing.xs,
  },
  topStart: {
    position: 'absolute',
    start: theme.spacing.sm,
    top: theme.spacing.sm,
  },
  topEnd: {
    position: 'absolute',
    end: theme.spacing.sm,
    top: theme.spacing.sm,
  },
  body: { gap: theme.spacing.xs, padding: theme.spacing.md },
  title: {
    color: theme.colors.navy,
    fontSize: theme.fontSizes.body,
    fontWeight: '600',
  },
  city: { color: theme.colors.grey, fontSize: theme.fontSizes.body },
});
