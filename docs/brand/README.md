# Vesta brand assets (VST-65)

## Files

| File | Size | Use |
|---|---|---|
| `logo.png` | 1024×1024, transparent | Login screen, reports, slides |
| `app-icon-1024.png` | 1024×1024, full-bleed | Home-screen app icon (Flutter and React Native) |
| `play-icon-512.png` | 512×512 | Google Play store icon |
| `feature-graphic-1024x500.png` | 1024×500 | Google Play feature graphic |

The same files are used by the Flutter app (`flutter-app/assets/images/`) and the React Native app (`react-native-app/assets/`) so both apps look identical.

## Design

- Mark: a pointed-arch studded door with the wordmark "Vesta".
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

**Updated 24 Oct 2026 (VST-94):** the four PNG files were replaced by an original design drawn in SVG (sources in `docs/brand/src/`, door mark alone in `logo-mark.svg`): a pointed-arch Tunisian studded door, in the Figma palette only (blue `#176AAB`, cream `#F7F3EB`, navy `#20394A`, terracotta `#A65D42`). Re-generate the PNGs from the SVG sources if the design changes. The first version came from logomaker.com and is no longer used.

## License status

The files in this folder are an original design made for the project, so they can be used on Google Play. The in-app copies (`flutter-app/assets/images/`, `react-native-app/assets/`) and the Android launcher icon still need the same swap; this is tracked separately.
## Still missing

- Launcher icons in the apps (run `flutter_launcher_icons` with the new `app-icon-1024.png`).
