import React, { useState } from 'react';
import {
  Image,
  Pressable,
  ScrollView,
  StyleSheet,
  Switch,
  View,
} from 'react-native';
import { NativeStackScreenProps } from '@react-navigation/native-stack';
import { AppText } from '../../core/components/AppText';
import { AppTextField } from '../../core/components/AppTextField';
import { PrimaryButton } from '../../core/components/PrimaryButton';
import { TextButton } from '../../core/components/TextButton';
import { theme } from '../../core/theme';
import { MainStackParamList } from '../../navigation/MainStack';
import { ListingType, RentPeriod } from '../../data/models/listingCategory';
import {
  addUniquePhotos,
  FieldError,
  listingTypes,
  maxListingPhotos,
  normalizeTunisianPhone,
  parseNumber,
  propertyTypes,
  rentPeriods,
  validateCity,
  validateDescription,
  validateOptionalNumber,
  validatePhone,
  validatePrice,
  validateRentPeriod,
  validateRooms,
  validateTitle,
} from '../../data/models/newListing';
import {
  listingErrorKey,
  toListingFailure,
} from '../../data/repositories/listingErrors';
import { listingsRepository } from '../../data/repositories/listingsRepository';
import {
  pickFromGallery,
  PhotoFailure,
  photoErrorKey,
  takePhoto,
} from './photoService';

type Props = NativeStackScreenProps<MainStackParamList, 'PublishListing'>;

const typeKeys: Record<ListingType, string> = {
  sale: 'publishTypeSale',
  rent: 'publishTypeRent',
};
const periodKeys: Record<RentPeriod, string> = {
  night: 'publishPeriodNight',
  month: 'publishPeriodMonth',
  year: 'publishPeriodYear',
};
const propertyKeys: Record<(typeof propertyTypes)[number], string> = {
  apartment: 'propertyApartment',
  house: 'propertyHouse',
  villa: 'propertyVilla',
  studio: 'propertyStudio',
  riad: 'propertyRiad',
  guest_house: 'propertyGuestHouse',
};

type Errors = Record<string, FieldError>;

function Chips<T extends string>({
  values,
  keys,
  selected,
  onSelect,
}: {
  values: readonly T[];
  keys: Record<T, string>;
  selected: T | null;
  onSelect: (value: T) => void;
}): React.JSX.Element {
  return (
    <View style={styles.chips}>
      {values.map(value => (
        <Pressable
          key={value}
          accessibilityRole="button"
          onPress={() => onSelect(value)}
          style={[styles.chip, selected === value ? styles.chipOn : null]}
        >
          <AppText
            translationKey={keys[value]}
            style={[
              styles.chipText,
              selected === value ? styles.chipTextOn : null,
            ]}
          />
        </Pressable>
      ))}
    </View>
  );
}

