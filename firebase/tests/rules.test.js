import { readFileSync } from 'node:fs';
import { test, before, after, beforeEach } from 'node:test';
import {
  initializeTestEnvironment,
  assertSucceeds,
  assertFails,
} from '@firebase/rules-unit-testing';
import {
  doc, getDoc, getDocs, setDoc, updateDoc, deleteDoc, writeBatch,
  collection, query, where,
} from 'firebase/firestore';

let env;
const as = (uid) => env.authenticatedContext(uid).firestore();
const anon = () => env.unauthenticatedContext().firestore();

const makeListing = (owner, over = {}) => ({
  ownerId: owner, title: 'T', description: 'D', price: 100000,
  currency: 'TND', listingType: 'sale', propertyType: 'apartment',
  city: 'Tunis', photoCount: 0,
  createdAt: new Date(), updatedAt: new Date(), ...over,
});

before(async () => {
  env = await initializeTestEnvironment({
    projectId: 'demo-vesta',
    firestore: {
      rules: readFileSync('../firestore.rules', 'utf8'),
      host: '127.0.0.1',
      port: 8085,
    },
  });
});

after(async () => { await env.cleanup(); });

beforeEach(async () => {
  await env.clearFirestore();
  await env.withSecurityRulesDisabled(async (ctx) => {
    const db = ctx.firestore();
    await setDoc(doc(db, 'users/alice'), { displayName: 'Alice', createdAt: new Date() });
    await setDoc(doc(db, 'users/alice/private/contact'), { email: 'a@x.tn' });
    await setDoc(doc(db, 'listings/l1'), makeListing('alice'));
    await setDoc(doc(db, 'listings/l1/photos/p0'), { base64: 'abc', createdAt: new Date() });
    await setDoc(doc(db, 'favorites/alice_l1'),
      { userId: 'alice', listingId: 'l1', createdAt: new Date() });
    await setDoc(doc(db, 'conversations/l1_bob'), {
      participantIds: ['bob', 'alice'], listingId: 'l1',
      lastMessage: '', lastMessageAt: new Date(),
    });
    await setDoc(doc(db, 'conversations/l1_bob/messages/m0'), {
      senderId: 'bob', text: 'hello', createdAt: new Date(),
    });
  });
});

// ---------- listings ----------
test('annonce valide creee par son proprietaire : OK', async () => {
  await assertSucceeds(setDoc(doc(as('alice'), 'listings/l2'), makeListing('alice')));
});
test('devise de 2 lettres : refuse', async () => {
  await assertFails(setDoc(doc(as('alice'), 'listings/l2'), makeListing('alice', { currency: 'TN' })));
});
test('location sans rentPeriod : refuse', async () => {
  await assertFails(setDoc(doc(as('alice'), 'listings/l2'), makeListing('alice', { listingType: 'rent' })));
});
test('location avec rentPeriod month : OK', async () => {
  await assertSucceeds(setDoc(doc(as('alice'), 'listings/l2'),
    makeListing('alice', { listingType: 'rent', rentPeriod: 'month' })));
});
test('propertyType hors liste : refuse', async () => {
  await assertFails(setDoc(doc(as('alice'), 'listings/l2'), makeListing('alice', { propertyType: 'castle' })));
});
test('photoCount a 11 : refuse', async () => {
  await assertFails(setDoc(doc(as('alice'), 'listings/l2'), makeListing('alice', { photoCount: 11 })));
});
test('annonce creee au nom d un autre : refuse', async () => {
  await assertFails(setDoc(doc(as('alice'), 'listings/l2'), makeListing('bob')));
});
test('modification par un autre utilisateur : refuse', async () => {
  await assertFails(updateDoc(doc(as('bob'), 'listings/l1'), { title: 'Hack' }));
});
test('lecture sans etre connecte : OK (navigation en invite, VST-72)', async () => {
  await assertSucceeds(getDoc(doc(anon(), 'listings/l1')));
});
test('lecture par un utilisateur connecte : OK', async () => {
  await assertSucceeds(getDoc(doc(as('bob'), 'listings/l1')));
});

