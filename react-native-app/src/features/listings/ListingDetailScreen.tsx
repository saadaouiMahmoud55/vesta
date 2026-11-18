import React from 'react';
import { ActivityIndicator, ScrollView, StyleSheet, Text, View } from 'react-native';
import { NativeStackScreenProps } from '@react-navigation/native-stack';
import { AppText } from '../../core/components/AppText';
import { PrimaryButton } from '../../core/components/PrimaryButton';
import { theme } from '../../core/theme';
import { OfferTypeBadge } from '../../core/ui/OfferTypeBadge';
import { PriceText } from '../../core/ui/PriceText';
import { isUnavailable } from '../../data/models/listing';
import { offerTypeOf } from '../../data/models/offerType';
import { MainStackParamList } from '../../navigation/MainStack';
import { ContactButtons } from './ContactButtons';
import { PhotoGallery } from './PhotoGallery';
import { useListingDetail } from './useListingDetail';

type Props = NativeStackScreenProps<MainStackParamList, 'ListingDetails'>;

/**
 * Details of one listing (VST-39 part 2): photos, offer ribbon, price, title,
 * city and description. Read only. Key facts, amenities, check-in/out and
 * house rules come with VST-82; contact and chat with their own tickets.
 */
export function ListingDetailScreen({ route }: Props): React.JSX.Element {
  const { state, retry } = useListingDetail(route.params.listingId);

  if (state.status === 'loading') {
    return (
      <View style={styles.center}>
        <ActivityIndicator color={theme.colors.primary} />
      </View>
    );
  }
  if (state.status === 'notFound') {
    return <Message translationKey="listingDetailNotFound" />;
  }
  if (state.status === 'error') {
    return <Message translationKey="listingDetailLoadError" onRetry={retry} />;
  }

  const { listing, photos } = state;
  const offerType = offerTypeOf(listing);
  return (
    <ScrollView style={styles.screen}>
      <PhotoGallery photos={photos} />
      {isUnavailable(listing) ? (
        <View style={styles.unavailable}>
          <AppText
            translationKey="favoritesUnavailable"
            style={styles.unavailableText}
          />
        </View>
      ) : null}
      <View style={styles.body}>
        <OfferTypeBadge type={offerType} />
        <PriceText
          price={listing.price}
          currency={listing.currency}
          period={offerType === 'sale' ? null : listing.rentPeriod}
          priceStyle={styles.price}
        />
        <Text style={styles.title}>{listing.title}</Text>
        <Text style={styles.city}>{listing.city}</Text>
        <ContactButtons listing={listing} onSignInPress={() => undefined} />
        <Text style={styles.description}>{listing.description}</Text>
      </View>
    </ScrollView>
  );
}

function Message({
  translationKey,
  onRetry,
}: {
  translationKey: string;
  onRetry?: () => void;
}): React.JSX.Element {
  return (
    <View style={styles.center}>
      <AppText translationKey={translationKey} style={styles.message} />
      {onRetry ? <PrimaryButton labelKey="favoritesRetry" onPress={onRetry} /> : null}
    </View>
  );
}

const styles = StyleSheet.create({
  screen: { backgroundColor: theme.colors.background, flex: 1 },
  center: {
    alignItems: 'center',
    backgroundColor: theme.colors.background,
    flex: 1,
    gap: theme.spacing.lg,
    justifyContent: 'center',
    padding: theme.spacing.lg,
  },
  message: { textAlign: 'center' },
  unavailable: {
    backgroundColor: theme.colors.grey,
    paddingHorizontal: theme.spacing.md,
    paddingVertical: theme.spacing.sm,
  },
  unavailableText: { color: theme.colors.white, fontSize: theme.fontSizes.small },
  body: { gap: theme.spacing.sm, padding: theme.spacing.lg },
  price: { fontSize: theme.fontSizes.heading },
  title: {
    color: theme.colors.navy,
    fontSize: theme.fontSizes.body,
    fontWeight: '700',
  },
  city: { color: theme.colors.grey, fontSize: theme.fontSizes.body },
  description: {
    color: theme.colors.navy,
    fontSize: theme.fontSizes.body,
    marginTop: theme.spacing.md,
  },
});
