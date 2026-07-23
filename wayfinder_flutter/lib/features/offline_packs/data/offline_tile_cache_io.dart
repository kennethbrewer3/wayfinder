import 'package:idb_shim/idb_io.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

IdbFactory? _factory;

Future<IdbFactory> openOfflineTileIdbFactory() async {
  final existing = _factory;
  if (existing != null) {
    return existing;
  }
  final dir = await getApplicationSupportDirectory();
  final path = p.join(dir.path, 'offline_tiles_idb');
  final factory = getIdbFactorySembastIo(path);
  _factory = factory;
  return factory;
}