// ---------- photos ----------
test('photo p3 sans p1 ni p2 (id libre quelconque) : OK', async () => {
  const db = as('alice');
  const b = writeBatch(db);
  b.set(doc(db, 'listings/l1/photos/p3'), { base64: 'abc', createdAt: new Date() });
  b.update(doc(db, 'listings/l1'), { photoCount: 2 });
  await assertSucceeds(b.commit());
});
test('photo p9 : OK (limite de 10 photos)', async () => {
  await assertSucceeds(setDoc(doc(as('alice'), 'listings/l1/photos/p9'),
    { base64: 'abc', createdAt: new Date() }));
});
test('photo ajoutee par un autre que le proprietaire : refuse', async () => {
  await assertFails(setDoc(doc(as('bob'), 'listings/l1/photos/p2'),
    { base64: 'abc', createdAt: new Date() }));
});
test('photo trop grande (300000 caracteres) : refuse', async () => {
  await assertFails(setDoc(doc(as('alice'), 'listings/l1/photos/p2'),
    { base64: 'a'.repeat(300000), createdAt: new Date() }));
});
test('photo de 270000 caracteres : OK', async () => {
  await assertSucceeds(setDoc(doc(as('alice'), 'listings/l1/photos/p2'),
    { base64: 'a'.repeat(270000), createdAt: new Date() }));
});
test('mise a jour d une photo trop grande : refuse', async () => {
  await assertFails(updateDoc(doc(as('alice'), 'listings/l1/photos/p0'),
    { base64: 'a'.repeat(300000) }));
});
test('ajout de p1 + photoCount=2 dans un seul lot : OK', async () => {
  const db = as('alice');
  const b = writeBatch(db);
  b.set(doc(db, 'listings/l1/photos/p1'), { base64: 'abc', createdAt: new Date() });
  b.update(doc(db, 'listings/l1'), { photoCount: 2 });
  await assertSucceeds(b.commit());
});
test('creation annonce + photo p0 dans le meme lot : OK', async () => {
  const db = as('alice');
  const b = writeBatch(db);
  b.set(doc(db, 'listings/l2'), makeListing('alice', { photoCount: 1 }));
  b.set(doc(db, 'listings/l2/photos/p0'), { base64: 'abc', createdAt: new Date() });
  await assertSucceeds(b.commit());
});
test('suppression photo + annonce dans le meme lot : OK', async () => {
  const db = as('alice');
  const b = writeBatch(db);
  b.delete(doc(db, 'listings/l1/photos/p0'));
  b.delete(doc(db, 'listings/l1'));
  await assertSucceeds(b.commit());
});
test('suppression de photo par son proprietaire : OK', async () => {
  await assertSucceeds(deleteDoc(doc(as('alice'), 'listings/l1/photos/p0')));
});
test('suppression de photo par un autre : refuse', async () => {
  await assertFails(deleteDoc(doc(as('bob'), 'listings/l1/photos/p0')));
});

// ---------- users ----------
test('profil public lisible par un utilisateur connecte : OK', async () => {
  await assertSucceeds(getDoc(doc(as('bob'), 'users/alice')));
});
test('contact prive lu par un autre : refuse', async () => {
  await assertFails(getDoc(doc(as('bob'), 'users/alice/private/contact')));
});
test('contact prive lu par son proprietaire : OK', async () => {
  await assertSucceeds(getDoc(doc(as('alice'), 'users/alice/private/contact')));
});
test('profil modifie par un autre : refuse', async () => {
  await assertFails(updateDoc(doc(as('bob'), 'users/alice'), { displayName: 'X' }));
});

// ---------- favorites ----------
test('favori bob_l1 cree par bob : OK', async () => {
  await assertSucceeds(setDoc(doc(as('bob'), 'favorites/bob_l1'),
    { userId: 'bob', listingId: 'l1', createdAt: new Date() }));
});
test('favori avec l id d un autre : refuse', async () => {
  await assertFails(setDoc(doc(as('bob'), 'favorites/alice_l1'),
    { userId: 'bob', listingId: 'l1', createdAt: new Date() }));
});
test('lecture d un favori absent : OK', async () => {
  await assertSucceeds(getDoc(doc(as('bob'), 'favorites/bob_l9')));
});
test('lecture du favori d un autre : refuse', async () => {
  await assertFails(getDoc(doc(as('bob'), 'favorites/alice_l1')));
});

