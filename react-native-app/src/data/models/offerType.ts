import { categoryOf } from './listingCategory';
import { ListingType, RentPeriod } from './listingCategory';

export type OfferType = 'sale' | 'rent' | 'stay';

type HasOffer = {
  listingType: ListingType;
  rentPeriod?: RentPeriod | null;
};

/** Same rule as offerTypeOf in Flutter: sale, rent by month or year, stay by night. */
export function offerTypeOf(listing: HasOffer): OfferType {
  const category = categoryOf(listing);
  if (category === 'buy') {
    return 'sale';
  }
  return category;
}

/** Translation key of the ribbon text. */
export function offerLabelKey(type: OfferType): string {
  switch (type) {
    case 'stay':
      return 'offerStay';
    case 'rent':
      return 'offerRent';
    default:
      return 'offerSale';
  }
}

/** Translation key of the price unit. `null` when there is no unit (a sale). */
export function periodLabelKey(
  period: RentPeriod | null | undefined,
): string | null {
  switch (period) {
    case 'night':
      return 'unitNight';
    case 'month':
      return 'unitMonth';
    case 'year':
      return 'unitYear';
    default:
      return null;
  }
}
