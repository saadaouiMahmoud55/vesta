import { appConfig } from './config';

export type AppLanguage = (typeof appConfig.supportedLanguages)[number];

function isSupported(language: string | null | undefined): language is AppLanguage {
  return (
    !!language &&
    (appConfig.supportedLanguages as readonly string[]).includes(language)
  );
}

// Saved choice first, then the phone language, then Arabic (same as Flutter).
export function pickLanguage(
  saved: string | null | undefined,
  phone: string | null | undefined,
): AppLanguage {
  if (isSupported(saved)) return saved;
  if (isSupported(phone)) return phone;
  return appConfig.defaultLanguage;
}
