import React, { useEffect, useRef, useState } from 'react';
import {
  FlatList,
  Pressable,
  StyleSheet,
  Text,
  TextInput,
  View,
} from 'react-native';
import { useTranslation } from 'react-i18next';
import { AppText } from '../../core/components/AppText';
import { ErrorView } from '../../core/components/ErrorView';
import { LoadingView } from '../../core/components/LoadingView';
import { TextButton } from '../../core/components/TextButton';
import { theme } from '../../core/theme';
import { favoritesErrorKey } from '../../data/repositories/favoritesErrors';
import { useAuth } from '../auth/authController';
import { useFavorites } from '../favorites/favoritesController';
import { ListingCard } from '../listings/ListingCard';
import { PanelFilters, SearchFiltersSheet } from './SearchFiltersSheet';
import { useSearchController } from './searchController';

export function SearchScreen(): React.JSX.Element {
  const { t } = useTranslation();
  const { isSignedIn } = useAuth();
  const search = useSearchController();
  const favorites = useFavorites();
  const [sheetOpen, setSheetOpen] = useState(false);
  const firstRun = useRef(true);
  const { reload } = search;

  // Read the listings again when the user signs in or out (as Flutter).
  useEffect(() => {
    if (firstRun.current) {
      firstRun.current = false;
      return;
    }
    reload();
  }, [isSignedIn, reload]);

  // The city has its own text field: the badge counts the panel filters only.
  const panelCount =
    search.activeCount - (search.filters.city.trim() !== '' ? 1 : 0);

  const applyPanel = (panel: PanelFilters) => {
    search.setPriceRange(panel.minPrice, panel.maxPrice);
    search.setOfferType(panel.offerType);
    search.setPropertyType(panel.propertyType);
    setSheetOpen(false);
  };

  const renderBody = (): React.JSX.Element => {
    if (search.error !== null) {
      return (
        <View style={styles.center}>
          <ErrorView messageKey={favoritesErrorKey(search.error)} />
          <TextButton labelKey="favoritesRetry" onPress={reload} />
        </View>
      );
    }
    if (search.loading && search.results.length === 0) {
      return <LoadingView />;
    }
    return (
      <FlatList
        data={search.results}
        keyExtractor={item => item.id}
        contentContainerStyle={styles.list}
        refreshing={search.loading}
        onRefresh={reload}
        ListEmptyComponent={
          <AppText translationKey="searchNoResults" style={styles.empty} />
        }
        renderItem={({ item }) => {
          const saved = favorites.isFavorite(item.id);
          return (
            <View>
              <ListingCard listing={item} />
              <Pressable
                accessibilityRole="button"
                accessibilityLabel={t('tabFavorites')}
                accessibilityState={{ selected: saved }}
                hitSlop={8}
                onPress={() => favorites.toggle(item.id)}
                style={styles.heart}
              >
                <Text style={saved ? styles.heartOn : styles.heartOff}>
                  {saved ? '♥' : '♡'}
                </Text>
              </Pressable>
            </View>
          );
        }}
      />
    );
  };

  return (
    <View style={styles.screen}>
      <View style={styles.bar}>
        <TextInput
          style={styles.input}
          placeholder={t('searchHint')}
          placeholderTextColor={theme.colors.grey}
          returnKeyType="search"
          autoCorrect={false}
          // The controller waits 400 ms after the last keystroke.
          onChangeText={search.setCity}
        />
        <Pressable
          accessibilityRole="button"
          accessibilityLabel={t('searchFilters')}
          onPress={() => setSheetOpen(true)}
          style={styles.filterButton}
        >
          <AppText translationKey="searchFilters" style={styles.filterText} />
          {panelCount > 0 ? (
            <View style={styles.badge}>
              <Text style={styles.badgeText}>{panelCount}</Text>
            </View>
          ) : null}
        </Pressable>
      </View>
      {favorites.error !== null ? (
        <Pressable accessibilityRole="button" onPress={favorites.clearError}>
          <AppText
            translationKey={favoritesErrorKey(favorites.error)}
            style={styles.favoritesError}
          />
        </Pressable>
      ) : null}
      {renderBody()}
      <SearchFiltersSheet
        visible={sheetOpen}
        filters={search.filters}
        onApply={applyPanel}
        onClose={() => setSheetOpen(false)}
      />
    </View>
  );
}

const styles = StyleSheet.create({
  screen: { backgroundColor: theme.colors.background, flex: 1 },
  center: {
    alignItems: 'center',
    flex: 1,
    gap: theme.spacing.sm,
    justifyContent: 'center',
    padding: theme.spacing.lg,
  },
  bar: {
    alignItems: 'center',
    flexDirection: 'row',
    gap: theme.spacing.sm,
    padding: theme.spacing.md,
  },
  input: {
    backgroundColor: theme.colors.white,
    borderColor: theme.colors.border,
    borderRadius: theme.radius.md,
    borderWidth: 1,
    color: theme.colors.navy,
    flex: 1,
    padding: theme.spacing.sm,
  },
  filterButton: {
    alignItems: 'center',
    borderColor: theme.colors.primary,
    borderRadius: theme.radius.round,
    borderWidth: 1,
    flexDirection: 'row',
    gap: theme.spacing.xs,
    paddingHorizontal: theme.spacing.md,
    paddingVertical: theme.spacing.sm,
  },
  filterText: { color: theme.colors.primary, fontWeight: '600' },
  badge: {
    alignItems: 'center',
    backgroundColor: theme.colors.primary,
    borderRadius: theme.radius.round,
    justifyContent: 'center',
    minWidth: 20,
    paddingHorizontal: theme.spacing.xs,
  },
  badgeText: { color: theme.colors.white, fontSize: theme.fontSizes.small },
  favoritesError: {
    color: theme.colors.error,
    fontSize: theme.fontSizes.small,
    paddingHorizontal: theme.spacing.md,
  },
  list: { gap: theme.spacing.md, padding: theme.spacing.md },
  empty: { color: theme.colors.grey, textAlign: 'center' },
  heart: {
    alignItems: 'center',
    backgroundColor: theme.colors.white,
    borderRadius: theme.radius.round,
    height: 36,
    justifyContent: 'center',
    position: 'absolute',
    right: theme.spacing.sm,
    top: theme.spacing.sm,
    width: 36,
  },
  heartOn: { color: theme.colors.primary, fontSize: 20 },
  heartOff: { color: theme.colors.grey, fontSize: 20 },
});
