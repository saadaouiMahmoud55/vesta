import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';

/// Translated label of an amenity key (the database stores the key only).
String amenityLabel(AppLocalizations l, String key) {
  switch (key) {
    case 'wifi':
      return l.amenityWifi;
    case 'ac':
      return l.amenityAc;
    case 'heating':
      return l.amenityHeating;
    case 'kitchen':
      return l.amenityKitchen;
    case 'parking':
      return l.amenityParking;
    case 'pool':
      return l.amenityPool;
    case 'breakfast':
      return l.amenityBreakfast;
    case 'washing_machine':
      return l.amenityWashingMachine;
    case 'tv':
      return l.amenityTv;
    default:
      return l.amenityGarden;
  }
}

IconData amenityIcon(String key) {
  switch (key) {
    case 'wifi':
      return Icons.wifi;
    case 'ac':
      return Icons.ac_unit;
    case 'heating':
      return Icons.thermostat;
    case 'kitchen':
      return Icons.kitchen;
    case 'parking':
      return Icons.local_parking;
    case 'pool':
      return Icons.pool;
    case 'breakfast':
      return Icons.free_breakfast;
    case 'washing_machine':
      return Icons.local_laundry_service;
    case 'tv':
      return Icons.tv;
    default:
      return Icons.yard;
  }
}

String houseRuleLabel(AppLocalizations l, String key) {
  switch (key) {
    case 'no_smoking':
      return l.ruleNoSmoking;
    case 'no_pets':
      return l.ruleNoPets;
    case 'no_parties':
      return l.ruleNoParties;
    default:
      return l.ruleQuietHours;
  }
}

IconData houseRuleIcon(String key) {
  switch (key) {
    case 'no_smoking':
      return Icons.smoke_free;
    case 'no_pets':
      return Icons.pets;
    case 'no_parties':
      return Icons.celebration;
    default:
      return Icons.bedtime;
  }
}
