import React, { useRef, useState } from 'react';
import {
  Alert,
  Linking,
  Pressable,
  StyleSheet,
  Text,
  TextInput,
  View,
} from 'react-native';
import MapView, { Marker, UrlTile } from 'react-native-maps';
import { useTranslation } from 'react-i18next';
import { appConfig, formatPrice } from '../../core/config';
import { AppText } from '../../core/components/AppText';
import { theme } from '../../core/theme';
import { findMe, locationMessageKey } from './locationService';
import { MapPin } from './mapPins';
import { searchPlaces, TunisiaPlace } from './tunisiaPlaces';
import { useMapPins } from './useMapPins';

const osmTiles = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

/** Map of all available listings on OpenStreetMap, with Tunisian city search. */
export function MapScreen(): React.JSX.Element {
  const { t } = useTranslation();
  const { pins, loading, failed, reload } = useMapPins();
  const mapRef = useRef<MapView>(null);
  const [query, setQuery] = useState('');
  const [selected, setSelected] = useState<MapPin | null>(null);
  const suggestions = searchPlaces(query);

  const goTo = (latitude: number, longitude: number, zoom = 0.2) =>
    mapRef.current?.animateToRegion(
      { latitude, longitude, latitudeDelta: zoom, longitudeDelta: zoom },
      400,
    );

  const pickPlace = (place: TunisiaPlace) => {
    setQuery(place.name);
    goTo(place.latitude, place.longitude);
  };

  const showMe = async () => {
    const result = await findMe();
    if (result.status === 'granted') {
      goTo(result.latitude as number, result.longitude as number, 0.05);
      return;
    }
    const key = locationMessageKey(result.status);
    if (key === null) {
      return;
    }
    Alert.alert(
      t(key),
      undefined,
      result.status === 'deniedForever'
        ? [
            { text: t('mapOpenSettings'), onPress: () => Linking.openSettings() },
            { text: 'OK' },
          ]
        : [{ text: 'OK' }],
    );
  };

  return (
    <View style={styles.container}>
      <MapView
        ref={mapRef}
        style={styles.map}
        mapType="none"
        initialRegion={{
          ...appConfig.defaultMapCenter,
          latitudeDelta: 4,
          longitudeDelta: 4,
        }}
        showsUserLocation
        onPress={() => setSelected(null)}
      >
        <UrlTile urlTemplate={osmTiles} maximumZ={19} flipY={false} />
        {pins.map(pin => (
          <Marker
            key={pin.listing.id}
            coordinate={pin}
            onPress={() => setSelected(pin)}
          >
            <View
              style={[
                styles.pin,
                selected?.listing.id === pin.listing.id && styles.pinSelected,
              ]}
            >
              <Text style={[styles.pinText, selected?.listing.id === pin.listing.id && styles.pinTextSelected]}>
                {formatPrice(pin.listing.price, pin.listing.currency || undefined)}
              </Text>
            </View>
          </Marker>
        ))}
      </MapView>

      <View style={styles.top}>
        <TextInput
          value={query}
          onChangeText={setQuery}
          placeholder={t('searchHint')}
          placeholderTextColor={theme.colors.grey}
          style={styles.search}
          autoCorrect={false}
        />
        {suggestions.length > 0 && (
          <View style={styles.suggestions}>
            {suggestions.map(place => (
              <Pressable
                key={place.name}
                onPress={() => pickPlace(place)}
                style={styles.suggestion}
              >
                <Text style={styles.suggestionText}>
                  {place.name} · {place.nameAr}
                </Text>
              </Pressable>
            ))}
          </View>
        )}
      </View>

      <Pressable
        onPress={showMe}
        accessibilityRole="button"
        accessibilityLabel={t('mapMyLocation')}
        style={styles.me}
      >
        <AppText translationKey="mapMyLocation" style={styles.meText} />
      </Pressable>

      {failed && (
        <Pressable onPress={reload} style={styles.banner}>
          <AppText translationKey="favoritesErrorNoNetwork" />
          <AppText translationKey="favoritesRetry" style={styles.retry} />
        </Pressable>
      )}
      {!loading && !failed && pins.length === 0 && (
        <View style={styles.banner}>
          <AppText translationKey="mapNoListings" />
        </View>
      )}
      {selected !== null && (
        <View style={styles.preview}>
          <Text style={styles.previewTitle}>{selected.listing.title}</Text>
          <Text style={styles.previewText}>
            {formatPrice(selected.listing.price, selected.listing.currency || undefined)} · {selected.listing.city}
          </Text>
        </View>
      )}
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: theme.colors.background },
  map: { flex: 1 },
  top: { position: 'absolute', top: theme.spacing.lg, left: theme.spacing.md, right: theme.spacing.md },
  search: {
    backgroundColor: theme.colors.white,
    borderColor: theme.colors.border,
    borderRadius: theme.radius.md,
    borderWidth: 1,
    color: theme.colors.navy,
    fontSize: theme.fontSizes.body,
    paddingHorizontal: theme.spacing.md,
    paddingVertical: theme.spacing.sm,
  },
  suggestions: {
    backgroundColor: theme.colors.white,
    borderRadius: theme.radius.md,
    marginTop: theme.spacing.xs,
    overflow: 'hidden',
  },
  suggestion: { padding: theme.spacing.sm + 4, borderBottomColor: theme.colors.border, borderBottomWidth: 1 },
  pin: {
    backgroundColor: theme.colors.white,
    borderColor: theme.colors.primary,
    borderRadius: theme.radius.lg,
    borderWidth: 2,
    paddingHorizontal: theme.spacing.sm,
    paddingVertical: theme.spacing.xs,
  },
  pinSelected: { backgroundColor: theme.colors.primary },
  pinText: { color: theme.colors.navy, fontSize: theme.fontSizes.small, fontWeight: '700' },
  pinTextSelected: { color: theme.colors.white },
  suggestionText: { color: theme.colors.navy, fontSize: theme.fontSizes.body },
  previewText: { color: theme.colors.navy, fontSize: theme.fontSizes.body },
  me: {
    position: 'absolute',
    right: theme.spacing.md,
    bottom: 120,
    backgroundColor: theme.colors.primary,
    borderRadius: theme.radius.round,
    paddingHorizontal: theme.spacing.md,
    paddingVertical: theme.spacing.sm + 2,
  },
  meText: { color: theme.colors.white, fontSize: theme.fontSizes.small },
  banner: {
    position: 'absolute',
    bottom: theme.spacing.lg,
    left: theme.spacing.md,
    right: theme.spacing.md,
    backgroundColor: theme.colors.white,
    borderRadius: theme.radius.md,
    padding: theme.spacing.md,
  },
  retry: { color: theme.colors.primary, fontWeight: '700' },
  preview: {
    position: 'absolute',
    bottom: theme.spacing.lg,
    left: theme.spacing.md,
    right: theme.spacing.md,
    backgroundColor: theme.colors.white,
    borderRadius: theme.radius.md,
    padding: theme.spacing.md,
    gap: theme.spacing.xs,
  },
  previewTitle: { color: theme.colors.navy, fontSize: theme.fontSizes.body, fontWeight: '700' },
});
