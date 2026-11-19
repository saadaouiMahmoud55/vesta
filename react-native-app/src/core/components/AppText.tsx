import React from 'react';
import { Text, TextProps, StyleSheet } from 'react-native';
import { useTranslation } from 'react-i18next';
import { theme } from '../theme';

type Props = TextProps & {
  translationKey: string;
  values?: Record<string, string | number>;
};
export function AppText({
  translationKey,
  values,
  style,
  ...props
}: Props): React.JSX.Element {
  const { t } = useTranslation();
  return (
    <Text {...props} style={[styles.text, style]}>
      {t(translationKey, values)}
    </Text>
  );
}
const styles = StyleSheet.create({
  text: { color: theme.colors.navy, fontSize: theme.fontSizes.body },
});