// ---------- conversations ----------
test('lecture d une conversation absente : OK', async () => {
  await assertSucceeds(getDoc(doc(as('carol'), 'conversations/l1_carol')));
});
test('acheteur cree la conversation l1_carol avec le proprietaire : OK', async () => {
  await assertSucceeds(setDoc(doc(as('carol'), 'conversations/l1_carol'), {
    participantIds: ['carol', 'alice'], listingId: 'l1',
    lastMessage: '', lastMessageAt: new Date(),
  }));
});
test('proprietaire qui ouvre une conversation sur sa propre annonce : refuse', async () => {
  await assertFails(setDoc(doc(as('alice'), 'conversations/l1_alice'), {
    participantIds: ['alice', 'alice'], listingId: 'l1',
    lastMessage: '', lastMessageAt: new Date(),
  }));
});
test('conversation avec un mauvais id : refuse', async () => {
  await assertFails(setDoc(doc(as('carol'), 'conversations/wrong'), {
    participantIds: ['carol', 'alice'], listingId: 'l1',
    lastMessage: '', lastMessageAt: new Date(),
  }));
});
test('autre participant different du proprietaire : refuse', async () => {
  await assertFails(setDoc(doc(as('carol'), 'conversations/l1_carol'), {
    participantIds: ['carol', 'bob'], listingId: 'l1',
    lastMessage: '', lastMessageAt: new Date(),
  }));
});
test('lecture par un non-participant : refuse', async () => {
  await assertFails(getDoc(doc(as('carol'), 'conversations/l1_bob')));
});
test('lecture par un participant : OK', async () => {
  await assertSucceeds(getDoc(doc(as('bob'), 'conversations/l1_bob')));
});
test('changer participantIds a l update : refuse', async () => {
  await assertFails(updateDoc(doc(as('bob'), 'conversations/l1_bob'),
    { participantIds: ['bob', 'carol'] }));
});
test('changer listingId a l update : refuse', async () => {
  await assertFails(updateDoc(doc(as('bob'), 'conversations/l1_bob'), { listingId: 'l9' }));
});
test('mettre a jour lastMessage : OK', async () => {
  await assertSucceeds(updateDoc(doc(as('bob'), 'conversations/l1_bob'), { lastMessage: 'salut' }));
});

// ---------- chat VST-44 : ecriture groupee message + conversation ----------
// L app ecrit la conversation avec set(..., merge) : creation au premier message,
// mise a jour ensuite. participantIds est toujours [acheteur, proprietaire].
test('chat : 1er message, set merge cree la conversation (acheteur) : OK', async () => {
  const db = as('carol');
  const conv = doc(db, 'conversations/l1_carol');
  const batch = writeBatch(db);
  batch.set(conv, {
    participantIds: ['carol', 'alice'], listingId: 'l1',
    lastMessage: 'salut', lastMessageAt: new Date(), unread: { alice: 1 },
  }, { merge: true });
  batch.set(doc(db, 'conversations/l1_carol/messages/m1'),
    { senderId: 'carol', text: 'salut', createdAt: new Date() });
  await assertSucceeds(batch.commit());
});
test('chat : reponse du proprietaire, set merge avec le meme ordre : OK', async () => {
  const db = as('alice');
  const conv = doc(db, 'conversations/l1_bob');
  const batch = writeBatch(db);
  batch.set(conv, {
    participantIds: ['bob', 'alice'], listingId: 'l1',
    lastMessage: 'oui', lastMessageAt: new Date(), unread: { bob: 1 },
  }, { merge: true });
  batch.set(doc(db, 'conversations/l1_bob/messages/m2'),
    { senderId: 'alice', text: 'oui', createdAt: new Date() });
  await assertSucceeds(batch.commit());
});
test('chat : set merge qui change l ordre de participantIds : refuse', async () => {
  await assertFails(setDoc(doc(as('alice'), 'conversations/l1_bob'), {
    participantIds: ['alice', 'bob'], listingId: 'l1',
    lastMessage: 'oui', lastMessageAt: new Date(),
  }, { merge: true }));
});
test('chat : compteur unread mis a jour par un participant : OK', async () => {
  await assertSucceeds(updateDoc(doc(as('bob'), 'conversations/l1_bob'), { 'unread.alice': 1 }));
});
test('chat : un non-participant ne peut pas modifier la conversation', async () => {
  await assertFails(updateDoc(doc(as('carol'), 'conversations/l1_bob'), { 'unread.alice': 0 }));
});
test('chat : un non-participant ne peut pas lister les conversations des autres', async () => {
  await assertFails(getDocs(query(collection(as('carol'), 'conversations'),
    where('participantIds', 'array-contains', 'bob'))));
});
test('chat : un participant liste ses conversations (array-contains) : OK', async () => {
  await assertSucceeds(getDocs(query(collection(as('bob'), 'conversations'),
    where('participantIds', 'array-contains', 'bob'))));
});
test('chat : message envoye sans conversation valide (non-participant) : refuse', async () => {
  const db = as('carol');
  const batch = writeBatch(db);
  batch.set(doc(db, 'conversations/l1_bob'), {
    participantIds: ['bob', 'alice'], listingId: 'l1', lastMessage: 'x', lastMessageAt: new Date(),
  }, { merge: true });
  batch.set(doc(db, 'conversations/l1_bob/messages/m3'),
    { senderId: 'carol', text: 'x', createdAt: new Date() });
  await assertFails(batch.commit());
});

