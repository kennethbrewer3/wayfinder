import 'package:serverpod/serverpod.dart';

/// Adds permissive CORS headers for browser tile requests (including Range).
class CorsMiddleware extends MiddlewareObject {
  const CorsMiddleware();

  @override
  Handler call(Handler next) {
    return (Request req) async {
      if (req.method == Method.options) {
        return Response.ok(
          headers: Headers.build(_applyCors),
        );
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
    mh.accessControlAllowMethods = AccessControlAllowMethodsHeader.methods(
      [Method.get, Method.head, Method.post, Method.options],
    );
    mh.accessControlAllowHeaders = AccessControlAllowHeadersHeader.headers([
      'Content-Type',
      'Range',
      'X-Pmtiles-Name',
    ]);
    mh.accessControlExposeHeaders = AccessControlExposeHeadersHeader.headers([
      'Accept-Ranges',
      'Content-Range',
      'Content-Length',
      'Content-Type',
    ]);
  }
}
