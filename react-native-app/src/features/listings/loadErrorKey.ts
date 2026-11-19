/**
 * Translation key of the message shown when the listings cannot be read.
 * The repository throws a failure whose `error` is `noNetwork` when the
 * phone is offline; anything else gives the generic message.
 */
export function loadErrorKey(error: unknown): string {
  const code = (error as { error?: unknown } | null | undefined)?.error;
  return code === 'noNetwork'
    ? 'favoritesErrorNoNetwork'
    : 'favoritesErrorUnknown';
}
