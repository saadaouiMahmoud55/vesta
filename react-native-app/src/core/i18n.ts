import AsyncStorage from '@react-native-async-storage/async-storage';
import * as Localization from 'expo-localization';
import { reloadAppAsync } from 'expo';
import { I18nManager } from 'react-native';
import i18n from 'i18next';
import { initReactI18next } from 'react-i18next';
import { appConfig } from './config';
import { pickLanguage } from './language';
import en from './translations/en';
import fr from './translations/fr';
import ar from './translations/ar';

export { i18n };
const savedLanguageKey = 'vesta.language';
const resources = {
  en: { translation: en },
  fr: { translation: fr },
  ar: { translation: ar },
};
const phoneLanguage = Localization.getLocales()[0]?.languageCode ?? 'en';

i18n.use(initReactI18next).init({
  resources,
  lng: pickLanguage(null, phoneLanguage),
  fallbackLng: 'en',
  interpolation: { escapeValue: false },
  compatibilityJSON: 'v4',
});

export async function initializeLanguage(): Promise<void> {
  const savedLanguage = await AsyncStorage.getItem(savedLanguageKey);
  const language = pickLanguage(savedLanguage, phoneLanguage);
  await i18n.changeLanguage(language);
  const shouldUseRTL = language === 'ar';
  if (I18nManager.isRTL !== shouldUseRTL) {
    I18nManager.allowRTL(true);
    I18nManager.forceRTL(shouldUseRTL);
    await reloadAppAsync();
  }
}

export async function changeAppLanguage(
  language: (typeof appConfig.supportedLanguages)[number],
): Promise<void> {
  const directionChanged = (i18n.language === 'ar') !== (language === 'ar');
  await AsyncStorage.setItem(savedLanguageKey, language);
  await i18n.changeLanguage(language);
  if (directionChanged) {
    I18nManager.allowRTL(true);
    I18nManager.forceRTL(language === 'ar');
    await reloadAppAsync();
  }
}
