import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/app_color_tokens.dart';
import '../../app/theme/app_typography.dart';
import '../../data/images/image_import_service.dart';
import 'asset_image_provider.dart';

/// Opens the system image picker and returns the chosen file's bytes, or null
/// when the person cancels.
Future<Uint8List?> pickImageBytesFromDevice() async {
  final file = await FilePicker.pickFile(type: FileType.image);
  return file?.readAsBytes();
}

/// Shows the current image with buttons to choose or remove one. A file that
/// is not an image shows its message under the buttons.
class ImagePickerField extends ConsumerStatefulWidget {
  const ImagePickerField({
    required this.label,
    required this.assetId,
    required this.onImagePicked,
    required this.onRemove,
    this.pickImageBytes = pickImageBytesFromDevice,
    super.key,
  });

  final String label;
  final String? assetId;
  final Future<void> Function(Uint8List bytes) onImagePicked;
  final VoidCallback onRemove;
  final Future<Uint8List?> Function() pickImageBytes;

  @override
  ConsumerState<ImagePickerField> createState() => _ImagePickerFieldState();
}

class _ImagePickerFieldState extends ConsumerState<ImagePickerField> {
  String? _errorMessage;

  Future<void> _choose() async {
    String? errorMessage;
    try {
      final bytes = await widget.pickImageBytes();
      if (bytes == null) return;
      await widget.onImagePicked(bytes);
    } on ImageImportException catch (exception) {
      errorMessage = exception.message;
    } on Object {
      errorMessage = "Couldn't import that image";
      if (mounted) setState(() => _errorMessage = errorMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<AppColorTokens>()!;
    final assetId = widget.assetId;
    final imageBytes = assetId == null
        ? null
        : ref.watch(assetImageBytesProvider(assetId)).value;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: tokens.paper,
            border: Border.all(color: tokens.rule),
            borderRadius: BorderRadius.circular(4),
          ),
          child: imageBytes == null
              ? Icon(Icons.image_outlined, color: tokens.rule)
              : Padding(
                  padding: const EdgeInsets.all(4),
                  child: Image.memory(imageBytes, fit: BoxFit.contain),
                ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.label,
                style: const TextStyle(fontSize: AppTypography.body),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  OutlinedButton(
                    onPressed: _choose,
                    child: Text(
                      assetId == null ? 'Choose image' : 'Replace image',
                    ),
                  ),
                  if (assetId != null)
                    TextButton(
                      onPressed: widget.onRemove,
                      child: const Text('Remove image'),
                    ),
                ],
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 6),
                Text(
                  _errorMessage!,
                  style: TextStyle(
                    fontSize: AppTypography.caption,
                    color: theme.colorScheme.error,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
