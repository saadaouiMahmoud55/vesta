import 'dart:convert';

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Round avatar: the photo (base64) if there is one, otherwise the initials
/// of [name], otherwise a person icon.
class AppAvatar extends StatelessWidget {
  const AppAvatar({super.key, this.photoBase64, this.name, this.radius = 24});

  final String? photoBase64;
  final String? name;
  final double radius;

  String _initials() {
    final parts = (name ?? '')
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '';
    final first = parts.first.substring(0, 1);
    if (parts.length == 1) return first.toUpperCase();
    return (first + parts.last.substring(0, 1)).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    ImageProvider? image;
    final data = photoBase64;
    if (data != null && data.isNotEmpty) {
      try {
        image = MemoryImage(base64Decode(data));
      } catch (_) {
        image = null; // bad base64: show the initials
      }
    }
    final initials = _initials();
    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.primary,
      backgroundImage: image,
      child: image != null
          ? null
          : initials.isEmpty
          ? Icon(Icons.person, size: radius, color: AppColors.white)
          : Text(
              initials,
              style: TextStyle(
                fontSize: radius * 0.75,
                fontWeight: FontWeight.w500,
                color: AppColors.white,
              ),
            ),
    );
  }
}
