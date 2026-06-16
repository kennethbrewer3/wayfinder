import 'package:serverpod/serverpod.dart';

/// CORS for the public REST API under `/api`.
class RestCorsMiddleware extends MiddlewareObject {
  const RestCorsMiddleware();

  @override
  Handler call(Handler next) {
    return (Request req) async {
      if (req.method == Method.options) {
        return Response.ok(headers: Headers.build(_applyCors));
      }

      final result = await next(req);
      if (result is Response) {
        return result.copyWith(
          headers: result.headers.transform(_applyCors),
        );
      }

      return result;
    };
  }

  void _applyCors(MutableHeaders mh) {
    mh.accessControlAllowOrigin =
        const AccessControlAllowOriginHeader.wildcard();
    mh.accessControlAllowMethods = AccessControlAllowMethodsHeader.methods([
      Method.get,
      Method.head,
      Method.post,
      Method.put,
      Method.patch,
      Method.delete,
      Method.options,
    ]);
    mh.accessControlAllowHeaders = AccessControlAllowHeadersHeader.headers([
      'Content-Type',
      'Authorization',
      'X-API-Key',
    ]);
  }
}