// ---------- messages ----------
test('message ecrit par un participant : OK', async () => {
  await assertSucceeds(setDoc(doc(as('bob'), 'conversations/l1_bob/messages/m1'),
    { senderId: 'bob', text: 'hi', createdAt: new Date() }));
});
test('message avec un senderId usurpe : refuse', async () => {
  await assertFails(setDoc(doc(as('bob'), 'conversations/l1_bob/messages/m1'),
    { senderId: 'alice', text: 'hi', createdAt: new Date() }));
});
test('message ecrit par un non-participant : refuse', async () => {
  await assertFails(setDoc(doc(as('carol'), 'conversations/l1_bob/messages/m1'),
    { senderId: 'carol', text: 'hi', createdAt: new Date() }));
});
test('message lu par un non-participant : refuse', async () => {
  await assertFails(getDoc(doc(as('carol'), 'conversations/l1_bob/messages/m0')));
});
test('message modifie : refuse', async () => {
  await assertFails(updateDoc(doc(as('bob'), 'conversations/l1_bob/messages/m0'), { text: 'edit' }));
});
test('message supprime : refuse', async () => {
  await assertFails(deleteDoc(doc(as('bob'), 'conversations/l1_bob/messages/m0')));
});

// ---------- hardening (VST-71) ----------
test('message de 2000 caracteres : OK', async () => {
  await assertSucceeds(setDoc(doc(as('bob'), 'conversations/l1_bob/messages/m1'),
    { senderId: 'bob', text: 'a'.repeat(2000), createdAt: new Date() }));
});
test('message de 2001 caracteres : refuse', async () => {
  await assertFails(setDoc(doc(as('bob'), 'conversations/l1_bob/messages/m1'),
    { senderId: 'bob', text: 'a'.repeat(2001), createdAt: new Date() }));
});
test('profil : createdAt non modifiable', async () => {
  await assertFails(updateDoc(doc(as('alice'), 'users/alice'), { createdAt: new Date() }));
});
test('contact : email qui n est pas un texte : refuse', async () => {
  await assertFails(setDoc(doc(as('alice'), 'users/alice/private/contact'), { email: 12345 }));
});
test('contact : phone qui n est pas un texte : refuse', async () => {
  await assertFails(setDoc(doc(as('alice'), 'users/alice/private/contact'),
    { email: 'a@x.tn', phone: 12345 }));
});
test('contact : email seul : OK', async () => {
  await assertSucceeds(setDoc(doc(as('alice'), 'users/alice/private/contact'),
    { email: 'b@x.tn' }));
});
test('contact : email et phone en texte : OK', async () => {
  await assertSucceeds(setDoc(doc(as('alice'), 'users/alice/private/contact'),
    { email: 'b@x.tn', phone: '+21612345678' }));
});
test('annonce : createdAt non modifiable', async () => {
  await assertFails(updateDoc(doc(as('alice'), 'listings/l1'), { createdAt: new Date() }));
});
test('annonce : le proprietaire modifie le titre : OK', async () => {
  await assertSucceeds(updateDoc(doc(as('alice'), 'listings/l1'), { title: 'Nouveau titre' }));
});

