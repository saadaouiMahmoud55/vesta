import React from 'react';
import {
  ActivityIndicator,
  Pressable,
  StyleSheet,
  PressableProps,
} from 'react-native';
import { AppText } from './AppText';
import { theme } from '../theme';

type Props = PressableProps & { labelKey: string; loading?: boolean };
export function PrimaryButton({
  labelKey,
  loading = false,
  disabled,
  style,
  ...props
}: Props): React.JSX.Element {
  const inactive = loading || disabled;
  return (
    <Pressable
      accessibilityRole="button"
      disabled={inactive}
      style={state => [
        styles.button,
        inactive ? styles.inactive : null,
        typeof style === 'function' ? style(state) : style,
      ]}
      {...props}
    >
      {loading ? (
        <ActivityIndicator color={theme.colors.white} />
      ) : (
        <AppText translationKey={labelKey} style={styles.label} />
      )}
    </Pressable>
  );
}
const styles = StyleSheet.create({
  button: {
    alignItems: 'center',
    backgroundColor: theme.colors.primary,
    borderRadius: theme.radius.md,
    padding: theme.spacing.md,
  },
  inactive: { opacity: 0.6 },
  label: { color: theme.colors.white, fontWeight: '700' },
});
