import React from 'react';
import {
  createNativeStackNavigator,
  NativeStackScreenProps,
} from '@react-navigation/native-stack';
import { useTranslation } from 'react-i18next';
import { ChatListScreen } from '../features/chat/ChatListScreen';
import { ChatScreen } from '../features/chat/ChatScreen';
import { ListingDetailScreen } from '../features/listings/ListingDetailScreen';
import { PublishListingScreen } from '../features/listings/PublishListingScreen';
import { MainTabs } from './MainTabs';

export type MainStackParamList = {
  Tabs: undefined;
  ChatList: undefined;
  ChatRoom: { conversationId: string };
  PublishListing: undefined;
  ListingDetails: { listingId: string };
};
const Stack = createNativeStackNavigator<MainStackParamList>();

function ChatListRoute({
  navigation,
}: NativeStackScreenProps<MainStackParamList, 'ChatList'>): React.JSX.Element {
  return (
    <ChatListScreen
      onOpen={conversationId =>
        navigation.navigate('ChatRoom', { conversationId })
      }
    />
  );
}

function ChatRoomRoute({
  navigation,
  route,
}: NativeStackScreenProps<MainStackParamList, 'ChatRoom'>): React.JSX.Element {
  return (
    <ChatScreen
      conversationId={route.params.conversationId}
      onOpenListing={listingId =>
        navigation.navigate('ListingDetails', { listingId })
      }
    />
  );
}

export function MainStack(): React.JSX.Element {
  const { t } = useTranslation();
  return (
    <Stack.Navigator screenOptions={{ headerShown: false }}>
      <Stack.Screen name="Tabs" component={MainTabs} />
      <Stack.Screen
        name="ChatList"
        component={ChatListRoute}
        options={{ headerShown: true, title: t('chatTitle') }}
      />
      <Stack.Screen
        name="ChatRoom"
        component={ChatRoomRoute}
        options={{ headerShown: true, title: t('chatTitle') }}
      />
      <Stack.Screen
        name="PublishListing"
        component={PublishListingScreen}
        options={{ headerShown: true, title: t('publishTitle') }}
      />
      <Stack.Screen
        name="ListingDetails"
        component={ListingDetailScreen}
        options={{ headerShown: true, title: '' }}
      />
    </Stack.Navigator>
  );
}
