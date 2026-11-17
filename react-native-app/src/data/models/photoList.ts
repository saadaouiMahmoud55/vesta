/** A photo document as read from `listings/{id}/photos`. */
export type PhotoDoc = { id: string; base64: unknown };

/**
 * Base64 strings of a listing, sorted by document id (p0 first = cover).
 * Ids can have gaps, so the position is never used (same as getPhotos in
 * Flutter). Documents without a text `base64` are skipped. Keep at most 10
 * photos: `p10` would sort before `p2`.
 */
export function photosFromDocs(docs: readonly PhotoDoc[]): string[] {
  return [...docs]
    .sort((a, b) => (a.id < b.id ? -1 : a.id > b.id ? 1 : 0))
    .flatMap(item => (typeof item.base64 === 'string' ? [item.base64] : []));
}

/** Counter of the gallery, e.g. `2 / 5` (index starts at 0). */
export const galleryCounter = (index: number, total: number): string =>
  `${index + 1} / ${total}`;
