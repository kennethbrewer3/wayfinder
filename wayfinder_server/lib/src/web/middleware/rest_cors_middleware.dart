import 'dart:convert';

import 'package:serverpod/serverpod.dart';

/// CORS for the public REST API under `/api`.
class RestCorsMiddleware extends MiddlewareObject {
  const RestCorsMiddleware();

  @override
  Handler call(Handler next) {
    return (Request req) async {
      if (_isPreflight(req)) {
        return Response.ok(headers: Headers.build(_applyCors));
      }

      try {
        final result = await next(req);
        if (result is Response) {
          return result.copyWith(
            headers: result.headers.transform(_applyCors),
          );
        }

        return result;
      } catch (error, _) {
        return Response.internalServerError(
          body: Body.fromString(
            jsonEncode({'error': error.toString()}),
            mimeType: MimeType.json,
          ),
          headers: Headers.build(_applyCors),
        );
      }
    };
  }

  static bool _isPreflight(Request req) {
    return req.method == Method.options;
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
