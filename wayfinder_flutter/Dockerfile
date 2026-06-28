# Build stage — context is the repo root (see docker-compose.yaml).
FROM ghcr.io/cirruslabs/flutter:stable AS build
WORKDIR /app

RUN apt-get update \
  && apt-get install -y --no-install-recommends git ca-certificates \
  && rm -rf /var/lib/apt/lists/*

COPY pubspec.docker.client.yaml pubspec.yaml
COPY wayfinder_client/pubspec.yaml wayfinder_client/pubspec.yaml
COPY wayfinder_client/lib wayfinder_client/lib
COPY wayfinder_client/dartdoc_options.yaml wayfinder_client/dartdoc_options.yaml
COPY wayfinder_client/analysis_options.yaml wayfinder_client/analysis_options.yaml
COPY wayfinder_flutter/pubspec.yaml wayfinder_flutter/pubspec.yaml
COPY wayfinder_flutter/lib wayfinder_flutter/lib
COPY wayfinder_flutter/web wayfinder_flutter/web
COPY wayfinder_flutter/assets wayfinder_flutter/assets
COPY wayfinder_flutter/analysis_options.yaml wayfinder_flutter/analysis_options.yaml

WORKDIR /app/wayfinder_flutter

ARG APP_BUILD_COMMIT=dev
ARG APP_BUILD_TIME=

RUN flutter pub get
RUN flutter build web --release \
  --dart-define=APP_BUILD_COMMIT=${APP_BUILD_COMMIT} \
  --dart-define=APP_BUILD_TIME=${APP_BUILD_TIME}
RUN printf '{"gitCommit":"%s","buildTime":"%s"}\n' \
  "${APP_BUILD_COMMIT}" "${APP_BUILD_TIME}" > build/web/build-info.json

FROM nginx:1.27-alpine

COPY wayfinder_flutter/nginx.conf /etc/nginx/conf.d/default.conf
COPY wayfinder_flutter/docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

COPY --from=build /app/wayfinder_flutter/build/web /usr/share/nginx/html

EXPOSE 8080

ENTRYPOINT ["/docker-entrypoint.sh"]
