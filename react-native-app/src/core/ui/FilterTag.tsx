import React from 'react';
import { Pressable, StyleSheet } from 'react-native';
import { AppText } from '../components/AppText';
import { theme } from '../theme';

/**
 * Pill chip used for filters and choices (property type, period, language,
 * amenities). Same as `FilterTag` in Flutter: white when off, primary when on.
 */
export function FilterTag({
  labelKey,
  selected,
  onPress,
}: {
  labelKey: string;
  selected: boolean;
  onPress: () => void;
}): React.JSX.Element {
  return (
    <Pressable
      accessibilityRole="button"
      accessibilityState={{ selected }}
      onPress={onPress}
      style={[styles.tag, selected ? styles.tagOn : null]}
    >
      <AppText
        translationKey={labelKey}
        style={[styles.text, selected ? styles.textOn : null]}
      />
    </Pressable>
  );
}

const styles = StyleSheet.create({
  tag: {
    backgroundColor: theme.colors.white,
    borderColor: theme.colors.border,
    borderRadius: theme.radius.round,
    borderWidth: 1,
    paddingHorizontal: theme.spacing.md,
    paddingVertical: theme.spacing.sm,
  },
  tagOn: {
    backgroundColor: theme.colors.primary,
    borderColor: theme.colors.primary,
  },
  text: { color: theme.colors.navy },
  textOn: { color: theme.colors.white, fontWeight: '600' },
});