export function PublishListingScreen({
  navigation,
}: Props): React.JSX.Element {
  const [title, setTitle] = useState('');
  const [description, setDescription] = useState('');
  const [price, setPrice] = useState('');
  const [listingType, setListingType] = useState<ListingType>('sale');
  const [rentPeriod, setRentPeriod] = useState<RentPeriod | null>(null);
  const [propertyType, setPropertyType] = useState<string>('apartment');
  const [city, setCity] = useState('');
  const [bedrooms, setBedrooms] = useState('');
  const [bathrooms, setBathrooms] = useState('');
  const [area, setArea] = useState('');
  const [phone, setPhone] = useState('');
  const [whatsapp, setWhatsapp] = useState(false);
  const [photos, setPhotos] = useState<string[]>([]);
  const [errors, setErrors] = useState<Errors>({});
  const [message, setMessage] = useState<string | null>(null);
  const [submitting, setSubmitting] = useState(false);

  const addPhotos = async (pick: () => Promise<string[]>) => {
    setMessage(null);
    try {
      const incoming = await pick();
      const added = addUniquePhotos(photos, incoming, maxListingPhotos);
      setPhotos(added.photos);
      setErrors(previous => ({ ...previous, photos: null }));
      if (added.overLimit) {
        setMessage('listingErrorTooManyPhotos');
      } else if (added.duplicates) {
        setMessage('publishPhotosDuplicates');
      }
    } catch (error) {
      setMessage(
        error instanceof PhotoFailure && error.error !== 'permission'
          ? photoErrorKey(error.error)
          : 'photoErrorReadFailed',
      );
    }
  };

  const submit = async () => {
    const found: Errors = {
      title: validateTitle(title),
      description: validateDescription(description),
      price: validatePrice(price),
      rentPeriod: validateRentPeriod(listingType, rentPeriod),
      city: validateCity(city),
      bedrooms: validateRooms(bedrooms),
      bathrooms: validateRooms(bathrooms),
      area: validateOptionalNumber(area),
      phone: validatePhone(phone),
      photos: photos.length === 0 ? 'listingErrorNoPhotos' : null,
    };
    setErrors(found);
    setMessage(null);
    if (Object.values(found).some(error => error !== null)) {
      return;
    }
    const optional = (value: string): number | null =>
      value.trim().length === 0 ? null : parseNumber(value);
    setSubmitting(true);
    try {
      await listingsRepository.createListing(
        {
          title: title.trim(),
          description: description.trim(),
          price: parseNumber(price),
          listingType,
          rentPeriod: listingType === 'rent' ? rentPeriod : null,
          propertyType,
          city: city.trim(),
          bedrooms: optional(bedrooms),
          bathrooms: optional(bathrooms),
          areaSqm: optional(area),
          contactPhone: normalizeTunisianPhone(phone) ?? '',
          whatsappEnabled: whatsapp,
        },
        photos,
      );
      setMessage('publishSuccess');
      navigation.goBack();
    } catch (error) {
      setMessage(listingErrorKey(toListingFailure(error).error));
    } finally {
      setSubmitting(false);
    }
  };

  return (
    <ScrollView
      contentContainerStyle={styles.container}
      keyboardShouldPersistTaps="handled"
    >
      <AppTextField
        labelKey="publishFieldTitle"
        errorKey={errors.title ?? undefined}
        value={title}
        onChangeText={setTitle}
      />
      <AppTextField
        labelKey="publishFieldDescription"
        errorKey={errors.description ?? undefined}
        value={description}
        onChangeText={setDescription}
        multiline
        style={styles.multiline}
      />
      <AppText translationKey="publishListingType" />
      <Chips
        values={listingTypes}
        keys={typeKeys}
        selected={listingType}
        onSelect={value => {
          setListingType(value);
          if (value === 'sale') {
            setRentPeriod(null);
          }
        }}
      />
      {listingType === 'rent' ? (
        <>
          <AppText translationKey="publishRentPeriod" />
          <Chips
            values={rentPeriods}
            keys={periodKeys}
            selected={rentPeriod}
            onSelect={setRentPeriod}
          />
          {errors.rentPeriod ? (
            <AppText
              translationKey={errors.rentPeriod}
              style={styles.error}
            />
          ) : null}
        </>
      ) : null}
      <AppText translationKey="publishPropertyType" />
      <Chips
        values={propertyTypes}
        keys={propertyKeys}
        selected={propertyType as (typeof propertyTypes)[number]}
        onSelect={setPropertyType}
      />
      <AppTextField
        labelKey="publishFieldPrice"
        errorKey={errors.price ?? undefined}
        value={price}
        onChangeText={setPrice}
        keyboardType="decimal-pad"
      />
      <AppTextField
        labelKey="publishFieldCity"
        errorKey={errors.city ?? undefined}
        value={city}
        onChangeText={setCity}
      />
      <AppTextField
        labelKey="publishFieldBedrooms"
        errorKey={errors.bedrooms ?? undefined}
        value={bedrooms}
        onChangeText={setBedrooms}
        keyboardType="number-pad"
      />
      <AppTextField
        labelKey="publishFieldBathrooms"
        errorKey={errors.bathrooms ?? undefined}
        value={bathrooms}
        onChangeText={setBathrooms}
        keyboardType="number-pad"
      />
      <AppTextField
        labelKey="publishFieldArea"
        errorKey={errors.area ?? undefined}
        value={area}
        onChangeText={setArea}
        keyboardType="decimal-pad"
      />
      <AppTextField
        labelKey="publishFieldPhone"
        errorKey={errors.phone ?? undefined}
        value={phone}
        onChangeText={setPhone}
        keyboardType="phone-pad"
      />
      <View style={styles.row}>
        <AppText translationKey="publishWhatsapp" />
        <Switch value={whatsapp} onValueChange={setWhatsapp} />
      </View>

      <AppText translationKey="publishPhotosTitle" style={styles.section} />
      <View style={styles.row}>
        <PrimaryButton
          labelKey="publishAddFromGallery"
          onPress={() => addPhotos(() => pickFromGallery(maxListingPhotos - photos.length))}
          disabled={photos.length >= maxListingPhotos}
        />
        <PrimaryButton
          labelKey="publishAddFromCamera"
          onPress={() => addPhotos(takePhoto)}
          disabled={photos.length >= maxListingPhotos}
        />
      </View>
      <View style={styles.photos}>
        {photos.map((photo, index) => (
          <View key={photo.slice(-40) + index} style={styles.thumbWrap}>
            <Image
              source={{ uri: `data:image/jpeg;base64,${photo}` }}
              style={styles.thumb}
            />
            <TextButton
              labelKey="publishRemovePhoto"
              onPress={() =>
                setPhotos(photos.filter((_, position) => position !== index))
              }
            />
          </View>
        ))}
      </View>
      {errors.photos ? (
        <AppText translationKey={errors.photos} style={styles.error} />
      ) : null}

      {message ? (
        <AppText
          translationKey={message}
          style={message === 'publishSuccess' ? styles.success : styles.error}
        />
      ) : null}
      <PrimaryButton
        labelKey="publishSubmit"
        loading={submitting}
        onPress={submit}
      />
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: {
    backgroundColor: theme.colors.background,
    gap: theme.spacing.md,
    padding: theme.spacing.lg,
  },
  multiline: { minHeight: 100, textAlignVertical: 'top' },
  chips: { flexDirection: 'row', flexWrap: 'wrap', gap: theme.spacing.sm },
  chip: {
    borderColor: theme.colors.border,
    borderRadius: theme.radius.round,
    borderWidth: 1,
    paddingHorizontal: theme.spacing.md,
    paddingVertical: theme.spacing.sm,
  },
  chipOn: {
    backgroundColor: theme.colors.primary,
    borderColor: theme.colors.primary,
  },
  chipText: { color: theme.colors.navy },
  chipTextOn: { color: theme.colors.white },
  row: {
    alignItems: 'center',
    flexDirection: 'row',
    gap: theme.spacing.sm,
    justifyContent: 'space-between',
  },
  section: { fontWeight: '700' },
  photos: { flexDirection: 'row', flexWrap: 'wrap', gap: theme.spacing.sm },
  thumbWrap: { alignItems: 'center', width: 100 },
  thumb: {
    backgroundColor: theme.colors.sand,
    borderRadius: theme.radius.md,
    height: 80,
    width: 100,
  },
  error: { color: theme.colors.error, fontSize: theme.fontSizes.small },
  success: { color: theme.colors.primary, fontSize: theme.fontSizes.small },
});
