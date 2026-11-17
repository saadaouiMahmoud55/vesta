import React, { useEffect, useState } from 'react';
import {
  Modal,
  Pressable,
  ScrollView,
  StyleSheet,
  TextInput,
  View,
} from 'react-native';
import { useTranslation } from 'react-i18next';
import { AppText } from '../../core/components/AppText';
import { PrimaryButton } from '../../core/components/PrimaryButton';
import { TextButton } from '../../core/components/TextButton';
import { theme } from '../../core/theme';
import { ListingCategory } from '../../data/models/listingCategory';
import { SearchFilters } from './searchFilters';

export type PanelFilters = {
  minPrice: number | null;
  maxPrice: number | null;
  offerType: ListingCategory | null;
  propertyType: string | null;
};

type Props = {
  visible: boolean;
  filters: SearchFilters;
  onApply: (panel: PanelFilters) => void;
  onClose: () => void;
};

const offerOptions: { key: ListingCategory | null; labelKey: string }[] = [
  { key: null, labelKey: 'searchAll' },
  { key: 'buy', labelKey: 'searchTypeSale' },
  { key: 'rent', labelKey: 'searchTypeRent' },
  { key: 'stay', labelKey: 'searchTypeStay' },
];

/** Same values as propertyTypes in Flutter (listing_repository.dart). */
const propertyOptions: { key: string | null; labelKey: string }[] = [
  { key: null, labelKey: 'searchAll' },
  { key: 'apartment', labelKey: 'searchPropApartment' },
  { key: 'house', labelKey: 'searchPropHouse' },
  { key: 'villa', labelKey: 'searchPropVilla' },
  { key: 'studio', labelKey: 'searchPropStudio' },
  { key: 'riad', labelKey: 'searchPropRiad' },
  { key: 'guest_house', labelKey: 'searchPropGuestHouse' },
];

const digitsOnly = (text: string): string => text.replace(/\D/g, '');
const toNumber = (text: string): number | null =>
  text === '' ? null : Number(text);

type ChipProps = {
  labelKey: string;
  selected: boolean;
  onPress: () => void;
};

function Chip({ labelKey, selected, onPress }: ChipProps): React.JSX.Element {
  return (
    <Pressable
      accessibilityRole="button"
      accessibilityState={{ selected }}
      onPress={onPress}
      style={[styles.chip, selected ? styles.chipOn : null]}
    >
      <AppText
        translationKey={labelKey}
        style={selected ? styles.chipTextOn : null}
      />
    </Pressable>
  );
}

/** Price, offer type and property type. Applied only on "Apply" (as Flutter). */
export function SearchFiltersSheet({
  visible,
  filters,
  onApply,
  onClose,
}: Props): React.JSX.Element {
  const { t } = useTranslation();
  const [min, setMin] = useState('');
  const [max, setMax] = useState('');
  const [offerType, setOfferType] = useState<ListingCategory | null>(null);
  const [propertyType, setPropertyType] = useState<string | null>(null);

  // Each time the panel opens, start from the filters in use.
  useEffect(() => {
    if (visible) {
      setMin(filters.minPrice === null ? '' : String(filters.minPrice));
      setMax(filters.maxPrice === null ? '' : String(filters.maxPrice));
      setOfferType(filters.offerType);
      setPropertyType(filters.propertyType);
    }
  }, [visible, filters]);

  const reset = () => {
    setMin('');
    setMax('');
    setOfferType(null);
    setPropertyType(null);
  };

  const apply = () => {
    onApply({
      minPrice: toNumber(min),
      maxPrice: toNumber(max),
      offerType,
      propertyType,
    });
  };

  return (
    <Modal
      visible={visible}
      transparent
      animationType="slide"
      onRequestClose={onClose}
    >
      <View style={styles.overlay}>
        <Pressable
          accessibilityRole="button"
          accessibilityLabel={t('searchFilters')}
          onPress={onClose}
          style={styles.backdrop}
        />
        <View style={styles.sheet}>
          <ScrollView
            contentContainerStyle={styles.content}
            keyboardShouldPersistTaps="handled"
          >
            <AppText translationKey="searchFilters" style={styles.title} />
            <View style={styles.priceRow}>
              <TextInput
                style={styles.input}
                value={min}
                onChangeText={text => setMin(digitsOnly(text))}
                keyboardType="numeric"
                placeholder={t('searchPriceMin')}
                placeholderTextColor={theme.colors.grey}
              />
              <TextInput
                style={styles.input}
                value={max}
                onChangeText={text => setMax(digitsOnly(text))}
                keyboardType="numeric"
                placeholder={t('searchPriceMax')}
                placeholderTextColor={theme.colors.grey}
              />
            </View>
            <AppText translationKey="searchOfferType" style={styles.label} />
            <View style={styles.chips}>
              {offerOptions.map(option => (
                <Chip
                  key={option.labelKey}
                  labelKey={option.labelKey}
                  selected={offerType === option.key}
                  onPress={() => setOfferType(option.key)}
                />
              ))}
            </View>
            <AppText translationKey="searchPropertyType" style={styles.label} />
            <View style={styles.chips}>
              {propertyOptions.map(option => (
                <Chip
                  key={option.labelKey}
                  labelKey={option.labelKey}
                  selected={propertyType === option.key}
                  onPress={() => setPropertyType(option.key)}
                />
              ))}
            </View>
            <View style={styles.actions}>
              <TextButton labelKey="searchReset" onPress={reset} />
              <PrimaryButton labelKey="searchApply" onPress={apply} />
            </View>
          </ScrollView>
        </View>
      </View>
    </Modal>
  );
}

const styles = StyleSheet.create({
  overlay: { flex: 1, justifyContent: 'flex-end' },
  backdrop: {
    ...StyleSheet.absoluteFill,
    backgroundColor: theme.colors.navy,
    opacity: 0.4,
  },
  sheet: {
    backgroundColor: theme.colors.background,
    borderTopLeftRadius: theme.radius.md,
    borderTopRightRadius: theme.radius.md,
    maxHeight: '85%',
  },
  content: { gap: theme.spacing.md, padding: theme.spacing.md },
  title: {
    color: theme.colors.navy,
    fontSize: theme.fontSizes.title,
    fontWeight: '700',
  },
  label: { color: theme.colors.navy, fontWeight: '600' },
  priceRow: { flexDirection: 'row', gap: theme.spacing.sm },
  input: {
    backgroundColor: theme.colors.white,
    borderColor: theme.colors.border,
    borderRadius: theme.radius.md,
    borderWidth: 1,
    color: theme.colors.navy,
    flex: 1,
    padding: theme.spacing.sm,
  },
  chips: { flexDirection: 'row', flexWrap: 'wrap', gap: theme.spacing.sm },
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
  actions: { gap: theme.spacing.sm },
});