// ---------- photos (VST-35) ----------
test('photo lue par un utilisateur connecte : OK', async () => {
  await assertSucceeds(getDoc(doc(as('bob'), 'listings/l1/photos/p0')));
});
test('photo lue sans etre connecte : OK (navigation en invite, VST-72)', async () => {
  await assertSucceeds(getDoc(doc(anon(), 'listings/l1/photos/p0')));
});
test('proprietaire ajoute la photo p1 : OK', async () => {
  await assertSucceeds(setDoc(doc(as('alice'), 'listings/l1/photos/p1'),
    { base64: 'abc', createdAt: new Date() }));
});
test('les dix photos p0 a p9 avec photoCount 10 dans un lot : OK', async () => {
  const db = as('alice');
  const b = writeBatch(db);
  for (const id of ['p1', 'p2', 'p3', 'p4', 'p5', 'p6', 'p7', 'p8', 'p9']) {
    b.set(doc(db, `listings/l1/photos/${id}`), { base64: 'abc', createdAt: new Date() });
  }
  b.update(doc(db, 'listings/l1'), { photoCount: 10 });
  await assertSucceeds(b.commit());
});
test('photo p10 : refuse', async () => {
  await assertFails(setDoc(doc(as('alice'), 'listings/l1/photos/p10'),
    { base64: 'abc', createdAt: new Date() }));
});
test('photo avec un id libre (photo1) : refuse', async () => {
  await assertFails(setDoc(doc(as('alice'), 'listings/l1/photos/photo1'),
    { base64: 'abc', createdAt: new Date() }));
});
test('photo de 280000 caracteres exactement : OK', async () => {
  await assertSucceeds(setDoc(doc(as('alice'), 'listings/l1/photos/p2'),
    { base64: 'a'.repeat(280000), createdAt: new Date() }));
});
test('photo de 280001 caracteres : refuse', async () => {
  await assertFails(setDoc(doc(as('alice'), 'listings/l1/photos/p2'),
    { base64: 'a'.repeat(280001), createdAt: new Date() }));
});
test('photo sans champ base64 : refuse', async () => {
  await assertFails(setDoc(doc(as('alice'), 'listings/l1/photos/p2'),
    { createdAt: new Date() }));
});
test('photo avec un base64 qui n est pas un texte : refuse', async () => {
  await assertFails(setDoc(doc(as('alice'), 'listings/l1/photos/p2'),
    { base64: 12345, createdAt: new Date() }));
});
test('mise a jour d une photo par un autre utilisateur : refuse', async () => {
  await assertFails(updateDoc(doc(as('bob'), 'listings/l1/photos/p0'), { base64: 'xyz' }));
});
test('photo avec un champ supplementaire volumineux : refuse', async () => {
  await assertFails(setDoc(doc(as('alice'), 'listings/l1/photos/p2'),
    { base64: 'abc', createdAt: new Date(), junk: 'a'.repeat(500000) }));
});
// ---------- VST-74 : types d'offre, statuts, nouveaux champs ----------
const create = (over) => setDoc(doc(as('alice'), 'listings/l2'), makeListing('alice', over));
const stay = { listingType: 'rent', rentPeriod: 'night', propertyType: 'guest_house' };
const longRent = { listingType: 'rent', rentPeriod: 'month' };

