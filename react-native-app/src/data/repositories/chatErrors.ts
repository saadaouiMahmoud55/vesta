export type ChatError =
  | 'notSignedIn'
  | 'ownListing'
  | 'messageTooLong'
  | 'noNetwork'
  | 'permissionDenied'
  | 'unknown';

export class ChatFailure extends Error {
  readonly error: ChatError;

  constructor(error: ChatError) {
    super(error);
    this.name = 'ChatFailure';
    this.error = error;
  }
}

/** Same mapping as the Flutter ChatRepository. */
export function mapChatCode(code: string): ChatError {
  switch (code) {
    case 'permission-denied':
      return 'permissionDenied';
    case 'unavailable':
    case 'deadline-exceeded':
    case 'network-request-failed':
      return 'noNetwork';
    case 'unauthenticated':
      return 'notSignedIn';
    default:
      return 'unknown';
  }
}

/** Translation key for an error shown after opening a chat or sending. */
export function chatErrorKey(error: ChatError): string {
  switch (error) {
    case 'ownListing':
      return 'chatOwnListing';
    case 'noNetwork':
      return 'chatSendError';
    case 'messageTooLong':
    case 'permissionDenied':
      return 'chatSendFailed';
    default:
      return 'chatContactError';
  }
}