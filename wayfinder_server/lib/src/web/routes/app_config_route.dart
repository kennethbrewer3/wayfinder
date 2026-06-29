import 'package:serverpod/serverpod.dart';

class AppConfigWidget extends JsonWidget {
  AppConfigWidget({
    required this.apiUrl,
    required this.webUrl,
  }) : super(
         object: {
           'apiUrl': apiUrl,
           'webUrl': webUrl,
         },
       );

  final String apiUrl;
  final String webUrl;
}

class AppConfigRoute extends WidgetRoute {
  AppConfigRoute({
    required ServerConfig apiConfig,
    required ServerConfig webConfig,
  }) : widget = AppConfigWidget(
         apiUrl: apiConfig.publicUrl.toString(),
         webUrl: webConfig.publicUrl.toString(),
       );

  final AppConfigWidget widget;

  @override
  Future<WebWidget> build(Session session, Request request) async {
    return widget;
  }
}

extension on ServerConfig {
  Uri get publicUrl => Uri(
    scheme: publicScheme,
    host: publicHost,
    port: publicPort,
  );
}
