import React from 'react';
import { StyleSheet, View } from 'react-native';
import { AppText } from './AppText';
import { theme } from '../theme';

export function ErrorView({
  messageKey,
}: {
  messageKey: string;
}): React.JSX.Element {
  return (
    <View style={styles.view}>
      <AppText translationKey={messageKey} style={styles.error} />
    </View>
  );
}
const styles = StyleSheet.create({
  view: {
    alignItems: 'center',
    flex: 1,
    justifyContent: 'center',
    padding: theme.spacing.lg,
  },
  error: { color: theme.colors.error },
});
