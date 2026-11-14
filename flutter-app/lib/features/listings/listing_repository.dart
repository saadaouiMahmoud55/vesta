import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/config/app_config.dart';
import 'listing.dart';

/// Errors the UI can show. Screens turn them into translated messages.
enum ListingError {
  notSignedIn,
  noPhotos,
  tooManyPhotos,
  noNetwork,
  permissionDenied,
  unknown,
}

class ListingFailure implements Exception {
  const ListingFailure(this.error);

  final ListingError error;
}

/// Maximum photos per listing (ids p0 to p9, see docs/data-model.md).
/// Keep it at 10 or less: photos are read sorted by id, and `p10` would
/// sort before `p2`.
const int maxListingPhotos = 10;

/// Values allowed by the rules and the data model.
const List<String> listingTypes = ['sale', 'rent'];
const List<String> rentPeriods = ['night', 'month', 'year'];
const List<String> propertyTypes = [
  'apartment',
  'house',
  'villa',
  'studio',
  'riad',
  'guest_house',
];

/// Keys allowed by the rules (docs/data-model.md). Max 10 amenities, 4 rules.
const List<String> amenityKeys = [
  'wifi',
  'ac',
  'heating',
  'kitchen',
  'parking',
  'pool',
  'breakfast',
  'washing_machine',
  'tv',
  'garden',
];
const List<String> houseRuleKeys = [
  'no_smoking',
  'no_pets',
  'no_parties',
  'quiet_hours',
];

/// Limits checked in the app (the rules only check the minimum).
const int maxGuestsLimit = 30;
const int maxRoomsLimit = 20;

/// Data entered in the publish form.
class NewListing {
  const NewListing({
    required this.title,
    required this.description,
    required this.price,
    required this.listingType,
    required this.propertyType,
    required this.city,
    this.rentPeriod,
    this.bedrooms,
    this.bathrooms,
    this.areaSqm,
    this.contactPhone,
    this.whatsappEnabled = false,
    this.maxGuests,
    this.amenities = const [],
    this.checkIn,
    this.checkOut,
    this.houseRules = const [],
    this.latitude,
    this.longitude,
  });

  final String title;
  final String description;
  final num price;
  final String listingType; // 'sale' or 'rent'
  final String? rentPeriod; // required only when listingType == 'rent'
  final String propertyType;
  final String city;
  final num? bedrooms;
  final num? bathrooms;
  final num? areaSqm;
  final String? contactPhone;
  final bool whatsappEnabled;
  final num? maxGuests;
  final List<String> amenities; // keys of amenityKeys
  final String? checkIn; // 'HH:mm'
  final String? checkOut; // 'HH:mm'
  final List<String> houseRules; // keys of houseRuleKeys
  final double? latitude; // exact position chosen on the map (optional)
  final double? longitude;
}

/// Only place that talks to the `listings` collection and its photos.
class ListingRepository {
  FirebaseFirestore get _db => FirebaseFirestore.instance;
  FirebaseAuth get _auth => FirebaseAuth.instance;

