import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../settings/asset_image_provider.dart';

/// A stored image (logo or signature) shown at its natural proportions.
class PageImage extends ConsumerWidget {
  const PageImage({required this.assetId, required this.maxHeight, super.key});

  final String assetId;
  final double maxHeight;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bytes = ref.watch(assetImageBytesProvider(assetId)).value;
    if (bytes == null) return SizedBox(height: maxHeight);
    return Align(
      alignment: Alignment.centerLeft,
      child: Image.memory(bytes, height: maxHeight, fit: BoxFit.contain),
    );
  }
}
