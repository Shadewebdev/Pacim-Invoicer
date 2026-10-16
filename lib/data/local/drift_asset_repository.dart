import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart';
import 'package:pacim_invoicer/data/local/pacim_database.dart';
import 'package:pacim_invoicer/data/repositories/asset_repository.dart';
import 'package:pacim_invoicer/domain/exceptions/document_exceptions.dart';

const String _pngMimeType = 'image/png';
const String _jpegMimeType = 'image/jpeg';
const List<int> _pngSignature = [0x89, 0x50, 0x4E, 0x47];

class DriftAssetRepository implements AssetRepository {
  DriftAssetRepository(this._database);

  final PacimDatabase _database;

  @override
  Future<String> storeImage(Uint8List bytes) async {
    final assetId = sha256.convert(bytes).toString();
    try {
      await _database
          .into(_database.assetRows)
          .insert(
            AssetRowsCompanion.insert(
              assetId: assetId,
              bytes: bytes,
              mimeType: _mimeTypeOf(bytes),
            ),
            mode: InsertMode.insertOrIgnore,
          );
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(StorageWriteException(error), stackTrace);
    }
    return assetId;
  }

  @override
  Future<Uint8List?> loadImage(String assetId) async {
    final row = await (_database.select(
      _database.assetRows,
    )..where((asset) => asset.assetId.equals(assetId))).getSingleOrNull();
    return row?.bytes;
  }

  String _mimeTypeOf(Uint8List bytes) {
    final isPng =
        bytes.length >= _pngSignature.length &&
        _pngSignature.indexed.every((entry) => bytes[entry.$1] == entry.$2);
    return isPng ? _pngMimeType : _jpegMimeType;
  }
}
