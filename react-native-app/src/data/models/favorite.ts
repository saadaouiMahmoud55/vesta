export type FavoriteDoc = {
  listingId: string;
  /** null for a moment right after an add (server has not answered yet). */
  createdAt: { toMillis(): number } | null;
};

/** Newest first. A null createdAt is a favorite just added: it goes first. */
export function sortFavoriteIds(docs: FavoriteDoc[]): string[] {
  return [...docs]
    .sort((a, b) => {
      if (a.createdAt === null && b.createdAt === null) {
        return 0;
      }
      if (a.createdAt === null) {
        return -1;
      }
      if (b.createdAt === null) {
        return 1;
      }
      return b.createdAt.toMillis() - a.createdAt.toMillis();
    })
    .map(item => item.listingId);
}
