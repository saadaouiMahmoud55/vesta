/** Private contact of a listing: listings/{id}/contact/info (VST-74). */
export type ListingContact = {
  /** E.164 number: +216 and 8 digits. */
  phone: string;
  whatsapp: boolean;
};

/** Same rule as getContact in Flutter: no phone string means no contact. */
export function contactFromData(
  data: Record<string, unknown> | undefined,
): ListingContact | null {
  const phone = data?.contactPhone;
  if (typeof phone !== 'string') {
    return null;
  }
  return { phone, whatsapp: data?.whatsappEnabled === true };
}