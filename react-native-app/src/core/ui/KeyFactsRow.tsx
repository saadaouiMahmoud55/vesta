import React from 'react';
import { StyleSheet, Text, View } from 'react-native';
import { theme } from '../theme';

/** One fact: an icon and a short value, e.g. a bed icon and `3`. */
export type KeyFact = {
  /** Any element (an icon). The kit does not depend on an icon library. */
  icon: React.ReactNode;
  value: string;
};

/**
 * Row of key facts (rooms, bathrooms, area, guests...). Same as
 * `KeyFactsRow` in Flutter. The values read left-to-right in Arabic. The
 * facts of a listing depend on its offer type (docs/offer-types.md,
 * section 3): the screen builds the list.
 */
export function KeyFactsRow({
  facts,
}: {
  facts: readonly KeyFact[];
}): React.JSX.Element {
  return (
    <View style={styles.row}>
      {facts.map((fact, index) => (
        <View key={`${index}-${fact.value}`} style={styles.fact}>
          {fact.icon}
          <Text style={styles.value}>{fact.value}</Text>
        </View>
      ))}
    </View>
  );
}

const styles = StyleSheet.create({
  row: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: theme.spacing.md,
  },
  fact: {
    alignItems: 'center',
    flexDirection: 'row',
    gap: theme.spacing.sm,
  },
  value: {
    color: theme.colors.grey,
    fontSize: theme.fontSizes.small,
    writingDirection: 'ltr',
  },
});
