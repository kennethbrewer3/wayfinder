import 'package:serverpod/serverpod.dart';

import '../../generated/protocol.dart';
import '../../pmtiles/pmtiles_catalog_sync.dart';
import '../../pmtiles/pmtiles_file_groups.dart';
import '../../pmtiles/pmtiles_storage.dart';
import '../../pmtiles/pmtiles_upload_handler.dart';
import 'rest_json.dart';

abstract final class PmtilesRestHandlers {
  static final _idParam = PathParam<String>(#id, (value) => value);

  static PmtilesStorage get _storage => PmtilesStorage();

  static Future<Result> list(Request request) async {
    return RestJson.handleErrors(() async {
      final session = await request.session;
      await PmtilesCatalogSync.sync(session);
      final files = await PmtilesFileGroups.withGroupIds(
        session,
        await PmtilesFile.db.find(
          session,
          orderBy: (t) => t.addedAt,
          orderDescending: true,
        ),
      );
      return RestJson.ok(RestJson.encodeModels(files));
    });
  }

  static Future<Result> getActive(Request request) async {
    return RestJson.handleErrors(() async {
      final session = await request.session;
      final active = await PmtilesFile.db.findFirstRow(
        session,
        where: (t) => t.isActive.equals(true),
      );
      return RestJson.ok({'id': active?.id.uuid});
    });
  }

  static Future<Result> setActive(Request request) async {
    return RestJson.handleErrors(() async {
      final session = await request.session;
      final body = await RestJson.readObject(request);
      final id = RestJson.parseOptionalUuid(body['id'], label: 'id');
      if (id == null) {
        throw const FormatException('Field "id" is required');
      }

      final file = await PmtilesFile.db.findById(session, id);
      if (file == null) {
        return RestJson.error(404, 'PMTiles file not found');
      }
      if (!_storage.existsForEntry(id: id.uuid, name: file.name)) {
        return RestJson.error(400, 'PMTiles file bytes missing on disk');
      }

      await PmtilesFile.db.updateRow(
        session,
        file.copyWith(isActive: true),
      );

      return RestJson.ok({'id': id.uuid});
    });
  }

  static Future<Result> clearActive(Request request) async {
    return RestJson.handleErrors(() async {
      final session = await request.session;
      await PmtilesFile.db.updateWhere(
        session,
        where: (t) => t.isActive.equals(true),
        columnValues: (t) => [t.isActive(false)],
      );
      return RestJson.noContent();
    });
  }

  static Future<Result> delete(Request request) async {
    return RestJson.handleErrors(() async {
      final session = await request.session;
      final id = RestJson.parseUuid(
        request.pathParameters.get(_idParam),
        label: 'pmtiles id',
      );

      final file = await PmtilesFile.db.findById(session, id);
      if (file == null) {
        return RestJson.error(404, 'PMTiles file not found');
      }

      await PmtilesFileGroups.removeAllForFile(session, id);
      await _storage.deleteForEntry(id: id.uuid, name: file.name);
      await PmtilesFile.db.deleteRow(session, file);

      return RestJson.noContent();
    });
  }

  static Future<Result> upload(Request request) async {
    final session = await request.session;
    return handlePmtilesUpload(session, request);
  }
}
