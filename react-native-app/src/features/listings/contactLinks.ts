import { Listing } from '../../data/models/listing';
import { categoryOf } from '../../data/models/listingCategory';

/** tel: link for the dialer. The number is E.164 (+216XXXXXXXX). */
export function telUrl(phone: string): string {
  return `tel:${phone}`;
}

/**
 * WhatsApp link that only opens the WhatsApp app, never the browser: the
 * number without "+", and the message pre-filled. When WhatsApp is not
 * installed, opening it fails and the screen shows "WhatsApp is not
 * installed", like the Flutter app (externalNonBrowserApplication).
 */
export function whatsappAppUrl(phone: string, message: string): string {
  const digits = phone.replace('+', '');
  return `whatsapp://send?phone=${digits}&text=${encodeURIComponent(message)}`;
}

export type ContactMessageKey =
  | 'contactMessageSale'
  | 'contactMessageRent'
  | 'contactMessageStay';

/** Pre-filled message by offer type: buy, rent or stay (same as Flutter). */
export function contactMessageKey(
  listing: Pick<Listing, 'listingType' | 'rentPeriod'>,
): ContactMessageKey {
  switch (categoryOf(listing)) {
    case 'buy':
      return 'contactMessageSale';
    case 'stay':
      return 'contactMessageStay';
    default:
      return 'contactMessageRent';
  }
}