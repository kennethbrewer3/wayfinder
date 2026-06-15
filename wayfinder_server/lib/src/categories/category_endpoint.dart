import 'package:serverpod/serverpod.dart';

import '../core/endpoint_logging.dart';
import '../generated/protocol.dart';

class CategoryEndpoint extends Endpoint with EndpointLogging {
  static const _tag = 'category';

  Future<List<Category>> listCategories(Session session) {
    return loggedCall(
      session,
      _tag,
      'listCategories',
      () => Category.db.find(
        session,
        orderBy: (t) => t.sortOrder,
      ),
      onSuccess: (categories) => 'count=${categories.length}',
    );
  }

  Future<Category?> getCategory(Session session, UuidValue id) {
    return loggedCall(
      session,
      _tag,
      'getCategory',
      () => Category.db.findById(session, id),
      onSuccess: (category) =>
          category == null ? 'not found id=$id' : 'found id=$id',
    );
  }

  Future<Category> createCategory(Session session, Category category) {
    return loggedCall(
      session,
      _tag,
      'createCategory',
      () => Category.db.insertRow(session, category),
      onSuccess: (created) => 'id=${created.id} name="${created.name}"',
    );
  }

  Future<Category> updateCategory(Session session, Category category) {
    return loggedCall(
      session,
      _tag,
      'updateCategory',
      () => Category.db.updateRow(session, category),
      onSuccess: (updated) => 'id=${updated.id} sortOrder=${updated.sortOrder}',
    );
  }

  Future<bool> deleteCategory(Session session, UuidValue id) {
    return loggedCall(
      session,
      _tag,
      'deleteCategory',
      () async {
        final deleted = await Category.db.deleteWhere(
          session,
          where: (t) => t.id.equals(id),
        );
        return deleted.isNotEmpty;
      },
      onSuccess: (deleted) => deleted ? 'deleted id=$id' : 'not found id=$id',
    );
  }
}
