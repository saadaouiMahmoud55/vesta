import React from 'react';
import { ScrollView, StyleSheet, View } from 'react-native';
import { useTranslation } from 'react-i18next';
import { useNavigation } from '@react-navigation/native';
import type { NativeStackNavigationProp } from '@react-navigation/native-stack';
import type { MainStackParamList } from '../../navigation/MainStack';
import { appConfig, formatPrice } from '../../core/config';
import { AppText } from '../../core/components/AppText';
import { PrimaryButton } from '../../core/components/PrimaryButton';
import { changeAppLanguage } from '../../core/i18n';
import { useAuth } from '../auth/authController';
import { theme } from '../../core/theme';

const languageKeys = {
  en: 'languageEn',
  fr: 'languageFr',
  ar: 'languageAr',
} as const;

export function HomeScreen(): React.JSX.Element {
  const { t } = useTranslation();
  const { signOut } = useAuth();
  const navigation =
    useNavigation<NativeStackNavigationProp<MainStackParamList>>();
  return (
    <ScrollView contentContainerStyle={styles.container}>
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
      {/* Temporary: opens the chat until the real entry point exists. */}
      <PrimaryButton
        labelKey="chatTitle"
        onPress={() => navigation.navigate('ChatList')}
      />
      {/* Temporary: the profile and settings screens will own Log out. */}
      <PrimaryButton labelKey="authLogoutButton" onPress={() => signOut()} />
    </ScrollView>
  );
}
const styles = StyleSheet.create({
  container: {
    alignItems: 'center',
    backgroundColor: theme.colors.background,
    flexGrow: 1,
    gap: theme.spacing.lg,
    justifyContent: 'center',
    padding: theme.spacing.lg,
  },
  title: {
    color: theme.colors.primary,
    fontSize: theme.fontSizes.heading,
    fontWeight: '700',
  },
  languageLabel: { marginTop: theme.spacing.lg },
  languages: { flexDirection: 'row', gap: theme.spacing.sm },
});
