import React, { useState } from 'react';
import { FlatList, Pressable, StyleSheet, View } from 'react-native';
import { AppText } from '../../core/components/AppText';
import { ErrorView } from '../../core/components/ErrorView';
import { LoadingView } from '../../core/components/LoadingView';
import { TextButton } from '../../core/components/TextButton';
import { theme } from '../../core/theme';
import {
  categoryOf,
  ListingCategory,
} from '../../data/models/listingCategory';
import { favoritesErrorKey } from '../../data/repositories/favoritesErrors';
import { useAuth } from '../auth/authController';
import { ListingCard } from '../listings/ListingCard';
import { useFavoriteListings } from './favoriteListingsController';
import { useFavorites } from './favoritesController';

const filters: { key: ListingCategory | null; labelKey: string }[] = [
  { key: null, labelKey: 'favoritesFilterAll' },
  { key: 'buy', labelKey: 'favoritesFilterBuy' },
  { key: 'rent', labelKey: 'favoritesFilterRent' },
  { key: 'stay', labelKey: 'favoritesFilterStay' },
];

export function FavoritesScreen(): React.JSX.Element {
  const { isSignedIn } = useAuth();
  const favorites = useFavorites();
  const listings = useFavoriteListings(favorites.ids);
  const [filter, setFilter] = useState<ListingCategory | null>(null);

  if (!isSignedIn) {
    return (
      <View style={styles.center}>
        <AppText translationKey="signInToContinueTitle" style={styles.title} />
        <AppText translationKey="signInToContinueBody" style={styles.body} />
      </View>
    );
  }

  const error = favorites.error ?? listings.error;
  if (error !== null) {
    return (
      <View style={styles.screen}>
        <ErrorView messageKey={favoritesErrorKey(error)} />
        <TextButton
          labelKey="favoritesRetry"
          onPress={() => {
            favorites.retry();
            listings.retry();
          }}
        />
      </View>
    );
  }

  if (favorites.loading || listings.loading) {
    return <LoadingView />;
  }

  if (favorites.ids.length === 0) {
    return (
      <View style={styles.center}>
        <AppText translationKey="favoritesEmptyTitle" style={styles.title} />
        <AppText translationKey="favoritesEmptyBody" style={styles.body} />
      </View>
    );
  }

  const visible = listings.items.filter(
    item =>
      filter === null ||
      (item.listing !== null && categoryOf(item.listing) === filter),
  );

  return (
    <View style={styles.screen}>
      <View style={styles.filters}>
        {filters.map(item => (
          <Pressable
            key={item.labelKey}
            accessibilityRole="button"
            accessibilityState={{ selected: filter === item.key }}
            onPress={() => setFilter(item.key)}
            style={[styles.chip, filter === item.key ? styles.chipOn : null]}
          >
            <AppText
              translationKey={item.labelKey}
              style={filter === item.key ? styles.chipTextOn : null}
            />
          </Pressable>
        ))}
      </View>
      <FlatList
        data={visible}
        keyExtractor={item => item.id}
        contentContainerStyle={styles.list}
        ListEmptyComponent={
          <AppText translationKey="favoritesFilterEmpty" style={styles.body} />
        }
        renderItem={({ item }) => (
          <View style={styles.row}>
            {item.listing !== null ? (
              <ListingCard listing={item.listing} />
            ) : (
              <AppText
                translationKey="favoritesUnavailable"
                style={styles.body}
              />
            )}
            <TextButton
              labelKey="favoritesRemove"
              onPress={() => favorites.toggle(item.id)}
            />
          </View>
        )}
      />
    </View>
  );
}

const styles = StyleSheet.create({
  screen: { backgroundColor: theme.colors.background, flex: 1 },
  center: {
    alignItems: 'center',
    backgroundColor: theme.colors.background,
    flex: 1,
    gap: theme.spacing.sm,
    justifyContent: 'center',
    padding: theme.spacing.lg,
  },
  title: {
    color: theme.colors.navy,
    fontSize: theme.fontSizes.title,
    fontWeight: '700',
    textAlign: 'center',
  },
  body: { color: theme.colors.grey, textAlign: 'center' },
  filters: {
    flexDirection: 'row',
    gap: theme.spacing.sm,
    padding: theme.spacing.md,
  },
  chip: {
    borderColor: theme.colors.border,
    borderRadius: theme.radius.round,
    borderWidth: 1,
    paddingHorizontal: theme.spacing.md,
    paddingVertical: theme.spacing.xs,
  },
  chipOn: {
    backgroundColor: theme.colors.primary,
    borderColor: theme.colors.primary,
  },
  chipTextOn: { color: theme.colors.white },
  list: { gap: theme.spacing.md, padding: theme.spacing.md },
  row: { gap: theme.spacing.xs },
});
