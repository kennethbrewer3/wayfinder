# Build stage — context is the repo root.
FROM dart:3.8.0 AS build
WORKDIR /app

COPY pubspec.docker.routing.yaml pubspec.yaml
COPY wayfinder_routing_server/pubspec.yaml wayfinder_routing_server/pubspec.yaml
COPY wayfinder_routing_server/bin wayfinder_routing_server/bin
COPY wayfinder_routing_server/lib wayfinder_routing_server/lib
COPY wayfinder_routing_server/analysis_options.yaml wayfinder_routing_server/analysis_options.yaml

WORKDIR /app/wayfinder_routing_server
RUN dart pub get
RUN dart compile exe bin/main.dart -o bin/server

# Temurin already owns /lib as a symlink — do not COPY Dart /runtime onto /.
FROM eclipse-temurin:21-jre-jammy

RUN apt-get update \
  && apt-get install -y --no-install-recommends ca-certificates curl osmium-tool \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /app

ARG GRAPHHOPPER_VERSION=9.1
RUN curl -fsSL \
  -o /app/graphhopper-web.jar \
  "https://repo1.maven.org/maven2/com/graphhopper/graphhopper-web/${GRAPHHOPPER_VERSION}/graphhopper-web-${GRAPHHOPPER_VERSION}.jar"

COPY --from=build /runtime/ /dart-runtime/
COPY --from=build /app/wayfinder_routing_server/bin/server /app/server
COPY wayfinder_routing_server/config/config.yml /app/config/config.yml
COPY wayfinder_routing_server/scripts/entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh

ARG WAYFINDER_BUILD_SHA=unknown
ARG WAYFINDER_BUILD_TIME=unknown
ENV WAYFINDER_BUILD_SHA=$WAYFINDER_BUILD_SHA
ENV WAYFINDER_BUILD_TIME=$WAYFINDER_BUILD_TIME

ENV LD_LIBRARY_PATH=/dart-runtime/lib
ENV PORT=18382
ENV DATA_DIR=/data
ENV GRAPHHOPPER_URL=http://127.0.0.1:8989
ENV GRAPHHOPPER_JAR=/app/graphhopper-web.jar
ENV GRAPHHOPPER_CONFIG=/app/config/config.yml
ENV JAVA_BIN=java
ENV JAVA_XMX=2g
ENV LOG_LEVEL=INFO

EXPOSE 18382
VOLUME /data

ENTRYPOINT ["/app/entrypoint.sh"]
