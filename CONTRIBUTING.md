# Contributing to Vesta

## Branches
- `main`: stable, only receives merges from `develop` at the end of a sprint.
- `develop`: integration branch. All feature PRs target `develop`.
- `feature/VST-<n>-<short-name>`: one branch per Jira ticket, e.g. `feature/VST-21-flutter-login`.
- `fix/VST-<n>-<short-name>`: bug fixes.

Always put the Jira key in the branch name, commit messages and PR title so Jira links them.

## Commits
`type(scope): message [VST-n]` — types: `feat`, `fix`, `docs`, `chore`, `test`, `refactor`.
Example: `feat(auth): add email login screen [VST-21]`

## Pull requests
1. Branch from `develop`, push, open a PR into `develop`.
2. Fill in the PR template. Assign the **reviewer** named in the Jira ticket.
3. No merge without 1 approval. No direct pushes to `main` or `develop`.
4. Keep PRs small (one ticket). Squash-merge.

## Definition of Done
- PR reviewed and merged
- Tested on a **real phone**
- Jira ticket updated and moved to Done

## Running the app on a phone that has the Play Store version
Debug builds use the app id `com.vesta.flutterapp.debug`, so `flutter run` installs next to the Play Store version (`com.vesta.flutterapp`) and does not remove it. Testers in the Google Play closed test must keep the Play version installed and never uninstall it before 11 Nov.

## Secrets
Never commit `google-services.json`, `GoogleService-Info.plist`, `.env`, keystores or API keys. If one leaks, tell Manar immediately so the key can be rotated.

## Team rhythm
Monday: 15-minute sync. Friday: demo of what is merged. Pair call when a feature is finished: explain the logic to the person who ports or reviews it.

## Design-system check (colors)
Colors only come from the theme files: `flutter-app/lib/core/theme/` (Flutter) and `react-native-app/src/core/theme.ts` (React Native). The token list is in `docs/brand/design-tokens.md`. A screen or a component never writes a color directly.

Before opening a PR, run this from the repo root (it needs Node, the same one as the React Native app):

```
node tools/check-colors.js
```

It fails and prints the file and the line if it finds `Color(0x`, `Color.fromRGBO`, `Color.fromARGB` or `Colors.x` (except `Colors.transparent`) in the Flutter app outside `lib/core/theme/`, or a hex color, `rgb(`, `hsl(` or a named color in the React Native app outside the theme file. `node tools/check-colors.js --self-test` checks that the script itself still works. The same check runs on GitHub for every PR into `develop`.

If a color is missing, add a token to the theme in both apps (small PR) and tell the team. In a very rare case a line can be skipped with the comment `color-check-ignore`; explain why in the PR.

## Translations (texts)
Every text of the app is in `docs/translations.csv` (English, French, Arabic). Never edit `app_en.arb`, `app_fr.arb`, `app_ar.arb` or the files in `react-native-app/src/core/translations/` by hand: edit the master file, run `node scripts/translations.js build` (then `flutter gen-l10n` in `flutter-app`) and commit the generated files with it. `node scripts/translations.js check` runs on GitHub for every PR into `develop`. A screen never writes a text directly. All the steps are in `docs/translations.md`.

