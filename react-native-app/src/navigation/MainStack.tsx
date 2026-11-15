import React from 'react';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import { useTranslation } from 'react-i18next';
import { PublishListingScreen } from '../features/listings/PublishListingScreen';
import { MainTabs } from './MainTabs';

export type MainStackParamList = { Tabs: undefined; PublishListing: undefined };
const Stack = createNativeStackNavigator<MainStackParamList>();

export function MainStack(): React.JSX.Element {
  const { t } = useTranslation();
  return (
    <Stack.Navigator>
      <Stack.Screen
        name="Tabs"
        component={MainTabs}
        options={{ headerShown: false }}
      />
      <Stack.Screen
        name="PublishListing"
        component={PublishListingScreen}
        options={{ title: t('publishTitle') }}
      />
    </Stack.Navigator>
  );
}