test('terrain a vendre (land) : OK', async () => {
  await assertSucceeds(create({ propertyType: 'land' }));
});
test('local commercial a louer au mois : OK', async () => {
  await assertSucceeds(create({ ...longRent, propertyType: 'commercial' }));
});
test('terrain loue a la nuit : refuse', async () => {
  await assertFails(create({ listingType: 'rent', rentPeriod: 'night', propertyType: 'land' }));
});
test('local commercial loue a la nuit : refuse', async () => {
  await assertFails(create({ listingType: 'rent', rentPeriod: 'night', propertyType: 'commercial' }));
});
test('sejour (location a la nuit) maison d hotes : OK', async () => {
  await assertSucceeds(create(stay));
});
test('prix a 0 : refuse', async () => {
  await assertFails(create({ price: 0 }));
});
test('prix negatif : refuse', async () => {
  await assertFails(create({ price: -5 }));
});
test('prix au maximum (50 000 000) : OK', async () => {
  await assertSucceeds(create({ price: 50000000 }));
});
test('prix absurde (VST-104) : refuse', async () => {
  await assertFails(create({ price: 50000001 }));
  await assertFails(create({ price: 9223372036854775807 }));
});

// statuts selon le type d'offre
test('statut absent : OK (traite comme available)', async () => {
  await assertSucceeds(create({}));
});
test('vente avec statut sold : OK', async () => {
  await assertSucceeds(create({ status: 'sold' }));
});
test('vente avec statut rented : refuse', async () => {
  await assertFails(create({ status: 'rented' }));
});
test('vente avec statut unavailable : refuse', async () => {
  await assertFails(create({ status: 'unavailable' }));
});
test('location au mois avec statut rented : OK', async () => {
  await assertSucceeds(create({ ...longRent, status: 'rented' }));
});
test('location au mois avec statut sold : refuse', async () => {
  await assertFails(create({ ...longRent, status: 'sold' }));
});
test('sejour avec statut unavailable : OK', async () => {
  await assertSucceeds(create({ ...stay, status: 'unavailable' }));
});
test('sejour avec statut sold : refuse', async () => {
  await assertFails(create({ ...stay, status: 'sold' }));
});
test('sejour avec statut rented : refuse', async () => {
  await assertFails(create({ ...stay, status: 'rented' }));
});
test('statut inconnu : refuse', async () => {
  await assertFails(create({ status: 'banana' }));
});
test('proprietaire passe son annonce en reserved : OK', async () => {
  await assertSucceeds(updateDoc(doc(as('alice'), 'listings/l1'), { status: 'reserved' }));
});
test('un autre utilisateur change le statut : refuse', async () => {
  await assertFails(updateDoc(doc(as('bob'), 'listings/l1'), { status: 'sold' }));
});
test('proprietaire passe en vente sold puis en a la nuit : refuse (statut incompatible)', async () => {
  await assertSucceeds(updateDoc(doc(as('alice'), 'listings/l1'), { status: 'sold' }));
  await assertFails(updateDoc(doc(as('alice'), 'listings/l1'),
    { listingType: 'rent', rentPeriod: 'night' }));
});

// badge verified : jamais pose par l'app
test('creation avec verified true : refuse', async () => {
  await assertFails(create({ verified: true }));
});
test('creation avec verified false : OK', async () => {
  await assertSucceeds(create({ verified: false }));
});
test('proprietaire se met verified true : refuse', async () => {
  await assertFails(updateDoc(doc(as('alice'), 'listings/l1'), { verified: true }));
});
test('annonce verified par la console, le proprietaire modifie le titre : OK', async () => {
  await env.withSecurityRulesDisabled(async (ctx) => {
    await updateDoc(doc(ctx.firestore(), 'listings/l1'), { verified: true });
  });
  await assertSucceeds(updateDoc(doc(as('alice'), 'listings/l1'), { title: 'Nouveau titre' }));
});
test('annonce verified par la console, le proprietaire retire le badge : refuse', async () => {
  await env.withSecurityRulesDisabled(async (ctx) => {
    await updateDoc(doc(ctx.firestore(), 'listings/l1'), { verified: true });
  });
  await assertFails(updateDoc(doc(as('alice'), 'listings/l1'), { verified: false }));
});