  /// Creates the listing and its photos in ONE batch write.
  /// [photosBase64] holds 1 to 10 already compressed base64 strings.
  /// Returns the id of the new listing.
  Future<String> createListing({
    required NewListing listing,
    required List<String> photosBase64,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw const ListingFailure(ListingError.notSignedIn);
    if (photosBase64.isEmpty) {
      throw const ListingFailure(ListingError.noPhotos);
    }
    if (photosBase64.length > maxListingPhotos) {
      throw const ListingFailure(ListingError.tooManyPhotos);
    }

    try {
      final ref = _db.collection('listings').doc(); // auto-id
      final batch = _db.batch();

      batch.set(ref, {
        'ownerId': user.uid,
        'title': listing.title,
        'description': listing.description,
        'price': listing.price,
        'currency': AppConfig.currency,
        'listingType': listing.listingType,
        // rentPeriod only for rentals, the field is absent for a sale
        if (listing.listingType == 'rent') 'rentPeriod': listing.rentPeriod,
        'propertyType': listing.propertyType,
        'city': listing.city,
        // docs/data-model.md: the apps always write the status.
        'status': 'available',
        // optional fields are written only when filled
        if (listing.bedrooms != null) 'bedrooms': listing.bedrooms,
        if (listing.bathrooms != null) 'bathrooms': listing.bathrooms,
        if (listing.areaSqm != null) 'areaSqm': listing.areaSqm,
        if (listing.maxGuests != null) 'maxGuests': listing.maxGuests,
        if (listing.amenities.isNotEmpty) 'amenities': listing.amenities,
        if (listing.checkIn != null) 'checkIn': listing.checkIn,
        if (listing.checkOut != null) 'checkOut': listing.checkOut,
        if (listing.houseRules.isNotEmpty) 'houseRules': listing.houseRules,
        if (listing.latitude != null && listing.longitude != null) ...{
          'latitude': listing.latitude,
          'longitude': listing.longitude,
        },
        'photoCount': photosBase64.length,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Fixed ids p0..p4: the id gives the display order, p0 = cover.
      for (var i = 0; i < photosBase64.length; i++) {
        batch.set(ref.collection('photos').doc('p$i'), {
          'base64': photosBase64[i],
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      // Private contact details stay outside the public listing document.
      final phone = listing.contactPhone;
      if (phone != null) {
        batch.set(ref.collection('contact').doc('info'), {
          'contactPhone': phone,
          'whatsappEnabled': listing.whatsappEnabled,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
      return ref.id;
    } on FirebaseException catch (e) {
      throw ListingFailure(_mapCode(e.code));
    }
  }

  /// Live list of the signed-in user's own listings, newest first.
  /// Needs the index (ownerId, createdAt desc) from firestore.indexes.json.
  Stream<List<Listing>> watchMyListings() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value(const []);
    return _db
        .collection('listings')
        .where('ownerId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(Listing.fromDoc).toList());
  }

  /// Deletes the listing, its photos and its contact in ONE batch
  /// (otherwise they stay orphaned, see docs/data-model.md).
  Future<void> deleteListing(Listing listing) async {
    final user = _auth.currentUser;
    if (user == null) throw const ListingFailure(ListingError.notSignedIn);

    try {
      final ref = _db.collection('listings').doc(listing.id);
      final batch = _db.batch();
      for (var i = 0; i < listing.photoCount; i++) {
        batch.delete(ref.collection('photos').doc('p$i'));
      }
      batch.delete(ref.collection('contact').doc('info'));
      batch.delete(ref);
      await batch.commit();
    } on FirebaseException catch (e) {
      throw ListingFailure(_mapCode(e.code));
    }
  }

  /// Reads the private contact of a listing (contact/info).
  /// Call it only for a signed-in user: guests must not even try (rules).
  /// Returns null when the owner gave no number.
  Future<({String phone, bool whatsapp})?> getContact(String listingId) async {
    try {
      final snap = await _db
          .collection('listings')
          .doc(listingId)
          .collection('contact')
          .doc('info')
          .get();
      final data = snap.data();
      final phone = data?['contactPhone'] as String?;
      if (phone == null) return null;
      return (phone: phone, whatsapp: data?['whatsappEnabled'] == true);
    } on FirebaseException catch (e) {
      throw ListingFailure(_mapCode(e.code));
    }
  }

  /// Reads listings by id, in the same order as [ids].
  /// An entry is null when the listing no longer exists (deleted by its
  /// owner) or cannot be read (for example hidden): the caller skips it
  /// or shows "no longer available".
  Future<List<Listing?>> getListingsByIds(List<String> ids) {
    return Future.wait(ids.map(_getListingOrNull));
  }

  Future<Listing?> _getListingOrNull(String id) async {
    try {
      final doc = await _db.collection('listings').doc(id).get();
      if (!doc.exists) return null;
      return Listing.fromDoc(doc);
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') return null;
      throw ListingFailure(_mapCode(e.code));
    }
  }

  /// Cover photo (id p0) of a listing, as base64. Null if there is none.
  Future<String?> getCoverPhotoBase64(String listingId) async {
    try {
      final doc = await _db
          .collection('listings')
          .doc(listingId)
          .collection('photos')
          .doc('p0')
          .get();
      return doc.data()?['base64'] as String?;
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') return null;
      throw ListingFailure(_mapCode(e.code));
    }
  }

  /// Newest listings first, for the Explore tab. Hidden listings are skipped:
  /// the rules let everybody read them, so the app must filter them.
  /// Sorting only on createdAt needs no Firestore index.
  Future<List<Listing>> getLatestListings({int limit = 20}) async {
    try {
      final snapshot = await _db
          .collection('listings')
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();
      return [
        for (final doc in snapshot.docs)
          if ((doc.data()['status'] as String?) != 'hidden')
            Listing.fromDoc(doc),
      ];
    } on FirebaseException catch (e) {
      throw ListingFailure(_mapCode(e.code));
    }
  }

  /// Reads one listing. Returns null when it does not exist.
  Future<Listing?> getListing(String id) async {
    try {
      final doc = await _db.collection('listings').doc(id).get();
      if (!doc.exists) return null;
      return Listing.fromDoc(doc);
    } on FirebaseException catch (e) {
      throw ListingFailure(_mapCode(e.code));
    }
  }

  /// Reads the photos of a listing as base64 strings, sorted by id
  /// (p0 first = cover). Ids can have gaps, so we never use the position.
  Future<List<String>> getPhotos(String id) async {
    try {
      final snap = await _db
          .collection('listings')
          .doc(id)
          .collection('photos')
          .get();
      final docs = snap.docs.toList()..sort((a, b) => a.id.compareTo(b.id));
      return [
        for (final doc in docs)
          if (doc.data()['base64'] is String) doc.data()['base64'] as String,
      ];
    } on FirebaseException catch (e) {
      throw ListingFailure(_mapCode(e.code));
    }
  }

  /// Changes only the status of a listing (owner only, enforced by the
  /// rules). `updatedAt` follows, like on every write.
  Future<void> updateStatus(Listing listing, String status) async {
    final user = _auth.currentUser;
    if (user == null) throw const ListingFailure(ListingError.notSignedIn);
    if (!allowedStatuses(offerTypeOf(listing)).contains(status)) {
      throw const ListingFailure(ListingError.unknown);
    }
    try {
      await _db.collection('listings').doc(listing.id).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      throw ListingFailure(_mapCode(e.code));
    }
  }

  ListingError _mapCode(String code) {
    switch (code) {
      case 'unavailable':
      case 'network-request-failed':
        return ListingError.noNetwork;
      case 'permission-denied':
        return ListingError.permissionDenied;
      default:
        return ListingError.unknown;
    }
  }
}
