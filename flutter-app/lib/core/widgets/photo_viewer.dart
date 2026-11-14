import 'dart:convert';

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Shows a base64 photo full size in a dialog (VST-134). Pinch to zoom, tap
/// outside the photo to close. Does nothing if the photo is empty or cannot
/// be decoded.
Future<void> showPhotoViewer(BuildContext context, String? photoBase64) async {
  final data = photoBase64;
  if (data == null || data.isEmpty) return;

  final ImageProvider image;
  try {
    image = MemoryImage(base64Decode(data));
  } catch (_) {
    return; // bad base64: nothing to show
  }

  await showDialog<void>(
    context: context,
    builder: (dialogContext) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: GestureDetector(
        onTap: () => Navigator.of(dialogContext).pop(),
        child: InteractiveViewer(
          minScale: 1,
          maxScale: 4,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: ColoredBox(
              color: AppColors.navy,
              child: Image(
                key: const ValueKey('photo-viewer-image'),
                image: image,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
