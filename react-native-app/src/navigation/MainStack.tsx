import React from 'react';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import { MainTabs } from './MainTabs';

export type MainStackParamList = { Tabs: undefined };
const Stack = createNativeStackNavigator<MainStackParamList>();

export function MainStack(): React.JSX.Element {
  return (
    <Stack.Navigator screenOptions={{ headerShown: false }}>
      <Stack.Screen name="Tabs" component={MainTabs} />
    </Stack.Navigator>
  );
}