// nouveaux champs optionnels
test('furnished booleen : OK', async () => {
  await assertSucceeds(create({ ...longRent, furnished: true }));
});
test('furnished en texte : refuse', async () => {
  await assertFails(create({ ...longRent, furnished: 'oui' }));
});
test('negotiable en nombre : refuse', async () => {
  await assertFails(create({ negotiable: 1 }));
});
test('amenities valides : OK', async () => {
  await assertSucceeds(create({ ...stay, amenities: ['wifi', 'ac', 'pool'] }));
});
test('amenity inconnue : refuse', async () => {
  await assertFails(create({ ...stay, amenities: ['wifi', 'jacuzzi'] }));
});
test('amenities en texte au lieu d une liste : refuse', async () => {
  await assertFails(create({ ...stay, amenities: 'wifi' }));
});
test('11 amenities : refuse', async () => {
  await assertFails(create({ ...stay, amenities: Array(11).fill('wifi') }));
});
test('houseRules valides : OK', async () => {
  await assertSucceeds(create({ ...stay, houseRules: ['no_smoking', 'no_pets'] }));
});
test('houseRule inconnue : refuse', async () => {
  await assertFails(create({ ...stay, houseRules: ['no_dancing'] }));
});
test('checkIn 14:00 : OK', async () => {
  await assertSucceeds(create({ ...stay, checkIn: '14:00', checkOut: '11:30' }));
});
test('checkIn 25:99 : refuse', async () => {
  await assertFails(create({ ...stay, checkIn: '25:99' }));
});
test('checkIn sans les deux points : refuse', async () => {
  await assertFails(create({ ...stay, checkIn: '1400' }));
});
test('availableFrom en date : OK', async () => {
  await assertSucceeds(create({ ...longRent, availableFrom: new Date() }));
});
test('availableFrom en texte : refuse', async () => {
  await assertFails(create({ ...longRent, availableFrom: '2026-12-01' }));
});
test('maxGuests a 0 : refuse', async () => {
  await assertFails(create({ ...stay, maxGuests: 0 }));
});
test('maxGuests 4 et minNights 2 : OK', async () => {
  await assertSucceeds(create({ ...stay, maxGuests: 4, minNights: 2, beds: 3 }));
});
test('yearBuilt 1700 : refuse', async () => {
  await assertFails(create({ yearBuilt: 1700 }));
});
test('yearBuilt 2015 : OK', async () => {
  await assertSucceeds(create({ yearBuilt: 2015 }));
});
test('documentsNote de 201 caracteres : refuse', async () => {
  await assertFails(create({ documentsNote: 'a'.repeat(201) }));
});
test('documentsNote de 200 caracteres : OK', async () => {
  await assertSucceeds(create({ documentsNote: 'a'.repeat(200) }));
});
test('viewCount negatif : refuse', async () => {
  await assertFails(create({ viewCount: -1 }));
});
test('annonce existante sans nouveaux champs : le proprietaire peut encore la modifier', async () => {
  await assertSucceeds(updateDoc(doc(as('alice'), 'listings/l1'), { price: 120000 }));
});

