import React from 'react';
import {
  I18nManager,
  StyleProp,
  StyleSheet,
  Text,
  TextStyle,
  View,
} from 'react-native';

/**
 * True when the app is shown right-to-left (Arabic). The language is set in
 * `core/i18n.ts` with `I18nManager.forceRTL`. Same as `isRtl` in Flutter.
 */
export function isRtl(): boolean {
  return I18nManager.isRTL;
}

/**
 * Icon that flips in Arabic (back arrow, chevron). Give it the left-to-right
 * icon as a child. Same as `DirectionalIcon` in Flutter; the kit has no icon
 * library, so the screen provides the icon element.
 */
export function DirectionalIcon({
  children,
}: {
  children: React.ReactNode;
}): React.JSX.Element {
  return <View style={isRtl() ? styles.flipped : null}>{children}</View>;
}

/**
 * Text that always reads left-to-right, even inside an Arabic screen:
 * phone numbers, prices, areas. Same as `LtrText` in Flutter.
 */
export function LtrText({
  children,
  style,
}: {
  children: React.ReactNode;
  style?: StyleProp<TextStyle>;
}): React.JSX.Element {
  return <Text style={[styles.ltr, style]}>{children}</Text>;
}

const styles = StyleSheet.create({
  ltr: { writingDirection: 'ltr' },
  flipped: { transform: [{ scaleX: -1 }] },
});
