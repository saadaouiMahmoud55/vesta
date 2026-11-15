import React from 'react';
import { StyleSheet, View } from 'react-native';
import { AppText } from '../core/components/AppText';
import { theme } from '../core/theme';

type Props = { titleKey: string };

// Temporary screen. Each owner replaces it in MainTabs.tsx with the real one.
export function PlaceholderScreen({ titleKey }: Props): React.JSX.Element {
  return (
    <View style={styles.container}>
      <AppText translationKey={titleKey} style={styles.title} />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: theme.colors.background,
  },
  title: { fontSize: theme.fontSizes.title, color: theme.colors.navy },
});