// ---------- VST-74 : contact de l'annonce (listings/{id}/contact/info) ----------
const contactRef = (db, id = 'l1') => doc(db, `listings/${id}/contact/info`);
const seedContact = async () => {
  await env.withSecurityRulesDisabled(async (ctx) => {
    await setDoc(contactRef(ctx.firestore()), { contactPhone: '+21620123456', whatsappEnabled: true });
  });
};
test('contact : lu par un utilisateur connecte : OK', async () => {
  await seedContact();
  await assertSucceeds(getDoc(contactRef(as('bob'))));
});
test('contact : lu sans etre connecte (invite) : refuse', async () => {
  await seedContact();
  await assertFails(getDoc(contactRef(anon())));
});
test('contact : cree par le proprietaire avec un bon numero : OK', async () => {
  await assertSucceeds(setDoc(contactRef(as('alice')),
    { contactPhone: '+21620123456', whatsappEnabled: true }));
});
test('contact : numero qui commence par 9 : OK', async () => {
  await assertSucceeds(setDoc(contactRef(as('alice')), { contactPhone: '+21698123456' }));
});
test('contact : sans +216 : refuse', async () => {
  await assertFails(setDoc(contactRef(as('alice')), { contactPhone: '20123456' }));
});
test('contact : autre pays (+33) : refuse', async () => {
  await assertFails(setDoc(contactRef(as('alice')), { contactPhone: '+33612345678' }));
});
test('contact : 7 chiffres seulement : refuse', async () => {
  await assertFails(setDoc(contactRef(as('alice')), { contactPhone: '+2162012345' }));
});
test('contact : 9 chiffres : refuse', async () => {
  await assertFails(setDoc(contactRef(as('alice')), { contactPhone: '+216201234567' }));
});
test('contact : premier chiffre 1 : refuse', async () => {
  await assertFails(setDoc(contactRef(as('alice')), { contactPhone: '+21610123456' }));
});
test('contact : lettres dans le numero : refuse', async () => {
  await assertFails(setDoc(contactRef(as('alice')), { contactPhone: '+2162012345a' }));
});
test('contact : numero en nombre : refuse', async () => {
  await assertFails(setDoc(contactRef(as('alice')), { contactPhone: 21620123456 }));
});
test('contact : champ inconnu : refuse', async () => {
  await assertFails(setDoc(contactRef(as('alice')),
    { contactPhone: '+21620123456', email: 'x@y.tn' }));
});
test('contact : whatsappEnabled en texte : refuse', async () => {
  await assertFails(setDoc(contactRef(as('alice')),
    { contactPhone: '+21620123456', whatsappEnabled: 'oui' }));
});
test('contact : cree par un autre utilisateur : refuse', async () => {
  await assertFails(setDoc(contactRef(as('bob')), { contactPhone: '+21620123456' }));
});
test('contact : cree sans etre connecte : refuse', async () => {
  await assertFails(setDoc(contactRef(anon()), { contactPhone: '+21620123456' }));
});
test('contact d une annonce qui n existe pas : refuse', async () => {
  await assertFails(setDoc(contactRef(as('alice'), 'nope'), { contactPhone: '+21620123456' }));
});
test('contact : modifie par le proprietaire : OK', async () => {
  await seedContact();
  await assertSucceeds(updateDoc(contactRef(as('alice')), { whatsappEnabled: false }));
});
test('contact : modifie par un autre : refuse', async () => {
  await seedContact();
  await assertFails(updateDoc(contactRef(as('bob')), { contactPhone: '+21620999999' }));
});
test('contact : supprime par le proprietaire : OK', async () => {
  await seedContact();
  await assertSucceeds(deleteDoc(contactRef(as('alice'))));
});
test('contact : supprime par un autre : refuse', async () => {
  await seedContact();
  await assertFails(deleteDoc(contactRef(as('bob'))));
});
test('creation annonce + contact dans le meme lot : OK', async () => {
  const db = as('alice');
  const b = writeBatch(db);
  b.set(doc(db, 'listings/l2'), makeListing('alice'));
  b.set(contactRef(db, 'l2'), { contactPhone: '+21620123456', whatsappEnabled: true });
  await assertSucceeds(b.commit());
});
test('suppression annonce + photo + contact dans le meme lot : OK', async () => {
  await seedContact();
  const db = as('alice');
  const b = writeBatch(db);
  b.delete(doc(db, 'listings/l1/photos/p0'));
  b.delete(contactRef(db));
  b.delete(doc(db, 'listings/l1'));
  await assertSucceeds(b.commit());
});

// ---------- VST-72 : navigation en invite ----------
test('invite : ne peut pas creer d annonce', async () => {
  await assertFails(setDoc(doc(anon(), 'listings/l2'), makeListing('alice')));
});
test('invite : ne peut pas modifier une annonce', async () => {
  await assertFails(updateDoc(doc(anon(), 'listings/l1'), { title: 'Hack' }));
});
test('invite : ne peut pas supprimer une annonce', async () => {
  await assertFails(deleteDoc(doc(anon(), 'listings/l1')));
});
test('invite : ne peut pas ajouter de photo', async () => {
  await assertFails(setDoc(doc(anon(), 'listings/l1/photos/p1'),
    { base64: 'abc', createdAt: new Date() }));
});
test('invite : ne peut pas lire une conversation', async () => {
  await assertFails(getDoc(doc(anon(), 'conversations/l1_bob')));
});
test('invite : ne peut pas lire les favoris', async () => {
  await assertFails(getDoc(doc(anon(), 'favorites/alice_l1')));
});
