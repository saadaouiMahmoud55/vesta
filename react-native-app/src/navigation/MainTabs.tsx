import React from 'react';
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';
import { useTranslation } from 'react-i18next';
import { HomeScreen } from '../features/listings/HomeScreen';
import { PlaceholderScreen } from './PlaceholderScreen';
import { theme } from '../core/theme';

export type MainTabsParamList = {
  Explore: undefined;
  Search: undefined;
  Map: undefined;
  Favorites: undefined;
  Profile: undefined;
};
const Tab = createBottomTabNavigator<MainTabsParamList>();

// To plug a real screen, replace the component of its tab below.
const SearchTab = () => <PlaceholderScreen titleKey="tabSearch" />;
const MapTab = () => <PlaceholderScreen titleKey="tabMap" />;
const FavoritesTab = () => <PlaceholderScreen titleKey="tabFavorites" />;
const ProfileTab = () => <PlaceholderScreen titleKey="tabProfile" />;

export function MainTabs(): React.JSX.Element {
  const { t } = useTranslation();
  return (
    <Tab.Navigator
      initialRouteName="Explore"
      screenOptions={{
        headerShown: false,
        tabBarActiveTintColor: theme.colors.primary,
        tabBarInactiveTintColor: theme.colors.grey,
      }}
    >
      <Tab.Screen
        name="Explore"
        component={HomeScreen}
        options={{ title: t('tabExplore') }}
      />
      <Tab.Screen
        name="Search"
        component={SearchTab}
        options={{ title: t('tabSearch') }}
      />
      <Tab.Screen
        name="Map"
        component={MapTab}
        options={{ title: t('tabMap') }}
      />
      <Tab.Screen
        name="Favorites"
        component={FavoritesTab}
        options={{ title: t('tabFavorites') }}
      />
      <Tab.Screen
        name="Profile"
        component={ProfileTab}
        options={{ title: t('tabProfile') }}
      />
    </Tab.Navigator>
  );
}
