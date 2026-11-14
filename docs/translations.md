# Translations (VST-70)

All texts of the app (English, French, Tunisian Arabic) live in **one file**: `docs/translations.csv`. A script generates the files that Flutter and React Native read, so the two apps always show the same texts. The first version of the master file was created from the texts that already existed in both apps.

| What | Where |
|---|---|
| Master file (edit this one) | `docs/translations.csv` |
| Script | `scripts/translations.js` |
| Generated for Flutter (do not edit) | `flutter-app/lib/l10n/app_en.arb`, `app_fr.arb`, `app_ar.arb`, then `flutter-app/lib/l10n/generated/` |
| Generated for React Native (do not edit) | `react-native-app/src/core/translations/en.ts`, `fr.ts`, `ar.ts` |
| Arabic words and tone | `docs/i18n/glossary-ar-TN.md` |

## Commands (from the repo root, Node 22 like the rest of the repo)

```
node scripts/translations.js build        # master file -> the 6 generated files
node scripts/translations.js check        # master file is valid and generated files are up to date
node scripts/translations.js --self-test  # the script itself still works
```

After `build`, regenerate the Flutter classes (they are committed):

```
cd flutter-app
flutter gen-l10n
```

React Native needs nothing more: it imports the generated `.ts` files. `check` runs on GitHub for every PR into `develop`. Do not edit a generated file by hand: the next `build` would erase the change and `check` fails.

## Add a text

1. Add one row at the end of the block of its screen in `docs/translations.csv`: `key,en,fr,ar,screen,note`.
2. Write the three texts. A developer may write only English and ask for French and Arabic in the PR; the row is not merged with an empty cell (`check` fails).
3. `node scripts/translations.js build`, then `cd flutter-app` and `flutter gen-l10n`.
4. Use the key in the code: Flutter `AppLocalizations.of(context).authLoginButton`, React Native `translationKey="authLoginButton"`.
5. Commit the master file and the generated files together.

To change a text, edit the row and run `build`. To rename or remove a key, search the code first (`git grep -n authLoginButton`), then change the row and the code in the same PR.

## Columns and rules

- `key`: English, lowercase, with dots: `auth.login.button`, `listing.price.per_night`. Both apps use the camelCase form of the key (`authLoginButton`, `listingPricePerNight`) because a Dart name cannot contain a dot. Two keys that give the same camelCase name are refused.
- `en`, `fr`, `ar`: the three texts. No space at the start or the end.
- `screen`: where the text is used (Auth, Publish listing, Favorites...).
- `note`: free text for reviewers. If a text is really the same in two languages (`Version`, `Email`, `Vesta`), write `same in en and fr` (or `same in all languages`). Without that note, `check` refuses a French or Arabic text equal to the English one: it protects against an English text forgotten in the other files.
- Values that change at runtime use a placeholder written the same way in the three languages: `Example price: {price}`. With a number: `{count:int}` (types: `string`, `int`, `double`, `num`). The script writes `{price}` in the ARB files (with the type) and `{{price}}` for React Native. Plurals: write two keys (`photos.one`, `photos.other`) and choose in the code.
- Never translate `Vesta` and `TND`. Prices are formatted by `formatPrice` (see `docs/i18n/glossary-ar-TN.md`), not written in a text.
- Arabic: simple Tunisian Arabic, Arabic script, the words of the glossary. Numbers use Latin digits (0 to 9): `check` refuses Arabic-Indic digits. Latin letters inside an Arabic text give a warning (allowed: `Vesta`, `TND`, `WhatsApp`, `m²`, `km`).
- Real line break in a text: avoid it. If needed, write it inside quotes in the CSV.

## Edit the CSV

Open `docs/translations.csv` in VS Code, or in Google Sheets (File > Import > Replace spreadsheet, UTF-8, comma; then File > Download > CSV). In Excel use Data > From Text/CSV and choose UTF-8, otherwise the Arabic is unreadable. The script accepts commas or semicolons and a BOM. Check the diff before committing: only the rows you changed should differ.

## Who does what (VST-70)

- The developer who builds a screen adds the keys and the English text.
- Ahmed completes French and Arabic and checks the wording. Manar answers when a wording is unclear.
- One Arabic speaker and one French speaker read all the texts before the freeze.

## Right-to-left check (Arabic, real phone)

At the end of each feature, on a real phone set to Arabic (in the app: language Arabic), in both apps, open each screen of the feature and look for:

- the layout is mirrored: back arrow, list items, form labels, tab order, buttons on the right side;
- icons that must not mirror (play, phone, photos) stay as they are; icons with a direction (back, next, send) are mirrored;
- text is not cut and does not overflow its box (long Arabic words, buttons, tabs);
- mixed texts: a price `TND 120,000 / ليلة`, an email, a phone number or `Vesta` inside an Arabic sentence stay readable, in the right order, with the punctuation on the right side;
- numbers use Latin digits everywhere (prices, dates, counters);
- keyboard, text fields and error messages start on the right.

For each problem, create a bug ticket named `RTL: <screen>: <problem> (Flutter|React Native)` with a screenshot, the phone model and the steps. Then link it to VST-70.

## Final check (by 13 Nov)

```
node scripts/translations.js check
git grep -n -E "(Text|SelectableText)\(\s*['\"]" -- "flutter-app/lib/*.dart" ":!flutter-app/lib/l10n/*"
git grep -n -E "(label|labelText|hintText|title|tooltip|semanticLabel)\s*:\s*(const\s+)?(Text\()?['\"]" -- "flutter-app/lib/*.dart" ":!flutter-app/lib/l10n/*"
git grep -n -E ">\s*[A-Za-z][^<{]*<" -- "react-native-app/src/*.tsx"
git grep -n -E "[ (](title|label|placeholder|accessibilityLabel)=\"[A-Za-z]" -- "react-native-app/src/*.tsx"
```

The first command must pass: no missing key, no English text left in the French or Arabic files. The `git grep` lines list texts written directly in a screen; every result must be moved to a key (a few results, like a technical string, can be fine: say why in the PR).
