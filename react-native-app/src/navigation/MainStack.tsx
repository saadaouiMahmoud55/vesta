import React from 'react';
import {
  createNativeStackNavigator,
  NativeStackScreenProps,
} from '@react-navigation/native-stack';
import { useTranslation } from 'react-i18next';
import { ChatListScreen } from '../features/chat/ChatListScreen';
import { ChatScreen } from '../features/chat/ChatScreen';
import { MainTabs } from './MainTabs';

export type MainStackParamList = {
  Tabs: undefined;
  ChatList: undefined;
  ChatRoom: { conversationId: string };
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
  route,
}: NativeStackScreenProps<MainStackParamList, 'ChatRoom'>): React.JSX.Element {
  // onOpenListing stays empty: the listing details screen does not exist yet.
  return <ChatScreen conversationId={route.params.conversationId} />;
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
    </Stack.Navigator>
  );
}