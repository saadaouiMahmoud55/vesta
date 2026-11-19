// VST-34: tests for the authentication and `users` rules.
// Run with the emulator started (see ../README.md): npm test
import { readFileSync } from 'node:fs';
import { test, before, after, beforeEach } from 'node:test';
import {
  initializeTestEnvironment,
  assertSucceeds,
  assertFails,
} from '@firebase/rules-unit-testing';
import {
  doc, collection, getDoc, getDocs, setDoc, updateDoc, deleteDoc,
} from 'firebase/firestore';

let env;
const as = (uid) => env.authenticatedContext(uid).firestore();
const anon = () => env.unauthenticatedContext().firestore();

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
  });
});

// ---------- signed-out user ----------
test('signed out: cannot read a profile', async () => {
  await assertFails(getDoc(doc(anon(), 'users/alice')));
});
test('signed out: cannot list profiles', async () => {
  await assertFails(getDocs(collection(anon(), 'users')));
});
test('signed out: cannot create a profile', async () => {
  await assertFails(setDoc(doc(anon(), 'users/eve'), { displayName: 'Eve' }));
});
test('signed out: cannot read private contact', async () => {
  await assertFails(getDoc(doc(anon(), 'users/alice/private/contact')));
});
test('signed out: cannot write a listing, a favorite or a conversation', async () => {
  const db = anon();
  await assertFails(setDoc(doc(db, 'favorites/eve_l1'), { userId: 'eve', listingId: 'l1' }));
  await assertFails(setDoc(doc(db, 'conversations/l1_eve'), {
    participantIds: ['eve', 'alice'], listingId: 'l1',
  }));
  await assertFails(setDoc(doc(db, 'listings/l9'), { ownerId: 'eve', title: 'T' }));
});

// ---------- signed-in user: profiles ----------
test('signed in: can read another user public profile', async () => {
  await assertSucceeds(getDoc(doc(as('bob'), 'users/alice')));
});
test('signed in: can list profiles', async () => {
  await assertSucceeds(getDocs(collection(as('bob'), 'users')));
});
test('sign-up: user creates own profile and private contact', async () => {
  const db = as('bob');
  await assertSucceeds(setDoc(doc(db, 'users/bob'), {
    displayName: 'Bob', createdAt: new Date(),
  }));
  await assertSucceeds(setDoc(doc(db, 'users/bob/private/contact'), { email: 'b@x.tn' }));
});
test('user cannot create a profile for someone else', async () => {
  await assertFails(setDoc(doc(as('bob'), 'users/carol'), { displayName: 'Carol' }));
});
test('profile without displayName is refused', async () => {
  await assertFails(setDoc(doc(as('bob'), 'users/bob'), { createdAt: new Date() }));
});
test('displayName that is not a string is refused', async () => {
  await assertFails(setDoc(doc(as('bob'), 'users/bob'), { displayName: 42 }));
});
test('user can update own displayName', async () => {
  await assertSucceeds(updateDoc(doc(as('alice'), 'users/alice'), { displayName: 'Alice B' }));
});
test('user cannot update someone else profile', async () => {
  await assertFails(updateDoc(doc(as('bob'), 'users/alice'), { displayName: 'Hacked' }));
});
test('photoBase64 under the limit: OK', async () => {
  await assertSucceeds(updateDoc(doc(as('alice'), 'users/alice'),
    { photoBase64: 'a'.repeat(270000) }));
});
test('photoBase64 over the limit: refused', async () => {
  await assertFails(updateDoc(doc(as('alice'), 'users/alice'),
    { photoBase64: 'a'.repeat(300000) }));
});
test('photoBase64 that is not a string: refused', async () => {
  await assertFails(updateDoc(doc(as('alice'), 'users/alice'), { photoBase64: 123 }));
});

// ---------- delete ----------
test('user cannot delete someone else profile', async () => {
  await assertFails(deleteDoc(doc(as('bob'), 'users/alice')));
});
test('user cannot delete someone else private contact', async () => {
  await assertFails(deleteDoc(doc(as('bob'), 'users/alice/private/contact')));
});
test('user can delete own profile', async () => {
  await assertSucceeds(deleteDoc(doc(as('alice'), 'users/alice')));
});

// ---------- private contact ----------
test('private contact: other user cannot write it', async () => {
  await assertFails(setDoc(doc(as('bob'), 'users/alice/private/contact'), { email: 'evil@x.tn' }));
});
test('private contact: owner can update it', async () => {
  await assertSucceeds(setDoc(doc(as('alice'), 'users/alice/private/contact'),
    { email: 'new@x.tn', phone: '20123456' }));
});
test('private: only the document named contact is allowed', async () => {
  await assertFails(setDoc(doc(as('alice'), 'users/alice/private/other'), { x: 1 }));
});

// ---------- anything not described in the data model ----------
test('unknown collection: read and write refused even when signed in', async () => {
  const db = as('alice');
  await assertFails(getDoc(doc(db, 'admin/config')));
  await assertFails(setDoc(doc(db, 'admin/config'), { x: 1 }));
});
test('unknown subcollection under users: refused', async () => {
  await assertFails(setDoc(doc(as('alice'), 'users/alice/secrets/s1'), { x: 1 }));
});
