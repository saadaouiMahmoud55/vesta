import React, { useCallback } from 'react';
import { ActivityIndicator, FlatList, StyleSheet, View } from 'react-native';
import {
  NavigationProp,
  useFocusEffect,
  useNavigation,
} from '@react-navigation/native';
import { useTranslation } from 'react-i18next';
import { appConfig, formatPrice } from '../../core/config';
import { AppText } from '../../core/components/AppText';
import { PrimaryButton } from '../../core/components/PrimaryButton';
import { changeAppLanguage } from '../../core/i18n';
import { useAuth } from '../auth/authController';
import { theme } from '../../core/theme';
import { ListingCard } from '../../core/ui/ListingCard';
import { Listing, isUnavailable } from '../../data/models/listing';
import { offerTypeOf } from '../../data/models/offerType';
import { MainStackParamList } from '../../navigation/MainStack';
import { useCoverPhoto } from './coverPhotos';
import { useLatestListings } from './useLatestListings';

const languageKeys = {
  en: 'languageEn',
  fr: 'languageFr',
  ar: 'languageAr',
} as const;

function ListingItem({
  listing,
  onPress,
}: {
  listing: Listing;
  onPress: () => void;
}): React.JSX.Element {
  const cover = useCoverPhoto(listing.id);
  return (
    <ListingCard
      title={listing.title}
      city={listing.city}
      price={listing.price}
      currency={listing.currency}
      offerType={offerTypeOf(listing)}
      period={listing.rentPeriod}
      coverBase64={cover}
      unavailable={isUnavailable(listing)}
      onPress={onPress}
    />
  );
}

const Separator = (): React.JSX.Element => <View style={styles.separator} />;

export function HomeScreen(): React.JSX.Element {
  const { t } = useTranslation();
  const { signOut } = useAuth();
  const navigation = useNavigation<NavigationProp<MainStackParamList>>();
  const { listings, loading, refreshing, errorKey, reload } =
    useLatestListings();

  // Read the listings again each time the tab gets the focus (after a publish).
  useFocusEffect(
    useCallback(() => {
      reload();
    }, [reload]),
  );

  let empty: React.JSX.Element;
  if (loading) {
    empty = <ActivityIndicator color={theme.colors.primary} />;
  } else if (errorKey) {
    empty = (
      <View style={styles.message}>
        <AppText translationKey={errorKey} />
        <PrimaryButton labelKey="favoritesRetry" onPress={() => reload()} />
      </View>
    );
  } else {
    empty = <AppText translationKey="listingsEmpty" style={styles.empty} />;
  }

  const header = (
    <View style={styles.header}>
      <AppText translationKey="appName" style={styles.title} />
      <AppText
        translationKey="homePriceExample"
        values={{ price: formatPrice(450000) }}
      />
      <AppText translationKey="languageLabel" style={styles.languageLabel} />
      <View style={styles.languages}>
        {appConfig.supportedLanguages.map(language => (
          <PrimaryButton
            key={language}
            labelKey={languageKeys[language]}
            onPress={() => changeAppLanguage(language)}
            accessibilityLabel={t('languageLabel')}
          />
        ))}
      </View>
      <PrimaryButton
        labelKey="publishButton"
        onPress={() => navigation.navigate('PublishListing')}
      />
      {/* Temporary: opens the chat list until the chat has its own tab. */}
      <PrimaryButton
        labelKey="chatTitle"
        onPress={() => navigation.navigate('ChatList')}
      />
      {/* Temporary: the profile and settings screens will own Log out. */}
      <PrimaryButton labelKey="authLogoutButton" onPress={() => signOut()} />
    </View>
  );

  return (
    <FlatList
      style={styles.screen}
      contentContainerStyle={styles.container}
      data={listings}
      keyExtractor={item => item.id}
      ListHeaderComponent={header}
      ListEmptyComponent={empty}
      ItemSeparatorComponent={Separator}
      refreshing={refreshing}
      onRefresh={() => reload(true)}
      renderItem={({ item }) => (
        <ListingItem
          listing={item}
          onPress={() =>
            navigation.navigate('ListingDetails', { listingId: item.id })
          }
        />
      )}
    />
  );
}
const styles = StyleSheet.create({
  screen: { backgroundColor: theme.colors.background },
  container: { flexGrow: 1, padding: theme.spacing.lg },
  header: {
    alignItems: 'center',
    gap: theme.spacing.lg,
    paddingBottom: theme.spacing.lg,
  },
  title: {
    color: theme.colors.primary,
    fontSize: theme.fontSizes.heading,
    fontWeight: '700',
  },
  languageLabel: { marginTop: theme.spacing.lg },
  languages: { flexDirection: 'row', gap: theme.spacing.sm },
  separator: { height: theme.spacing.md },
  message: { alignItems: 'center', gap: theme.spacing.lg },
  empty: { textAlign: 'center' },
});
