import React, { useState } from 'react';
import { Linking, Pressable, StyleSheet, View } from 'react-native';
import { useTranslation } from 'react-i18next';
import { AppText } from '../../core/components/AppText';
import { PrimaryButton } from '../../core/components/PrimaryButton';
import { theme } from '../../core/theme';
import { Listing } from '../../data/models/listing';
import { useAuth } from '../auth/authController';
import { contactMessageKey, telUrl, whatsappAppUrl } from './contactLinks';
import { useListingContact } from './useListingContact';

type Props = {
  listing: Listing;
  /** A guest taps "Sign in to see the contact": the screen opens the login. */
  onSignInPress: () => void;
};

type OutlineProps = { labelKey: string; onPress: () => void };

function OutlineButton({ labelKey, onPress }: OutlineProps): React.JSX.Element {
  return (
    <Pressable
      accessibilityRole="button"
      onPress={onPress}
      style={[styles.outline, styles.grow]}
    >
      <AppText translationKey={labelKey} style={styles.outlineLabel} />
    </Pressable>
  );
}

/**
 * Call and WhatsApp buttons under the price (VST-80, port of ContactButtons
 * in Flutter). A guest sees "Sign in to see the contact" and never reads the
 * private contact. The phone number is never logged.
 */
export function ContactButtons({
  listing,
  onSignInPress,
}: Props): React.JSX.Element | null {
  const { t } = useTranslation();
  const { isSignedIn } = useAuth();
  const contact = useListingContact(listing.id);
  const [errorKey, setErrorKey] = useState<string | null>(null);

  if (!isSignedIn) {
    return (
      <View style={styles.row}>
        <OutlineButton
          labelKey="contactSignInToSee"
          onPress={onSignInPress}
        />
      </View>
    );
  }
  if (contact === null) {
    return null;
  }

  const open = async (url: string, failureKey: string): Promise<void> => {
    setErrorKey(null);
    try {
      await Linking.openURL(url);
    } catch {
      setErrorKey(failureKey);
    }
  };

  return (
    <View style={styles.wrap}>
      <View style={styles.row}>
        <PrimaryButton
          labelKey="contactCall"
          style={styles.grow}
          onPress={() => open(telUrl(contact.phone), 'contactCallError')}
        />
        {contact.whatsapp ? (
          <OutlineButton
            labelKey="contactWhatsapp"
            onPress={() =>
              open(
                whatsappAppUrl(
                  contact.phone,
                  t(contactMessageKey(listing), { title: listing.title }),
                ),
                'contactNoWhatsapp',
              )
            }
          />
        ) : null}
      </View>
      {errorKey !== null ? (
        <AppText translationKey={errorKey} style={styles.error} />
      ) : null}
    </View>
  );
}

const styles = StyleSheet.create({
  wrap: { gap: theme.spacing.sm },
  row: { flexDirection: 'row', gap: theme.spacing.sm },
  grow: { flex: 1 },
  outline: {
    alignItems: 'center',
    borderColor: theme.colors.primary,
    borderRadius: theme.radius.md,
    borderWidth: 1,
    padding: theme.spacing.md,
  },
  outlineLabel: { color: theme.colors.primary, fontWeight: '700' },
  error: { color: theme.colors.error, fontSize: theme.fontSizes.small },
});