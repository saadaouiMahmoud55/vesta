import React from 'react';
import { Pressable, PressableProps, StyleSheet } from 'react-native';
import { AppText } from './AppText';
import { theme } from '../theme';

type Props = PressableProps & { labelKey: string };
export function TextButton({
  labelKey,
  disabled,
  ...props
}: Props): React.JSX.Element {
  return (
    <Pressable
      accessibilityRole="button"
      disabled={disabled}
      style={[styles.button, disabled ? styles.disabled : null]}
      {...props}
    >
      <AppText translationKey={labelKey} style={styles.label} />
    </Pressable>
  );
}
const styles = StyleSheet.create({
  button: { alignItems: 'center', padding: theme.spacing.sm },
  disabled: { opacity: 0.6 },
  label: { color: theme.colors.primary, fontWeight: '600' },
});
