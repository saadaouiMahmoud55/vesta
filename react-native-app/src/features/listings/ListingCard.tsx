import React, { useEffect, useState } from 'react';
import { Image, StyleSheet, Text, View } from 'react-native';
import { AppText } from '../../core/components/AppText';
import { formatPrice } from '../../core/config';
import { theme } from '../../core/theme';
import { isUnavailable, Listing } from '../../data/models/listing';
import {
  FavoritesError,
  FavoritesFailure,
  favoritesErrorKey,
} from '../../data/repositories/favoritesErrors';
import { listingsRepository } from '../../data/repositories/listingsRepository';

type Props = { listing: Listing };

export function ListingCard({ listing }: Props): React.JSX.Element {
  const [cover, setCover] = useState<string | null>(null);
  const [coverError, setCoverError] = useState<FavoritesError | null>(null);
  const unavailable = isUnavailable(listing);

  useEffect(() => {
    let cancelled = false;
    listingsRepository
      .getCoverPhotoBase64(listing.id)
      .then(value => {
        if (!cancelled) {
          setCover(value);
        }
      })
      .catch(failure => {
        if (!cancelled) {
          setCoverError(
            failure instanceof FavoritesFailure ? failure.error : 'unknown',
          );
        }
      });
    return () => {
      cancelled = true;
    };
  }, [listing.id]);

  return (
    <View style={styles.card}>
      <View style={styles.photo}>
        {cover ? (
          <Image
            source={{ uri: `data:image/jpeg;base64,${cover}` }}
            style={styles.image}
            onError={() => setCoverError('unknown')}
          />
        ) : null}
        {unavailable ? (
          <>
            <View style={styles.veil} />
            <View style={styles.badgeWrap}>
              <AppText
                translationKey="favoritesUnavailable"
                style={styles.badge}
              />
            </View>
          </>
        ) : null}
      </View>
      {coverError !== null ? (
        <AppText
          translationKey={favoritesErrorKey(coverError)}
          style={styles.photoError}
        />
      ) : null}
      <View style={styles.body}>
        <Text style={styles.title}>{listing.title}</Text>
        <Text style={styles.city}>{listing.city}</Text>
        <Text style={styles.price}>
          {formatPrice(listing.price, listing.currency || undefined)}
        </Text>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  card: {
    backgroundColor: theme.colors.white,
    borderColor: theme.colors.border,
    borderRadius: theme.radius.md,
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
  badgeWrap: {
    ...StyleSheet.absoluteFill,
    justifyContent: 'flex-end',
    padding: theme.spacing.sm,
  },
  badge: {
    alignSelf: 'flex-start',
    backgroundColor: theme.colors.grey,
    borderRadius: theme.radius.md,
    color: theme.colors.white,
    fontSize: theme.fontSizes.small,
    paddingHorizontal: 10,
    paddingVertical: theme.spacing.xs,
  },
  photoError: {
    color: theme.colors.error,
    fontSize: theme.fontSizes.small,
    paddingHorizontal: theme.spacing.md,
    paddingTop: theme.spacing.sm,
  },
  body: { gap: theme.spacing.xs, padding: theme.spacing.md },
  title: {
    color: theme.colors.navy,
    fontSize: theme.fontSizes.body,
    fontWeight: '600',
  },
  city: { color: theme.colors.grey, fontSize: theme.fontSizes.body },
  price: {
    color: theme.colors.primary,
    fontSize: theme.fontSizes.body,
    fontWeight: '700',
  },
});
