import React from 'react';
import { ActivityIndicator, StyleSheet, View } from 'react-native';
import { AppText } from './AppText';
import { theme } from '../theme';

export function LoadingView(): React.JSX.Element {
  return (
    <View style={styles.view}>
      <ActivityIndicator color={theme.colors.primary} />
      <AppText translationKey="loading" />
    </View>
  );
}
const styles = StyleSheet.create({
  view: {
    alignItems: 'center',
    backgroundColor: theme.colors.background,
    flex: 1,
    gap: theme.spacing.md,
    justifyContent: 'center',
  },
});
