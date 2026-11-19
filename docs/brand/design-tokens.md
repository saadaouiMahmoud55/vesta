# Vesta design tokens (VST-78)

Figma is the reference for the color palette only: [Vesta mockups](https://www.figma.com/design/C6EyAhtCYf3JNf2NOiMikY/Vesta-mockups).

- Flutter: `flutter-app/lib/core/theme/app_colors.dart` (`AppColors`).
- React Native: `react-native-app/src/core/theme.ts` (`theme.colors`).
- A screen never writes a color directly: it uses a token from these files.
- Check with `node tools/check-colors.js` (see `CONTRIBUTING.md`). The PR template has a checkbox for it.

| Token | Figma hex | Code hex |
|---|---|---|
| primary | `#176AAB` | `#176AAB` |
| navy | `#20394A` | `#20394A` |
| grey | `#6B777B` | `#6B777B` |
| white | `#FFFFFF` | `#FFFFFF` |
| border | `#E5E5DF` | `#E5E5DF` |
| background | `#FAF8F4` | `#FAF8F4` |
| terracotta | `#A65D42` | `#A65D42` |
| sand | `#F0E7DA` | `#F0E7DA` |
| error | not in Figma | `#A33B32` |
