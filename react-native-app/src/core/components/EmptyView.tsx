import React from 'react';
import { StyleSheet, View } from 'react-native';
import { AppText } from './AppText';
import { theme } from '../theme';

export function EmptyView({
  messageKey,
}: {
  messageKey: string;
}): React.JSX.Element {
  return (
    <View style={styles.view}>
      <AppText translationKey={messageKey} />
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
});
