import React from 'react';
import { StyleSheet, TextInput, TextInputProps, View } from 'react-native';
import { AppText } from './AppText';
import { theme } from '../theme';

type Props = TextInputProps & { labelKey: string; errorKey?: string };
export function AppTextField({
  labelKey,
  errorKey,
  style,
  ...props
}: Props): React.JSX.Element {
  return (
    <View style={styles.container}>
      <AppText translationKey={labelKey} />
      <TextInput
        placeholderTextColor={theme.colors.grey}
        style={[styles.input, errorKey ? styles.inputError : null, style]}
        {...props}
      />
      {errorKey ? (
        <AppText translationKey={errorKey} style={styles.error} />
      ) : null}
    </View>
  );
}
const styles = StyleSheet.create({
  container: { gap: theme.spacing.xs },
  input: {
    borderColor: theme.colors.border,
    borderRadius: theme.radius.sm,
    borderWidth: 1,
    color: theme.colors.navy,
    padding: theme.spacing.md,
  },
  inputError: { borderColor: theme.colors.error },
  error: { color: theme.colors.error, fontSize: theme.fontSizes.small },
});
