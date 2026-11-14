import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/phone_utils.dart';
import '../../l10n/generated/app_localizations.dart';
import '../map/location_picker_screen.dart';
import '../map/tunisia_places.dart';
import 'listing_controller.dart';
import 'listing_labels.dart';
import 'listing_repository.dart';
import 'photo_service.dart';

class PublishListingScreen extends ConsumerStatefulWidget {
  const PublishListingScreen({super.key});

  @override
  ConsumerState<PublishListingScreen> createState() =>
      _PublishListingScreenState();
}

class _PublishListingScreenState extends ConsumerState<PublishListingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _price = TextEditingController();
  final _city = TextEditingController();
  final _cityFocus = FocusNode();
  // Exact position chosen on the map (optional, VST-42).
  LatLng? _location;
  final _bedrooms = TextEditingController();
  final _bathrooms = TextEditingController();
  final _area = TextEditingController();
  final _phone = TextEditingController();
  final _guests = TextEditingController();
  final _photoService = PhotoService();

  String _listingType = 'sale';
  String? _rentPeriod;
  String _propertyType = 'apartment';
  bool _whatsapp = false;
  final List<String> _photos = []; // base64 strings, index 0 = cover
  final Set<String> _amenities = {};
  final Set<String> _houseRules = {};
  TimeOfDay? _checkIn;
  TimeOfDay? _checkOut;
  String? _photoMessage;
  bool _rentPeriodMissing = false;

  @override
  void dispose() {
    for (final c in [
      _title,
      _description,
      _price,
      _city,
      _bedrooms,
      _bathrooms,
      _area,
      _phone,
      _guests,
    ]) {
      c.dispose();
    }
    _cityFocus.dispose();
    super.dispose();
  }

  // ---- translation of error enums (no text in the logic files) ----
  String _fieldError(AppLocalizations l, ListingFieldError e) {
    switch (e) {
      case ListingFieldError.titleRequired:
        return l.listingErrorTitleRequired;
      case ListingFieldError.descriptionRequired:
        return l.listingErrorDescriptionRequired;
      case ListingFieldError.priceInvalid:
        return l.listingErrorPriceInvalid;
      case ListingFieldError.cityRequired:
        return l.listingErrorCityRequired;
      case ListingFieldError.rentPeriodRequired:
        return l.listingErrorRentPeriodRequired;
      case ListingFieldError.numberInvalid:
        return l.listingErrorNumberInvalid;
      case ListingFieldError.guestsInvalid:
        return l.listingErrorGuestsInvalid;
      case ListingFieldError.roomsInvalid:
        return l.listingErrorRoomsInvalid;
    }
  }

  String _listingError(AppLocalizations l, ListingError e) {
    switch (e) {
      case ListingError.notSignedIn:
        return l.listingErrorNotSignedIn;
      case ListingError.noPhotos:
        return l.listingErrorNoPhotos;
      case ListingError.tooManyPhotos:
        return l.listingErrorTooManyPhotos;
      case ListingError.noNetwork:
        return l.listingErrorNoNetwork;
      case ListingError.permissionDenied:
        return l.listingErrorPermissionDenied;
      case ListingError.unknown:
        return l.listingErrorUnknown;
    }
  }

  String _photoError(AppLocalizations l, PhotoError e) {
    switch (e) {
      case PhotoError.tooManyPhotos:
        return l.listingErrorTooManyPhotos;
      case PhotoError.tooLarge:
        return l.photoErrorTooLarge;
      case PhotoError.readFailed:
        return l.photoErrorReadFailed;
    }
  }

  String _propertyLabel(AppLocalizations l, String type) {
    switch (type) {
      case 'apartment':
        return l.propertyApartment;
      case 'house':
        return l.propertyHouse;
      case 'villa':
        return l.propertyVilla;
      case 'studio':
        return l.propertyStudio;
      case 'riad':
        return l.propertyRiad;
      default:
        return l.propertyGuestHouse;
    }
  }

  String _periodLabel(AppLocalizations l, String period) {
    switch (period) {
      case 'night':
        return l.publishPeriodNight;
      case 'month':
        return l.publishPeriodMonth;
      default:
        return l.publishPeriodYear;
    }
  }

  // ---- time: shown with the device format, stored as HH:mm ----
  String _hhmm(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:'
      '${t.minute.toString().padLeft(2, '0')}';

  Future<void> _pickTime({required bool checkIn}) async {
    final picked = await showTimePicker(
      context: context,
      initialTime:
          (checkIn ? _checkIn : _checkOut) ??
          TimeOfDay(hour: checkIn ? 14 : 11, minute: 0),
    );
    if (picked == null || !mounted) return;
    setState(() {
      if (checkIn) {
        _checkIn = picked;
      } else {
        _checkOut = picked;
      }
    });
  }

  // ---- photos ----
  /// Gallery: several photos at once. Camera: one photo.
  /// A photo already in the list is not added twice.
  Future<void> _addPhoto(ImageSource source) async {
    final l = AppLocalizations.of(context);
    try {
      final remaining = maxListingPhotos - _photos.length;
      final List<String> picked;
      if (source == ImageSource.gallery) {
        picked = await _photoService.pickPhotos(remaining: remaining);
      } else {
        final one = await _photoService.pickPhoto(
          source: source,
          currentCount: _photos.length,
          maxPhotos: maxListingPhotos,
        );
        picked = [?one];
      }
      if (picked.isEmpty || !mounted) return;
      final added = addUniquePhotos(
        _photos,
        picked,
        max: maxListingPhotos,
      );
      setState(() {
        _photos
          ..clear()
          ..addAll(added.photos);
        _photoMessage = added.duplicates
            ? l.publishPhotosDuplicates
            : added.overLimit
                ? l.listingErrorTooManyPhotos
                : null;
      });
    } on PhotoFailure catch (e) {
      if (!mounted) return;
      setState(() => _photoMessage = _photoError(l, e.error));
    } catch (_) {
      if (!mounted) return;
      setState(() => _photoMessage = l.photoErrorReadFailed);
    }
  }

  // ---- submit ----
  num? _optional(TextEditingController c) {
    final text = c.text.trim();
    return text.isEmpty ? null : num.tryParse(text);
  }

  Future<void> _submit() async {
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);

    final formOk = _formKey.currentState!.validate();
    final periodMissing = validateRentPeriod(_listingType, _rentPeriod) != null;
    setState(() {
      _rentPeriodMissing = periodMissing;
      if (_photos.isEmpty) _photoMessage = l.listingErrorNoPhotos;
    });
    if (!formOk || periodMissing || _photos.isEmpty) return;

    final listing = NewListing(
      title: _title.text.trim(),
      description: _description.text.trim(),
      price: num.parse(_price.text.trim()),
      listingType: _listingType,
      rentPeriod: _listingType == 'rent' ? _rentPeriod : null,
      propertyType: _propertyType,
      city: _city.text.trim(),
      bedrooms: _optional(_bedrooms),
      bathrooms: _optional(_bathrooms),
      areaSqm: _optional(_area),
      contactPhone: normalizeTunisianPhone(_phone.text),
      whatsappEnabled: _whatsapp,
      maxGuests: _optional(_guests),
      // Keep the order of amenityKeys / houseRuleKeys, whatever the taps.
      amenities: [
        for (final k in amenityKeys)
          if (_amenities.contains(k)) k,
      ],
      checkIn: _checkIn == null ? null : _hhmm(_checkIn!),
      checkOut: _checkOut == null ? null : _hhmm(_checkOut!),
      houseRules: [
        for (final k in houseRuleKeys)
          if (_houseRules.contains(k)) k,
      ],
      latitude: _location == null ? null : _round6(_location!.latitude),
      longitude: _location == null ? null : _round6(_location!.longitude),
    );

    final ok = await ref
        .read(listingControllerProvider.notifier)
        .publish(listing: listing, photosBase64: List.of(_photos));
    if (!mounted) return;

    if (ok) {
      messenger.showSnackBar(SnackBar(content: Text(l.publishSuccess)));
      ref.read(listingControllerProvider.notifier).reset();
      context.pop();
    }
  }

  /// Rounds to 6 decimals (about 10 cm): enough, and a clean number.
  double _round6(double v) => (v * 1e6).roundToDouble() / 1e6;

  /// City with suggestions: the owner types and picks a Tunisian city or town
  /// (Latin or Arabic spelling). Typing something else is still allowed.
  Widget _cityField(AppLocalizations l) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    return RawAutocomplete<TunisiaPlace>(
      textEditingController: _city,
      focusNode: _cityFocus,
      displayStringForOption: (place) => place.name,
      optionsBuilder: (value) => searchPlaces(value.text),
      onSelected: (_) => setState(() {}),
      fieldViewBuilder: (context, controller, focusNode, onSubmitted) {
        return TextFormField(
          controller: controller,
          focusNode: focusNode,
          decoration: InputDecoration(
            labelText: l.publishFieldCity,
            helperText: l.publishCityHelper,
            suffixIcon: const Icon(Icons.search),
          ),
          onChanged: (_) => setState(() {}),
          validator: (v) {
            final e = validateCity(v);
            return e == null ? null : _fieldError(l, e);
          },
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: AlignmentDirectional.topStart,
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(8),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: 240,
                maxWidth: MediaQuery.sizeOf(context).width - 32,
              ),
              child: ListView(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                children: [
                  for (final place in options)
                    ListTile(
                      dense: true,
                      leading: const Icon(Icons.place_outlined),
                      title: Text(isArabic ? place.nameAr : place.name),
                      subtitle: Text(isArabic ? place.name : place.nameAr),
                      onTap: () => onSelected(place),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickLocation() async {
    final picked = await Navigator.of(context).push<LatLng>(
      MaterialPageRoute(
        builder: (_) => LocationPickerScreen(
          initialPoint: _location,
          cityCenter: placeByName(_city.text)?.point,
        ),
      ),
    );
    if (picked != null && mounted) setState(() => _location = picked);
  }

  /// Button to place the exact position on the map, and its state.
  Widget _locationTile(AppLocalizations l) {
    final theme = Theme.of(context);
    final location = _location;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OutlinedButton.icon(
          onPressed: _pickLocation,
          icon: const Icon(Icons.pin_drop_outlined),
          label: Text(
            location == null ? l.publishLocationSet : l.publishLocationChange,
          ),
        ),
        const SizedBox(height: 4),
        if (location == null)
          Text(l.publishLocationHint, style: theme.textTheme.bodySmall)
        else
          Row(
            children: [
              const Icon(Icons.check_circle, size: 18, color: AppColors.primary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(l.publishLocationSaved,
                    style: theme.textTheme.bodySmall),
              ),
              TextButton(
                onPressed: () => setState(() => _location = null),
                child: Text(l.publishLocationRemove),
              ),
            ],
          ),
      ],
    );
  }

  Widget _timeTile({
    required String label,
    required TimeOfDay? value,
    required String emptyLabel,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: const Icon(Icons.schedule),
        label: Text(
          '$label: ${value == null ? emptyLabel : value.format(context)}',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final state = ref.watch(listingControllerProvider);
    final loading = state.isLoading;

    String? fieldValidator(
      String? v,
      ListingFieldError? Function(String?) check,
    ) {
      final e = check(v);
      return e == null ? null : _fieldError(l, e);
    }

    return Scaffold(
      appBar: AppBar(title: Text(l.publishTitle)),
      body: AbsorbPointer(
        absorbing: loading,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextFormField(
                controller: _title,
                decoration: InputDecoration(labelText: l.publishFieldTitle),
                validator: (v) => fieldValidator(v, validateTitle),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _description,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: l.publishFieldDescription,
                ),
                validator: (v) => fieldValidator(v, validateDescription),
              ),
              const SizedBox(height: 12),
              SegmentedButton<String>(
                segments: [
                  ButtonSegment(value: 'sale', label: Text(l.publishTypeSale)),
                  ButtonSegment(value: 'rent', label: Text(l.publishTypeRent)),
                ],
                selected: {_listingType},
                onSelectionChanged: (s) => setState(() {
                  _listingType = s.first;
                  if (_listingType == 'sale') _rentPeriod = null;
                  _rentPeriodMissing = false;
                }),
              ),
              if (_listingType == 'rent') ...[
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _rentPeriod,
                  decoration: InputDecoration(
                    labelText: l.publishRentPeriod,
                    errorText: _rentPeriodMissing
                        ? l.listingErrorRentPeriodRequired
                        : null,
                  ),
                  items: [
                    for (final p in rentPeriods)
                      DropdownMenuItem(
                        value: p,
                        child: Text(_periodLabel(l, p)),
                      ),
                  ],
                  onChanged: (v) => setState(() {
                    _rentPeriod = v;
                    _rentPeriodMissing = false;
                  }),
                ),
              ],
              const SizedBox(height: 12),
              TextFormField(
                controller: _price,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(labelText: l.publishFieldPrice),
                validator: (v) => fieldValidator(v, validatePrice),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _propertyType,
                decoration: InputDecoration(labelText: l.publishPropertyType),
                items: [
                  for (final t in propertyTypes)
                    DropdownMenuItem(
                      value: t,
                      child: Text(_propertyLabel(l, t)),
                    ),
                ],
                onChanged: (v) =>
                    setState(() => _propertyType = v ?? _propertyType),
              ),
              const SizedBox(height: 12),
              _cityField(l),
              const SizedBox(height: 12),
              _locationTile(l),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phone,
                keyboardType: TextInputType.phone,
                textDirection: TextDirection.ltr,
                decoration: InputDecoration(
                  labelText: l.publishFieldPhone,
                  prefixText: '+216 ',
                ),
                validator: (v) => isValidTunisianPhone(v ?? '')
                    ? null
                    : l.listingErrorPhoneInvalid,
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l.publishWhatsapp),
                value: _whatsapp,
                onChanged: (v) => setState(() => _whatsapp = v),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _guests,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: l.publishFieldGuests),
                validator: (v) => fieldValidator(v, validateGuests),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _bedrooms,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: l.publishFieldBedrooms,
                ),
                validator: (v) => fieldValidator(v, validateRooms),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _bathrooms,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: l.publishFieldBathrooms,
                ),
                validator: (v) => fieldValidator(v, validateRooms),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _area,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(labelText: l.publishFieldArea),
                validator: (v) => fieldValidator(v, validateOptionalNumber),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      l.publishAmenitiesTitle,
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                  Text(l.publishAmenitiesCounter(_amenities.length)),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final key in amenityKeys)
                    FilterChip(
                      avatar: Icon(amenityIcon(key), size: 18),
                      label: Text(amenityLabel(l, key)),
                      selected: _amenities.contains(key),
                      onSelected: (on) => setState(() {
                        if (on) {
                          _amenities.add(key);
                        } else {
                          _amenities.remove(key);
                        }
                      }),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  _timeTile(
                    label: l.publishCheckIn,
                    value: _checkIn,
                    emptyLabel: l.publishTimeNotSet,
                    onTap: () => _pickTime(checkIn: true),
                  ),
                  const SizedBox(width: 12),
                  _timeTile(
                    label: l.publishCheckOut,
                    value: _checkOut,
                    emptyLabel: l.publishTimeNotSet,
                    onTap: () => _pickTime(checkIn: false),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(l.publishRulesTitle, style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final key in houseRuleKeys)
                    FilterChip(
                      avatar: Icon(houseRuleIcon(key), size: 18),
                      label: Text(houseRuleLabel(l, key)),
                      selected: _houseRules.contains(key),
                      onSelected: (on) => setState(() {
                        if (on) {
                          _houseRules.add(key);
                        } else {
                          _houseRules.remove(key);
                        }
                      }),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                '${l.publishPhotosTitle}  ${_photos.length}/$maxListingPhotos',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: () => _addPhoto(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library_outlined),
                    label: Text(l.publishAddFromGallery),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    onPressed: () => _addPhoto(ImageSource.camera),
                    icon: const Icon(Icons.photo_camera_outlined),
                    label: Text(l.publishAddFromCamera),
                  ),
                ],
              ),
              if (_photoMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    _photoMessage!,
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                ),
              const SizedBox(height: 8),
              SizedBox(
                height: 96,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _photos.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, i) => Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.memory(
                          base64Decode(_photos[i]),
                          width: 96,
                          height: 96,
                          fit: BoxFit.cover,
                        ),
                      ),
                      PositionedDirectional(
                        top: 0,
                        end: 0,
                        child: IconButton(
                          tooltip: l.publishRemovePhoto,
                          iconSize: 18,
                          color: AppColors.white,
                          style: IconButton.styleFrom(
                            backgroundColor: AppColors.navy.withValues(
                              alpha: 0.6,
                            ),
                          ),
                          icon: const Icon(Icons.close),
                          onPressed: () => setState(() {
                            _photos.removeAt(i);
                            _photoMessage = null;
                          }),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (state.error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    _listingError(l, state.error!),
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: loading ? null : _submit,
                child: loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l.publishSubmit),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
