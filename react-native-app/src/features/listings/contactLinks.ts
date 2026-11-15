/** tel: link for the dialer. The number is E.164 (+216XXXXXXXX). */
export function telUrl(phone: string): string {
  return `tel:${phone}`;
}

/** wa.me link: the number without "+", and the message pre-filled. */
export function whatsappUrl(phone: string, message: string): string {
  const digits = phone.replace('+', '');
  return `https://wa.me/${digits}?text=${encodeURIComponent(message)}`;
}