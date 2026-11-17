import { galleryCounter, photosFromDocs } from '../src/data/models/photoList';
import { loadErrorKey } from '../src/features/listings/loadErrorKey';

describe('photosFromDocs', () => {
  it('sorts the photos by document id, p0 first', () => {
    const docs = [
      { id: 'p2', base64: 'c' },
      { id: 'p0', base64: 'a' },
      { id: 'p1', base64: 'b' },
    ];
    expect(photosFromDocs(docs)).toEqual(['a', 'b', 'c']);
  });

  it('keeps the order of the ids when there are gaps', () => {
    const docs = [
      { id: 'p4', base64: 'e' },
      { id: 'p0', base64: 'a' },
      { id: 'p2', base64: 'c' },
    ];
    expect(photosFromDocs(docs)).toEqual(['a', 'c', 'e']);
  });

  it('skips a document without a text base64', () => {
    const docs = [
      { id: 'p0', base64: 'a' },
      { id: 'p1', base64: undefined },
      { id: 'p2', base64: 42 },
      { id: 'p3', base64: 'd' },
    ];
    expect(photosFromDocs(docs)).toEqual(['a', 'd']);
  });

  it('does not change the list it receives', () => {
    const docs = [
      { id: 'p1', base64: 'b' },
      { id: 'p0', base64: 'a' },
    ];
    photosFromDocs(docs);
    expect(docs[0].id).toBe('p1');
  });

  it('gives an empty list when there is no photo', () => {
    expect(photosFromDocs([])).toEqual([]);
  });
});

describe('galleryCounter', () => {
  it('counts from 1', () => {
    expect(galleryCounter(0, 5)).toBe('1 / 5');
    expect(galleryCounter(4, 5)).toBe('5 / 5');
  });
});

describe('loadErrorKey', () => {
  it('has a message for a phone that is offline', () => {
    expect(loadErrorKey({ error: 'noNetwork' })).toBe(
      'favoritesErrorNoNetwork',
    );
  });

  it('has a generic message for anything else', () => {
    expect(loadErrorKey({ error: 'unknown' })).toBe('favoritesErrorUnknown');
    expect(loadErrorKey(new Error('boom'))).toBe('favoritesErrorUnknown');
    expect(loadErrorKey(null)).toBe('favoritesErrorUnknown');
  });
});
