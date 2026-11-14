import { useCallback, useEffect, useState } from 'react';
import { chatRepository } from '../../data/repositories/chatRepository';
import { ChatError, ChatFailure } from '../../data/repositories/chatErrors';
import {
  ChatMessage,
  Conversation,
  parseConversationId,
  totalUnread,
} from '../../data/models/chat';
import { useAuth } from '../auth/authController';

/**
 * How long the screen waits before telling the user the message is still in
 * the queue (offline). The message is not lost: Firestore sends it when the
 * network is back.
 */
export const sendWaitLimit = 8000;

/**
 * Live conversations of the signed-in user, newest first. Restarts by itself
 * when the user signs in or out, and stops listening when the screen closes.
 * `unreadTotal` is for the badge on the chat icon (0 for a guest).
 */
export function useConversations() {
  const { uid } = useAuth();
  const [conversations, setConversations] = useState<Conversation[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<ChatError | null>(null);
  const [attempt, setAttempt] = useState(0);

  useEffect(() => {
    setLoading(true);
    setError(null);
    return chatRepository.watchConversations(
      next => {
        setConversations(next);
        setLoading(false);
      },
      failure => {
        setError(failure.error);
        setLoading(false);
      },
    );
  }, [uid, attempt]);

  const unreadTotal = uid === null ? 0 : totalUnread(conversations, uid);
  const retry = useCallback(() => setAttempt(count => count + 1), []);

  return { conversations, loading, error, unreadTotal, retry };
}

/**
 * Live messages of one conversation, newest first (last 50 only). The
 * listener stops when the chat screen closes: no leak.
 */
export function useMessages(conversationId: string) {
  const { uid } = useAuth();
  const [messages, setMessages] = useState<ChatMessage[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<ChatError | null>(null);
  const [attempt, setAttempt] = useState(0);

  useEffect(() => {
    setLoading(true);
    setError(null);
    return chatRepository.watchMessages(
      conversationId,
      next => {
        setMessages(next);
        setLoading(false);
      },
      failure => {
        setError(failure.error);
        setLoading(false);
      },
    );
  }, [conversationId, uid, attempt]);

  const retry = useCallback(() => setAttempt(count => count + 1), []);

  return { messages, loading, error, retry };
}

/** Public name of a user, for the conversation list and the chat header. */
export function useUserName(uid: string): string | null {
  const [name, setName] = useState<string | null>(null);

  useEffect(() => {
    let active = true;
    setName(null);
    chatRepository
      .getUserName(uid)
      .then(value => {
        if (active) {
          setName(value);
        }
      })
      .catch(() => {});
    return () => {
      active = false;
    };
  }, [uid]);

  return name;
}

async function sendWithLimit(
  sending: Promise<void>,
  limitMs: number,
): Promise<'sent' | 'timeout'> {
  let timer: ReturnType<typeof setTimeout> | undefined;
  const timeout = new Promise<'timeout'>(resolve => {
    timer = setTimeout(() => resolve('timeout'), limitMs);
  });
  try {
    return await Promise.race([sending.then(() => 'sent' as const), timeout]);
  } finally {
    if (timer !== undefined) {
      clearTimeout(timer);
    }
  }
}

/**
 * Sends `text` in the conversation and reports what the screen should show.
 * Returns null when the message reached the server, or the ChatError
 * otherwise.
 *
 * VST-51 hook: the in-app alert for the other person is created from here
 * (after a successful send), not in the screen.
 */
export async function sendChatMessage(input: {
  conversationId: string;
  ownerId: string;
  text: string;
}): Promise<ChatError | null> {
  const ids = parseConversationId(input.conversationId);
  if (ids === null) {
    return 'unknown';
  }
  try {
    const result = await sendWithLimit(
      chatRepository.sendMessage({
        listingId: ids.listingId,
        buyerId: ids.buyerId,
        ownerId: input.ownerId,
        text: input.text,
      }),
      sendWaitLimit,
    );
    return result === 'timeout' ? 'noNetwork' : null;
  } catch (failure) {
    return failure instanceof ChatFailure ? failure.error : 'unknown';
  }
}
