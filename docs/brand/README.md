# Vesta brand assets (VST-65, VST-94)

## Files

| File | Size | Use |
|---|---|---|
| `logo.png` | 1024×1024, transparent | Login screen, reports, slides |
| `app-icon-1024.png` | 1024×1024, full-bleed | Home-screen app icon (Flutter and React Native) |
| `play-icon-512.png` | 512×512 | Google Play store icon |
| `feature-graphic-1024x500.png` | 1024×500 | Google Play feature graphic |

The in-app copies are in `flutter-app/assets/images/` and `react-native-app/assets/`, so both apps look identical. Flutter launcher icons are generated with `flutter_launcher_icons` (configured in `flutter-app/pubspec.yaml`). The React Native app has the icon files in `assets/` but `app.json` does not reference them yet (the demo runs in Expo Go). The color token list is in `design-tokens.md`.

## Design

- Mark: a pointed-arch Tunisian studded door with the wordmark "Vesta".
- App icon: the cream door on the brand blue.
- Logo and feature graphic: the blue door and the navy wordmark on cream (feature graphic) or transparent (logo).

## Colors

| Name | Hex |
|---|---|
| Primary blue | `#176AAB` |
| Background cream | `#FAF8F4` |
| Navy | `#20394A` |
| Terracotta | `#A65D42` |

These are the Figma palette values, also used in `app_colors.dart` (Flutter) and `theme.ts` (React Native).

## How the logo was made

Since 24 Oct 2026 (VST-94) the PNG files are an original design drawn in SVG (sources in `docs/brand/src/`, door mark alone in `logo-mark.svg`), in the Figma palette only. Re-generate the PNGs from the SVG sources if the design changes. The first version came from logomaker.com and is no longer used.

## License status

The files in this folder are an original design made for the project, so they can be used on Google Play.
